--[[

function Uppdrag:Serialize(...)
  local args = {...}
  local output = { }
  for i, v in ipairs(args) do
     local prettyKey = "[" .. tostring(i) .. "]"
     table.insert(output, prettyKey .. " = ")
     SerializeRecursive(v, 0, { }, prettyKey, output)
     if (i < #args) then
        table.insert(output, ",\n")
     end
  end
  return table.concat(output, "");
end

function Uppdrag:SerializeRecursive(variable, level, paths, path, output)

  local function Append(output, ...)
     local text = ""
     local args = {...}
     for i, v in ipairs(args) do
        text = text .. tostring(v)
     end
     table.insert(output, text)
  end

  local function Quote(variable)
     if (type(variable) == "string") then
        return "\"" .. variable .. "\""
     end
     return variable
  end

  local function Indent(level)
     return string.rep(' ', level)
  end

  local function GetOrAddPath(paths, curPath, curTable)
     local prevPath = paths[curTable]
     if (prevPath == nil) then
        paths[curTable] = curPath
     end
     return prevPath
  end

  local variableType = type(variable)

  if (variableType == "function") then
     Append(output, "<function>")
  elseif (variableType == "boolean" or variableType == "number" or variableType == "string") then
     Append(output, Quote(variable))
  elseif (variableType == "table") then

     local prevPath = GetOrAddPath(paths, path, variable)

     if (prevPath ~= nil) then
        Append(output, prevPath)
     else
        Append(output, "{\n")
        local key = next(variable, nil)
        while (key ~= nil) do

           local prettyKey = "[" .. Quote(key) .. "]"
           Append(output, Indent(level + 1), prettyKey ," = ")

           local value = variable[key]
           local nextPath = path .. "." .. prettyKey
           SerializeRecursive(value, level + 1, paths, nextPath, output)

           local nextKey = next(variable, key)
           if (nextKey ~= nil) then
              Append(output, ",\n")
           end

           key = nextKey
        end
        Append(output, "\n", Indent(level), "}")
     end
  end
end

local y = {
  ["1"] = 2,
  ["c"] =  "d",
  ["flork"] = {
     [1] = "a",
     [2] = "b"
  }
}

local x = {
  ["d"] = {
     [1] = y,
     [2] = y
  },
  ["b"] = y,
  [1] = function(x) return 1 end
}

print("---")
local text = Serialize(x, y)

print(text)

]]