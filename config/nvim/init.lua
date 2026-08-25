-- ~/.config/nvim/init.lua
-- 미니멀 단일파일 Neovim 설정 (Neovim 0.12+)

------------------------------------------------------------------------------
-- 기본 옵션
------------------------------------------------------------------------------
vim.o.number         = true
vim.o.relativenumber = true
vim.o.expandtab      = true
vim.o.shiftwidth     = 2
vim.o.tabstop        = 2
vim.o.smartindent    = true
vim.o.signcolumn     = 'yes'
vim.o.undofile       = true
vim.o.ignorecase     = true
vim.o.smartcase      = true
vim.o.scrolloff      = 4
vim.o.winborder      = 'rounded'  -- floating window 기본 border (LSP hover, blink 등)

-- 테마: mac_classic (truecolor) — colors/mac_classic.lua 참조
vim.o.termguicolors = true
vim.o.background    = 'light'

-- Leader 키 = Space (플러그인 키맵 충돌 방지를 위해 키맵 정의 전에 설정)
vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '

------------------------------------------------------------------------------
-- 의존성 안내
------------------------------------------------------------------------------
if vim.fn.executable('tree-sitter') == 0 then
  vim.notify(
    'tree-sitter CLI not found. Install with: brew install tree-sitter-cli',
    vim.log.levels.WARN
  )
end

------------------------------------------------------------------------------
-- vim.pack 훅: 플러그인 install/update 시 빌드/후처리
-- (PackChanged kind="install"은 plugin load 이전에 발생하므로 필요시 packadd)
-- ※ 반드시 vim.pack.add() 이전에 등록해야 첫 install에도 동작.
------------------------------------------------------------------------------
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end
    if not ev.data.active then vim.cmd.packadd(name) end

    if name == 'nvim-treesitter' then
      vim.cmd('TSUpdate')
    elseif name == 'fff.nvim' then
      -- prebuilt 바이너리 다운로드 (실패 시 cargo로 자동 빌드)
      require('fff.download').download_or_build_binary()
    elseif name == 'blink.cmp' then
      -- prebuilt fuzzy matcher 바이너리 다운로드 (없으면 Lua fallback)
      pcall(function() require('blink.cmp.fuzzy.download').ensure_downloaded() end)
    end
  end,
})

------------------------------------------------------------------------------
-- 플러그인
------------------------------------------------------------------------------
vim.pack.add({
  -- main 브랜치는 v0.12+ 전용 재작성판 (master는 0.11 호환용)
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  -- 파일/콘텐츠 fuzzy finder (Rust 네이티브 백엔드, frecency 랭킹)
  { src = 'https://github.com/dmtrKovalenko/fff.nvim' },
  -- 자동완성 (v1 stable, v2는 breaking 작업 중)
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.*') },
  -- blink.cmp의 snippet 소스가 사용하는 표준 스니펫 모음
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
})

------------------------------------------------------------------------------
-- 컬러스킴 (colors/mac_classic.lua 정의)
------------------------------------------------------------------------------
vim.cmd.colorscheme('mac_classic')

------------------------------------------------------------------------------
-- blink.cmp (자동완성)
-- nvim 0.11+에서 LSP capabilities를 vim.lsp.config('*')에 자동 등록하므로
-- vtsls 설정 따로 손볼 필요 없음.
------------------------------------------------------------------------------
require('blink.cmp').setup({
  keymap = { preset = 'super-tab' },  -- Tab/S-Tab 네비, Enter 확정
  appearance = { nerd_font_variant = 'mono' },
  completion = { documentation = { auto_show = true, auto_show_delay_ms = 300 } },
  sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
  fuzzy = { implementation = 'prefer_rust_with_warning' },
})

------------------------------------------------------------------------------
-- Treesitter
-- 파서는 :TSInstall <언어명> 으로 그때그때 설치 (예: :TSInstall rust python)
-- 설치된 파서는 ~/.local/share/nvim/site/parser/*.so 에 저장됨
------------------------------------------------------------------------------

-- 파일 열 때 hi-light 시작 (파서 없으면 silent skip)
-- treesitter 성공 시 vim regex :syntax를 꺼서 더블 패스(플래시) 방지
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    if pcall(vim.treesitter.start, args.buf) then
      vim.bo[args.buf].syntax = ''
    end
  end,
})

------------------------------------------------------------------------------
-- LSP (Neovim 0.11+ 네이티브 API, 별도 플러그인 없음)
-- 설치: npm i -g @vtsls/language-server
------------------------------------------------------------------------------
vim.lsp.config('vtsls', {
  cmd = { 'vtsls', '--stdio' },
  filetypes = {
    'javascript', 'javascriptreact', 'javascript.jsx',
    'typescript', 'typescriptreact', 'typescript.tsx',
  },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
})

vim.lsp.enable('vtsls')

-- LspAttach 시 추가 키맵 (0.11 기본: K=hover, gra=code_action, grn=rename,
-- grr=references, gri=implementation, gO=symbols, ]d/[d=diagnostic)
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  end,
})

------------------------------------------------------------------------------
-- fff.nvim 키맵 (글로벌)
-- 픽커 내부 키맵: <CR>=open, <C-s>/<C-v>/<C-t>=split/vsplit/tab,
-- <Tab>=multi-select, <C-q>=quickfix, <S-Tab>=cycle grep mode, <Esc>=close
------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>ff', function() require('fff').find_files() end,
  { desc = 'FFF: find files' })
vim.keymap.set('n', '<leader>fg', function() require('fff').live_grep() end,
  { desc = 'FFF: live grep' })
vim.keymap.set('n', '<leader>fc', function()
  require('fff').live_grep({ query = vim.fn.expand('<cword>') })
end, { desc = 'FFF: grep word under cursor' })
