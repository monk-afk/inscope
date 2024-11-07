--==[[=====================]]==--
--==[[ inScope © 2024 monk ]]==--
--==[[=====================]]==--

-- add it to $PATH or something
-- local IS = require("inscope")

  -- get command line arguments
local clip = {}

  -- assign the file name and path to -1 and 0
clip[0] = string.gsub(arg[0], "^([%w/]-/?)([%w%.]+)$",
  function(path, file)
    clip[file] = path -- makes key = val
    return file, path -- makes index[n]
  end)

  -- evaluate argumets after the file
for p = 1, #arg do
  clip[p] = string.gsub(arg[p], "%-*([%w-]+)=?([%s%S]*)",
    function(param, val)
      clip[param] = val == "" or tonumber(val) or val
      return param, val
    end)
end  -- https://github.com/monk-afk/various/blob/main/lua/clip.lua

if clip.help or clip.h or clip.inscope then
  io.stdout:write([[
  InScope version 0.0.1 - A function to view scope

  Usage: $ lua your_file.lua [OPTIONS][=VALUE]

  Command Line Arguments:
    --help, -h             Show the help message
    --no-prompt            Disable promt to continue callback. Default: Enabled
    --no-color             Disable ANSI color to stdout. Default: ANSI Enabled
    --log-file[=file.log]  Enable Logging. Default: Disabled or /tmp/inscope.log

  How to Integrate:
    1. Define the callback to view scopes with dofile or require:
          local IS = require("inscope") -- if in your system's PATH
          local IS = dofile("/path/to/inscope.lua") -- from anywhere

    2. Add callback anywhere to view it's scope:
          IS("optional label")

    3. Run the file as usual or in a terminal session.
        InScope pause the running file and print scoped variables at every callback.


  MIT License Copyright (c) 2024 monk (https://github.com/monk-afk/InScope)
  Attribution Copyright (C) 2010-2018 celeron55, Perttu Ahola <celeron55@gmail.com>

  InScope running from: ]]..arg[0], "\n"):flush()

  return
end  -- crashes out when help is used

local prompt = not clip["no-prompt"] and function()
  io.stdout:write("\nPress Enter to continue\n"):flush()
  while true do
    io.read("*line")
    break
  end
end or function() end


local color = not clip["no-color"] and function(output)
  local patterns = {
    -- sometimes the index is not colored
  [".*%s+)(%f[%w_].+)(%s=%s.+"] = "\27[33m",       -- keys 

    [".*)([^%p]true[^%p]?)(.*"] = "\27[96m",       -- bool true
   [".*)([^%p]false[^%p]?)(.*"] = "\27[95m",       -- bool false
     [".*)([^%p]nil[^%p]?)(.*"] = "\27[4m",        -- bool nil

         [".*<)(userdata)(:.*"] = "\27[36m",       -- userdata
        [".*%()(closed)(%)>.*"] = "\27[31m\27[4m", -- closed file
         [".*<)(function)(:.*"] = "\27[32m",       -- function
              [".*)(0x%x+)(.*"] = "\27[34m\27[4m", -- hexadecimal

          -- Opening line
           ["%[)(%d+%.%d+)(%]"] = "\27[40m\27[92m", -- Timestamp
        [".+ Step:%s)(%d+)(%s"] = "\27[31m",        -- Step: N
        [".+ line:%s)(%d+)(%s"] = "\27[32m",        -- line: N
             ["%s<)([%w_]+)(>"] = "\27[40m\27[92m", -- Block ID/name

        [".*\")([%S%s]+)(\".*"] = "\27[94m",       -- quoted strings
     ["%s+)([^.]%d+[^.])(,?%s"] = "\27[34m",       -- quoted strings
  }

  local unset_color = "\27[0m"
  for i = 1, #output do
    for pattern, set_color in pairs(patterns) do

      output[i] = string.gsub(output[i], "("..pattern..")",
        function(pretext, context, sutext)
          local context = context or ""
          return table.concat({pretext, set_color, context, unset_color, sutext})
        end)
    end
  end
  local output = table.concat(output, "\n")
  io.stdout:write("\n", output, "\n"):flush()
end or function(output)
  local output = table.concat(output, "\n")
  io.stdout:write("\n", output, "\n"):flush()
end


  -- option for writing to log file
local default_log = "/tmp/inscope_debug.log"
local log_file = clip["log-file"] == true and io.open(default_log, "a+") or
    type(clip["log-file"]) == "string" and io.open(clip["log-file"], "a+")

local write_log = log_file and function(output)
  log_file:write(table.concat(output, "\n"),"\n"):flush()
  return output
end or function() end

-- write to stdout and optionally /tmp/
local function send_output(output)
  write_log(output)
  color(output)
  prompt()
end


-- counter closure
local function stepcounter()
	local count = 0
	return function()
		count = count + 1
		return count
	end
end
local step = stepcounter()


-- pass each line through this for a step and timestamp
local function step_time(output)
	local current_step = step()
	local handle = io.popen("date +%H%M%S.%N")
	local timestamp = handle:read("*a"):gsub("\n", "")
	handle:close()

  local step_header = string.format("[%.04f] Step: %s %s", timestamp, current_step, output[1])
  output[1] = step_header

  return send_output(output)
end


-- ATTRIBUTION (full license in readme.md) -----------------------------------------
-- GNU LGPL 2.1 Copyright (C) 2010-2018 Perttu Ahola <celeron55@gmail.com>        --
------------------------------------------------------------------------------------
local string_sub, string_find = string.sub, string.find
local function basic_dump(o)
	local tp = type(o)
	if tp == "number" then
		return tostring(o)
	elseif tp == "string" then
		return string.format("%q", o)
	elseif tp == "boolean" then
		return tostring(o)
	elseif tp == "nil" then
		return "nil"
	elseif tp == "userdata" then
		return string.format("<%s: %s>", tp, tostring(o))
	elseif tp == "function" then
		return o  -- returned as-is to filter globals/env variables
	else
		return string.format("<%s>", tp)
	end
end

local function dump(o, indent, nested, level)
	local t = type(o)
  if t ~= "table" or t == "userdata" then
		return basic_dump(o)
	end

  nested = nested or {}
	if nested[o] then
		return "[[ circular ref ]]"
	end

	nested[o] = true
	indent = indent or "  "
	level = level or 2
	local ret = {}
	local dumped_indexes = {}

	for i, v in ipairs(o) do
		ret[#ret + 1] = dump(v, indent, nested, level + 1)
		dumped_indexes[i] = true
	end

	for k, v in pairs(o) do
		if not dumped_indexes[k] then

			if type(k) ~= "string" then
				k = "["..dump(k, indent, nested, level + 1).."]"
			end

      if type(o[k]) == "function" then
        v = string.format("<%s>", tostring(o[k]))
      end

			v = dump(v, indent, nested, level + 1)
			ret[#ret + 1] = k.." = "..v
		end
	end

	nested[o] = nil
	if indent ~= "" then
		local indent_open = "\n" .. string.rep(indent, level)
		local indent_close = "\n" .. string.rep(indent, level - 1)
		return string.format("{%s%s%s}", indent_open,
				table.concat(ret, "," .. indent_open), indent_close)
	end
	return "{"..table.concat(ret, ", ").."}"
end
------------------------------------------------------------------------------------
-- END OF ATTRIBUTION --------------------------------------------------------------
------------------------------------------------------------------------------------

-- get the scoped bindings
local function local_bindings(func)
	local function get_binds(level, bindings)
    local level = level or 1
    do local i = 1
      while true do
        local name, value = debug.getlocal(level, i)
        if not name then break end
        bindings[name] = value
        i = i + 1
      end
    end
    return bindings
  end

  local bindings = get_binds(4, {})
  for name, value in pairs(bindings) do
    if name ~= "_ENV" then -- ignore environment globals

      bindings[name] = dump(value)
    end
  end
	return bindings
end

local function inscope(label)
  local level = 2
  local debug_info = debug.getinfo(level)
  local current_line = debug_info.currentline
  local func = debug_info.func
  local name = debug_info.name or tostring(func)

  local output = {}
  output[1] = string.format("line: %s %s <%s>",
      current_line, label and "\""..label.."\"" or "", name)

  for k, v in pairs(local_bindings(func)) do
    if tostring(v) ~= tostring(inscope) then -- we're not debugging the debugger
      if type(v) == "function" then -- type returned from basic_dump
        output[#output + 1] = string.format("  %s = <%s>", k, tostring(v))
      else
        output[#output + 1] = string.format("  %s = %s", k, tostring(v))
      end
    end
  end
  step_time(output)
end

return inscope



--==[[================================================================================]]==--
--==[[ MIT License                                                                    ]]==--
--==[[                                                                                ]]==--
--==[[ Copyright (c) 2024  monk                                                       ]]==--
--==[[                                                                                ]]==--
--==[[ Permission is hereby granted, free of charge, to any person obtaining a copy   ]]==--
--==[[ of this software and associated documentation files (the "Software"), to deal  ]]==--
--==[[ in the Software without restriction, including without limitation the rights   ]]==--
--==[[ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      ]]==--
--==[[ copies of the Software, and to permit persons to whom the Software is          ]]==--
--==[[ furnished to do so, subject to the following conditions:                       ]]==--
--==[[                                                                                ]]==--
--==[[ The above copyright notice and this permission notice shall be included in all ]]==--
--==[[ copies or substantial portions of the Software.                                ]]==--
--==[[                                                                                ]]==--
--==[[ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     ]]==--
--==[[ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       ]]==--
--==[[ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    ]]==--
--==[[ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         ]]==--
--==[[ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  ]]==--
--==[[ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  ]]==--
--==[[ SOFTWARE.                                                                      ]]==--
--==[[================================================================================]]==--
