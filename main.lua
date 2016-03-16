local cgmath = require('cgmath')
local renderer = require('renderer')

local time = 0

local archer_walk_speed = 2000
local archer_run_speed = 5000

local ARCHER_FACING_LEFT = 1
local ARCHER_FACING_RIGHT = -1
local ARCHER_BRAKE_TIME_THRESHOLD = 0.2
local archer = {
  state = "idle",

  acc = cgmath.v2(),
  vel = cgmath.v2(),
  pos = cgmath.v2(490, 75),

  facing = 1,

  time_in_state_run = 0,

  anims = {},
  current_anim,
  current_frame = 1,
  current_anim_finished = false,
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

function load_archer_anim(name, from, to, fps, loop)
  if loop == nil then
    loop = true
  end

  local anim = {
    frames = {},
    loop = loop,
    fps = fps,
  }

  for i = from, to do
    local texture = renderer.load_texture2('assets/archer/' .. name .. i .. '.png')
    local sprite = renderer.sprite_from_texture(texture, cgmath.bbox2(), cgmath.v2(48, 30))
    table.insert(anim.frames, sprite)
  end

  return anim
end

function love.load()
  for i = 1, 6 do
    local texture = renderer.load_texture2('assets/layer-' .. i .. '.png')
    table.insert(background, texture)
  end

  archer.anims.idle = load_archer_anim('idle', 1, 4, 4)
  archer.anims.walk = load_archer_anim('walk', 1, 4, 6)
  archer.anims.run = load_archer_anim('run', 1, 4, 10)
  archer.anims.charge = load_archer_anim('shoot', 1, 2, 6, false)
  archer.anims.shoot = load_archer_anim('shoot', 3, 5, 8, false)
  archer.anims.charge_up = load_archer_anim('shoot-up', 1, 1, 0, false)
  archer.anims.shoot_up = load_archer_anim('shoot-up', 2, 4, 8, false)
  archer.anims.brake = load_archer_anim('brake', 1, 1, 0)

  archer.current_anim = 'idle'
end

function love.keypressed(key)
  if key == 'escape' then
    love.event.push('quit')
  end
end

function change_archer_anim_to(archer, anim, frame)
  frame = frame or 1
  if archer.current_anim ~= anim then
    archer.current_frame = frame
    archer.current_anim_finished = false
  end
  archer.current_anim = anim
end

function change_archer_state_to_idle(archer)
  archer.state = 'idle'
  archer.acc = cgmath.v2(0, 0)
  archer.vel = cgmath.v2(0, 0)
  change_archer_anim_to(archer, 'idle')
end

function change_archer_state_to_walk(archer, facing)
  local facing = facing or archer.facing

  archer.facing = facing
  archer.state = 'walk'
  archer.acc = cgmath.v2(archer.facing * archer_walk_speed, 0)
  change_archer_anim_to(archer, 'walk')
end

function change_archer_state_to_run(archer, facing)
  local facing = facing or archer.facing

  archer.facing = facing
  archer.state = 'run'
  archer.acc = cgmath.v2(archer.facing * archer_run_speed, 0)
  change_archer_anim_to(archer, 'run')
end

function change_archer_state_to_brake(archer)
  archer.state = 'brake'
  archer.acc = cgmath.v2(0, 0)
  change_archer_anim_to(archer, 'brake')
end

function change_archer_state_to_charge(archer)
  archer.state = 'charge'
  archer.acc = cgmath.v2(0, 0)
  archer.vel = cgmath.v2(0, 0)
  change_archer_anim_to(archer, 'charge')
end

function love.update(dt)
  if archer.state == 'idle' then
    if love.keyboard.isDown('space') then
      change_archer_state_to_charge(archer)
    elseif love.keyboard.isDown('d') then
      if love.keyboard.isDown('lshift') then
        change_archer_state_to_run(archer, ARCHER_FACING_LEFT)
      else
        change_archer_state_to_walk(archer, ARCHER_FACING_LEFT)
      end
    elseif love.keyboard.isDown('a') then
      if love.keyboard.isDown('lshift') then
        change_archer_state_to_run(archer, ARCHER_FACING_RIGHT)
      else
        change_archer_state_to_walk(archer, ARCHER_FACING_RIGHT)
      end
    end
  elseif archer.state == 'walk' then
    if love.keyboard.isDown('space') then
      change_archer_state_to_charge(archer)
    elseif not love.keyboard.isDown('a') and not love.keyboard.isDown('d') then
      change_archer_state_to_idle(archer)
    else
      if archer.facing == ARCHER_FACING_LEFT then
        if not love.keyboard.isDown('d') and love.keyboard.isDown('a') then
          archer.acc = cgmath.v2(-archer_walk_speed, 0)
          archer.facing = ARCHER_FACING_RIGHT
        end
      else
        if not love.keyboard.isDown('a') and love.keyboard.isDown('d') then
          archer.acc = cgmath.v2(archer_walk_speed, 0)
          archer.facing = ARCHER_FACING_LEFT
        end
      end

      if love.keyboard.isDown('lshift') then
        change_archer_state_to_run(archer)
      end
    end
  elseif archer.state == 'run' then
    archer.time_in_state_run = archer.time_in_state_run + dt

    if archer.facing == 1 then
      if not love.keyboard.isDown('d') then
        if archer.time_in_state_run > ARCHER_BRAKE_TIME_THRESHOLD then
          change_archer_state_to_brake(archer)
        else
          change_archer_state_to_idle(archer)
        end
      end
    else
      if not love.keyboard.isDown('a') then
        if archer.time_in_state_run > ARCHER_BRAKE_TIME_THRESHOLD then
          change_archer_state_to_brake(archer)
        else
          change_archer_state_to_idle(archer)
        end
      end
    end

    if archer.state == 'run' and not love.keyboard.isDown('lshift') then
      if archer.time_in_state_run > ARCHER_BRAKE_TIME_THRESHOLD then
        change_archer_state_to_brake(archer)
      else
        change_archer_state_to_walk(archer)
      end
    end

    if archer.state ~= 'run' then
      archer.time_in_state_run = 0
    end
  elseif archer.state == 'brake' then
    if math.abs(archer.vel.x) <= 1 then
      change_archer_state_to_idle(archer)
    end
  elseif archer.state == 'charge' then
    if archer.current_anim_finished then
      if love.keyboard.isDown('a') then
        archer.facing = ARCHER_FACING_RIGHT
      elseif love.keyboard.isDown('d') then
        archer.facing = ARCHER_FACING_LEFT
      end

      if not love.keyboard.isDown('space') then
        archer.state = 'shoot'
        change_archer_anim_to(archer, 'shoot')
      end

      if love.keyboard.isDown('w') then
        archer.state = 'charge_up'
        change_archer_anim_to(archer, 'charge_up')
      end
    end
  elseif archer.state == 'charge_up' then
    if love.keyboard.isDown('a') then
      archer.facing = ARCHER_FACING_RIGHT
    elseif love.keyboard.isDown('d') then
      archer.facing = ARCHER_FACING_LEFT
    end

    if not love.keyboard.isDown('space') then
      archer.state = 'shoot_up'
      change_archer_anim_to(archer, 'shoot_up')
    end

    if not love.keyboard.isDown('w') then
      archer.state = 'charge'
      change_archer_anim_to(archer, 'charge', 2)
    end
  elseif archer.state == 'shoot' then
    if archer.current_anim_finished then
      change_archer_state_to_idle(archer)
    end
  elseif archer.state == 'shoot_up' then
    if archer.current_anim_finished then
      change_archer_state_to_idle(archer)
    end
  end

  time = time + dt

  clouds[1].offset = clouds[1].offset - 60 * dt
  clouds[2].offset = clouds[2].offset - 60 * dt

  if clouds[1].offset <= -1080 then
    clouds[1].offset = clouds[1].offset + 1080
    clouds[2].offset = clouds[2].offset + 1080
  end

  do
    local acc = archer.acc - 15 * archer.vel
    local archer_dp = archer.vel * dt + 0.5 * acc * dt * dt
    archer.pos = archer.pos + archer_dp
    archer.vel = archer.vel + dt * acc

    local anim = archer.anims[archer.current_anim]
    local frame = archer.current_frame +  anim.fps * dt
    if frame >= #anim.frames + 1 then
      if anim.loop then
        frame = frame - #anim.frames
      else
        frame = #anim.frames
        archer.current_anim_finished = true
      end
    end
    archer.current_frame = frame
  end
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

  local anim = archer.anims[archer.current_anim]
  local frame = math.floor(archer.current_frame)
  renderer.draw_sprite(anim.frames[frame], archer.pos, archer.facing)
end
