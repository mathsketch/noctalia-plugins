_G.EXRC_ROOT_DIR = string.sub(debug.getinfo(1, 'S').short_src, 0, -11)
vim.cmd("set runtimepath+=" .. _G.EXRC_ROOT_DIR .. "/.nvim")
