#!/usr/bin/env python3
"""
jev_context_pruner.py — Jev 上下文智能剪枝器
抄自 tamaratran/fast-jev-compaction (GitHub 4k+ stars，2026-09 Jev 赛道顶流项目)

核心功能:
  在 Agent (Gemini 3.8 Flash) 执行了高频工具调用 (如 run_command / 编译日志 / 检查输出) 后，
  利用 Jev (System 1) 毫秒级判定该日志的有效信息密度，把冗余或成功无害的长日志剪枝，
  保留错误栈和关键产物，彻底解决上下文膨胀与长文本计费问题。
"""

import os
import sys

# 兼容 Windows 控制台 UTF-8 输出
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

# 保证能直接导入当前目录模块
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from jev import call_jev


def prune_tool_output(tool_name: str, tool_output: str, max_chars: int = 400) -> str:
    """
    对长工具执行日志进行 Jev 语义评估与修剪
    :param tool_name: 工具名称 (如 run_command, git_diff, build)
    :param tool_output: 工具原始返回的超长文本
    :param max_chars: 触发剪枝的阈值长度
    :return: 经过 Jev 保真修剪后的紧凑文本
    """
    if len(tool_output) <= max_chars:
        return tool_output

    sample_state = (
        f"Tool Name: {tool_name}\n"
        f"Length: {len(tool_output)} chars\n"
        f"--- Output Head (first 300 chars) ---\n{tool_output[:300]}\n"
        f"--- Output Tail (last 300 chars) ---\n{tool_output[-300:]}\n"
    )

    payload = {
        "state": sample_state,
        "questions": {
            "has_error_or_critical": {
                "type": "noul",
                "instructions": "Does this output report a fatal error, failed test, build break, or critical warning?",
            },
            "prune_strategy": {
                "type": "choice",
                "instructions": "Select the best context retention strategy for this tool output.",
                "criteria": {
                    "replace_success": "Entirely normal success output, replace with compact summary line.",
                    "keep_error_lines": "Failure or mixed output, extract only error/warning lines.",
                    "keep_head_tail": "Informative query output, keep brief snippet of head and tail.",
                },
            },
        },
    }

    try:
        res = call_jev(payload)
        answers = res.get("answers", {})
        has_error = answers.get("has_error_or_critical", {}).get("noul", 0.0) >= 0.5
        strategy = answers.get("prune_strategy", {}).get("choice", "keep_head_tail")

        if not has_error and strategy == "replace_success":
            return f"[Jev-Pruned] {tool_name} 执行成功 (已省略 {len(tool_output)} 字符冗余常规日志 [OK])"

        if strategy == "keep_error_lines":
            error_keywords = ("error", "fail", "err", "warn", "exception", "traceback", "fatal", "exit code")
            error_lines = [
                line for line in tool_output.splitlines() if any(kw in line.lower() for kw in error_keywords)
            ]
            if error_lines:
                return (
                    f"[Jev-Pruned: 提取关键异常信息 ({len(error_lines)} 行)]\n"
                    + "\n".join(error_lines[:25])
                    + (f"\n... (其余 {len(error_lines)-25} 行异常被折叠)" if len(error_lines) > 25 else "")
                )

        # 默认或 keep_head_tail
        return f"{tool_output[:250]}\n\n... [Jev 已折叠中间 {len(tool_output)-500} 字符日志] ...\n\n{tool_output[-250:]}"

    except Exception:
        # 网络或接口降级逻辑
        return f"{tool_output[:200]}\n... [剪枝器降级截断] ...\n{tool_output[-200:]}"


if __name__ == "__main__":
    # 测试样例 1: 成功的漫长构建日志
    success_log = "Building target...\n" + ("Compiling file.c\n" * 100) + "Build complete! 0 errors, 0 warnings."
    print("=== 测试 1: 成功构建日志修剪 ===")
    print(prune_tool_output("run_command", success_log))

    # 测试样例 2: 含有致命报错的日志
    fail_log = (
        ("Processing items...\n" * 20)
        + "Error: ConnectionRefusedError(10061, 'Connect call failed')\n"
        + "Traceback (most recent call last):\n  File 'app.py', line 42\n"
        + ("Finished with failure.\n" * 5)
    )
    print("\n=== 测试 2: 失败报错日志修剪 ===")
    print(prune_tool_output("run_command", fail_log))
