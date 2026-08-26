#!/usr/bin/env bash
#
# git clean 필터 — stdin 으로 받은 codex/config.toml 에서 Codex 앱이 자동으로
# 채워 넣는 머신 상태를 걷어내고 stdout 으로 넘긴다. 대상은 [projects.*] 신뢰
# 기록, 앱이 번들로 심는 node_repl·computer-use MCP 서버, openai-bundled
# 마켓플레이스와 그 플러그인 활성 기록, computer-use notify 훅이다. 전부 앱이
# 다시 만들어 주는 값이고 앱 버전이 올라갈 때마다 바뀌므로 추적할 이유가 없다.
#
# 등록은 install.sh 가 한다. 필터가 없는 클론에서는 git 이 내용을 그대로
# 통과시키므로(required 를 켜지 않았다) 동작이 깨지지 않는다.
#
set -euo pipefail

# 걷어낸 블록 앞뒤의 문단 구분 빈 줄이 남으면 그것만으로도 diff 가 생긴다.
# 그래서 빈 줄은 바로 내보내지 않고 모아 뒀다가 살아남는 줄이 나올 때만 흘리고,
# 걷어낼 블록을 만나면 모아 둔 빈 줄을 버린다. 파일 끝에 몰린 빈 줄도 같은
# 이유로 사라진다. 블록은 헤더에서 걷어내기 시작해 다음 헤더에서 다시 판정하되,
# 사람이 남긴 구획 주석은 앱이 넣는 블록에 없으므로 주석을 만나면 즉시 끝낸다.
awk '
  /^\[/ {
    skip = ($0 ~ /^\[projects\./ \
         || $0 ~ /^\[mcp_servers\.node_repl[].]/ \
         || $0 ~ /^\[mcp_servers\.computer-use\]/ \
         || $0 ~ /^\[marketplaces\.openai-bundled\]/ \
         || $0 ~ /^\[plugins\."[^"]*@openai-bundled"\]/)
    if (skip) { blanks = 0; next }
  }
  /^[[:space:]]*$/           { blanks++; next }
  skip && /^#/               { skip = 0 }
  skip                       { next }
  /^notify = .*SkyComputerUseClient/ { blanks = 0; next }
                             { for (; blanks > 0; blanks--) print ""; print }
'
