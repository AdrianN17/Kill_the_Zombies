local Gamestate = require "libs.gamestate"
local serialize = require "libs.ser"
menu = Gamestate.new()
local game= require "gamestate.game"
local sprites= require "assets.img.sprites"

local img=nil
local score=0


function menu:init()
	img=sprites
end

function menu:enter()
	local data=nil
	if love.filesystem.getInfo("score.lua") then
      data =love.filesystem.load("score.lua")()
      score=data.score
    else
    	love.filesystem.write("score.lua",serialize({score=0}))
    end
end

function menu:update(dt)

end

function menu:draw()
	for i = 0, love.graphics.getWidth() / img.fondo:getWidth() do
        for j = 0, love.graphics.getHeight() / img.fondo:getHeight() do
            love.graphics.draw(img.fondo, i * img.fondo:getWidth(), j * img.fondo:getHeight())
        end
    end


	love.graphics.draw(img.titulo,105,60,0,0.7,0.7)

	love.graphics.draw(img.boton,300,350,0,1.5,1.5)

	
	love.graphics.print("Mejor puntuacion : " .. score, 310,500)

	love.graphics.draw(img.img3,img.mouse[2],love.mouse.getX()-15,love.mouse.getY()-15)

end

function menu:mousepressed(x,y,button)
	if x>300 and y>350 and x<552 and y<420.5 then
		Gamestate.switch(game)
	end
end


return menu