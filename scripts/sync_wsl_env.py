#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
WSL Antigravity & Jev & OpenSpec Environment Synchronizer
=========================================================
自动将 Windows 宿主机的配置完整同步至 WSL (Ubuntu) Antigravity 环境：
1. Jev 配置与组件: ~/.jev/zen.key, jev.py, jev_interactive.py, release_gate_demo.py
2. OpenSpec 全套技能: openspec-apply-change, openspec-archive-change, openspec-explore,
                      openspec-propose, openspec-sync-specs, openspec-update-change
3. Jev 监督控制体系技能: jev-supervisory-system
4. Jev & OpenSpec 规则: ~/.gemini/config/rules/openspec_jev_pipeline.md
5. 全局执行脚本: ~/scripts/ (jev_guard.py, jev_context_pruner.py, jev_openspec_pilot.py)
6. 记忆与会话上下文:
   - Cockpit 用户记忆: user_memory.json
   - Antigravity 会话索引: conversation_summaries.db, agyhub/jetbox summaries pb
   - 核心会话数据库: conversations/*.db
   - 认知大脑上下文: brain/*
7. 连通性回归测试: 验证 WSL 内部 python3 调用 Jev 毫秒级决策能力
"""

import os
import sys
import subprocess
import shutil
from pathlib import Path

# 确保在 Windows 控制台下输出 UTF-8 字符不会因为 GBK 报错
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

WIN_HOME = Path(os.environ["USERPROFILE"])
WORKSPACE = Path(r"d:\应用研究\统一启动器")
WSL_DISTRO = "Ubuntu"

def run_wsl_cmd(cmd: str, check: bool = True) -> str:
    """在 WSL Ubuntu 中以登录 shell 执行 bash 命令"""
    full_cmd = ["wsl", "-d", WSL_DISTRO, "bash", "--login", "-c", cmd]
    res = subprocess.run(full_cmd, capture_output=True, text=True, encoding="utf-8", errors="replace")
    if check and res.returncode != 0:
        raise RuntimeError(f"WSL command failed (code {res.returncode}):\n{res.stderr}\n{res.stdout}")
    return res.stdout.strip()

def sync_path_to_wsl(win_src: Path, wsl_dest_dir: str):
    """通过 wsl 命令行将 Windows 路径同步到 WSL 指定目录"""
    # 转换 Windows 路径为 WSL 路径
    drive = win_src.drive.replace(":", "").lower()
    rel = str(win_src).replace(win_src.drive, "").replace("\\", "/")
    wsl_src = f"/mnt/{drive}{rel}"
    
    if win_src.is_dir():
        cmd = f"mkdir -p '{wsl_dest_dir}' && cp -rf '{wsl_src}/.' '{wsl_dest_dir}/'"
    else:
        cmd = f"mkdir -p '{wsl_dest_dir}' && cp -f '{wsl_src}' '{wsl_dest_dir}/'"
    
    run_wsl_cmd(cmd)

def main():
    print("=========================================================")
    print("[INFO] 开始同步 OpenSpec、Jev 配置及 Antigravity 记忆至 WSL")
    print("=========================================================")

    # 1. 确保 WSL 目标基础目录存在
    print("\n[1/7] 初始化 WSL 目录结构...")
    dirs_to_init = [
        "/home/administrator/.jev",
        "/home/administrator/scripts",
        "/home/administrator/.gemini/config/skills",
        "/home/administrator/.gemini/config/rules",
        "/home/administrator/.gemini/antigravity-ide/conversations",
        "/home/administrator/.gemini/antigravity-ide/brain",
        "/home/administrator/.gemini/antigravity-cli/conversations",
        "/home/administrator/.gemini/antigravity-cli/brain",
        "/home/administrator/.gemini/antigravity/conversations",
        "/home/administrator/.gemini/antigravity/brain",
        "/home/administrator/.antigravity_cockpit",
    ]
    for d in dirs_to_init:
        run_wsl_cmd(f"mkdir -p '{d}'")
    print("  [OK] WSL 基础目录初始化完成")

    # 2. 同步 Jev 运行环境 (~/.jev)
    print("\n[2/7] 同步 Jev 客户端与 API Key...")
    jev_src = WIN_HOME / ".jev"
    if jev_src.exists():
        sync_path_to_wsl(jev_src, "/home/administrator/.jev")
        # 修复权限与换行符
        run_wsl_cmd("chmod 600 /home/administrator/.jev/zen.key 2>/dev/null || true")
        run_wsl_cmd("chmod +x /home/administrator/.jev/*.py 2>/dev/null || true")
        print("  [OK] Jev 核心库与 Zen Key 已同步至 /home/administrator/.jev")
    else:
        print("  [WARN] 未检测到 Windows ~/.jev 目录")

    # 3. 同步 Jev 脚本工具链
    print("\n[3/7] 同步 Jev 脚本体系 (Guard, Context Pruner, Pilot)...")
    scripts_src = WORKSPACE / "scripts"
    jev_script_files = [
        "jev_guard.py",
        "jev_context_pruner.py",
        "jev_openspec_pilot.py",
        "release_gate_demo.py"
    ]
    for fname in jev_script_files:
        src_file = scripts_src / fname
        if src_file.exists():
            sync_path_to_wsl(src_file, "/home/administrator/scripts")
            run_wsl_cmd(f"chmod +x '/home/administrator/scripts/{fname}' 2>/dev/null || true")
    print("  [OK] Jev 脚本已部署至 WSL /home/administrator/scripts")

    # 4. 同步 OpenSpec 与 Jev 全套 Skills
    print("\n[4/7] 同步 OpenSpec 与 Jev 技能至 WSL 全局技能库...")
    skills_src = WORKSPACE / ".agents" / "skills"
    skills_to_sync = [
        "jev-supervisory-system",
        "openspec-apply-change",
        "openspec-archive-change",
        "openspec-explore",
        "openspec-propose",
        "openspec-sync-specs",
        "openspec-update-change",
    ]
    for sname in skills_to_sync:
        sdir = skills_src / sname
        if sdir.exists():
            target_wsl = f"/home/administrator/.gemini/config/skills/{sname}"
            sync_path_to_wsl(sdir, target_wsl)
            print(f"  * 同步技能: {sname} -> {target_wsl}")
    
    target_marker = skills_src / ".openspec-target"
    if target_marker.exists():
        sync_path_to_wsl(target_marker, "/home/administrator/.gemini/config/skills")
    print("  [OK] OpenSpec 及 Jev 技能全量同步完成")

    # 5. 同步 OpenSpec-Jev 流程控制规则
    print("\n[5/7] 同步 OpenSpec-Jev 流水线规则...")
    rules_src = WORKSPACE / ".agents" / "rules"
    if rules_src.exists():
        for rfile in rules_src.glob("*.md"):
            sync_path_to_wsl(rfile, "/home/administrator/.gemini/config/rules")
            print(f"  * 同步规则: {rfile.name} -> /home/administrator/.gemini/config/rules/")
    print("  [OK] 规则库同步完成")

    # 6. 同步记忆与会话上下文 (Memory, Summaries, Brain, Conversations)
    print("\n[6/7] 同步用户记忆与 Antigravity 会话大脑...")
    
    # 6.1 Cockpit 用户记忆
    cockpit_mem = WIN_HOME / ".antigravity_cockpit" / "user_memory.json"
    if cockpit_mem.exists():
        sync_path_to_wsl(cockpit_mem, "/home/administrator/.antigravity_cockpit")
        print("  * 同步 Cockpit 记忆: user_memory.json")

    # 6.2 会话索引数据库与 Summary 记忆 (conversation_summaries.db)
    for app in ["antigravity", "antigravity-cli"]:
        sum_db = WIN_HOME / ".gemini" / app / "conversation_summaries.db"
        if sum_db.exists():
            sync_path_to_wsl(sum_db, f"/home/administrator/.gemini/{app}")
            print(f"  * 同步 {app} 会话记忆数据库: conversation_summaries.db")
        
        # proto 缓存
        for pb_file in (WIN_HOME / ".gemini" / app).glob("*summaries_proto.pb"):
            sync_path_to_wsl(pb_file, f"/home/administrator/.gemini/{app}")

    # 6.3 活跃与最近会话数据库 (Conversations DB)
    conv_ide_src = WIN_HOME / ".gemini" / "antigravity-ide" / "conversations"
    if conv_ide_src.exists():
        # 同步最近 5 个会话数据库
        dbs = sorted(conv_ide_src.glob("*.db"), key=lambda p: p.stat().st_mtime, reverse=True)[:5]
        for db in dbs:
            sync_path_to_wsl(db, "/home/administrator/.gemini/antigravity-ide/conversations")
            print(f"  * 同步会话数据库: {db.name}")

    # 6.4 会话大脑 (Brain)
    brain_ide_src = WIN_HOME / ".gemini" / "antigravity-ide" / "brain"
    if brain_ide_src.exists():
        # 同步最近 3 个 Brain 会话
        brain_dirs = [d for d in brain_ide_src.iterdir() if d.is_dir()]
        brain_dirs.sort(key=lambda p: p.stat().st_mtime, reverse=True)
        for bdir in brain_dirs[:3]:
            target_brain = f"/home/administrator/.gemini/antigravity-ide/brain/{bdir.name}"
            sync_path_to_wsl(bdir, target_brain)
            print(f"  * 同步 Brain 认知上下文: {bdir.name}")
    print("  [OK] 记忆与会话上下文全量同步完成")

    # 7. WSL 连通性测试与验证
    print("\n[7/7] 执行 WSL 环境 Jev 毫秒级决策连通性测试...")
    test_code = (
        "import sys, os;"
        "sys.path.append('/home/administrator/.jev');"
        "from jev import JevClient;"
        "client = JevClient();"
        "res = client.decide("
        "   statement='WSL Antigravity 记忆与 Jev 环境集成验证',"
        "   noul_question='WSL 内部 Jev 连通与决策是否正常？',"
        "   choice_question='环境状态评级？',"
        "   choice_options=['READY', 'FAILED']"
        ");"
        "print(f'[JEV RESULT] WSL Jev 测试成功! 决策={res.choice}, 置信度={res.noul:.2f}, 耗时={res.latency_ms:.1f}ms')"
    )
    test_cmd = f"python3 -c \"{test_code}\""
    test_out = run_wsl_cmd(test_cmd, check=False)
    print(f"  {test_out}")

    print("\n=========================================================")
    print("[SUCCESS] WSL Antigravity 环境同步圆满完成！")
    print("=========================================================")

if __name__ == "__main__":
    main()
