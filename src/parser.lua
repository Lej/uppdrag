local Parser = LibStub("AceAddon-3.0"):GetAddon("Uppdrag"):NewModule("Parser")

function Parser:Parse(text)

  local root = { }
  local current = root
  local level = 1

  for line in string.gmatch(text, "[^\n]+") do

    local op, prefix, key, value = self:ParseLine(line)
    local prefixLength = prefix:len()

    if (prefixLength < level) then
      for i = 1, level - prefixLength do
        current = current.parent
      end
    elseif (prefixLength > level + 1) then
      error(prefixLength)
    end

    if (op == "set") then
      current[key] = value
    elseif (op == "child") then
      value.parent = current
      current[key] = value
      current = value
    elseif (op == "insert") then
      table.insert(current, value)
    end

    level = prefixLength
  end

  return root

end

function Parser:ParseLine(line)

  if (line == "+") then
    line = "+ " -- Copy paste from WoW loses trailing space
  end

  local _, _, prefix, key, value = string.find(line, "^(#+) ([a-zA-Z0-9]+): (.*)$")
  if (key) then
    return "set", prefix, key, value
  end

  local _, _, prefix, key = string.find(line, "^(#+) ([a-zA-Z0-9]+)$")
  if (key) then
    return "child", prefix, key, { }
  end

  local _, _, prefix, value = string.find(line, "^(#*+) (.*)$")
  if (value) then
    return "insert", prefix, nil, value
  end

  return nil
end
