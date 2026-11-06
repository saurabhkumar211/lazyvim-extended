return {
  "barrett-ruth/live-server.nvim",
  cmd = { "LiveServerStart", "LiveServerStop" },
  config = function()
    require("live-server").setup({
      args = { "--port=5500" }, -- 👈 Change 5500 to whatever port you want!
    })

    -- LazyVim Keymaps
    vim.keymap.set("n", "<leader>ls", "<cmd>LiveServerStart<cr>", { desc = "Start Live Server" })
    vim.keymap.set("n", "<leader>lx", "<cmd>LiveServerStop<cr>", { desc = "Stop Live Server" })
  end,
  keys = { "<leader>ls", "<leader>lx" },
}
