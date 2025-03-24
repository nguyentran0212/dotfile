local cmp = require("cmp")

function setAutoCmp(mode)
  if mode then
    cmp.setup({
      completion = {
        autocomplete = { require('cmp.types').cmp.TriggerEvent.TextChanged }
      }
    })
  else
    cmp.setup({
      completion = {
        autocomplete = false
      }
    })
  end
end

-- enable automatic completion popup on typing
vim.cmd('command AutoCmpOn lua setAutoCmp(true)')

-- disable automatic competion popup on typing
vim.cmd('command AutoCmpOff lua setAutoCmp(false)')
