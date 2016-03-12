local cgmath = require('cgmath')

local _M = {}

function _M.load_texture2(filename)
  local image = love.graphics.newImage(filename)

  local result = {
    image = image,
    width = image:getWidth(),
    height = image:getHeight(),
  }

  return result
end

function _M.sprite_from_texture(texture, bbox, anchor)
  local result = { texture = texture, bbox = bbox, anchor = anchor }

  local size = cgmath.get_bbox2_size(bbox)
  if size.x == 0 then
    size.x = texture.width
  end

  if size.y == 0 then
    size.y = texture.height
  end

  result.bbox = cgmath.bbox2_min_size(bbox.min, size)

  return result
end

function _M.setup_coord()
  love.graphics.scale(1, -1)
  love.graphics.translate(0, -love.graphics.getHeight())
end

function _M.draw_texture2(texture, pos)
  love.graphics.draw(texture.image, pos.x, pos.y + texture.height, 0, 1, -1)
end

function _M.draw_sprite(sprite, pos)
  local pos = pos - sprite.anchor
  love.graphics.draw(sprite.texture.image, pos.x, pos.y + sprite.texture.height, 0, 1, -1)
end

return _M
