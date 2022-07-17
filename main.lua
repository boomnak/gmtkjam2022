local suit = require "suit"

local Die = require "die"

local lg = love.graphics
local lk = love.keyboard

local tutorial = {
  { 4, 0, 0, 0, 0, 0, 3 }
}
local easy = {
  { 2, 0, 0 },
  { 0, 0, 0 },
  { 0, 0, 4 }
}
local mid = {
  { -1, -1, 0, 0, -1 },
  { -1, 0, 1, 0, -1 },
  { -1, 0, 0, 0, -1 },
  { -1, -1, 0, 0, 0 },
  { 0, 2, 0, -1, -1 }
}
local challenge = {
	{-1,-1,-1,-1,-1,-1},
	{0,0,0,0,0,0},
	{0,-1,0,0,-1,0},
	{1,-1,0,0,-1,2},
	{-1,-1,-1,-1,-1,-1}
}
local intermediate = {
  { 2, -1, -1, -1, -1, -1, 3 },
  { 0, 0, -1, -1, -1, 0, 0 },
  { -1, 0, 0, -1, 0, 0, -1 },
  { -1, 0, 0, 0, 0, 0, -1 },
  { -1, -1, 0, 0, 0, -1, -1 },
  { -1, -1, -1, 1, -1, -1, -1 },
  { -1, -1, -1, -1, -1, -1, -1 }
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
  { 0, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 1, -1, 6, 0, -1, -1, 0, -1, -1, -1, -1, -1, -1, 0 },
  { 0, -1, -1, -1, -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, 0, 0, -1, 0, -1, 0, -1, 0, -1, 0, -1, -1, -1, 0 },
  { 0, -1, -1, -1, 0, -1, 0, -1, 0, -1, 0, -1, 4, -1, 0 },
  { 0, 0, 0, 0, 0, 0, 0, -1, 0, -1, 0, -1, 0, -1, 5 },
  { 0, -1, 0, -1, -1, -1, 0, -1, 0, -1, 0, -1, 0, -1, -1 },
  { 0, -1, 0, 0, 2, -1, 0, 0, 0, -1, 0, -1, 0, 0, 0 },
  { 0, -1, 0, -1, -1, -1, 0, 0, 0, -1, 0, -1, -1, -1, 0 },
  { 0, -1, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
  { 0, -1, 0, -1, -1, -1, -1, 0, 0, 0, -1, -1, -1, -1, 0 },
  { 0, -1, 0, -1, 0, 0, 0, 0, 0, 0, -1, 0, 3, -1, 0 },
  { 0, -1, 0, 0, 0, -1, -1, -1, -1, 0, -1, 0, 0, -1, 0 },
  { 0, -1, -1, -1, -1, -1, 0, 0, 0, 0, -1, 0, -1, -1, 0 },
  { 0, 0, 0, 0, 0, 0, 0, -1, -1, -1, -1, 0, 0, 0, 0 }
}

local maps = { tutorial, easy, mid, challenge, intermediate, complex, labyrinth }
local mapIndex = 1
local map = maps[mapIndex]

local bgm_game = love.audio.newSource("/assets/snd/Cavernous_Desert02.mp3", "stream")
local bgm_victory = love.audio.newSource("/assets/snd/Shakkar.ogg", "stream")

bgm_game:setLooping(true)
bgm_game:play()

local tileSize = 64
local mapTransform
local die
local objectives = {}
local isPressed = {}
local floorTile
local gapTile

local update
local draw

local function pair(i, j)
  return i + 257 * j
end

local function fromPair(p)
  local i = math.fmod(p, 257)
  local j = math.floor(p / 257)
  return i, j
end

local enemy
local function newEnemy(x, y)
  enemy = {
    x = x,
    y = y,
    update = function(self)
      if die.moved then
        local dx, dy = die.x - self.x, die.y - self.y

        local cx, cy = self.x, self.y
        if math.abs(dx) > math.abs(dy) then
          self.x = self.x + (die.x - self.x) / math.abs(die.x - self.x)
        else
          self.y = self.y + (die.y - self.y) / math.abs(die.y - self.y)
        end

        if self.y <= 0 or self.y > #map
            or self.x <= 0 or self.x > #map[1]
            or map[self.y][self.x] == -1 then
          self.x = cx
          self.y = cy

          -- Try all possible movements until one works
          for _, d in pairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do

            if self.y + d[2] > 0 and self.y + d[2] <= #map
                and self.x + d[1] > 0 and self.x + d[1] <= #map[1]
                and map[self.y + d[2]][self.x + d[1]] ~= -1 then
              self.x = self.x + d[1]
              self.y = self.y + d[2]
              break
            end
          end
        end

        if self.x == die.x and self.y == die.y then
          love.event.quit()
        end
      end
    end,
    draw = function(self)
      lg.setColor(1, 0, 0, 1)
      lg.rectangle(
        "fill",
        (self.x - 1) * tileSize,
        (self.y - 1) * tileSize,
        tileSize, tileSize
      )
    end,
  }
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

  if mapIndex == #maps then
    --newEnemy(1, 1)
  end
end

local function gameUpdate(dt)
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
	elseif next(objectives) == nil and mapIndex > #maps then
		--go back to menu and give scores as number of steps taken
		bgm_game:stop()
		bgm_victory:play()
  end

  if lk.isDown("escape") then
    love.event.quit()
  end

  if enemy ~= nil then
    enemy:update()
  end
end

local function gameDraw()
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

  if enemy ~= nil then
    enemy:draw()
  end

  -- Draw die
  die:draw()

  lg.pop()

  lg.setColor(1, 1, 1, 1)
  lg.print("Dice of Daedalus")
  lg.print("Steps: " .. tostring(die.steps), 0, 24)
end

local function startUpdate()
  suit.layout:reset(lg.getWidth() / 2 - 100, lg.getHeight() / 2 - 100)
  suit.Label("Dice of Daedalus", {}, suit.layout:row(200, 50))
  suit.layout:row()
  if suit.Button("Start", suit.layout:row()).hit then
    loadMap(0)
    update = gameUpdate
    draw = gameDraw
  end
end

local function startDraw()
  suit.draw()
end

function love.load()
  lg.setNewFont(30)
  floorTile = lg.newImage("assets/img/7.png")
  gapTile = lg.newImage("assets/img/8.png")

  update = startUpdate
  draw = startDraw
end

function love.update(dt)
  update(dt)
  isPressed = {}
end

function love.draw()
  draw()
end

function love.keypressed(key)
  isPressed[key] = true
  suit.keypressed(key)
end
