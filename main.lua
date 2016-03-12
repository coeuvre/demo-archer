local cgmath = require('cgmath')
local renderer = require('renderer')

local time = 0

local archer = {
  anim = {},

  current_anim,
  current_frame = 1,
}

local background = {}
local clouds = {
  {
    offset = 0,
  },
  {
    offset = 1080,
  }
}

function love.load()
  for i = 1, 6 do
    local texture = renderer.load_texture2('assets/layer-' .. i .. '.png')
    table.insert(background, texture)
  end

  local idle = {}
  for i = 1, 4 do
    local texture = renderer.load_texture2('assets/archer/idle' .. i .. '.png')
    local sprite = renderer.sprite_from_texture(texture, cgmath.bbox2(), cgmath.v2(48, 30))
    table.insert(idle, sprite)
  end
  archer.anim.idle = idle

  local shoot = {}
  for i = 1, 4 do
    local texture = renderer.load_texture2('assets/archer/shoot' .. i .. '.png')
    local sprite = renderer.sprite_from_texture(texture, cgmath.bbox2(), cgmath.v2(48, 30))
    table.insert(shoot, sprite)
  end
  archer.anim.shoot = shoot

  archer.current_anim = 'idle'
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.push('quit')
  end
end

function love.update(dt)
  time = time + dt

  clouds[1].offset = clouds[1].offset - 60 * dt
  clouds[2].offset = clouds[2].offset - 60 * dt

  if clouds[1].offset <= -1080 then
    clouds[1].offset = clouds[1].offset + 1080
    clouds[2].offset = clouds[2].offset + 1080
  end

  archer.current_frame = math.floor(4 * time) % #archer.anim[archer.current_anim] + 1
end

function love.draw()
  renderer.setup_coord()

  for i, texture in ipairs(background) do
    if i == 6 then
      renderer.draw_texture2(texture, cgmath.v2(clouds[1].offset, 0))
      renderer.draw_texture2(texture, cgmath.v2(clouds[2].offset, 0))
    else
      renderer.draw_texture2(texture, cgmath.v2(0, 0))
    end
  end

  renderer.draw_sprite(archer.anim[archer.current_anim][archer.current_frame], cgmath.v2(200, 75))
end
