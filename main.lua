function love.load()
end

function love.update(dt)
  if love.keyboard.isDown("escape") then
    love.event.quit()
  end
end

function love.draw()
  love.graphics.print("BoomNack GMTK Game Jam Entry")
end
