local M = {}

local function expand_keys(t)
  local result = {}
  for k, v in pairs(t) do
    k = vim.fs.normalize(k)
    result[k] = v
  end
  return result
end

local dispatch = setmetatable({
  ["string"] = function(x) require(x) end,
  ["function"] = function(x) x() end
}, { __index = function() error("You must use either a function or a string") end
})

function M.setup(t)
  if type(t) ~= "table" then
    error(('Expected "table" got %q').format(type(t)))
  end
  local projects = expand_keys(t)
  vim.api.nvim_create_autocmd({ "VimEnter", "BufReadPost", "LspAttach" }, {
    group = vim.api.nvim_create_augroup("projectconf", { clear = true }),
    callback = function()
      local cwd = vim.loop.cwd()
      for path, conf in pairs(projects) do
        if path == cwd then
          dispatch[type(conf)](conf)
        end
      end
    end
  })
end

return M
