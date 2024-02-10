local Cursor = {}
Cursor.__index = Cursor

local cursors = 0

function Cursor:new(name)
	cursors = cursors + 1
	return setmetatable({ buf = nil, lnum = nil, id = cursors, name = name }, self)
end

function Cursor:place(bufname, lnum, focus)
	local buf = vim.fn.bufnr(bufname, true)
	if self.buf and vim.api.nvim_buf_is_loaded(self.buf) then
		vim.fn.sign_unplace("GdbNvim", { id = self.id, buffer = self.buf })
	end
	if focus then
		local win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(win, buf)
		vim.api.nvim_win_set_cursor(0, { tonumber(lnum), 0 })
	end
	vim.fn.sign_place(self.id, "GdbNvim", self.name, buf, { lnum = lnum })
	self.buf = buf
	self.lnum = lnum
end

function Cursor:unplace()
	if self.buf and vim.api.nvim_buf_is_loaded(self.buf) then
		vim.fn.sign_unplace("GdbNvim", { id = self.id, buffer = self.buf })
	end
	self.buf = nil
	self.lnum = nil
end

return Cursor
