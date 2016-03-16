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
  love.graphics.push()

  love.graphics.translate(0, texture.height)
  love.graphics.scale(1, -1)

  love.graphics.draw(texture.image, pos.x, pos.y)

  love.graphics.pop()
end

function _M.draw_sprite(sprite, pos, sx)
  love.graphics.push()

  love.graphics.draw(sprite.texture.image, pos.x, pos.y + sprite.texture.height,
                     0, sx, -1, sprite.anchor.x, -sprite.anchor.y)

  love.graphics.pop()
end

return _M
