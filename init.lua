-- Light Neovim config using the built-in plugin manager (vim.pack).
-- Commenting is built in: gcc (line), gc + motion / visual selection.

vim.g.mapleader = " "

-- Basics
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.opt.showmode = false      -- lualine shows the mode
vim.opt.fillchars = { eob = " ", vert = "│" }

-- Skip unused built-in providers (faster startup on Windows)
for _, p in ipairs({ "python3", "ruby", "node", "perl" }) do
  vim.g["loaded_" .. p .. "_provider"] = 0
end

-- Neo-tree replaces netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Folder nvim was opened in (`nvim some/dir` or the shell's cwd)
local launch_dir = (function()
  local arg = vim.fn.argv(0)
  if arg ~= "" and vim.fn.isdirectory(arg) == 1 then return vim.fn.fnamemodify(arg, ":p") end
  return vim.fn.getcwd()
end)()

---------------------------------------------------------------------------
-- Theme: vermillion on black
---------------------------------------------------------------------------
local c = {
  bg = "#0b0b0b", bg2 = "#141414", bg3 = "#1f1f1f", line = "#2a2a2a",
  fg = "#e8dcd4", muted = "#7a6a62", dim = "#4a403b",
  verm = "#e34234", ember = "#ff6a2b", amber = "#ffa94d", gold = "#f2c14e",
  red = "#ff3b30", green = "#9ccc65",
}

-- Light regex syntax with everything neutral except comments
vim.cmd("syntax on")
vim.api.nvim_create_autocmd("FileType", {
  callback = function() pcall(vim.treesitter.stop) end,
})

local function hl(group, opts) vim.api.nvim_set_hl(0, group, opts) end
local neutral = {
  "Constant", "String", "Character", "Number", "Boolean", "Float", "Identifier", "Function",
  "Statement", "Conditional", "Repeat", "Label", "Operator", "Keyword", "Exception",
  "PreProc", "Include", "Define", "Macro", "PreCondit", "Type", "StorageClass", "Structure",
  "Typedef", "Special", "SpecialChar", "Tag", "Delimiter", "Debug", "Underlined", "Title",
}
for _, g in ipairs(neutral) do hl(g, { fg = c.fg }) end

hl("Normal", { fg = c.fg, bg = c.bg })
hl("NormalNC", { fg = c.fg, bg = c.bg })
hl("NormalFloat", { fg = c.fg, bg = c.bg2 })
hl("FloatBorder", { fg = c.verm, bg = c.bg2 })
hl("FloatTitle", { fg = c.bg, bg = c.verm, bold = true })
hl("Comment", { fg = c.amber, italic = true })
hl("SpecialComment", { fg = c.amber, italic = true })
hl("Todo", { fg = c.bg, bg = c.verm, bold = true })
hl("CursorLine", { bg = c.bg2 })
hl("CursorLineNr", { fg = c.verm, bold = true })
hl("LineNr", { fg = c.dim })
hl("SignColumn", { bg = c.bg })
hl("WinSeparator", { fg = c.line })
hl("Visual", { bg = "#3a1a14" })
hl("Search", { fg = c.bg, bg = c.amber })
hl("IncSearch", { fg = c.bg, bg = c.verm, bold = true })
hl("CurSearch", { fg = c.bg, bg = c.verm, bold = true })
hl("MatchParen", { fg = c.ember, bold = true, underline = true })
hl("Pmenu", { fg = c.fg, bg = c.bg2 })
hl("PmenuSel", { fg = c.bg, bg = c.verm, bold = true })
hl("PmenuThumb", { bg = c.verm })
hl("StatusLine", { fg = c.muted, bg = c.bg2 })
hl("NonText", { fg = c.dim })
hl("Directory", { fg = c.verm })
hl("ErrorMsg", { fg = c.red, bold = true })
hl("WarningMsg", { fg = c.amber })
hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn", { fg = c.amber })
hl("DiagnosticInfo", { fg = c.gold })
hl("DiagnosticHint", { fg = c.muted })

-- Neo-tree
hl("NeoTreeNormal", { fg = c.fg, bg = c.bg })
hl("NeoTreeNormalNC", { fg = c.fg, bg = c.bg })
hl("NeoTreeCursorLine", { bg = c.bg3, bold = true })
hl("NeoTreeRootName", { fg = c.verm, bold = true })
hl("NeoTreeDirectoryIcon", { fg = c.verm })
hl("NeoTreeDirectoryName", { fg = c.fg })
hl("NeoTreeFileNameOpened", { fg = c.ember, italic = true })
hl("NeoTreeIndentMarker", { fg = c.line })
hl("NeoTreeExpander", { fg = c.muted })
hl("NeoTreeModified", { fg = c.ember })
hl("NeoTreeGitAdded", { fg = c.green })
hl("NeoTreeGitModified", { fg = c.amber })
hl("NeoTreeGitDeleted", { fg = c.red })
hl("NeoTreeGitUntracked", { fg = c.gold, italic = true })
hl("NeoTreeGitConflict", { fg = c.red, bold = true })
hl("NeoTreeGitIgnored", { fg = c.dim })
hl("NeoTreeDotfile", { fg = c.muted })
hl("NeoTreeWinSeparator", { fg = c.line, bg = c.bg })
hl("NeoTreeFloatBorder", { fg = c.verm, bg = c.bg2 })
hl("NeoTreeTitleBar", { fg = c.bg, bg = c.verm, bold = true })

-- Telescope
hl("TelescopeBorder", { fg = c.line, bg = c.bg })
hl("TelescopePromptBorder", { fg = c.verm, bg = c.bg })
hl("TelescopePromptPrefix", { fg = c.verm })
hl("TelescopeTitle", { fg = c.bg, bg = c.verm, bold = true })
hl("TelescopeSelection", { fg = c.fg, bg = c.bg3, bold = true })
hl("TelescopeMatching", { fg = c.ember, bold = true })

-- Dashboard
hl("DashArt1", { fg = "#e34234", bold = true })
hl("DashArt2", { fg = "#ee5530", bold = true })
hl("DashArt3", { fg = "#f7682c", bold = true })
hl("DashArt4", { fg = "#ff7f33", bold = true })
hl("DashArt5", { fg = "#ff983f", bold = true })
hl("DashKey", { fg = c.verm, bold = true })
hl("DashText", { fg = c.muted })

---------------------------------------------------------------------------
-- Plugins
---------------------------------------------------------------------------
vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-neo-tree/neo-tree.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/vyfor/cord.nvim",
  "https://github.com/folke/which-key.nvim",
}, { confirm = false })

