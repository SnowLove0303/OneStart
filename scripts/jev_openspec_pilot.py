#!/usr/bin/env python3
"""
jev_openspec_pilot.py — OpenSpec 与 Jev (System 1) 协同导航与执行纠偏器

核心策略:
  1. 路径导航 (Task Router): 实时解析 OpenSpec 的 tasks.md，由 Jev 选出当前唯一合法步进任务，防止乱序跳步；
  2. 边界防偏 (Scope Sentinel): 检查 Agent 即将执行的动作是否在 proposal.md 的规定边界内，拦截越权改动；
  3. 证据验收防假打勾 (Evidence Belay): 只有当 Jev 确认终端测试/命令输出具备充分证据时，才允许将任务状态标记为已完成。
"""

import os
import re
import sys

# 兼容 Windows 控制台 UTF-8 输出
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from jev import call_jev, decide_choice, decide_noul


def get_active_change_dir(repo_root: str, change_name: str = None) -> str:
    """定位 OpenSpec 变更目录"""
    changes_dir = os.path.join(repo_root, "openspec", "changes")
    if not os.path.exists(changes_dir):
        raise FileNotFoundError(f"OpenSpec changes 目录不存在: {changes_dir}")

    if change_name:
        target = os.path.join(changes_dir, change_name)
        if os.path.isdir(target):
            return target
        raise FileNotFoundError(f"未找到指定的 OpenSpec change: {change_name}")

    # 自动获取第一个活跃变更
    for item in os.listdir(changes_dir):
        if item == "archive":
            continue
        p = os.path.join(changes_dir, item)
        if os.path.isdir(p) and os.path.exists(os.path.join(p, "tasks.md")):
            return p

    raise FileNotFoundError("未找到包含 tasks.md 的活跃 OpenSpec change")


def parse_tasks(tasks_file: str) -> list[dict]:
    """解析 tasks.md 中所有任务项"""
    content = open(tasks_file, encoding="utf-8").read()
    pattern = re.compile(r"^\s*-\s*\[([ xX])\]\s*(.+)$", re.MULTILINE)
    tasks = []
    for idx, match in enumerate(pattern.finditer(content)):
        done = match.group(1).lower() == "x"
        task_text = match.group(2).strip()
        tasks.append({"index": idx + 1, "done": done, "text": task_text, "raw": match.group(0)})
    return tasks


def get_next_task_guidance(change_dir: str) -> dict:
    """
    【策略一：路径导航】
    由 Jev 分析当前未完成的任务项，输出唯一当前推进路标与前置依赖分析
    """
    tasks_file = os.path.join(change_dir, "tasks.md")
    tasks = parse_tasks(tasks_file)
    pending_tasks = [t for t in tasks if not t["done"]]

    if not pending_tasks:
        return {"all_done": True, "message": "所有 OpenSpec 任务均已完成，可以执行归档 (archive)！"}

    first_pending = pending_tasks[0]
    total = len(tasks)
    done_count = total - len(pending_tasks)

    return {
        "all_done": False,
        "progress": f"{done_count}/{total} ({done_count/total*100:.1f}%)",
        "current_target_index": first_pending["index"],
        "current_task": first_pending["text"],
        "remaining_count": len(pending_tasks),
    }


def verify_action_scope(change_dir: str, action_description: str) -> tuple[bool, float]:
    """
    【策略二：边界防偏航】
    用 Jev 校验当前动作是否符合 proposal.md 的目标范围，防止出现无关改动
    """
    proposal_file = os.path.join(change_dir, "proposal.md")
    proposal_text = open(proposal_file, encoding="utf-8").read() if os.path.exists(proposal_file) else ""

    state = (
        f"--- OpenSpec Proposal ---\n{proposal_text[:1200]}\n"
        f"--- Proposed Agent Action ---\n{action_description}\n"
    )
    instructions = (
        "Is this action strictly within the scope and goals outlined in the OpenSpec proposal, "
        "without introducing out-of-scope refactoring or modifying unrelated systems?"
    )
    prob = decide_noul(state, instructions)
    return prob >= 0.75, prob


def verify_task_completion_evidence(task_text: str, execution_log: str) -> tuple[bool, float, str]:
    """
    【策略三：防假完成与防盲目打钩】
    在 Agent 试图标记任务完成前，由 Jev 审查实际运行命令的日志证据
    """
    state = (
        f"--- OpenSpec Task Specification ---\n{task_text}\n"
        f"--- Execution Output & Test Logs ---\n{execution_log[-1200:]}\n"
    )

    payload = {
        "state": state,
        "questions": {
            "is_evidence_sufficient": {
                "type": "noul",
                "instructions": (
                    "Does the execution output provide clear and undeniable evidence that the task requirements "
                    "were successfully performed and verified, without unresolved errors or failures?"
                ),
            },
            "verdict": {
                "type": "choice",
                "instructions": "Determine if this task is verified as complete or needs further work.",
                "criteria": {
                    "passed": "Fully verified with valid passing output or successful file generation.",
                    "failed_test": "Errors, syntax failures, or test crashes are present in the output.",
                    "insufficient_evidence": "No clear command execution or test log provided.",
                },
            },
        },
    }

    res = call_jev(payload)
    answers = res.get("answers", {})
    prob = answers.get("is_evidence_sufficient", {}).get("noul", 0.0)
    verdict = answers.get("verdict", {}).get("choice", "insufficient_evidence")

    is_verified = prob >= 0.8 and verdict == "passed"
    return is_verified, prob, verdict


if __name__ == "__main__":
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    print("=== OpenSpec & Jev 协同导航与纠偏器测试 ===")

    try:
        change_dir = get_active_change_dir(repo_root)
        print(f"当前选定 OpenSpec Change: {os.path.basename(change_dir)}")

        # 1. 路径导航
        guidance = get_next_task_guidance(change_dir)
        print("\n[1. 路径指引状态]")
        print(f"进度: {guidance.get('progress')}")
        print(f"当前必须攻坚的任务: {guidance.get('current_task')}")

        # 2. 边界防偏
        sample_action = "修改 System\\Workflow-Launcher.ps1 加载唯一 .psd1 配置"
        in_scope, prob = verify_action_scope(change_dir, sample_action)
        print("\n[2. 动作范围校验]")
        print(f"拟执行动作: {sample_action}")
        print(f"合规放行: {in_scope} (Jev 置信概率: {prob:.2f})")

        # 3. 证据核验
        fake_log = "Error: File guanzhitong.config.psd1 not found. Process terminated with exit code 1."
        verified, p, verdict = verify_task_completion_evidence(guidance.get("current_task"), fake_log)
        print("\n[3. 假完成拦截检验]")
        print(f"模拟报错日志拦截结果: Verified={verified}, Verdict={verdict}, Prob={p:.2f}")

    except Exception as e:
        print(f"执行异常: {e}")
