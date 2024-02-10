local M = require("gdb.parse")
local expect = MiniTest.expect

describe("result", function()
	it("done", function()
		expect.equality(M.parse("^done\n(gdb)\n"),
			{
				out_of_band_records = {},
				result_record = { token = "", class = "done" }
			})
	end)

	it("running", function()
		expect.equality(M.parse('^running\n(gdb)\n'),
			{
				out_of_band_records = {},
				result_record = { token = "", class = "running" }
			})
	end)

	it("connected", function()
		expect.equality(M.parse('^connected\n(gdb)\n'),
			{
				out_of_band_records = {},
				result_record = { token = "", class = "connected" }
			})
	end)

	it("error", function()
		expect.equality(M.parse('^error\n(gdb)\n'),
			{
				out_of_band_records = {},
				result_record = { token = "", class = "error" }
			})
	end)

	it("exit", function()
		expect.equality(M.parse('^exit\n(gdb)\n'),
			{
				out_of_band_records = {},
				result_record = { token = "", class = "exit" }
			})
	end)
end)

describe("stream", function()
	it("console", function()
		expect.equality(M.parse('~"message"\n(gdb)\n'),
			{
				out_of_band_records = { { type = "console", msg = "message" } },
				result_record = {}
			})
	end)

	it("target", function()
		expect.equality(M.parse('@"message"\n(gdb)\n'),
			{
				out_of_band_records = { { type = "target", msg = "message" } },
				result_record = {},
			})
	end)

	it("log", function()
		expect.equality(M.parse('&"message"\n(gdb)\n'),
			{
				out_of_band_records = { { type = "log", msg = "message" } },
				result_record = {},
			})
	end)
end)

