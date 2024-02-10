local expect = MiniTest.expect

describe("gdb", function()
	local child, job_id

	setup(function()
		child = MiniTest.new_child_neovim()
		child.restart({ '-u', 'scripts/minimal_init.lua' })
		child.bo.readonly = false
		child.o.laststatus = 0 -- prevent statusline
		child.lua([[M = require('gdb').setup({debug = true})]])
		child.api.nvim_command("GdbStart /tmp/gdb_nvim_pty")
		expect.no_equality(vim.uv.fs_stat("/tmp/gdb_nvim_log_" .. child.fn.getpid() .. ".txt"), nil)
		os.execute("sleep " .. 1) -- wait for pty creation
		expect.no_equality(vim.uv.fs_stat("/tmp/gdb_nvim_pty"), nil)
		job_id = vim.fn.jobstart("gdb -q tests/src/test")
		vim.fn.chansend(job_id, "new-ui mi /tmp/gdb_nvim_pty\n")
	end)

	before_each(function()
		vim.fn.chansend(job_id, "start\n")
		vim.fn.jobwait({ job_id }, 1000)
	end)

	it("step", function()
		vim.fn.chansend(job_id, "step\n")
		vim.fn.jobwait({ job_id }, 1000)
		expect.reference_screenshot(child.get_screenshot())
	end)

	it("next", function()
		vim.fn.chansend(job_id, "next\n")
		vim.fn.jobwait({ job_id }, 1000)
		expect.reference_screenshot(child.get_screenshot())
	end)

	it("stop", function()
		child.api.nvim_command("GdbStop")
		expect.equality(vim.uv.fs_stat("/tmp/gdb_nvim_log_" .. child.fn.getpid() .. ".txt"), nil)
		expect.equality(vim.uv.fs_stat("/tmp/gdb_nvim_pty"), nil)
	end)
end)
