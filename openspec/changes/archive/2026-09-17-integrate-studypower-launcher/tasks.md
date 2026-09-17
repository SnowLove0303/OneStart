## 1. OpenSpec and configuration

- [x] 1.1 Record the StudyPower launcher capability and confirmed paths, command, and port in the change artifacts; verify with `openspec validate integrate-studypower-launcher --strict`
- [x] 1.2 Add StudyPower path, port, URL, and readiness settings to the existing launcher configuration; verify the configured project and `package.json` exist

## 2. Launcher integration

- [x] 2.1 Add StudyPower process/endpoint detection and bounded readiness polling using the existing launcher logging pattern; verify an absent instance reports not running
- [x] 2.2 Add StudyPower start and stop functions using the existing project directory and production command; verify `start studypower` reaches `http://127.0.0.1:3100` and `stop studypower` removes the matching process
- [x] 2.3 Add StudyPower to the menu, aggregate status, convenience aliases, and `start`/`stop` command dispatch without changing `start all`; verify the command help and menu include the new target

## 3. Documentation and verification

- [x] 3.1 Document StudyPower launcher commands in the root and System README files; verify both documents show the same start/stop usage
- [x] 3.2 Run PowerShell parse checks and OpenSpec validation; verify no syntax or spec validation errors
- [x] 3.3 Perform end-to-end start, HTTP readiness, status, duplicate-start, and stop checks; verify unrelated workspace changes remain untouched
- [x] 3.4 Review the final diff, commit the confirmed integration changes, and push the OneStart branch; verify the remote contains the commit
