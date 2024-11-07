ansi color reference sheet

```lua
-- Use this to test terminal color support:
local function colortest()
  local c = tonumber(arg[1]) or 8
  for m = 0, 128, c do
    for n = 1, c do
      local o = m + n
      io.stdout:write(
        string.format("\27[%dm[%d]\27[0m\t", o, o))
    end
    io.stdout:write("\n")
  end
end
colortest()
--

-- unset
local set   = "\27["
local unset = "\27[0m"
-- formatting
local clear  = "\27[2J" 
local blink  = "\27[5m" 
local bold   = "\27[1m" 
local faint  = "\27[2m" 
local italic = "\27[3m" 
local invert = "\27[7m" 
local strike = "\27[9m"
local under  = "\27[4m" 
local under2 = "\27[21m"
local over   = "\27[53m"
local nl     = "\n"
-- monochrome
local black  = "\27[30m"
local white  = "\27[29m"
local l_grey = "\27[37m"
local d_grey = "\27[90m"
-- dark colors
local d_red    = "\27[31m"
local d_green  = "\27[32m"
local d_yellow = "\27[33m"
local d_blue   = "\27[34m"
local d_mauve  = "\27[35m"
local d_cyan   = "\27[36m"
-- not dark colors
local red    = "\27[91m"
local green  = "\27[92m"
local yellow = "\27[93m"
local blue   = "\27[94m"
local mauve  = "\27[95m"
local cyan   = "\27[96m"
-- background colors
local bg_black  = "\27[40m"
local bg_grey   = "\27[47m"
local bg_smoke  = "\27[100m"
local bg_white  = "\27[107m"
local bg_red    = "\27[41m"
local bg_green  = "\27[42m"
local bg_orange = "\27[43m"
local bg_blue   = "\27[44m"
local bg_violet = "\27[45m"
local bg_cyan   = "\27[46m"
local bg_ruby    = "\27[101m"
local bg_lime    = "\27[102m"
local bg_banana  = "\27[103m"
local bg_ocean   = "\27[104m"
local bg_aqua    = "\27[105m"
local bg_magenta = "\27[106m"
```