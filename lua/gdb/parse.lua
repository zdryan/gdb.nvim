local M = { ignore_token = "000" }

local parse_results
local parse_result_value

local function parse_result_array(s)
	assert(s:byte(1) == string.byte("["))

	local retval = {}
	s = s:sub(2)

	while s ~= nil and s:len() > 0 do
		local c = s:byte(1)

		if c == string.byte(",") then
			s = s:sub(2)
		elseif c == string.byte("]") then
			s = s:sub(2)
			break
		else
			local value, remaining = parse_result_value(s)
			table.insert(retval, value)
			s = remaining
		end
	end

	return retval, s
end

local function parse_result_const(s)
	assert(s:byte(1) == string.byte("\""))

	return s:match([["([^"]*)"(.*)]])
end

parse_result_value = function(s)
	local c = s:byte(1)
	if c == string.byte("{") then
		return parse_results(s)
	elseif c == string.byte("[") then
		return parse_result_array(s)
	elseif c == string.byte("\"") then
		return parse_result_const(s)
	else
		return nil
	end
end

parse_results = function(s)
	local retval = {}

	while s ~= nil and s:len() > 0 do
		local c = s:byte(1)

		if c == string.byte("{") or c == string.byte(",") or c == string.byte("[") or c == string.byte("]") then
			s = s:sub(2)
		elseif c == string.byte("}") then
			break
		else
			local variable, var_remaining = s:match([[([%l%-]+)=(.*)]])
			if not variable then
				return nil
			end
			local value, val_remaining = parse_result_value(var_remaining)
			if not value then
				return nil
			end
			retval[variable] = value
			s = val_remaining
		end
	end

	return retval
end

local function parse_result_record(output)
	local retval = {}
	local token, class, result = string.match(output, [[(%d*)[%^]([%l]+)(.*)]])
	if token then
		retval.token = token
		retval.class = class
		if result:len() > 0 then
			retval.result = parse_results(result:sub(2))
			if not retval.result then
				return nil
			end
		end
		return retval, token:len() + class:len() + result:len() + 2
	end
	return nil
end

local function parse_stream_record(output)
	local delim, message = string.match(output, [[([~@&])"([^"]*)"]])
	if delim then
		local retval = { msg = message }
		if delim == "~" then
			retval.type = "console"
		elseif delim == "@" then
			retval.type = "target"
		else
			retval.type = "log"
		end
		return retval, delim:len() + message:len() + 3
	end
	return nil
end

local function parse_async_record(output)
	local token, delim, class, result = string.match(output, [[(%d*)([*+=])([%l%-]+)(.*)]])
	if token then
		local retval = { token = token, class = class, result = {} }
		-- explicitly handle "-traceframe-change,end"
		if result:len() > 0 and result:sub(2) ~= "end" then
			retval.result = parse_results(result:sub(2))
			if not retval.result then
				return nil
			end
		end

		if delim == "*" then
			retval.type = "exec"
		elseif delim == "+" then
			retval.type = "status"
		else
			retval.type = "notify"
		end
		return retval, token:len() + delim:len() + class:len() + result:len() + 1
	end
	return nil
end


local function parse_out_of_band_record(data)
	local async, async_read = parse_async_record(data)

	if async then
		return async, async_read
	end

	local stream, stream_read = parse_stream_record(data)
	if stream then
		return stream, stream_read
	end

	return nil
end

function M.parse(data)
	if data:sub(-1) ~= "\n" then
		return nil
	end

	local retval = { out_of_band_records = {}, result_record = {} }
	local read = 0
	for s in data:gmatch("[^\n]+") do
		local norm, count = string.gsub(s, "\r", "")
		read = read + count + 1

		-- empty string
		if norm == "" then
			goto continue
		end

		-- ignore echoed input commands
		if string.match(norm, "^" .. M.ignore_token .. "%-") then
			read = read + s:len()
			goto continue
		end

		-- end of output delimiter
		local delim = string.match(norm, "%(gdb%)%s*")
		if delim then
			read = read + delim:len()
			goto continue
		end

		-- out of band records
		local oob, oob_read = parse_out_of_band_record(norm)
		if oob then
			read = read + oob_read
			table.insert(retval.out_of_band_records, oob)
			goto continue
		end

		--result record
		local result, result_read = parse_result_record(norm)
		if result then
			retval.result_record = result
			read = read + result_read
			goto continue
		end

		if not oob and not result and not delim then
			return nil
		end

		::continue::
	end

	return retval, read
end

return M
