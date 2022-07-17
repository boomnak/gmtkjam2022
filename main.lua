local Die = require "die"

local lg = love.graphics
local lk = love.keyboard

local tutorial = {
  { 4, 0, 0, 0, 0, 0, 3 }
}
local mid = {
  { -1, -1, 0, 0, -1 },
  { -1, 0, 1, 0, -1 },
  { -1, 0, 0, 0, -1 },
  { -1, -1, 0, 0, 0 },
  { 0, 2, 0, -1, -1 }
}
local complex = {
  { 3, 0, 0, 0, 0, 0, 0, 0, 4 },
  { 0, 0, -1, -1, 0, -1, -1, 0, 0 },
  { 0, -1, -1, -1, 0, -1, -1, -1, 0 },
  { 0, -1, -1, 0, 0, 0, -1, -1, 0 },
  { 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, -1, -1, 0, 0, 0, -1, -1, 0 },
  { 0, -1, -1, -1, 0, -1, -1, -1, 0 },
  { 0, 0, -1, -1, 0, -1, -1, 0, 0 },
  { 1, 0, 0, 0, 0, 0, 0, 0, 2 }
}

local labyrinth = {
	{0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0},
	{0,1,-1,6,0,-1,-1,0,-1,-1,-1,-1,-1,-1,0},
	{0,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,0},
	{0,0,0,-1,0,-1,0,-1,0,-1,0,-1,-1,-1,0},
	{0,-1,-1,-1,0,-1,0,-1,0,-1,0,-1,4,-1,0},
	{0,0,0,0,0,0,0,-1,0,-1,0,-1,0,-1,5},
	{0,-1,0,-1,-1,-1,0,-1,0,-1,0,-1,0,-1,-1},
	{0,-1,0,0,2,-1,0,-1,0,-1,0,-1,0,0,0},
	{0,-1,0,-1,-1,-1,0,-1,0,-1,0,-1,-1,-1,0},
	{0,-1,0,-1,0,0,0,0,0,0,0,0,0,0,0},
	{0,-1,0,-1,-1,-1,-1,0,0,0,-1,-1,-1,-1,0},
	{0,-1,0,-1,0,0,0,0,0,0,-1,0,3,-1,0},
	{0,-1,0,0,0,-1,-1,-1,-1,0,-1,0,0,-1,0},
	{0,-1,-1,-1,-1,-1,0,0,0,0,-1,0,-1,-1,0},
	{0,0,0,0,0,0,0,-1,-1,-1,-1,0,0,0,0}
}

local maps = { tutorial, mid, complex, labyrinth }
local mapIndex = 1
local map = maps[mapIndex]

local tileSize = 64
local mapTransform
local die
local objectives = {}
local isPressed = {}
local floorTile
local gapTile

local function pair(i, j)
  return i + 257 * j
end

local function loadMap(steps)
  local w, h, _ = love.window.getMode()
  mapTransform = love.math.newTransform(
    w / 2, h / 2,
    math.pi / 4,
    nil, nil,
    tileSize * #map[1] / 2,
    tileSize * #map / 2
  )

  for i = 1, #map do
    for j = 1, #map[i] do
      if map[i][j] > 0 then
        objectives[pair(i, j)] = map[i][j]
      end
    end
  end

  die = Die.new(math.ceil(#map[1] / 2), math.ceil(#map / 2))
  die.steps = steps
end

function love.load()
  lg.setNewFont(30)
  floorTile = lg.newImage("assets/img/7.png")
  gapTile = lg.newImage("assets/img/8.png")

  loadMap(0)
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

  if next(objectives) == nil and mapIndex < #maps then
    -- All objectives met, so move to next map.
    mapIndex = mapIndex + 1
    map = maps[mapIndex]
    loadMap(die.steps)
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
  lg.push()
  lg.applyTransform(mapTransform)

  -- Draw isometric map at mapx,mapy
  for i = 1, #map do
    for j = 1, #map[i] do
      local tile = map[i][j]
      local x = tileSize * (j - 1)
      local y = tileSize * (i - 1)

      if tile < 0 then
        lg.setColor(0.5, 0.5, 0, 1)
        lg.draw(gapTile, x, y)
      elseif tile > 0 and objectives[pair(i, j)] ~= nil then
        lg.setColor(0.8, 0.8, 0, 1)
        lg.draw(Die.faces[tile], x, y)
      else
        lg.setColor(0.8, 0.8, 0, 1)
        lg.draw(floorTile, x, y)
      end
    end
  end
  -- Draw map grid
  lg.setColor(0, 0, 0, 1)
  for i = 0, #map[1] + 1 do
    lg.line(i * tileSize, 0, i * tileSize, #map * tileSize)
  end
  for i = 0, #map + 1 do
    lg.line(0, i * tileSize, #map[1] * tileSize, i * tileSize)
  end

  -- Draw die
  die:draw()

  lg.pop()

  lg.setColor(1, 1, 1, 1)
  lg.print("Dice of Daedalus")
  lg.print("Steps: " .. tostring(die.steps), 0, 24)
end
