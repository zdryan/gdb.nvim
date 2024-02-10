local M = { _pipe = nil, _handle = nil, _pty = nil, _cursors = { current_line = nil, breakpoints = {} } }

local cursor = require("gdb.cursor")
local parser = require("gdb.parse")
local config = require("gdb.config")
local uv = vim.version().minor >= 10 and vim.uv or vim.loop

local function get_program_execution(record)
	local retval = { line = nil, fullname = nil, stopped = false }
	if record.out_of_band_records then
		for _, oob in ipairs(record.out_of_band_records) do
			if oob.class == "stopped" then
				retval.stopped = true
				if oob.result and oob.result.frame and oob.result.frame.fullname then
					retval.line = oob.result.frame.line
					retval.fullname = oob.result.frame.fullname
				end
			end
		end
	end
	if record.result_record and record.result_record.result then
		local class = record.result_record.class
		local frame = record.result_record.result.frame
		if class == "done" and frame and frame.line and frame.fullname then
			retval.line = frame.line
			retval.fullname = frame.fullname
		end
	end
	return retval
end

function M.setup(opts)
	if vim.fn.executable('socat') == 0 then
		print('gdb.nvim: socat not in path. Aborting setup')
		return
	end

	config.setup(opts)

	-- GdbStart user command
	vim.api.nvim_create_user_command("GdbStart", function(a)
		M._cursors.current_line = cursor:new("GdbNvimCurrentLine")

		local pid = vim.fn.getpid()
		M._pipe = uv.new_pipe(false)
		local log = config.debug and io.open("/tmp/gdb_nvim_log_" .. pid .. ".txt", "w") or nil
		local buffer = ""

		M._pipe:bind("/tmp/gdb_nvim_sock_" .. pid)
		M._pipe:listen(128, function()
			local client = uv.new_pipe(false)
			M._pipe:accept(client)
			client:read_start(function(err, chunk)
				assert(not err, err)
				if chunk then
					buffer = buffer .. chunk
					local record, read = parser.parse(buffer)
					if record then
						buffer = buffer:sub(read)
						local exec = get_program_execution(record)
						if exec.line and exec.fullname then
							vim.schedule(function()
								M._cursors.current_line:place(exec.fullname, exec.line,
									true)
							end)
						elseif exec.stopped then
							client:write(parser.ignore_token .. "-stack-info-frame\n")
						end

						if log then
							log:write(vim.inspect(record))
							log:flush()
						end
					end
				else
					client:shutdown()
					client:close()
				end
			end)
		end)

		M._pty = a.args or ("/tmp/gdb_nvim_pty_" .. pid)
		local handle, _ = uv.spawn("socat", {
			args = { "PTY,wait-slave,pty-interval=0.1,link=" .. M._pty,
				"UNIX-CONNECT:/tmp/gdb_nvim_sock_" .. pid },
		})
		M._handle = handle
		print("[gdb.nvim] Enter in gdb console: 'new-ui mi '" .. M._pty .. "'")
	end, {
		desc = "Start nvim gdb",
		force = true,
		nargs = "?",
	})

	-- GdbStop user command
	vim.api.nvim_create_user_command("GdbStop", function()
		if M._handle and not M._handle:is_closing() then
			M._handle:close()
		end
		if M._pipe and not M._pipe:is_closing() then
			M._pipe:close()
		end
		local pid = vim.fn.getpid()
		vim.uv.fs_unlink(M._pty)
		vim.uv.fs_unlink("/tmp/gdb_nvim_log_" .. pid .. ".txt")
		M._cursors.current_line:unplace()
	end, {
		desc = "Stop nvim gdb",
		force = true,
	})
end

return M
