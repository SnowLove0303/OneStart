---
name: jev-supervisory-system
description: >-
  TypeSafe Jev (System 1) 全局监督与控制体系：为 Antigravity (Gemini 3.8 Flash) 提供毫秒级路径导航、
  变更范围防偏航、终端高危命令安全门禁、测试证据验收与上下文智能剪枝。当需要快速二值决策、路由多技能、
  校验完工证据或修剪冗长工具日志时激活。
license: MIT
compatibility: Windows / Linux / macOS, Python 3.10+
metadata:
  author: OneStart / TypeSafe
  version: "1.0.0"
---

# Jev 全局监督与控制体系 (Jev Supervisory System)

Jev 是专为软件决策设计的 System 1 结构化决策模型。本技能指导 Antigravity (Gemini 3.8 Flash) 
在复杂开发与重构生命周期中，以零 Token 浪费、毫秒级响应的方式持续保持**路径正确性**与**执行高质量**。

---

## 1. 核心操作规范 (Five Core Protocols)

### 规程 A：任务路径路标 (Task Navigation)
- **触发时机**：承接复杂多任务需求或 OpenSpec 规范变更时。
- **执行方式**：
  运行 `python scripts/jev_openspec_pilot.py`，获取当前唯一应当攻坚的目标任务。
- **约束**：
  严禁跨越未完成的任务抢跑，始终保持单任务闭环。

### 规程 B：变更范围防偏航 (Scope Sentinel)
- **触发时机**：准备修改核心配置文件、系统代码或执行深层重构前。
- **校验逻辑**：
  ```python
  from scripts.jev import decide_noul

  in_scope = (
      decide_noul(
          state=f"Proposal: {proposal}\nAction: {proposed_action}",
          instructions=(
              "Is this action strictly within the scope of the current task?"
          ),
      )
      >= 0.75
  )
```
- **处置**：若偏离范围，立即终止操作并向用户说明。

### 规程 C：终端操作安全门禁 (Safety Gate)
- **触发时机**：准备执行包含 `rm`, `del`, `format`, `drop`, `kill`, 递归覆盖等破坏性命令时。
- **校验逻辑**：
  调用 `python scripts/jev.py` 评估放行概率 `allow_probability`。
  阈值 `< 0.85` 时必须停止自主执行并等待用户明确确认。

### 规程 D：测试证据防假打钩 (Evidence Belay)
- **触发时机**：在完成代码编写，准备在任务清单中将 `- [ ]` 标记为 `- [x]` 或告知用户“已完成”时。
- **铁律**：
  1. 必须在终端运行真实测试（如 `pytest`, `npm test`, AST 检查或健康探针）；
  2. 测试日志必须经由 Jev 验证存在真实通过证据：
     ```python
     from scripts.jev_openspec_pilot import verify_task_completion_evidence

     verified, prob, verdict = verify_task_completion_evidence(
         task_spec, test_log
     )
```
  3. `verified == True` 时方可交卷；若为 `False` 必须继续修复。

### 规程 E：上下文智能剪枝 (Context Pruning)
- **触发时机**：单次命令产生超过 400 字符的冗长输出（如构建输出、庞大 JSON、长包列表）。
- **执行方式**：
  调用 `scripts/jev_context_pruner.py` 对输出进行修剪后再呈现，防止上下文污染导致大模型推理能力退化。

---

## 2. 全局环境与调用接口

- **全局凭据位置**：`C:\Users\Administrator\.jev\zen.key`
- **全局调用驱动**：`C:\Users\Administrator\.jev\jev.py`
- **项目级适配器**：`d:\应用研究\统一启动器\scripts\jev.py`
- **OpenSpec 导航器**：`d:\应用研究\统一启动器\scripts\jev_openspec_pilot.py`
