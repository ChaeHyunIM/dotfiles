#!/usr/bin/env bash
#
# dotfiles 설치 — 저장소 안의 파일을 홈 디렉터리의 원래 자리로 심링크한다.
# 몇 번을 다시 실행해도 결과가 같다.
#
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
linked=0
backed_up=0

# 목적지에 심링크가 아닌 실제 파일이 있으면 지우지 않고 백업으로 옮긴 뒤 링크한다.
link() {
  local src="$DOTFILES/$1" dst="$HOME/$2"
  if [[ ! -e "$src" ]]; then
    echo "  건너뜀 (원본 없음): $1" >&2
    return
  fi
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    mkdir -p "$(dirname "$BACKUP/$2")"
    mv "$dst" "$BACKUP/$2"
    backed_up=$((backed_up + 1))
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  linked=$((linked + 1))
}

echo "==> 셸 / git"
link shell/zshrc          .zshrc
link shell/zprofile       .zprofile
link shell/gitconfig      .gitconfig
link config/nvim          .config/nvim
# Ghostty 는 macOS 에서 이 경로를 읽는다. ~/.config/ghostty 가 아니다.
link config/ghostty/config "Library/Application Support/com.mitchellh.ghostty/config"

# git 신원은 저장소에 담지 않는다. 없으면 자리만 만들어 두고 값은 사람이 채운다.
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  cat > "$HOME/.gitconfig.local" <<'GITLOCAL'
[user]
	name = CHANGE_ME
	email = CHANGE_ME
GITLOCAL
  echo "  ~/.gitconfig.local 을 만들었다 — name/email 을 채울 것"
fi

echo "==> Codex"
link codex/config.toml    .codex/config.toml
link codex/AGENTS.md      .codex/AGENTS.md

echo "==> 스킬 정본 (런타임 중립)"
link agents/skills            .agents/skills
link agents/.skill-lock.json  .agents/.skill-lock.json

# ~/.claude 에는 세션 기록·로그 같은 런타임 파일이 함께 살기 때문에
# 디렉터리째 링크하지 않고 관리 대상만 개별로 건다.
echo "==> Claude Code"
link claude/CLAUDE.md     .claude/CLAUDE.md
link claude/settings.json .claude/settings.json
link claude/commands      .claude/commands
link claude/hooks         .claude/hooks
link claude/scripts       .claude/scripts
link claude/output-styles .claude/output-styles

# 스킬 심링크는 저장소에 담지 않고 여기서 만든다.
# 정본은 ~/.agents 를 상대경로로 가리켜야 다른 런타임과 공유된다.
# ~/.codex/skills 에는 Codex 가 제공하는 .system 이 함께 살기 때문에
# ~/.claude/skills 와 마찬가지로 디렉터리째 링크하지 않고 하나씩 건다.
#
# 목적지가 심링크가 아닌 실제 디렉터리면 macOS 의 ln -sfn 은 교체하지 않고
# 그 안에 링크를 만들어 버린다. link() 와 같은 방식으로 백업으로 치운 뒤 건다.
link_skill() {
  local src="$1" dst="$2"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    local rel="${dst#"$HOME"/}"
    mkdir -p "$(dirname "$BACKUP/$rel")"
    mv "$dst" "$BACKUP/$rel"
    backed_up=$((backed_up + 1))
  fi
  ln -sfn "$src" "$dst"
  linked=$((linked + 1))
}

echo "==> 스킬 링크 재생성"
mkdir -p "$HOME/.claude/skills" "$HOME/.codex/skills"
for s in "$DOTFILES/agents/skills"/*/; do
  name="$(basename "$s")"
  link_skill "../../.agents/skills/$name" "$HOME/.claude/skills/$name"
  link_skill "../../.agents/skills/$name" "$HOME/.codex/skills/$name"
done
for s in "$DOTFILES/claude/skills"/*/; do
  name="$(basename "$s")"
  link_skill "${s%/}" "$HOME/.claude/skills/$name"
done
for s in "$DOTFILES/codex/skills"/*/; do
  name="$(basename "$s")"
  link_skill "${s%/}" "$HOME/.codex/skills/$name"
done

chmod +x "$DOTFILES/claude/hooks"/*.sh 2>/dev/null || true
chmod +x "$DOTFILES/claude/scripts"/*.sh 2>/dev/null || true
chmod +x "$DOTFILES/tools"/*.sh 2>/dev/null || true

# .gitattributes 가 가리키는 clean 필터. .git/config 는 추적되지 않으므로
# 클론할 때마다 다시 등록해야 한다.
if git -C "$DOTFILES" rev-parse --git-dir >/dev/null 2>&1; then
  git -C "$DOTFILES" config filter.codex-state.clean "$DOTFILES/tools/codex-clean.sh"
  echo "  codex-state clean 필터 등록"
fi

echo
echo "링크 $linked 개 생성"
if (( backed_up > 0 )); then
  echo "기존 파일 $backed_up 개를 $BACKUP 로 옮김"
fi
echo
echo "남은 수동 작업:"
echo "  - nvm 설치 후  nvm install 26"
echo "  - pnpm 설치    curl -fsSL https://get.pnpm.io/install.sh | sh -"
echo "  - claude / codex 로그인"
