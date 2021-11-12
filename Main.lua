-- title:  Main.lua
-- author(s): ReptitceFnct
-- desc:  
-- script: lua
-- input:
-- saveid: Platformer v1

--=========--
-- H E A D --
--=========--

-- This line make mark in the console during the excution 
io.stdout:setvbuf('no')

-- Stop love filters when we re-size image, it's essential for pixel art
love.graphics.setDefaultFilter("nearest")

-- with this line we can debugg step with step in Zerobrain
--if arg[#arg] == "-debug" then require("mobdebug").start() end

--===================--
-- V A R I A B L E S --
--===================--

-----------
-- images--
-----------

local imgTiles = {}
imgTiles["1"] = love.graphics.newImage("_Resources_/images/tile1.png")
--imgTiles["X"] = love.graphics.newImage("sprite_image.png")
imgPlayer = love.graphics.newImage("_Resources_/images/player/idle1.png")

-- Map and levels

local map = {}
local level = {}
local lstSprites = {}

--===================--
-- F U N C T I O N S --
--===================--

function LoadLevel(pNum)
  
  map = {}
  local filename = "_Resources_/levels/level"..tonumber(pNum)..".txt"
  
  for line in love.filesystem.lines(filename) do
    
    map[#map + 1] = line
  end
  
  -- Look for the player in the map
  level = {}
  level.playerStart = {}
  level.playerStart.col = 2
  level.playerStart.lig = 14
  
  for l=1,#map do
    
    for c=1,#map[1] do
      
      local char = string.sub(map[l],c,c)
      
      if char == "P" then
        
        level.playerStart.col = c
        level.playerStart.lig = l
      end
    end
  end
end

function InitGame(pLevel)
  
  listSprites = {}
  LoadLevel(pLevel)
  CreateSprite("player", (level.playerStart.col - 1) * 32, (level.playerStart.lig - 1) * 32)
  bJumpReady = true
end


function love.load()
  
  love.window.setTitle("Platformer")
  InitGame(1)
end

function getTileAt(pX, pY)
  
  local col = math.floor(pX / 32) + 1
  local lin = math.floor(pY / 32) + 1
  
  if col > 0 and col <= #map[1] and lin > 0 and lin <= #map then
    
    local id = string.sub(map[lin], col, col)
    return id
  end
  return 0
end

function CreateSprite(pType, pX, pY)
  
  local mySprite = {}
  
  mySprite.x = pX
  mySprite.y = pY
  mySprite.vx = 0
  mySprite.vy = 0
  mySprite.type = pType
  mySprite.frame = 0
  mySprite.standing = false
  
  table.insert(listSprites, mySprite)
  
  return mySprite
end

function isSolid(pID)
  
  if pID == "0" then
    
    return false
  end
  
  if pID == "1" then
    
    return true
  end
  
end

function updatePlayer(pPlayer, dt)
  
  -- locals for Physics
  local accel = 500
  local friction = 150
  local maxSpeed = 150
  local jumpVelocity = -280
  
  pPlayer.vy = 0
  
  -- Friction
  if pPlayer.vx > 0 then
    
    pPlayer.vx = pPlayer.vx - friction * dt
    
    if pPlayer.vx < 0 then
      
      pPlayer.vx = 0
    end
  end
  
  if pPlayer.vx < 0 then
    
    pPlayer.vx = pPlayer.vx + friction * dt
    
    if pPlayer.vx > 0 then
      
      pPlayer.vx = 0 
    end
  end
  
  --Keyboard
  
  if love.keyboard.isDown("right") then
    
    pPlayer.vx = pPlayer.vx + accel * dt
    
    if pPlayer.vx > maxSpeed then
      
      pPlayer.vx = maxSpeed
    end
  end
  
  if love.keyboard.isDown("left") then
    
    pPlayer.vx = pPlayer.vx - accel  *dt
    
    if pPlayer.vx < -maxSpeed then
      
      pPlayer.vx = -maxSpeed 
    end
  end
 
  
  if love.keyboard.isDown("up") and pPlayer.standing and bJumpReady then
    
    pPlayer.vy = -280
    pPLayer.standing = false
    bJumpReady = false
  end
  
  if love.keyboard.isDown("up") == false and bJumpReady == false and pPlayer.standing == true then
    
    bJumpReady = true
  end
  
  --move
  
  pPlayer.x = pPlayer.x + pPlayer.vx * dt
  pPlayer.y = pPlayer.y + pPlayer.vy * dt
end

function CollideRight(pSprite)
  
  local id1 = getTileAt(pSprite.x + 32, pSprite.y + 3)
  local id2 = getTileAt(pSprite.x + 32, pSprite.y + 30)
  return isSolid(id1) or isSolid(id2)
end

function CollideLeft(pSprite)
  
  local id1 = getTileAt(pSprite.x-1, pSprite.y + 3)
  local id2 = getTileAt(pSprite.x-1, pSprite.y + 30)
  return isSolid(id1) or isSolid(id2)
end

function CollideBelow(pSprite)
  
  local id1 = getTileAt(pSprite.x + 1, pSprite.y + 32)
  local id2 = getTileAt(pSprite.x + 30, pSprite.y + 32)
  return isSolid(id1) or isSolid(id2)
end

function CollideAbove(pSprite)
  
  local id1 = getTileAt(pSprite.x + 1, pSprite.y-1)
  local id2 = getTileAt(pSprite.x + 30, pSprite.y-1)
  return isSolid(id1) or isSolid(id2) 
end

function updateSprite(pSprite, dt)
  
  --locals for collisions
  local oldX = pSprite.x
  local oldY = pSprite.y
  
  --Specific behavior for player
  if pSprite.type == "player" then
    
    updatePlayer(pSprite, dt)
  end
  
  --Collision dtection
  local collide = false
  
  --on the right
  if pSprite.vx > 0 then
    
    collide = CollideRight(pSprite)
  end
  
  -- on the left
  if pSprite.vx < 0 then
    
    collide = CollideLeft(pSprite)
  end
  
  -- stop!
  if collide then
    
    pSprite.vx = 0
    local col = math.floor((pSprite.x + 16) / 32) + 1
    pSprite.x = (col - 1) * 32
  end
  
  collide = false
  
  -- above
  if pSprite.vy < 0 then
    
    collide = CollideAbove(pSprite)
    if collide then
      
      pSprite.vy = 0
      local lin = math.floor((pSprite.y + 16) / 32) + 1
      pSprite.y = (lin - 1) * 32
    end
  end
  
  collide = false
  
  -- Below
  if pSprite.standing or pSprite.vy > 0 then
    
    collide = CollideBelow(pSprite)
    
    if collide then
      
      pSprite.standing = true
      pSprite.vy = 0
      local lin = math.floor((pSprite.y + 16) / 32) + 1
      pSprite.y = (lin - 1) * 32
      
    else
      
      pSprite.standing = false
    end
  end
  
  --Sprite falling
  if pSprite.standing == false then 
    
    pSprite.vy = pSprite.vy + 500 * dt
  end
end

function love.update(dt)
  
  for nSprite = #listSprites, 1, -1 do
    
    local sprite = listSprites[nSprite]
    updateSprite(sprite, dt)
  end
end



function drawSprite(pSprite)
  
  if pSprite.type == "player" then
    
    love.graphics.rectangle("fill", pSprite.x, pSprite.y, 32, 32)
  else
    
    love.graphics.rectangle("fill", pSprite.x, pSprite.y, 32, 32)
  end
end


function love.draw()
  
 for l=1,#map do
   
    for c=1,#map[1] do
      
      local char = string.sub(map[l],c,c)
      if tonumber(char) ~= 0 then
        
        if imgTiles[char] ~= nil then
          
          love.graphics.draw(imgTiles[char], (c - 1) * 32, (l - 1) * 32)
        end
      end
    end
  end
  
  local id = getTileAt(love.mouse.getX(), love.mouse.getY())
  love.graphics.print(id, 0, 0)
  
  for nSprite = #listSprites, 1, -1 do
    
    local sprite = listSprites[nSprite]
    drawSprite(sprite)
  end
end


function love.keypressed(key)
  
  print(key)
end
