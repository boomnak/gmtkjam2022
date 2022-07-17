local lg = love.graphics

local Die = {}

function Die.new(x, y)
  -- Load the die faces when the first die is created
  if Die.faces == nil then
    Die.faces = {}
    for i = 1, 6 do
      Die.faces[i] = lg.newImage("assets/img/" .. tostring(i) .. ".png")
    end
  end
  if Die.rollSound == nil then
    Die.rollSound = love.audio.newSource("assets/snd/dice.wav", "static")
  end

  return setmetatable({
    x = x,
    y = y,
    w = 64,
    h = 64,
    top = 1,
    right = 3,
    down = 2,
    steps = 0,
    moved = false,
  },
    { __index = Die }
  )
end

function Die:update(dt, map, isPressed)
  self.moved = false
  local prev = {
    x = self.x,
    y = self.y,
    top = self.top,
    right = self.right,
    down = self.down
  }

  if isPressed["w"] or isPressed["up"] then
    self.y = self.y - 1
    self.moved = true

    local down = 7 - self.top
    self.top = self.down
    self.down = down
  elseif isPressed["a"] or isPressed["left"] then
    self.x = self.x - 1
    self.moved = true

    local right = 7 - self.top
    self.top = self.right
    self.right = right
  elseif isPressed["s"] or isPressed["down"] then
    self.y = self.y + 1
    self.moved = true

    local top = 7 - self.down
    self.down = self.top
    self.top = top
  elseif isPressed["d"] or isPressed["right"] then
    self.x = self.x + 1
    self.moved = true

    local top = 7 - self.right
    self.right = self.top
    self.top = top
  end

  if self.y <= 0 or self.y > #map
      or self.x <= 0 or self.x > #map[1]
      or map[self.y][self.x] == -1 then
    for k, v in pairs(prev) do
      self[k] = v
    end
    self.moved = false
  end
  if self.moved then
    self.steps = self.steps + 1
    love.audio.stop(Die.rollSound)
    love.audio.play(Die.rollSound)
  end
end

function Die:draw()
  lg.setColor(1, 1, 1, 1)
  lg.draw(
    Die.faces[self.top],
    (self.x - 1) * self.w - self.w / 2,
    (self.y - 1) * self.h - self.h / 2
  )

  lg.setColor(.9, .9, .9, 1)
  lg.draw(
    Die.faces[self.down],
    (self.x - 1) * self.w - self.w / 2,
    (self.y - 1) * self.h + self.h / 2,
    nil,
    nil, 0.5,
    nil, nil,
    0.5, 0
  )

  lg.setColor(.8, .8, .8, 1)
  lg.draw(
    Die.faces[self.right],
    self.x * self.w - 16,
    self.y * self.h - 48,
    -math.pi / 2,
    -1, 0.5,
    32, 32,
    0.5, 0
  )
end

return Die