-- Discord presence. Cord starts on the next tick (no startup cost); its small server binary is
-- shared by every nvim instance. Icons: the stock theme closest to vermillion on black.
-- First run / after updating the plugin: :Cord update
require("cord").setup({
  editor = { tooltip = "Neovim" },
  display = { theme = "default", flavor = "dark", view = "full" },
  idle = { timeout = 600000, details = "Away", tooltip = "away" },
  text = {
    workspace = function(o) return "in " .. o.workspace end,
    editing = function(o) return "Editing " .. o.filename end,
    viewing = function(o) return "Reading " .. o.filename end,
    file_browser = "Browsing files",
    terminal = "In the terminal",
    dashboard = "Home",
  },
  advanced = {
    server = { auto_update = false },                        -- no release check on every launch
    plugin = { debounce = { delay = 100, interval = 1500 } },  -- at most one update per 1.5 s
  },
})

-- File tree: <Space>e
require("neo-tree").setup({
  close_if_last_window = true,
  popup_border_style = "rounded",
  default_component_configs = {
    indent = {
      indent_size = 2,
      with_markers = true,
      indent_marker = "│",
      last_indent_marker = "╰",
      with_expanders = true,
      expander_collapsed = "\u{eab6}",
      expander_expanded = "\u{eab4}",
    },
    icon = {
      folder_closed = "\u{e5ff}",
      folder_open = "\u{e5fe}",
      folder_empty = "\u{f0256}",
      folder_empty_open = "\u{f0dcf}",
      default = "\u{f0214}",
    },
    modified = { symbol = "●" },
    name = { use_git_status_colors = true },
    git_status = {
      symbols = {
        added = "\u{eadc}", modified = "\u{eade}", deleted = "\u{eadf}", renamed = "\u{eae0}",
        untracked = "\u{eb32}", ignored = "\u{eadd}", unstaged = "\u{f0131}",
        staged = "\u{eab2}", conflict = "\u{eafe}",
      },
    },
  },
  window = { width = 32 },
  filesystem = {
    follow_current_file = { enabled = true },
    hijack_netrw_behavior = "open_current",
    filtered_items = { hide_dotfiles = false, hide_gitignored = false },
  },
})
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Toggle file tree" })

