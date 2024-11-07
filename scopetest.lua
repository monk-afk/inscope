--==[[ scopetest.lua ]]==--
--[[
    This script demonstrates the output provided by the InScope callback
]]

-- local inscope = require("inscope")
local IS = dofile("inscope.lua")

local function test_scope()
  -- closures with nested functions
  local function outer_scope()
    local outer_var = "outer value"
    
    local function inner_scope()
      local inner_var = "inner value"
      IS("Inside inner_scope function")
    end

    IS("Before calling inner_scope")
    inner_scope()
  end

  -- various data types
  local sample_table = {
    key1 = "val1",
    ["key 2"] = 42,
    nested = {
      "subval1", true, {nested_key = "deep"}
    }
  }
  local boolean_var = false
  local numeric_var = 123.456
  local string_var = "Hello, world in scope!"
  
  -- standard library in scope
  local io = io
  
  -- io operations as userdata
  local file_path = "/tmp/sample.txt"
  local file = io.open(file_path, "w+")
  file:write("Hello, file in scope!")
  file:close()

  -- comparing inscope calls
  IS("Before calling outer_scope")
  outer_scope()
  IS("After outer_scope call")

  -- dynamic label in a loop
  for i = 1, 3 do
    local loop_var = "Loop #" .. i
    IS("In loop " .. i)
  end

  IS("Last call in the block")
end

test_scope()
IS("End of script")