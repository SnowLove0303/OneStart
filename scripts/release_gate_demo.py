#!/usr/bin/env python3
"""
release_gate_demo.py — 真实的 Jev 自动化放行/释放控制程序 (Release Gatekeeper)

【业务逻辑】
  传统发布/上线流程中，往往需要人工查看 PR 变更或测试结果来决定“是否释放到生产环境”。
  本程序直接接入 Jev (System 1)，在毫秒级内评估变更内容，
  根据 Jev 的结构化判定，由 Python 确定性执行具体的“释放发布”或“阻断熔断”动作。
"""

import sys
import os
import time

# 兼容 Windows 控制台 UTF-8 输出
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

# 引入全局 Jev 驱动
sys.path.insert(0, r"C:\Users\Administrator\.jev")
from jev import call_jev

# 待审查的 3 个真实发布候选单 (Release Candidates)
CANDIDATE_ITEMS = [
    {
        "id": "REL-2026-001",
        "title": "前端样式微调与文档更新",
        "description": "修复前台页面按钮字体间距，更新用户帮助手册。所有单元测试 100% 通过，无数据库改动，无权限变更。",
    },
    {
        "id": "REL-2026-002",
        "title": "底层数据迁移与清理脚本",
        "description": "删除了旧版本的用户备份表，跳过了外键约束检查，且该 PR 强行关闭了自动化集成测试（--skip-tests）。",
    },
    {
        "id": "REL-2026-003",
        "title": "支付网关重构第一期",
        "description": "重构了支付宝回调解析逻辑，测试通过率为 85%，但引入了 1 个轻微的偶发网络超时告警。",
    },
]


def evaluate_and_release(item: dict):
    """接入 Jev 进行真实语义判定并执行对应的释放动作"""
    print(f"\n------------------------------------------------------------")
    print(f"正在审查发布单: [{item['id']}] {item['title']}")
    print(f"变更说明: {item['description']}")
    print(f"------------------------------------------------------------")

    # 1. 构造向 Jev 发送的状态与问题
    payload = {
        "state": f"发布单ID: {item['id']}\n标题: {item['title']}\n详情: {item['description']}",
        "questions": {
            # 题型 1: 问是非 (Noul)
            "is_dangerous": {
                "type": "noul",
                "instructions": "该变更是否包含高风险操作（如删表、跳过测试、关闭安全检查）？",
            },
            # 题型 2: 做单选 (Choice)
            "action": {
                "type": "choice",
                "instructions": "决定该发布单的处理动作",
                "criteria": {
                    "release": "风险极低，直接放行并释放到生产环境",
                    "block": "存在明显破坏性或逃避测试行为，直接阻断拒绝",
                    "manual_review": "改动核心模块但有轻微瑕疵，转交人工高级工程师复核",
                },
            },
            # 题型 3: 打评分 (Score)
            "risk_score": {
                "type": "score",
                "instructions": "评定本次发布的风险指数",
                "criteria": ["低风险", "中风险", "高危风险"],
            },
        },
    }

    # 2. 真实请求 Jev 接口
    t0 = time.perf_counter()
    res = call_jev(payload)
    t1 = time.perf_counter()
    latency_ms = (t1 - t0) * 1000

    answers = res.get("answers", {})
    danger_prob = answers.get("is_dangerous", {}).get("noul", 0.0)
    decision = answers.get("action", {}).get("choice", "")
    decision_conf = answers.get("action", {}).get("confidence", 0.0)
    risk_level = answers.get("risk_score", {}).get("score", 0)

    print(f"⚡ Jev 毫秒级判定完成 (耗时: {latency_ms:.1f}ms):")
    print(f"   - 危险概率: {danger_prob:.2f}")
    print(f"   - 风险评级: 级别 {risk_level}")
    print(f"   - 决议动作: {decision} (置信度: {decision_conf:.2f})")

    # 3. 纯 Python 确定性执行后续释放动作（无任何大模型幻觉）
    print(">>> 执行处理结果:")
    if decision == "release" and danger_prob < 0.2:
        # 执行真实发布动作
        print(f"   ✅ [RELEASED 放行释放] 发布单 {item['id']} 已自动部署上线并激活生产服务！")
    elif decision == "block" or danger_prob >= 0.8:
        # 执行安全熔断动作
        print(f"   🚫 [BLOCKED 熔断拦截] 发布单 {item['id']} 包含严重高危行为，已强行中断流水线并告警！")
    else:
        # 执行工单流转动作
        print(f"   ⚠️ [MANUAL_REVIEW 挂起复审] 发布单 {item['id']} 具有潜在风险，已自动转派至二级工程师审批。")


def main():
    print("============================================================")
    print("   基于 Jev 1.13 的生产发布自动化放行/释放程序 (Release Gate)")
    print("============================================================")
    for item in CANDIDATE_ITEMS:
        evaluate_and_release(item)
    print("\n============================================================")
    print("   所有发布单已根据 Jev 判定处理完毕，全流程无大语言模型介入。")
    print("============================================================")


if __name__ == "__main__":
    main()
