local Gamestate = require "libs.gamestate"
local sprites= require "assets.img.sprites"
pausa = Gamestate.new()

local img=nil

function pausa:init()
	img= sprites.pausa
end

function pausa:enter(from)
  self.from = from 
end

function pausa:draw()

  local w, h = love.graphics.getWidth(), love.graphics.getHeight()

  self.from:draw()

  love.graphics.setColor(0,0,0,0.4)
  love.graphics.rectangle('fill', 0,0, w, h)
  love.graphics.setColor(255,255,255)

  love.graphics.draw(img,w/2-249/2,h/2-106/2)

  love.graphics.print("Presione p para continuar ...",w/2-150,h/2+100)
end



function pausa:update(dt)
  self:arduino()
end

function pausa:arduino()
  local file = io.open("data.txt", "r")
  io.input(file)
  datos=io.read()
  io.close(file)

  if datos~= nil then
    local split={}
    local i=1
    for token in string.gmatch(datos, "[^%s]+") do
       split[i]=tonumber(token)
       i=i+1
    end

    if split[7]==0 then
      return Gamestate.pop() 
    end

  end
end


return pausa