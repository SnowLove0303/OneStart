# studypower-launcher Specification

## Purpose
为 StudyPower 提供统一启动器入口，使用户能够通过 OneStart PowerShell 在固定本地端口启动并访问个人思维导图与 Word 工作台。

## Requirements

### Requirement: Start StudyPower from the unified launcher

The unified PowerShell launcher SHALL support starting StudyPower from its configured project directory using the existing production start command and configured local port.

#### Scenario: Start a stopped StudyPower instance

- **WHEN** the user runs `start studypower` or the equivalent convenience command
- **THEN** the launcher starts StudyPower from `F:\APP Location\StudyPower` on the configured port `3100`, waits until the local web endpoint is reachable, and reports the local URL

#### Scenario: StudyPower project directory is unavailable

- **WHEN** the user requests StudyPower but the configured project directory or required package manifest is missing
- **THEN** the launcher reports an actionable error and does not start a process

#### Scenario: StudyPower fails to become ready

- **WHEN** the launcher starts StudyPower but the configured endpoint does not become reachable before the readiness timeout
- **THEN** the launcher reports a failed or timed-out start and returns a non-success command result

### Requirement: Avoid duplicate or unrelated process control

The launcher SHALL recognize an already-running StudyPower instance by its configured port and StudyPower project context, skip duplicate startup, and limit stop operations to the matching StudyPower process.

#### Scenario: StudyPower is already running

- **WHEN** the user requests StudyPower startup while the matching instance is already ready
- **THEN** the launcher skips starting another instance and opens or reports the existing local URL

#### Scenario: Stop StudyPower

- **WHEN** the user runs `stop studypower`
- **THEN** the launcher stops the matching StudyPower process when present, reports success when it is stopped or already absent, and does not stop unrelated services using other project directories

### Requirement: Expose StudyPower status and interactive entry

The launcher SHALL expose StudyPower in the interactive menu and aggregate platform status while preserving existing platform behavior.

#### Scenario: View aggregate status

- **WHEN** the user runs `status` or selects the aggregate status menu option
- **THEN** the launcher reports whether StudyPower is running and includes its local URL when it is ready

#### Scenario: Use the interactive menu

- **WHEN** the user opens the launcher menu
- **THEN** the menu provides explicit StudyPower start and stop actions and the prompt reflects the available option range

#### Scenario: Preserve existing all-platform startup

- **WHEN** the user runs `start all`
- **THEN** the launcher starts the existing platforms exactly as before and does not implicitly add StudyPower
