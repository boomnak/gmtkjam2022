local lg = love.graphics
local lk = love.keyboard

local map = {
  { -1, -1, 0, 0, -1 },
  { -1, 0, 1, 0, -1 },
  { -1, 0, 0, 0, -1 },
  { -1, -1, 0, 0, 0 },
  { 0, 2, 0, -1, -1 },
}

local mapx, mapy
local tileSize = 64

local die = {
  x = 3,
  y = 3,
  w = 64,
  h = 64,
  top = 1,
  right = 3,
  down = 2,
  steps = 0,
}
local dieRollSound
local dieFaces = {}

local objectives = {}

--[[
local shader_invert = love.graphics.newShader [[
  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
    vec4 col = texture2D( texture, texture_coords );
    return vec4(1-col.r, 1-col.g, 1-col.b, col.a);
  }
]]

local isPressed = {}

local function pair(i, j)
  return tostring(i) .. "," .. tostring(j)
end

local function shallowCopy(t)
  local copy = {}
  for k, v in pairs(t) do
    copy[k] = v
  end
  return copy
end

function love.load()
  mapx, mapy, _ = love.window.getMode()
  mapx, mapy = mapx / 2, mapy / 2

  lg.setNewFont(30)

  for i = 1, #map do
    for j = 1, #map[i] do
      if map[i][j] > 0 then
        objectives[pair(i, j)] = map[i][j]
      end
    end
  end

  dieRollSound = love.audio.newSource("assets/snd/dice.wav", "static")
  for i = 1, 6 do
    dieFaces[i] = lg.newImage("assets/img/" .. tostring(i) .. ".png")
  end
end

function love.update(_)
  local obj = objectives[pair(die.y, die.x)]
  if obj == die.top then
    objectives[pair(die.y, die.x)] = nil
  end

  local moved = false
  local prev = shallowCopy(die)
  if isPressed["w"] or isPressed["up"] then
    die.y = die.y - 1
    moved = true

    local down = 7 - die.top
    die.top = die.down
    die.down = down
  elseif isPressed["a"] or isPressed["left"] then
    die.x = die.x - 1
    moved = true

    local right = 7 - die.top
    die.top = die.right
    die.right = right
  elseif isPressed["s"] or isPressed["down"] then
    die.y = die.y + 1
    moved = true

    local top = 7 - die.down
    die.down = die.top
    die.top = top
  elseif isPressed["d"] or isPressed["right"] then
    die.x = die.x + 1
    moved = true

    local top = 7 - die.right
    die.right = die.top
    die.top = top
  end

  if die.y <= 0 or die.y > #map
      or die.x <= 0 or die.x > #map[1]
      or map[die.y][die.x] == -1 then
    die = prev
    moved = false
  end
  if moved then
    die.steps = die.steps + 1
    love.audio.stop(dieRollSound)
    love.audio.play(dieRollSound)
  end

  if lk.isDown("escape") then
    love.event.quit()
  end
  isPressed = {}
end

function love.keypressed(key)
  isPressed[key] = true
end

function love.draw()
  lg.setColor(1, 1, 1, 1)
  lg.print("Dave's Dice Roll")

  if next(objectives) == nil then
    lg.print("You won in " .. tostring(die.steps) .. " steps", 0, 30)
  end

  lg.push()
  lg.translate(mapx, 0)
  lg.rotate(math.pi / 4)

  -- Draw isometric map at mapx,mapy
  for i = 1, #map do
    for j = 1, #map[i] do
      local tile = map[i][j]
      local x = tileSize * (j - 1)
      local y = tileSize * (i - 1)

      if tile < 0 then
        lg.setColor(0, 0.5, 1, 1)
        lg.rectangle("fill", x, y, tileSize, tileSize)
      elseif tile > 0 and objectives[pair(i, j)] ~= nil then
        lg.draw(dieFaces[tile], x, y)
      else
        lg.setColor(0, 1, 0.5, 1)
        lg.rectangle("fill", x, y, tileSize, tileSize)
      end
    end
  end

  for i = 0, #map + 1 do
    lg.setColor(0, 0, 0, 1)
    lg.line(i * tileSize, 0, i * tileSize, #map * tileSize)
    lg.line(0, i * tileSize, #map[1] * tileSize, i * tileSize)
  end

  -- Draw die
  lg.setColor(1, 1, 1, 1)
  lg.draw(
    dieFaces[die.top],
    (die.x - 1) * die.w - die.w / 2, (die.y - 1) * die.h - die.h / 2
  )

  lg.setColor(.85, .85, .85, 1)
  lg.draw(
    dieFaces[die.down],
    (die.x - 1) * die.w - die.w / 2, (die.y - 1) * die.h + die.h / 2,
    nil,
    nil, 0.5,
    nil, nil,
    0.5, 0
  )

  lg.setColor(.75, .75, .75, 1)
  lg.draw(
    dieFaces[die.right],
    die.x * die.w - 16, die.y * die.h - 48,
    -math.pi / 2,
    -1, 0.5,
    32, 32,
    0.5, 0
  )

  lg.pop()
end
