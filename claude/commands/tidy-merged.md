---
allowed-tools: Bash(~/.claude/scripts/tidy-merged-worktrees.sh:*)
description: 머지된 agent/issue-* PR 의 로컬 워크트리와 브랜치를 일괄 정리하고, 남은 세션 목록을 알려줍니다.
model: haiku
---

## 실행 결과

!`~/.claude/scripts/tidy-merged-worktrees.sh`

## 할 일

위 출력을 한국어로 짧게 요약해서 보고한다. 판정은 스크립트가 이미 끝냈으니 다시 따지지 않는다.

- 정리된 브랜치를 나열한다.
- 건너뛴 항목은 사유별로 한 줄씩. PR 이 아직 OPEN 이거나 없어서 건너뛴 건 정상이므로 강조하지 않는다.
- "손으로 지울 세션" 목록이 있으면 이름과 pid 를 그대로 옮기고, cc agents 화면에서 ctrl+x 두 번으로
  지우면 된다고 안내한다. 세션은 스크립트가 지우지 않는다.
- 아무것도 정리되지 않았으면 한 줄로만 답한다. 추가 조사나 제안을 덧붙이지 않는다.

`--dry-run` 은 미리보기, `--report` 는 판정 근거 JSON 이다. 건너뛴 사유를 파고들 때만 쓴다.
