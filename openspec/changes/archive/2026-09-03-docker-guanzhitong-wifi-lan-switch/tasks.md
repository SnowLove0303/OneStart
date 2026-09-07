## 1. Baseline and launcher configuration

- [x] 1.1 Re-read the existing `System/Workflow-Launcher.ps1` and preserve its uncommitted user changes; verify the implementation diff is limited to the confirmed Docker Web integration areas.
- [x] 1.2 Add a single Docker target configuration for `guanzhitong-compliance`, Docker CLI discovery, container port `8765`, host port `18765`, and the dedicated firewall rule; verify no second launcher/configuration/port is introduced.

## 2. Docker service control and health checks

- [x] 2.1 Implement exact-container lookup and Docker availability checks; verify missing Docker/container/image produces a non-zero result without creating a container.
- [x] 2.2 Implement start/reuse and health/port-mapping verification for `guanzhitong-compliance`; verify `wll web` reaches the existing healthy container and reports `http://127.0.0.1:18765`.
- [x] 2.3 Replace the old local Python Web start/stop/status path for the `web` and `compliance` targets with the Docker target; verify no Python process is launched and no duplicate port owner is created.

## 3. Wi‑Fi LAN firewall switch

- [x] 3.1 Implement unique active Private WLAN discovery and CIDR calculation; verify the current machine resolves WLAN `192.168.0.119/24` to `192.168.0.0/24` and fails closed for Public or ambiguous interfaces.
- [x] 3.2 Implement administrator/elevation checks and idempotent dedicated firewall-rule update for TCP `18765`; verify `on` creates or repairs only the Guanzhitong rule with Private profile and the detected Wi‑Fi CIDR.
- [x] 3.3 Detect and keep Docker Desktop's broad TCP Backend inbound rule disabled; verify `on` does not leave an active broad Docker rule that can bypass the service-specific source restriction.
- [x] 3.4 Implement `wll lan on`, `wll lan off`, and `wll lan status`; verify `off` disables only the Guanzhitong rule, keeps localhost reachable, and does not stop/delete the container.
- [x] 3.5 Add interactive menu actions for LAN on/off/status; verify menu actions call the same command functions and do not duplicate firewall logic.

## 4. Logging, documentation, and validation

- [x] 4.1 Add structured launcher log entries and user-facing output for container state, WLAN identity, CIDR, firewall state, access URL, and failure reasons; verify success and failure paths are distinguishable in `System/logs/launcher.log`.
- [x] 4.2 Update `System/README.md` with the `wll lan` commands, Docker Web port, same-Wi‑Fi security boundary, admin requirement, and the fact that LAN off does not stop Docker; verify documentation matches the actual command syntax.
- [x] 4.3 Run PowerShell syntax/static checks and OpenSpec validation; verify all changed scripts parse and all planned requirements have corresponding implementation coverage.
- [x] 4.4 Replay the real workflow on the existing container: status → LAN on → status → localhost HTTP check → LAN off → status; verify container remains healthy, rule state transitions are correct, no extra container/image/port is created, and the LAN URL is reported.
- [x] 4.5 Perform final unique-object and working-tree audit; verify only the confirmed launcher files plus OpenSpec artifacts changed, the original baseline/branch is preserved, and no unrelated user modifications were overwritten.
