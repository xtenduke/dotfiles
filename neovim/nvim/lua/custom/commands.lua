-- Format
vim.api.nvim_create_user_command("Format", function()
  local ok, conform = pcall(require, "conform")
  if not ok then
    vim.notify("Conform.nvim is not loaded!", vim.log.levels.ERROR)
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  conform.format { bufnr = bufnr }
end, {
  desc = "Format current file with Conform",
  nargs = 0, -- no arguments required
})