describe("async", function()
	it("running", function()
		expect.equality(M.parse('*running,thread-id="thread"\n(gdb)\n'),
			{
				out_of_band_records = { { token = "", class = "running", type = "exec", result = { ["thread-id"] = "thread" } } },
				result_record = {}
			})
	end)

	it("stopped", function()
		expect.equality(
			M.parse('*stopped,reason="reason",thread-id="id",stopped-threads="stopped",core="core"\n(gdb)\n'),
			{
				out_of_band_records = { {
					token = "",
					class = "stopped",
					type = "exec",
					result = {
						reason = "reason",
						["thread-id"] = "id",
						["stopped-threads"] = "stopped",
						core = "core"
					}
				} },
				result_record = {}
			})
	end)

	it("thread group added", function()
		expect.equality(M.parse('=thread-group-added,id="id"\n(gdb)\n'),
			{
				out_of_band_records = { { token = "", class = "thread-group-added", type = "notify", result = { id = "id" } } },
				result_record = {}
			})
	end)

	it("thread group removed", function()
		expect.equality(M.parse('=thread-group-removed,id="id"\n(gdb)\n'),
			{
				out_of_band_records = { { token = "", class = "thread-group-removed", type = "notify", result = { id = "id" } } },
				result_record = {}
			})
	end)

	it("thread group started", function()
		expect.equality(M.parse('=thread-group-started,id="id",pid="pid"\n(gdb)\n'),
			{
				out_of_band_records = { {
					token = "",
					class = "thread-group-started",
					type = "notify",
					result = { id = "id", pid = "pid" }
				} },
				result_record       = {}
			})
	end)

	it("thread group exited", function()
		expect.equality(M.parse('=thread-group-exited,id="id"[,exit-code="code"]\n(gdb)\n'),
			{
				out_of_band_records = { {
					token = "",
					class = "thread-group-exited",
					type = "notify",
					result = { id = "id", ["exit-code"] = "code" }
				} },
				result_record = {}
			})
	end)

	it("thread created", function()
		expect.equality(M.parse('=thread-created,id="id",group-id="gid"\n(gdb)\n'),
			{
				out_of_band_records = { {
					token = "",
					class = "thread-created",
					type = "notify",
					result = { id = "id", ["group-id"] = "gid" }
				} },
				result_record = {}
			})
	end)

	it("thread exited", function()
		expect.equality(M.parse('=thread-exited,id="id",group-id="gid"\n(gdb)\n'),
			{
				out_of_band_records = { {
					token = "",
					class = "thread-exited",
					type = "notify",
					result = { id = "id", ["group-id"] = "gid" }
				} },
				result_record = {}
			})
	end)
	it("thread selected", function()
		expect.equality(M.parse('=thread-selected,id="id"[,frame="frame"]\n(gdb)\n'),
			{
				out_of_band_records = { { token = "", class = "thread-selected", type = "notify", result = { id = "id", frame = "frame" } } },
				result_record = {}
			})
	end)

	it("library loaded", function()
		expect.equality(
			M.parse(
				'=library-loaded,id="id",target-name="target",host-name="host",symbols-loaded="0",thread-group="i1",ranges=[{from="0xABC",to="0xDEF"}]\n(gdb)\n'),
			{
				out_of_band_records = { {
					token = "",
					class = "library-loaded",
					type = "notify",
					result = {
						id = "id",
						["target-name"] = "target",
						["host-name"] = "host",
						["symbols-loaded"] = "0",
						["thread-group"] = "i1",
						ranges = { { from = "0xABC", to = "0xDEF" } }
					}
				} },
				result_record = {}
			})
	end)

	it("library unloaded", function()
		expect.equality(M.parse('=library-unloaded,id="id",target-name="target",host-name="host"\n(gdb)\n'),
			{
				out_of_band_records = { {
					token = "",
					class = "library-unloaded",
					type = "notify",
					result = { id = "id", ["target-name"] = "target", ["host-name"] = "host" }
				} },
				result_record = {}
			})
	end)


	it("traceframe changed", function()
		expect.equality(M.parse('=traceframe-changed,num="0",tracepoint="0"\n(gdb)\n'),
			{
				out_of_band_records = { {
					token = "",
					class = "traceframe-changed",
					type = "notify",
					result = { num = "0", tracepoint = "0" }
				} },
				result_record = {}
			}
		)
	end)

	it("traceframe changed end", function()
		expect.equality(M.parse('=traceframe-changed,end\n(gdb)\n'),
			{
				out_of_band_records = { { token = "", class = "traceframe-changed", type = "notify", result = {} } },
				result_record = {}
			})
	end)

	it("trace state variable created", function()
		expect.equality(M.parse('=tsv-created,name="name",initial="initial"\n(gdb)\n'),
			{
				out_of_band_records = { {
					token = "",
					class = "tsv-created",
					type = "notify",
					result = { name = "name", initial = "initial" }
				} },
				result_record = {}
			})
	end)

	it("trace state variable deleted with name", function()
		expect.equality(M.parse('=tsv-deleted,name="name"\n(gdb)\n'),
			{
				out_of_band_records = { { token = "", class = "tsv-deleted", type = "notify", result = { name = "name" } } },
				result_record = {}
			})
	end)

	it("trace state variable deleted", function()
		expect.equality(M.parse('=tsv-deleted\n(gdb)\n'),
			{
				out_of_band_records = { { token = "", class = "tsv-deleted", type = "notify", result = {} } },
				result_record = {}
			})
	end)

	it("trace state varaible modified", function()
		expect.equality(M.parse('=tsv-modified,name="name",initial="initial"[,current="current"]\n(gdb)\n'),
			{
				out_of_band_records = {
					{
						token = "",
						class = "tsv-modified",
						type = "notify",
						result = { name = "name", initial = "initial", current = "current" }
					} },
				result_record = {}
			})
	end)

	it("breakpoint created", function()
		expect.equality(M.parse('=breakpoint-created,bkpt={}\n(gdb)\n'),
			{
				out_of_band_records = { { token = "", class = "breakpoint-created", type = "notify", result = { bkpt = {} } } },
				result_record = {}
			})
	end)

	it("breakpoint modified", function()
		expect.equality(M.parse('=breakpoint-modified,bkpt={}\n(gdb)\n'),
			{
				out_of_band_records = { { token = "", class = "breakpoint-modified", type = "notify", result = { bkpt = {} } } },
				result_record = {}
			})
	end)

	it("breakpoint deleted", function()
		expect.equality(M.parse('=breakpoint-deleted,id="0"\n(gdb)\n'),
			{
				out_of_band_records = { { token = "", class = "breakpoint-deleted", type = "notify", result = { id = "0" } } },
				result_record = {}
			})
	end)

	it("record started", function()
		expect.equality(M.parse('=record-started,thread-group="id",method="method"[,format="format"]\n(gdb)\n'),
			{
				out_of_band_records =
				{ {
					token = "",
					class = "record-started",
					type = "notify",
					result = { ["thread-group"] = "id", method = "method", format = "format" }
				} },
				result_record = {}
			})
	end)

	it("record stopped", function()
		expect.equality(M.parse('=record-stopped,thread-group="id"\n(gdb)\n'),
			{
				out_of_band_records = { { token = "", class = "record-stopped", type = "notify", result = { ["thread-group"] = "id" } } },
				result_record = {}
			})
	end)

	it("parameter changed", function()
		expect.equality(M.parse('=cmd-param-changed,param="param",value="value"\n(gdb)\n'),
			{
				out_of_band_records =
				{ {
					token = "",
					class = "cmd-param-changed",
					type = "notify",
					result = { param = "param", value = "value" }
				} },
				result_record = {}
			})
	end)

	it("memory changed", function()
		expect.equality(M.parse('=memory-changed,thread-group="id",addr="addr",len="0"[,type="code"]\n(gdb)\n'),
			{
				out_of_band_records = {
					{
						token = "",
						class = "memory-changed",
						type = "notify",
						result = { ["thread-group"] = "id", addr = "addr", len = "0", type = "code" }
					} },
				result_record = {}
			})
	end)
end)