-- Telescope: <Space>f...
require("telescope").setup({
  defaults = { prompt_prefix = "  ", selection_caret = "▍ ", border = true },
})
local tb = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", tb.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", tb.live_grep, { desc = "Search text" })
vim.keymap.set("n", "<leader>fb", tb.buffers, { desc = "Open buffers" })
vim.keymap.set("n", "<leader>fr", tb.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fk", tb.keymaps, { desc = "Search keybindings" })

-- Keybinding popup: press <Space> and wait; <Space>? lists everything
require("which-key").setup({
  preset = "modern",
  delay = 400,
  win = { border = "rounded" },
  spec = {
    { "<leader>f", group = "Find" },
    { "<leader>t", group = "Terminal" },
  },
})
vim.keymap.set("n", "<leader>?", function() require("which-key").show({ global = true }) end,
  { desc = "All keybindings" })
hl("WhichKey", { fg = c.verm, bold = true })
hl("WhichKeyGroup", { fg = c.amber })
hl("WhichKeyDesc", { fg = c.fg })
hl("WhichKeySeparator", { fg = c.dim })
hl("WhichKeyBorder", { fg = c.verm, bg = c.bg2 })

-- Status bar
local function mode_theme(bg)
  return {
    a = { fg = c.bg, bg = bg, gui = "bold" },
    b = { fg = c.fg, bg = c.bg3 },
    c = { fg = c.muted, bg = c.bg2 },
  }
end
require("lualine").setup({
  options = {
    theme = {
      normal = mode_theme(c.verm),
      insert = mode_theme(c.amber),
      visual = mode_theme(c.gold),
      replace = mode_theme(c.red),
      command = mode_theme(c.ember),
      terminal = mode_theme(c.green),
      inactive = mode_theme(c.dim),
    },
    globalstatus = true,
    component_separators = { left = "", right = "│" },
    section_separators = { left = "\u{e0b4}", right = "\u{e0b6}" },
    disabled_filetypes = { statusline = { "dashboard" } },
  },
  sections = {
    lualine_a = { { "mode", icon = "\u{e62b}", separator = { left = "\u{e0b6}" } } },
    lualine_b = {
      { "branch", icon = "\u{e725}" },
      { "diff", symbols = { added = "\u{f457} ", modified = "\u{f459} ", removed = "\u{f458} " } },
    },
    lualine_c = {
      { "filename", path = 1, symbols = { modified = " ●", readonly = " \u{f023}", unnamed = "[No Name]", newfile = " \u{f067}" } },
      { "diagnostics", symbols = { error = "\u{f057} ", warn = "\u{f071} ", info = "\u{f05a} ", hint = "\u{f0335} " } },
    },
    lualine_x = {
      "searchcount",
      "selectioncount",
      { function() return "\u{f1dd} " .. vim.bo.shiftwidth end },
      "encoding",
      { "fileformat", symbols = { unix = "\u{f31a}", dos = "\u{e70f}", mac = "\u{f179}" } },
    },
    lualine_y = { { "filetype", colored = false } },
    lualine_z = { "progress", { "location", separator = { right = "\u{e0b4}" } } },
  },
})

---------------------------------------------------------------------------
-- Terminal in the launch folder: <Space>tt (bottom) / <Space>tv (side)
---------------------------------------------------------------------------
local term = {}
local function toggle_term(vertical)
  if term.win and vim.api.nvim_win_is_valid(term.win) then
    vim.api.nvim_win_hide(term.win)
    term.win = nil
    return
  end
  vim.cmd(vertical and "botright 70vsplit" or "botright 12split")
  term.win = vim.api.nvim_get_current_win()
  if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
    vim.api.nvim_win_set_buf(term.win, term.buf)
  else
    term.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(term.win, term.buf)
    vim.fn.jobstart(vim.o.shell, {
      term = true,
      cwd = launch_dir,
      on_exit = function()
        vim.schedule(function()
          if term.buf and vim.api.nvim_buf_is_valid(term.buf) then vim.api.nvim_buf_delete(term.buf, { force = true }) end
          term.buf, term.win = nil, nil
        end)
      end,
    })
  end
  vim.wo[term.win].number = false
  vim.wo[term.win].cursorline = false
  vim.cmd.startinsert()
end
vim.keymap.set("n", "<leader>tt", function() toggle_term(false) end, { desc = "Terminal (launch dir)" })
vim.keymap.set("n", "<leader>tv", function() toggle_term(true) end, { desc = "Terminal side (launch dir)" })
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Leave terminal mode" })

---------------------------------------------------------------------------
-- Dashboard
---------------------------------------------------------------------------
local art = {
  "██ ▄▄ ██▀▄▄ ▄▄ ▄▄ ██▀█▄ ▄█▀ ▄█▀█▄ ▄▄▀▄▄      ▄▄ ▄▄ ▄▄ ▄█▀█▄▀█▄",
  "██ ██ ██ ██ ██ ██ ██ ██ ██  ██ ██ ██         ██ ██ ██ ██ ██ ██",
  "██▀█▄ ██▀██  ▀▀██ ██ ██ ██▀ ██ ██  ▀▀▄▄      ██ ██ ██ ██ ██ ██",
  "██ ██ ██ ██ ▄▄ ██ ██ ██ ██  ██ ██ ▄▄ ██      ▀█ █▀ ██ ██ ██ ██",
  "██ ██ ██ ██ ██▄▀▀ ██▄█▀ ▀█▄ ██ ██ ▀▀▄▀▀       ▀▄▀  ██ ██ ▀▀ ██",
}
local items = {
  { "f", "\u{f002}  Find file", tb.find_files },
  { "r", "\u{f1da}  Recent files", tb.oldfiles },
  { "g", "\u{f0b0}  Search text", tb.live_grep },
  { "e", "\u{e5ff}  File tree", function() vim.cmd("Neotree toggle") end },
  { "n", "\u{f15b}  New file", function() vim.cmd("enew") end },
  { "q", "\u{f011}  Quit", function() vim.cmd("qa") end },
}

local ns = vim.api.nvim_create_namespace("dashboard")
local function render(buf)
  local lines, marks = {}, {}
  local width = vim.api.nvim_win_get_width(0)
  local function add(text, group, key_len)
    local pad = math.max(0, math.floor((width - vim.fn.strdisplaywidth(text)) / 2))
    table.insert(lines, string.rep(" ", pad) .. text)
    table.insert(marks, { #lines - 1, pad, group, key_len })
  end
  for i, l in ipairs(art) do add(l, "DashArt" .. i) end
  add("", "DashText")
  add("", "DashText")
  for _, it in ipairs(items) do add(string.format("[%s]   %-16s", it[1], it[2]), "DashText", 3) end
  local top = math.max(0, math.floor((vim.o.lines - #lines) / 2) - 2)
  for _ = 1, top do table.insert(lines, 1, "") end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, m in ipairs(marks) do
    local row = m[1] + top
    vim.api.nvim_buf_set_extmark(buf, ns, row, m[2], { end_row = row, end_col = #lines[row + 1], hl_group = m[3] })
    if m[4] then vim.api.nvim_buf_set_extmark(buf, ns, row, m[2], { end_col = m[2] + m[4], hl_group = "DashKey", priority = 200 }) end
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() > 0 or vim.api.nvim_buf_get_name(0) ~= "" or vim.api.nvim_buf_line_count(0) > 1 then return end
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].filetype = "dashboard"
    vim.wo.number = false
    vim.wo.cursorline = false
    render(buf)
    for _, it in ipairs(items) do vim.keymap.set("n", it[1], it[3], { buffer = buf, nowait = true }) end
    vim.api.nvim_create_autocmd("VimResized", { buffer = buf, callback = function() render(buf) end })
    vim.api.nvim_create_autocmd("BufWipeout", {
      buffer = buf,
      callback = function() vim.wo.number = true; vim.wo.cursorline = true end,
    })
  end,
})

-- pi-sync: every :w under "PI ka stuff" is pushed to voidpi (mirror + live copy).
local ok_pi, pi_sync = pcall(dofile, "C:/Users/LENOVO/Documents/PI ka stuff/pi-sync/nvim/pi_sync.lua")
if ok_pi then pi_sync.setup() end
