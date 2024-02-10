local M = {}

local default = {
	sign_current_line = "🠊",
	sign_breakpoint = "⬤",
	debug = false,
}

function M.setup(opts)
	local config = vim.tbl_deep_extend("keep", opts or {}, default)
	for k, v in pairs(config) do
		M[k] = v
	end

	vim.fn.sign_define("GdbNvimCurrentLine", { text = config.sign_current_line })
	vim.fn.sign_define("GdbNvimBreakpoint", { text = config.sign_breakpoint })
end

return M
