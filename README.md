# dotfiles

Claude Code · Codex · zsh 설정을 한곳에 모은 저장소입니다. 여러 머신에서 같은 환경을 쓰려고
만들었습니다.

파일은 이 저장소에 두고, `install.sh` 가 홈 디렉터리의 원래 자리로 심링크를 겁니다. 설정을
고치면 곧바로 `git status` 에 잡힙니다. 다른 머신에는 `git pull` 한 번으로 반영됩니다.

## 새 머신 설치

```bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

git clone https://github.com/ChaeHyunIM/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

공개 저장소라 클론에 인증이 필요하지 않습니다.

`install.sh` 는 몇 번을 실행해도 안전합니다. 목적지에 실제 파일이 있으면 지우지 않습니다.
`~/.dotfiles-backup/<타임스탬프>/` 로 옮긴 뒤에 링크를 겁니다.

설치 후 수동으로 해야 하는 것:

| 항목 | 명령 |
|---|---|
| nvm | `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh \| bash` |
| Node | `nvm install 26` |
| pnpm | `curl -fsSL https://get.pnpm.io/install.sh \| sh -` |
| Claude Code 로그인 | `claude` 실행 후 인증 |
| Codex 로그인 | `codex` 실행 후 인증 |
| git 신원 | `~/.gitconfig.local` 의 `name` · `email` 채우기 |

git 의 이름과 이메일은 추적하지 않는 `~/.gitconfig.local` 에 둡니다. `shell/gitconfig` 가
`[include]` 로 불러옵니다. 머신·소속마다 값이 다르고, 공개 저장소에 남길 값도 아니기
때문입니다. `install.sh` 는 파일이 없을 때만 자리를 만들어 둡니다.

Homebrew 패키지는 관리하지 않습니다. 필요한 것을 그때그때 설치하세요.

## 구조

```
agents/skills/        스킬 정본 18개 — 런타임 중립. → ~/.agents/skills
claude/
  CLAUDE.md           전역 지침
  settings.json       모델 · 플러그인 · hook · 언어
  commands/           /commit, /tidy-merged
  hooks/              EnterWorktree 후 .env 링크
  scripts/            워크트리 정리
  output-styles/      korean-output
  skills/             Claude 전용 스킬 7개 (Workflow · Agent · Artifact 의존)
codex/                config.toml, AGENTS.md
shell/                zshrc, zprofile, gitconfig
config/ghostty/       터미널 설정
```

### 스킬이 두 군데로 나뉘는 이유

스킬 정본은 런타임 중립인 `~/.agents/skills/` 에 둡니다. Claude Code 외의 에이전트(Codex 등)와
함께 쓰기 때문입니다. `~/.claude/skills/<name>` 은 거기를 가리키는 **상대경로 심링크**입니다.

Workflow · Agent · Artifact 처럼 Claude Code 에만 있는 기능에 기대는 스킬은 `claude/skills/` 에
실제 디렉터리로 둡니다. 옮겨봐야 다른 런타임에서 돌지 않기 때문입니다.

심링크 자체는 저장소에 담지 않습니다. `install.sh` 가 매번 규약대로 다시 만듭니다. 경로가
어긋난 링크가 있어도 실행하는 김에 교정됩니다.

## 넣지 않는 것

| 대상 | 이유 |
|---|---|
| `~/.claude/history.jsonl`, `sessions/`, `projects/`, `daemon.log` | 런타임 기록 |
| `~/.claude/.credentials.json`, `~/.codex/auth.json` | 인증 정보 |
| `settings.local.json` | 머신별 권한 캐시 |
| `~/.claude/keybindings.json` | 기본값 덤프 — 이후 기본값 변경이 안 따라옴 |
| Codex `[projects.*]`, `openai-bundled` 마켓플레이스 | 앱이 자동 생성하는 머신 상태 |

`settings.json` 과 `codex/config.toml` 은 각 앱이 직접 쓰기도 합니다. 앱이 머신 상태를 도로
채워 넣으면 diff 에 잡힙니다. 커밋 전에 한 번 훑고 필요 없는 줄은 지우세요.

## 프로젝트별 설정은 여기 두지 않습니다

특정 저장소에서만 쓰는 규칙은 그 저장소의 `.claude/settings.json` 에 커밋합니다. 클론하는
팀원 모두에게 적용됩니다. 그 프로젝트를 열지 않았을 때는 존재하지 않습니다.

단 `autoMode` 는 user 또는 managed 스코프에서만 동작합니다. 프로젝트 파일에 넣으면
무시됩니다. 자동 승인을 막고 확인을 받으려면 프로젝트의 `permissions.ask` 로 표현하세요.

`permissions.ask` 규칙에는 문법 제약이 하나 있습니다. Bash 규칙의 `:*` 는 패턴 끝에서만 후행
와일드카드로 해석됩니다. 중간에 오면 콜론이 리터럴이 되어 아무것도 매칭하지 않습니다.
`Bash(psql:*prod*)` 가 아니라 `Bash(psql*prod*)` 로 써야 합니다.
