return {
  {
    name = "theme-hotreload",
    dir = vim.fn.stdpath("config"),
    lazy = false,
    priority = 1000,
    config = function()
      local config_path = vim.fn.stdpath("config")
      local transparency_file = config_path .. "/plugin/after/transparency.lua"

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyReload",
        callback = function()
          -- 1. Clear Lua module cache for the theme spec
          package.loaded["plugins.theme"] = nil

          vim.schedule(function()
            local ok, theme_spec = pcall(require, "plugins.theme")
            if not ok then
              return
            end

            -- 2. Identify the active theme plugin name
            local theme_plugin_name = nil
            for _, spec in ipairs(theme_spec) do
              if spec[1] and spec[1] ~= "LazyVim/LazyVim" then
                theme_plugin_name = spec.name or spec[1]
                break
              end
            end

            -- 3. Reset highlights and background defaults
            vim.cmd("highlight clear")
            if vim.fn.exists("syntax_on") == 1 then
              vim.cmd("syntax reset")
            end
            vim.o.background = "dark"

            -- 4. Purge cached theme files from package table to force a hard reload
            if theme_plugin_name then
              local plugin = require("lazy.core.config").plugins[theme_plugin_name]
              if plugin and plugin.dir then
                require("lazy.core.util").walkmods(plugin.dir .. "/lua", function(modname)
                  package.loaded[modname] = nil
                  package.preload[modname] = nil
                end)
              end
            end

            -- 5. Find colorscheme and apply it
            for _, spec in ipairs(theme_spec) do
              if spec[1] == "LazyVim/LazyVim" and spec.opts and spec.opts.colorscheme then
                local colorscheme = spec.opts.colorscheme
                local theme_plugin = theme_plugin_name and require("lazy.core.config").plugins[theme_plugin_name]

                if theme_plugin and theme_plugin._ and theme_plugin._.loaded then
                  require("lazy.core.loader").reload(theme_plugin)
                else
                  require("lazy.core.loader").colorscheme(colorscheme)
                end

                -- 6. Render changes and re-apply post-config settings (like transparency)
                vim.defer_fn(function()
                  pcall(vim.cmd.colorscheme, colorscheme)
                  vim.cmd("redraw!")

                  if vim.fn.filereadable(transparency_file) == 1 then
                    vim.defer_fn(function()
                      vim.cmd.source(transparency_file)
                      vim.api.nvim_exec_autocmds("ColorScheme", { modeline = false })
                      vim.api.nvim_exec_autocmds("VimEnter", { modeline = false })
                      vim.cmd("redraw!")
                    end, 5)
                  end
                end, 5)

                break
              end
            end
          end)
        end,
      })
    end,
  },
}
