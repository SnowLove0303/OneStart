# OpenSpec & Jev 协同执行规范 (Spec-Driven, Jev-Supervised Pipeline)

在当前工作区执行任何 OpenSpec 规范变更或复杂重构任务时，必须结合 Jev (System 1) 落实以下路径策略：

## 1. 单任务单步聚焦 (Single Task Focus)
- 在执行 OpenSpec 任务时，严格按照 `tasks.md` 从上至下单步推进，严禁跨步骤抢跑。
- 可运行 `python scripts/jev_openspec_pilot.py` 自动获取当前唯一合法的攻坚任务。

## 2. 变更范围防越界 (Scope Guard)
- 所有代码编写与修改必须严格限定在当前 OpenSpec `proposal.md` 与目标任务定义的范围内。
- 严禁借重构之名顺带修改未在 OpenSpec 中立项的无关模块。

## 3. 证据核验与防虚假打钩 (Evidence-Gated Checkoff)
- **严禁“未测先勾”**：在将 `tasks.md` 中的 `- [ ]` 更新为 `- [x]` 之前，必须在终端执行真实的测试或验证命令（如语法检查、单元测试、AST校验）。
- 只有在验证命令执行成功且产生充分的通过证据后，方可标记任务完成。

## 4. 上下文保鲜与剪枝 (Context Pruning)
- 在多任务连续执行过程中，若产生冗长常规构建日志或通过信息，应遵循 `scripts/jev_context_pruner.py` 剪枝策略，剔除无用冗余，防止上下文膨胀导致后续步骤偏航。
