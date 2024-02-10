local expect = MiniTest.expect

describe("cursor", function()
	local child

	before_each(function()
		child = MiniTest.new_child_neovim()
		child.restart({ '-u', 'scripts/minimal_init.lua' })
		child.bo.readonly = false
		child.o.laststatus = 0 -- prevent statusline (path agnostic)
		child.fn.sign_define("TestCurrentLine", { text = "🠊" })
		child.fn.sign_define("TestBreakpoint", { text = "⬤" })
	end)

	it("place sign", function()
		child.lua([[
		cursor = require('gdb.cursor')
		local buf = vim.fn.bufnr("tests/src/test.hpp", true)
		vim.api.nvim_command("noswap e tests/src/test.hpp")

		local line = cursor:new("TestCurrentLine")
		local break1 = cursor:new("TestBreakpoint")
		local break2 = cursor:new("TestBreakpoint")

		line:place(buf, 1)
		break1:place(buf, 2)
		break2:place(buf, 3)
		]])
		os.execute("sleep " .. 1)
		expect.reference_screenshot(child.get_screenshot())
	end)

	it("unplace sign", function()
		child.lua([[
		cursor = require('gdb.cursor')
		local buf = vim.fn.bufnr("tests/src/test.hpp", true)
		vim.api.nvim_command("noswap e tests/src/test.hpp")

		local line = cursor:new("TestCurrentLine")
		local break1 = cursor:new("TestBreakpoint")
		local break2 = cursor:new("TestBreakpoint")

		line:place(buf, 1)
		line:unplace()
		break1:place(buf, 2)
		break1:unplace()
		break2:place(buf, 3)
		break2:unplace()
		]])
		os.execute("sleep " .. 1)
		expect.reference_screenshot(child.get_screenshot())
	end)

	it("unplace unplaced sign", function()
		child.lua([[
		cursor = require('gdb.cursor')
		local buf = vim.fn.bufnr("tests/src/test.hpp", true)
		vim.api.nvim_command("noswap e tests/src/test.hpp")

		local line = cursor:new("TestCurrentLine")
		local break1 = cursor:new("TestBreakpoint")
		local break2 = cursor:new("TestBreakpoint")

		line:unplace()
		break1:unplace()
		break2:unplace()
		]])
		os.execute("sleep " .. 1)
		expect.reference_screenshot(child.get_screenshot())
	end)
end)
