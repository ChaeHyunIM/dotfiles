# dotfiles

Claude Code · Codex · zsh 설정을 한곳에 모은 저장소. 파일은 여기 살고, `install.sh` 가 홈의
원래 자리로 심링크를 건다. 설정을 고치면 `git status` 에 잡히고, `git pull` 로 다른 머신에
간다.

- 에이전트 설정 — Claude Code(지침·모델·플러그인·hook·스킬), Codex(모델·MCP·플러그인)
- 스킬 25개 — 정본 18개는 런타임 중립, Claude 전용 7개는 별도
- 셸 — zsh(zinit · p10k · nvm · fzf · zoxide), git, ghostty
- 에디터 — Neovim 단일파일 설정(init.lua) + mac_classic 테마

## 빠른 시작

```bash
git clone https://github.com/ChaeHyunIM/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

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
config/
  ghostty/            터미널 설정
  nvim/               init.lua, colors/mac_classic.lua
```

## install.sh

심링크를 거는 게 전부다. 의존성이 없어서 새 맥에서 바로 돈다.

몇 번을 돌려도 결과가 같다. 목적지에 심링크가 아닌 실파일이 있으면 지우지 않고
`~/.dotfiles-backup/<타임스탬프>/` 로 옮긴 뒤 링크한다.

스킬 심링크 25개는 저장소에 담지 않고 실행할 때마다 다시 만든다. 그래서 경로가 어긋난
링크가 있어도 돌리면 고쳐진다.

`~/.gitconfig.local` 이 없으면 자리만 만들어 둔다. 값은 직접 채운다.

## 아키텍처

**스킬이 두 군데로 나뉜다.** 정본은 런타임 중립인 `~/.agents/skills/` 에 두고,
`~/.claude/skills/<name>` 은 거기를 가리키는 상대경로 심링크다. Codex 와 같이 쓰기 때문이다.
Workflow · Agent · Artifact 처럼 Claude Code 에만 있는 기능에 기대는 스킬만
`claude/skills/` 에 실디렉터리로 둔다 — 옮겨봐야 다른 런타임에서 안 돈다.

**`~/.claude` 는 통째로 링크하지 않는다.** 세션 기록·로그·크리덴셜이 설정과 같은 디렉터리에
산다. 관리 대상만 파일 단위로 건다.

**git 신원은 저장소 밖에 둔다.** `shell/gitconfig` 가 `[include]` 로 `~/.gitconfig.local` 을
부른다. 기본값은 개인 계정, 회사 저장소는 저장소별로 덮어쓴다.

**안 넣는 것** — `history.jsonl` · `sessions/` · `projects/` · `daemon.log`(런타임 기록),
`.credentials.json` · `auth.json`(인증), `settings.local.json`(머신별),
`keybindings.json`(기본값 덤프 — 두면 이후 기본값 변경이 안 따라온다),
Codex `[projects.*]` 와 `openai-bundled`(앱이 자동 생성).

## 환경 설정

`install.sh` 가 못 하는 것들.

| 항목 | 명령 |
|---|---|
| nvm | `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh \| bash` |
| Node | `nvm install 26` |
| pnpm | `curl -fsSL https://get.pnpm.io/install.sh \| sh -` |
| 로그인 | `claude`, `codex` 각각 실행 후 인증 |
| git 신원 | `~/.gitconfig.local` 의 `name` · `email` |

Homebrew 패키지는 관리하지 않는다. 필요한 걸 그때그때 깐다.
