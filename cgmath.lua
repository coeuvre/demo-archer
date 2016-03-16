local _M = {}

local v2 = {}

local function is_v2(v)
  return type(v) == 'table' and type(v.x) == 'number' and type(v.y) == 'number'
end

function v2.__add(a, b)
  return _M.v2(a.x + b.x, a.y + b.y)
end

function v2.__sub(a, b)
  return _M.v2(a.x - b.x, a.y - b.y)
end

function v2.__mul(a, b)
  if type(a) == "number" then
    return _M.v2(a * b.x, a * b.y)
  else
    return _M.v2(a.x * b, a.y * b)
  end
end

function _M.v2(x, y)
  local result = setmetatable({ x = x or 0, y = y or 0 }, v2)

  return result
end

function _M.bbox2(min, max)
  local result = { min = min or _M.v2(), max = max or _M.v2() }

  return result
end

function _M.bbox2_min_size(min, size)
  local result = _M.bbox2(min, min + size)

  return result
end

function _M.get_bbox2_size(bbox)
  local result = bbox.max - bbox.min

  return result
end

return _M
