# dotfiles

Claude Code · Codex · zsh 설정을 한곳에 모아 여러 머신에서 같은 환경을 쓰기 위한 저장소.
파일은 이 저장소에 살고, `install.sh` 가 홈 디렉터리의 원래 자리로 심링크를 건다.
설정을 고치면 곧바로 `git status` 에 잡히고, `git pull` 한 번으로 다른 머신에 반영된다.

## 새 머신 설치

```bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

gh auth login
git clone git@github.com:<계정>/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

`install.sh` 는 몇 번을 실행해도 안전하다. 목적지에 실제 파일이 있으면 지우지 않고
`~/.dotfiles-backup/<타임스탬프>/` 로 옮긴 뒤 링크한다.

설치 후 수동으로 해야 하는 것:

| 항목 | 명령 |
|---|---|
| nvm | `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh \| bash` |
| Node | `nvm install 26` |
| pnpm | `curl -fsSL https://get.pnpm.io/install.sh \| sh -` |
| Claude Code 로그인 | `claude` 실행 후 인증 |
| Codex 로그인 | `codex` 실행 후 인증 |
| git 신원 | `~/.gitconfig.local` 의 `name` · `email` 채우기 |

git 의 이름과 이메일은 추적하지 않는 `~/.gitconfig.local` 에 두고 `shell/gitconfig` 가
`[include]` 로 불러온다. 머신·소속마다 값이 다르고, 공개 저장소에 남길 값도 아니기 때문이다.
`install.sh` 는 파일이 없을 때만 자리를 만들어 둔다.

Homebrew 패키지는 별도로 관리하지 않는다. 필요한 것을 그때그때 설치한다.

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

Claude Code 외의 에이전트(Codex 등)와 함께 쓰기 때문에, 스킬 정본은 런타임 중립인
`~/.agents/skills/` 에 두고 `~/.claude/skills/<name>` 은 거기를 가리키는 **상대경로 심링크**로 만든다.

Workflow · Agent · Artifact 처럼 Claude Code에만 있는 기능에 의존하는 스킬은 옮겨봐야
다른 런타임에서 안 도니까 `claude/skills/` 에 실제 디렉터리로 둔다.

심링크 자체는 저장소에 담지 않는다. `install.sh` 가 매번 규약대로 다시 만들기 때문에,
경로가 어긋난 링크가 있어도 실행하는 김에 교정된다.

## 넣지 않는 것

| 대상 | 이유 |
|---|---|
| `~/.claude/history.jsonl`, `sessions/`, `projects/`, `daemon.log` | 런타임 기록 |
| `~/.claude/.credentials.json`, `~/.codex/auth.json` | 인증 정보 |
| `settings.local.json` | 머신별 권한 캐시 |
| `~/.claude/keybindings.json` | 기본값 덤프. 있으면 향후 기본값 변경이 반영되지 않는다 |
| Codex `[projects.*]`, `openai-bundled` 마켓플레이스 | 앱이 자동 생성하는 머신 상태 |

`settings.json` 과 `codex/config.toml` 은 각 앱이 직접 쓰기도 한다. 앱이 머신 상태를
도로 채워 넣으면 diff 에 잡히므로, 커밋 전에 한 번 훑고 필요 없는 줄은 지운다.

## 프로젝트별 설정은 여기 두지 않는다

특정 저장소에서만 쓰는 규칙은 그 저장소의 `.claude/settings.json` 에 커밋한다.
클론하는 팀원 모두에게 적용되고, 그 프로젝트를 열지 않았을 때는 존재하지 않는다.

단 `autoMode` 는 user 또는 managed 스코프에서만 동작한다. 프로젝트 파일에 넣으면 무시되므로,
프로덕션 차단 같은 규칙은 프로젝트의 `permissions.deny` 로 표현한다.
