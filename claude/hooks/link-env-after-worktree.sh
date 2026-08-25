#!/usr/bin/env bash
# PostToolUse hook (matcher: EnterWorktree)
# 새 worktree 가 생성되면 메인 worktree 의 gitignored .env* 파일을 symlink 로 복제한다.
#
# 동작: stdin 으로 PostToolUse JSON 을 받아 tool_response 에서 worktree 경로를 추출,
#       그 디렉토리에서 link-worktree-env 를 실행.

set -uo pipefail

input=$(cat)

# tool_response 의 worktree 경로 필드명이 SDK 버전마다 다를 수 있어 fallback 으로 시도
path=$(echo "$input" | jq -r '
  .tool_response.path
  // .tool_response.cwd
  // .tool_response.worktree_path
  // .tool_response.worktreePath
  // .tool_response.directory
  // .tool_response.workingDirectory
  // empty
' 2>/dev/null)

if [[ -z "$path" || ! -d "$path" ]]; then
  # 응답 구조를 파악할 수 없으면 디버그용 덤프만 남기고 조용히 종료
  mkdir -p /tmp/claude-hook-debug
  echo "$input" > "/tmp/claude-hook-debug/enter-worktree-$(date +%s).json"
  exit 0
fi

(cd "$path" && /Users/imchaehyun/.local/bin/link-worktree-env) >&2 || true
exit 0
