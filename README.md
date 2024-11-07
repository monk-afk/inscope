```lua
--==[[=========================]]==--
--==[[ InScope           0.0.1 ]]==--
--==[[ Copyright (c) 2024 monk ]]==--
--==[[ License: MIT            ]]==--
--==[[ Attribution: GPL2.1     ]]==--
--==[[=========================]]==--

  This tool is basically a breakpoint callback which
  pauses the program and captures the state of variables
  in the current scope of that specific execution point.

___

  Usage: $ lua your_file.lua [OPTIONS][=VALUE]

  Command Line Arguments:
    --help, -h             Show the help message
    --no-prompt            Disable promt to continue callback. Default: Enabled
    --no-color             Disable ANSI color to stdout. Default: ANSI Enabled
    --log-file[=file.log]  Enable Logging. Default: Disabled or /tmp/inscope.log
___

  How to Integrate:
    1. Define the callback to view scopes with dofile or require:
          local IS = require("inscope") -- if in your system's PATH
          local IS = dofile("/path/to/inscope.lua") -- from anywhere

    2. Add callback anywhere to view its scope:
          IS("optional label")

    3. Run the file as usual or in a terminal session.
        InScope pause the running file and print scoped variables at every callback.
___

  Output Details:
    Every breakpoint callback will print a line starting with:

    (1)           (2)     (3)      (4)           (5)
    [100726.0154] Step: 2 line: 55 "in for loop" <process_func>

    1) Timestamp is formatted: HHMMSS.ms
    2) Step is the breaking point counter in order of execution
    3) line is the actual line number of the callback in the file
    4) "Quoted String" is the optional label as callback argument
    5) <function_name> name of function containing the breaking point
        - temporary functions will show as <function: 0x...>

    - Strings are quoted "double quote"
    - Functions are closed in <angle_brackets>
    - Userdata are closed in <angle_brackets>, and their state in (round_brackets)
    - Numbers and booleans are unquoted
    - Hexadecimal is underlined (if color is not disabled)
    - Tables are shown nested, with or without associated key
___

  Pattern Matching for ANSI Colors:

    The pattern assembly, if you add patterns of your own:
      ["patterns before)(the pattern to color)(patterns after"] = "\27[32m"
      Starts with unmatched closing capture ),
      followed by the closed capture (), then an unclosed open capture (
    This was to allow gsub without screwing the output:
      string.gsub(output, "("..pattern..")", function(pretext, context, sutext) ...
    As you see, the pattern section of the gsub will close the unclosed brackets, and also
    provide the captures as the variables of gsub's functional replacement.

___

  Limitations:
    - Unlimited table recursion may be undesireable in some cases
    - Specific application for debugging accessible scope values
    - Pattern matching for ANSI Color can be tricky

___

--==================================================================================--
--= MIT License                                                                    =--
--=                                                                                =--
--= Copyright (c) 2024  monk                                                       =--
--=                                                                                =--
--= Permission is hereby granted, free of charge, to any person obtaining a copy   =--
--= of this software and associated documentation files (the "Software"), to deal  =--
--= in the Software without restriction, including without limitation the rights   =--
--= to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      =--
--= copies of the Software, and to permit persons to whom the Software is          =--
--= furnished to do so, subject to the following conditions:                       =--
--=                                                                                =--
--= The above copyright notice and this permission notice shall be included in all =--
--= copies or substantial portions of the Software.                                =--
--=                                                                                =--
--= THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     =--
--= IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       =--
--= FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    =--
--= AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         =--
--= LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  =--
--= OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  =--
--= SOFTWARE.                                                                      =--
--==================================================================================--


Functions used under licence from Minetest core/builtin library:
  function basic_dump(o)
  function dump(o, indent, nested, level)
------------------------------------------------------------------------------------
-- Minetest                                                                       --
-- Copyright (C) 2010-2018 celeron55, Perttu Ahola <celeron55@gmail.com>          --
--                                                                                --
-- This program is free software; you can redistribute it and/or modify           --
-- it under the terms of the GNU Lesser General Public License as published by    --
-- the Free Software Foundation; either version 2.1 of the License, or            --
-- (at your option) any later version.                                            --
--                                                                                --
-- This program is distributed in the hope that it will be useful,                --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of                 --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                  --
-- GNU Lesser General Public License for more details.                            --
--                                                                                --
-- You should have received a copy of the GNU Lesser General Public License along --
-- with this program; if not, write to the Free Software Foundation, Inc.,        --
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.                    --
------------------------------------------------------------------------------------

```

I know this is not proper markdown format