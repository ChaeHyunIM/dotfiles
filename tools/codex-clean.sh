#!/usr/bin/env bash
#
# git clean 필터 — stdin 으로 받은 codex/config.toml 에서 Codex 앱이 자동으로
# 채워 넣는 [projects.*] 신뢰 기록을 걷어내고 stdout 으로 넘긴다.
#
# 앱은 새 디렉터리를 열 때마다 이 블록을 한 줄씩 늘린다. 머신 상태라 추적할
# 이유가 없는데, 그냥 두면 커밋할 때마다 diff 에 섞인다.
#
# 등록은 install.sh 가 한다. 필터가 없는 클론에서는 git 이 내용을 그대로
# 통과시키므로(required 를 켜지 않았다) 동작이 깨지지 않는다.
#
set -euo pipefail

# 블록은 헤더와 trust_level 두 줄이다. 블록을 지우면 그 앞뒤의 문단 구분 빈 줄이
# 남아 그것만으로도 diff 가 생긴다. 그래서 빈 줄은 바로 내보내지 않고 모아 뒀다가
# 살아남는 줄이 나올 때만 흘린다. 블록을 만나면 모아 둔 빈 줄을 버린다.
# 파일 끝에 몰린 빈 줄도 같은 이유로 사라진다.
awk '
  /^\[projects\./        { skip = 1; blanks = 0; next }
  skip && /^trust_level/ { skip = 0; next }
  skip                   { next }
  /^[[:space:]]*$/       { blanks++; next }
                         { for (; blanks > 0; blanks--) print ""; print }
'
