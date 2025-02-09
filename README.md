# espresso-visualizer.nvim

`espresso-visualizer.nvim` is a tiny plugin that grabs the most recent shot from a `https://visualizer.coffee/` profile. It provides commands to place it in a designated register, append it to the line, or open it in browser.

It creates no keybindings or commands by default - see below for guidance on configuring your own.

## installation

```lua
  {
    "brianmargolis/espresso-visualizer.nvim"
    lazy = true,
    config = function()
      require("espresso-visualizer").setup({
        -- required
        profile_name = "brian-margolis", // this is from https://visualizer.coffee/people/brian-margolis
      })
    keys = {
      {
        "<leader>oe",
        function()
          require("espresso-visualizer").append_last_shot({
            -- optional, decorator modifies the shot URL before appending it
            decorator = function(u)
              return "[visualizer.coffee](" .. u .. ")"
            end
          })
        end,
        desc = "append last shot",
      },
      {
        "<leader>oE",
        function()
          require("espresso-visualizer").open_last_shot()
        end,
        desc = "open last shot in the browser",
      },
    },
    end,
  },
```
