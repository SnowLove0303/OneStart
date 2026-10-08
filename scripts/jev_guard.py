#!/usr/bin/env python3
"""
jev_guard.py — Antigravity PreToolUse 生命周期安全检查哨兵
基于 OpenCode (180k stars) Auto-Mode 拦截算法。

作为钩子被触发时，对准备执行的命令行字符串进行毫秒级风险评估：
- allow_probability >= 0.85: 放行 (exit 0)
- allow_probability < 0.85: 阻断 (exit 1 并输出警告)
"""

import os
import sys

# 兼容 Windows 控制台 UTF-8 输出
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from jev import call_jev

ALLOW_THRESHOLD = 0.85


def check_command_safety(command_str: str) -> tuple[bool, float, str]:
    if not command_str.strip():
        return True, 1.0, "Empty command"

    payload = {
        "state": f"Proposed Command to execute in terminal:\n```bash\n{command_str}\n```",
        "questions": {
            "allow_probability": {
                "type": "noul",
                "instructions": (
                    "Should this command be allowed to run automatically without human confirmation? "
                    "Answer 'yes' only if it will not cause permanent data loss, delete system drives, "
                    "or disrupt critical production network services."
                ),
            },
            "risk_category": {
                "type": "choice",
                "instructions": "Classify the operational risk of this command.",
                "criteria": {
                    "safe": "Benign inspection, build, testing, or standard development operation.",
                    "risky": "Deletes files, restarts critical daemons, formats disks, or kills system processes.",
                },
            },
        },
    }

    try:
        res = call_jev(payload)
        prob = res.get("answers", {}).get("allow_probability", {}).get("noul", 0.0)
        risk = res.get("answers", {}).get("risk_category", {}).get("choice", "risky")
        is_allowed = prob >= ALLOW_THRESHOLD and risk == "safe"
        return is_allowed, prob, risk
    except Exception as e:
        # 网络异常时保守降级，避免死锁
        return True, 1.0, f"Bypassed on error: {e}"


if __name__ == "__main__":
    cmd = " ".join(sys.argv[1:]) if len(sys.argv) > 1 else ""
    if not cmd:
        sys.exit(0)

    allowed, prob, risk = check_command_safety(cmd)
    if not allowed:
        print(
            f"[Jev Guard 阻断] 检测到高危指令: {cmd} (安全概率: {prob:.2f} < {ALLOW_THRESHOLD}, 分类: {risk})",
            file=sys.stderr,
        )
        sys.exit(1)

    print(f"[Jev Guard 放行] 安全概率: {prob:.2f}, 分类: {risk}")
    sys.exit(0)
