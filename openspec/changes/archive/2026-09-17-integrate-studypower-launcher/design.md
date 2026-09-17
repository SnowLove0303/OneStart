## Context

OneStart already has centralized platform configuration, menu dispatch, command dispatch, logging, and platform-specific start/stop/status functions. StudyPower is an independent Next.js project at `F:\APP Location\StudyPower` with an existing `start` script and a verified local production port of `3100`.

The launcher repository has unrelated uncommitted user changes. The implementation must remain in the existing working tree and touch only the confirmed integration hunks and documentation.

## Goals / Non-Goals

**Goals:**

- Reuse the existing OneStart command, logging, menu, and status patterns.
- Start one StudyPower production process from its real project directory.
- Wait for the local endpoint before reporting success and opening the browser.
- Identify and stop only the StudyPower process associated with the configured project and port.

**Non-Goals:**

- Do not modify StudyPower source, dependencies, build output, or repository state.
- Do not add StudyPower to the existing `start all` aggregate.
- Do not create a second launcher, port, configuration file, or project copy.

## Decisions

1. **Use the existing Next.js production command.** The launcher will invoke `npm.cmd run start -- -p 3100` with `F:\APP Location\StudyPower` as the working directory. This uses the project's existing contract; a dev server would add slower, less stable runtime behavior and is not required by the request.

2. **Use a fixed local endpoint and readiness polling.** The launcher will check `http://127.0.0.1:3100` with a short request during the existing bounded startup wait. Port-only detection is insufficient because an unrelated process could occupy the port.

3. **Match process ownership before stopping.** Process discovery will inspect the listener on port `3100` and the matching Node command line/working-directory context. This avoids terminating unrelated Node services and avoids duplicate StudyPower instances.

4. **Open the browser through the existing helper.** The implementation will reuse `Open-PlatformUrl` instead of adding a new browser abstraction.

## Risks / Trade-offs

- [Node/npm resolution] → Use `npm.cmd` and the configured working directory; report a clear error if the executable cannot be started.
- [Port collision] → Require both the configured port and StudyPower project context for ownership; fail rather than taking over an unrelated listener.
- [Dirty launcher file] → Apply localized patches and review the final diff against the pre-existing working tree; do not reset or clean.
- [Long Next.js startup] → Use a bounded readiness timeout and show the captured launcher error instead of hanging indefinitely.

## Migration Plan

1. Add the OpenSpec artifacts and localized launcher/documentation changes.
2. Run PowerShell syntax and command-dispatch checks.
3. Start StudyPower through OneStart, verify HTTP readiness and status, then stop it through OneStart.
4. Review the diff and preserve unrelated working-tree changes.
5. Commit and push only the confirmed OneStart integration changes after verification.

Rollback is a revert of the integration hunks or commit; no StudyPower data or source files are changed.

## Open Questions

None. The project path, production command, and port were confirmed before implementation.
