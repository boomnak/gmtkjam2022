local map = {
  { -1, -1, 0, 0, -1 },
  { -1, 0, 0, 0, -1 },
  { -1, 0, 1, 0, -1 },
  { -1, -1, 0, 0, 0 },
  { 0, 2, 0, -1, -1 },
}

local mapx, mapy
local tileSize = 64

function love.load()
  mapx, mapy, _ = love.window.getMode()
  mapx, mapy = mapx / 2, mapy / 2

  love.graphics.setNewFont(30)
end

function love.update(dt)
  if love.keyboard.isDown("escape") then
    love.event.quit()
  end
  dt = dt
end

function love.draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Dav's Dice Roll")

  -- Draw isometric map at mapx,mapy
  love.graphics.push()
  love.graphics.translate(mapx, 0)
  love.graphics.rotate(math.pi / 4)

  for i = 1, #map do
    for j = 1, #map[i] do
      local tile = map[i][j]
      local x = tileSize * j - j
      local y = tileSize * i - i

      if tile < 0 then
        love.graphics.setColor(0, 0.5, 1, 1)
        love.graphics.rectangle("fill", x + 1, y + 1, tileSize - 2, tileSize - 2)
      else
        love.graphics.setColor(0, 1, 0.5, 1)
        love.graphics.rectangle("fill", x + 1, y + 1, tileSize - 2, tileSize - 2)

        if tile > 0 then
          love.graphics.setColor(1, 1, 1, 1)
          love.graphics.print(tostring(tile), x + 10, y + 20, -math.pi / 4)
        end
      end
    end
  end

  love.graphics.pop()
end
