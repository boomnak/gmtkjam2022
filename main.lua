local Die = require "die"

local lg = love.graphics
local lk = love.keyboard

local map = {
  { -1, -1, 0, 0, -1 },
  { -1, 0, 1, 0, -1 },
  { -1, 0, 0, 0, -1 },
  { -1, -1, 0, 0, 0 },
  { 0, 2, 0, -1, -1 },
}
local tileSize = 64
local mapTransform
local die = Die.new(3, 3)
local objectives = {}
local isPressed = {}

local function pair(i, j)
  return i + 257 * j
end

function love.load()
  local w, h, _ = love.window.getMode()
  map.x, map.y = w / 2, h / 2
  mapTransform = love.math.newTransform(
    map.x, map.y,
    math.pi / 4,
    nil, nil,
    tileSize * #map[1] / 2,
    tileSize * #map / 2
  )

  lg.setNewFont(30)

  for i = 1, #map do
    for j = 1, #map[i] do
      if map[i][j] > 0 then
        objectives[pair(i, j)] = map[i][j]
      end
    end
  end
end

function love.update(dt)
  local obj = objectives[pair(die.y, die.x)]
  if obj == die.top then
    objectives[pair(die.y, die.x)] = nil
  end

  local dx, dy = die.x, die.y
  die:update(dt, map, isPressed)
  mapTransform:translate(
    (dx - die.x) * tileSize,
    (dy - die.y) * tileSize
  )

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
  lg.applyTransform(mapTransform)

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
        lg.setColor(0, 1, 0.5, 1)
        lg.draw(Die.faces[tile], x, y)
      else
        lg.setColor(0, 1, 0.5, 1)
        lg.rectangle("fill", x, y, tileSize, tileSize)
      end
    end
  end
  -- Draw map grid
  for i = 0, #map + 1 do
    lg.setColor(0, 0, 0, 1)
    lg.line(i * tileSize, 0, i * tileSize, #map * tileSize)
    lg.line(0, i * tileSize, #map[1] * tileSize, i * tileSize)
  end

  -- Draw die
  die:draw()

  lg.pop()
end
