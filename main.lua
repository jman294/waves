local game = {}

-- Game Constants
game.STOPPED = 0
game.PLAYING = 1

-- Game stats
game.HEIGHT = 450
game.WIDTH = 800
game.drawCount = 0
game.killCount = 1
game.wave = 1
game.state = game.STOPPED
game.keyIsPressed = false

-- Player square
game.thrust = 1
game.gravity = .5
game.x = 25
game.y = 1
game.width = 30
game.height = game.width
game.invincible = false

-- Key bools
game.keys = {}
game.repeats = {}

-- Enemy Stuff
game.enemies = {}
game.Enemy = {}
game.Enemy.x = 0
game.Enemy.y = 0
game.Enemy.len = 10
game.Enemy.velocity = 4

function game.Enemy:new (o)
  o = o or {}   -- create object if user does not provide one
  setmetatable(o, self)
  self.__index = self
  return o
end

game.updateEnemies = function ()
  -- New Enemy frequency
  if game.drawCount % math.floor(1/game.wave * 40) == 0 then
    if game.killCount % (game.wave*15) == 0 then
      game.killCount = 1
      game.wave = game.wave + 1
    end

    if game.invincible then game.invincible = false end

    local enemy = game.Enemy:new()
    enemy.x = math.random(game.WIDTH + 10, game.WIDTH + 20)
    enemy.y = math.random(game.HEIGHT)
    enemy.velocity = game.wave + 1
    table.insert(game.enemies, enemy)
  end

  for k, v in pairs(game.enemies) do
    if game.checkCollision(game.x, game.y, game.width, game.height,
      v.x, v.y, v.len, v.len) and not game.invincible then
      game.wave = game.wave - 1
      game.invincible = true
    end

    if v.x + v.len < 0 then
      game.enemies[k] = nil
      game.killCount = game.killCount + 1
    else
      v.x = v.x - v.velocity
    end
  end
end

game.drawEnemies = function ()
  for k, v in pairs(game.enemies) do
    love.graphics.rectangle('fill', v.x, v.y, v.len, v.len)
  end
end

-- Util
game.checkCollision = function (x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2+w2 and
  x2 < x1+w1 and
  y1 < y2+h2 and
  y2 < y1+h1
end

-- Control Functions
game.keypressed = function (key, scancode, isrepeat)
  game.keyIsPressed = true
  game.keys[key] = true
  game.repeats[key] = true
end

game.keyreleased = function (key, scancode)
  game.keyIsPressed = false
  game.keys[key] = false
  game.repeats[key] = false
end

game.load = function ()
  love.window.setTitle('Waves')
  love.window.setMode(game.WIDTH, game.HEIGHT)
end

game.update = function (dt)
  if game.state == game.PLAYING then
    game.updateEnemies()

    -- Reset
    if game.wave < 1 then
      game.state = game.STOPPED
      game.wave = 1
      game.drawCount = 1
      game.killCount = 30
      game.y = game.HEIGHT/2 + game.height/2
      game.thrust = 1
      game.gravity = .5
      for k in pairs(game.enemies) do
        game.enemies[k] = nil
      end
    end

    -- Cheaty things
    if game.keys['q'] then love.event.quit() end
    if game.keys['a'] then game.wave = game.wave + 1 end

    game.y = game.y - game.thrust
    game.y = game.y + game.gravity

    if game.keys['space'] then
      game.thrust = game.thrust + .2
      game.gravity = .1
    else
      game.gravity = game.gravity + .1
      game.thrust = 1.5
    end

    -- Can't touch bottom
    if game.y > game.HEIGHT - game.height then
      game.y = game.HEIGHT - game.height
      -- Every five milliseconds, lose a life
      if game.drawCount % 5 == 0 then
        game.wave = game.wave - 1
      end
    end
    if game.y < 0 then game.y = game.HEIGHT - game.height end
  elseif game.keyIsPressed then
    game.state = game.PLAYING
  end
end

game.draw = function ()
  game.drawCount = game.drawCount + 1
  if game.state == game.PLAYING then
    game.drawEnemies()

    if game.invincible then
      love.graphics.setColor(255, 0, 0, 127)
      --love.graphics.rectangle('line', game.x, game.y, game.width, game.height)
    end
    love.graphics.rectangle('fill', game.x, game.y, game.width, game.height)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(game.wave, game.width/2, game.HEIGHT*.75)
    if game.keys['f3'] then
      love.graphics.print(game.killCount, 5, 5)
    end
  elseif game.state == game.STOPPED then
    love.graphics.print('Press a key to start', 5, 5)
  end
end


function love.keypressed (key, scancode, isrepeat)
  game.keypressed(key, scancode, isrepeat)
end
function love.keyreleased (key, scancode)
  game.keyreleased(key, scancode)
end
function love.update(dt)
  game.update(dt)
end
function love.load ()
  game.load()
end
function love.draw ()
  game.draw()
end
