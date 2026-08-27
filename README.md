# dotfiles

Claude Code · Codex · zsh 설정을 한곳에 모은 저장소. 파일은 여기 살고, `install.sh` 가 홈의
원래 자리로 심링크를 건다. 설정을 고치면 `git status` 에 잡히고, `git pull` 로 다른 머신에
간다.

스킬만 예외다. `install.sh` 는 스킬을 건드리지 않는다 — 원문과 디렉터리 구조만 저장소에 두고,
설치는 그 런타임의 에이전트에게 시킨다. 「스킬」 절을 볼 것.

- 에이전트 설정 — Claude Code(지침·모델·플러그인·hook), Codex(모델·MCP·플러그인)
- 스킬 26개 — 정본 24개는 런타임 중립, 런타임 전용이 따로
- 셸 — zsh(zinit · p10k · nvm · fzf · zoxide), git, ghostty
- 에디터 — Neovim 단일파일 설정(init.lua) + mac_classic 테마

## 빠른 시작

```bash
git clone https://github.com/ChaeHyunIM/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

## 구조

```
agents/skills/        스킬 정본 24개 — 런타임 중립. → ~/.agents/skills
claude/
  CLAUDE.md           전역 지침
  settings.json       모델 · 플러그인 · hook · 언어
  commands/           /commit
  hooks/              EnterWorktree 후 .env 링크
  output-styles/      korean-output
  skills/             Claude 전용 3개 (Workflow · Agent · Artifact 의존)
codex/                config.toml, AGENTS.md
  skills/             Codex 전용 1개
shell/                zshrc, zprofile, gitconfig
config/
  ghostty/config      터미널 설정 — macOS 는 ~/Library/Application Support/ 아래를 읽는다
  nvim/               init.lua, colors/mac_classic.lua
```

## install.sh

심링크를 거는 게 전부다. 의존성이 없어서 새 맥에서 바로 돈다.

몇 번을 돌려도 결과가 같다. 목적지에 심링크가 아닌 실파일이 있으면 지우지 않고
`~/.dotfiles-backup/<타임스탬프>/` 로 옮긴 뒤 링크한다.

스킬은 대상이 아니다. `~/.agents/skills` 만 걸어 두고, 런타임별 설치는 안 한다.

`~/.gitconfig.local` 이 없으면 자리만 만들어 둔다. 값은 직접 채운다.

## 스킬

저장소가 갖는 건 **스킬 원문과 디렉터리 구조뿐이다.** 어느 경로에 어떤 이름으로 얹어야
그 런타임이 스킬을 인식하는지는 런타임마다 다르고, 버전이 오르면 또 바뀐다. 그 규칙을
설치 스크립트에 박아 두면 저장소가 런타임 변경을 계속 쫓아다녀야 한다.

그래서 설치는 사람이 아니라 **그 런타임의 에이전트**가 한다. 새 머신에서 Claude Code 든
Codex 든 켜고 이렇게 시키면 된다.

```
~/dotfiles/agents/skills 가 런타임 중립 스킬 정본이고,
~/dotfiles/claude/skills 와 ~/dotfiles/codex/skills 는 각 런타임 전용이다.
지금 런타임이 스킬을 읽는 방식대로 이것들을 설치해줘.
```

에이전트가 자기 규칙을 알고 있으니 심링크를 걸든 복사하든 알아서 맞춘다.

**정본과 런타임 전용을 나누는 기준** — Workflow · Agent · Artifact 처럼 그 런타임에만
있는 기능에 기대면 전용이다. 옮겨봐야 다른 데서 안 돈다. 그 외에는 전부
`agents/skills/` 정본으로 두고 여러 런타임이 같이 쓴다.
`~/.agents/skills` 는 `install.sh` 가 저장소로 걸어 주므로, 정본을 고치면 곧바로
`git status` 에 잡힌다.

## 아키텍처

**`~/.claude` 는 통째로 링크하지 않는다.** 세션 기록·로그·크리덴셜이 설정과 같은 디렉터리에
산다. 관리 대상만 파일 단위로 건다.

**git 신원은 저장소 밖에 둔다.** `shell/gitconfig` 가 `[include]` 로 `~/.gitconfig.local` 을
부른다. 기본값은 개인 계정, 회사 저장소는 저장소별로 덮어쓴다.

**안 넣는 것** — `history.jsonl` · `sessions/` · `projects/` · `daemon.log`(런타임 기록),
`.credentials.json` · `auth.json`(인증), `settings.local.json`(머신별),
`keybindings.json`(기본값 덤프 — 두면 이후 기본값 변경이 안 따라온다),
Codex `[projects.*]` 와 앱이 심는 마켓플레이스 `openai-bundled`·`openai-primary-runtime`
(후자는 머신별 캐시 절대경로다).

## 환경 설정

`install.sh` 가 못 하는 것들.

| 항목 | 명령 |
|---|---|
| nvm | `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh \| bash` |
| Node | `nvm install 26` |
| pnpm | `curl -fsSL https://get.pnpm.io/install.sh \| sh -` |
| 로그인 | `claude`, `codex` 각각 실행 후 인증 |
| git 신원 | `~/.gitconfig.local` 의 `name` · `email` |
| 스킬 | 런타임 에이전트에게 시킨다 — 「스킬」 절 |

Homebrew 패키지는 관리하지 않는다. 필요한 걸 그때그때 깐다.
