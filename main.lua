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
}

local onKey = {
  w = function()
    die.y = die.y - 1

    local top = die.down
    local down = 7 - die.top
    die.top = top
    die.down = down
  end,
  a = function()
    die.x = die.x - 1

    local top = die.right
    local right = 7 - die.top
    die.top = top
    die.right = right
  end,
  s = function()
    die.y = die.y + 1

    local top = 7 - die.down
    local down = die.top
    die.top = top
    die.down = down
  end,
  d = function()
    die.x = die.x + 1

    local top = 7 - die.right
    local right = die.top
    die.top = top
    die.right = right
  end,
  escape = function()
    love.event.quit()
  end
}

function love.load()
  mapx, mapy, _ = love.window.getMode()
  mapx, mapy = mapx / 2, mapy / 2

  lg.setNewFont(30)
end

function love.update(_)
end

function love.keypressed(key)
  if onKey[key] ~= nil then
    onKey[key]()
  end
end

function love.draw()
  lg.setColor(1, 1, 1, 1)
  lg.print("Dav's Dice Roll")

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
          lg.setColor(1, 1, 1, 1)
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
