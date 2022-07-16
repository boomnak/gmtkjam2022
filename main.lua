local lg = love.graphics

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

local objectives = {}

local onKey = {
  w = function()
    die.y = die.y - 1
    die.steps = die.steps + 1

    local top = die.down
    local down = 7 - die.top
    die.top = top
    die.down = down
  end,
  a = function()
    die.x = die.x - 1
    die.steps = die.steps + 1

    local top = die.right
    local right = 7 - die.top
    die.top = top
    die.right = right
  end,
  s = function()
    die.y = die.y + 1
    die.steps = die.steps + 1

    local top = 7 - die.down
    local down = die.top
    die.top = top
    die.down = down
  end,
  d = function()
    die.x = die.x + 1
    die.steps = die.steps + 1

    local top = 7 - die.right
    local right = die.top
    die.top = top
    die.right = right
  end,
  escape = function()
    love.event.quit()
  end
}

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
end

function love.update(_)
  local obj = objectives[pair(die.y, die.x)]
  if obj == die.top then
    objectives[pair(die.y, die.x)] = nil
  end
end

function love.keypressed(key)
  local prev = shallowCopy(die)
  if onKey[key] ~= nil then
    onKey[key]()
  end

  if die.y <= 0 or die.y > #map
      or die.x <= 0 or die.x > #map[1]
      or map[die.y][die.x] == -1 then
    die = prev
  end
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
        lg.rectangle("fill", x + 1, y + 1, tileSize - 2, tileSize - 2)
      else
        lg.setColor(0, 1, 0.5, 1)
        lg.rectangle("fill", x + 1, y + 1, tileSize - 2, tileSize - 2)

        if tile > 0 then
          if objectives[pair(i, j)] ~= nil then
            lg.setColor(0, 0, 0, 1)
          else
            lg.setColor(1, 1, 1, 1)
          end
          lg.print(tostring(tile), x + 10, y + 20, -math.pi / 4)
        end
      end
    end
  end

  -- Draw die
  lg.setColor(1, 1, 1, 1)
  lg.rectangle("fill", (die.x - 1) * die.w - die.w / 2, (die.y - 1) * die.h - die.h / 2, die.w, die.h)
  lg.setColor(0, 0, 0, 1)
  lg.print(
    tostring(die.top),
    (die.x - 1) * die.w - 15,
    (die.y - 1) * die.h,
    -math.pi / 4
  )

  lg.setColor(.85, .85, .85, 1)
  lg.polygon("fill", {
    (die.x - 1) * die.w - die.w / 2, (die.y - 1) * die.h + die.h / 2,
    die.x * die.w - die.w / 2, (die.y - 1) * die.h + die.h / 2,
    die.x * die.w, die.y * die.h,
    (die.x - 1) * die.w, die.y * die.h,
  })
  lg.setColor(0, 0, 0, 1)
  lg.print(
    tostring(die.down),
    (die.x - 1) * die.w,
    (die.y - 1) * die.h + die.h / 2
  )

  lg.setColor(.75, .75, .75, 1)
  lg.polygon("fill", {
    die.x * die.w - die.w / 2, die.y * die.h - die.h / 2,
    die.x * die.w, die.y * die.h,
    die.x * die.w, (die.y - 1) * die.h,
    die.x * die.w - die.w / 2, (die.y - 1) * die.h - die.h / 2,
  })
  lg.setColor(0, 0, 0, 1)
  lg.print(
    tostring(die.right),
    die.x * die.w - die.w / 2,
    (die.y - 1) * die.h + 10,
    -(math.pi * 1) / 4
  )

  lg.pop()
end
