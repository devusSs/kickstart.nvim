-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

---@module 'lazy'
---@type LazySpec
return {
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      lint.linters_by_ft = {
        go = { 'golangcilint' },
      }

      local golangcilint = lint.linters.golangcilint
      if golangcilint then
        local original_args = golangcilint.args
        golangcilint.args = function()
          local args = type(original_args) == 'function' and original_args() or vim.deepcopy(original_args)
          if not args then return args end

          local target = nil
          if type(args[#args]) == 'function' then target = table.remove(args) end
          if not vim.tbl_contains(args, '--fast-only') then table.insert(args, '--fast-only') end
          if target then table.insert(args, target) end

          return args
        end
      end

      local lint_augroup = vim.api.nvim_create_augroup('custom-lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          if vim.bo.modifiable then lint.try_lint() end
        end,
      })
    end,
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    cmd = 'Neotree',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    keys = {
      { '<leader>e', '<cmd>Neotree reveal toggle left<CR>', desc = 'File [E]xplorer', silent = true },
      { '\\', '<cmd>Neotree reveal toggle left<CR>', desc = 'NeoTree reveal', silent = true },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = 'open_current',
        window = {
          mappings = {
            ['\\'] = 'close_window',
          },
        },
      },
    },
  },
}
