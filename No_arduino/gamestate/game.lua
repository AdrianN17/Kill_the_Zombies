local Gamestate = require "libs.gamestate"

local base = require "gamestate.base"
local Class = require "libs.class"
local sprites = require "assets.img.sprites"

spritesheet=nil
sonido=nil

local camview={x=0,y=0,w=0,h=0}

local Player = require "entidades.player"
local Zombie = require "entidades.enemigos"

local Municion = require "entidades.municion"
local Vida = require "entidades.vida"

local pausa = require "gamestate.pausa"
local serialize = require "libs.ser"

local sound= require "assets.sound.sonido"

local intervalo=0
local counter=0

local be=base.entidades

local game = Class{
	__includes = base
}

function game:init()
	spritesheet = sprites
	sonido=sound
end

function game:enter()
	intervalo=2.5
	base.init(self,"assets/mapas/mapa.lua")

	self:layers()


	self:tiles(1)
	self:tiles(2)

	self:object()

	self.map:removeLayer("Borrador")

	be:respawn_all(Zombie)


	be:seek_player()

	be.timer_player:every(intervalo, function() 

		if be.player.estado.vida then
			if be.cantidad_zombies<1 then
				be:respawn_all(Zombie)
			else
				be:respawn_random(Zombie)
			end
		end
	end)

	be.timer_player:every(25, function() 
		if intervalo>0.75 and be.player.estado.vida then
			intervalo=intervalo-0.25
		end

	end)
end

function game:update(dt)

	self.map:update(dt)

	be:collisions()

	be:limit(camview)

	be:script()

	self:change_items()

	counter=collectgarbage('count')/1000
end

function game:draw()
	camview.x,camview.y,camview.w,camview.h=self.cam:getVisible()
	self.map:draw(-camview.x,-camview.y,self.scale,self.scale)
	self.cam:setPosition(be:position())

	if be.player.estado.recarga then
		love.graphics.print("Recargando ... ", 400,300)
	end

	if not be.player.estado.vida then
		love.graphics.draw(spritesheet.muerte,180,250)
		love.graphics.print("Presione enter para continuar, M para volver al menu",160,400)
	end


	self:ui()

	--love.graphics.print('Memory actually used (in kB): ' .. counter, 580,50,0,0.7,0.7)
end

function game:mousepressed(x,y,button)
	local cx,cy=self.cam:toWorld(x,y)
	be:mousepressed(cx,cy,button)
end

function game:mousereleased(x,y,button)
	local cx,cy=self.cam:toWorld(x,y)
	be:mousereleased(cx,cy,button)
end

function game:keypressed(key)
	be:keypressed(key)

	if key=="return"  and not be.player.estado.vida then
		self:save_score()
		be:clear()
		self:enter()


	elseif key=="m" and not be.player.estado.vida then
		self:save_score()
		be:clear()
		Gamestate.switch(menu)
	end


	if key=="p" and be.player.estado.vida then
		Gamestate.push(pausa)
	end
end

function game:keyreleased(key)
	be:keyreleased(key)
end

function game:save_score()
	if love.filesystem.getInfo("score.lua") then
		local old_data=love.filesystem.load("score.lua")()

		if old_data.score<be.player.score then
			love.filesystem.write("score.lua",serialize({score=be.player.score}))
		end
	end
end

function game:tiles(pos)

	

	for y=1, self.map.height,1 do
		for x=1,self.map.width,1 do
			local tile = self.map.layers[pos].data[y][x]
			if tile then
				if tile.properties.Solido then
					be:add({body=self.collider:rectangle((x-1)*self.map.tilewidth,(y-1)*self.map.tileheight,self.map.tilewidth,self.map.tileheight)},"solidos")
				elseif tile.properties.Pared and tile.properties.Circular then
					local tx,ty=(x-1)*self.map.tilewidth,(y-1)*self.map.tileheight

					local objectgroup=tile.objectGroup.objects
					local x,y,w,h
					for _, obj in pairs(objectgroup) do
						x,y,w,h=obj.x,obj.y,obj.width,obj.height
					end

					local r=math.pow(w*h,1/2)/2

					be:add({body=self.collider:circle(tx+x+r,ty+y+r,r)},"solidos")

				elseif tile.properties.Pared and not tile.properties.Circular then

					be:add({body=self.collider:rectangle((x-1)*self.map.tilewidth,(y-1)*self.map.tileheight,self.map.tilewidth,self.map.tileheight)},"solidos")

				elseif tile.properties.Destruible then

					local tx,ty=(x-1)*self.map.tilewidth,(y-1)*self.map.tileheight
					local objectgroup=tile.objectGroup.objects
					local x,y,w,h

					for _, obj in pairs(objectgroup) do
						x,y,w,h=obj.x,obj.y,obj.width,obj.height
					end

					be:add({body=self.collider:rectangle(tx+x,ty+y,w,h),x=tx,y=ty,hp=5,gid=tile.gid, tipo="pared"},"destruible")
				end
			end
		end
	end

end

function game:object()

	for i, object in pairs(self.map.objects) do
		if object.name == "Player" then
			be:actor(Player(object.x,object.y,object.width,object.height))
		elseif object.name == "Caja" then
			be:add({body=self.collider:rectangle(object.x,object.y,object.width,-object.height),hp=5,tipo="caja",gid=object.gid, x=object.x, y=object.y-object.height},"destruible")
		elseif object.name == "Enemigo" then
			table.insert(be.respawn_enemigos,{x = object.x , y = object.y})
		end
	end
end

function game:layers()
	local layer_personajes = self.map.layers["Personajes"]


	function layer_personajes:draw()
		be:objetos_draw()
		be:balas_draw()
		be:enemigos_draw()
		be:player_draw()
	end

	function layer_personajes:update(dt)
		be:player_update(dt)
		be:enemigos_update(dt)
		be:balas_update(dt)
		be:objetos_update(dt)
	end
end

function game:change_items()

	for _,destruible in ipairs(be.destruible) do
		if destruible.hp<1 and destruible.tipo=="caja" then
			local x,y=destruible.body:center()

			local random= love.math.random(1,10)

			if random >=5 then
				be:add(Municion(x,y),"objetos")
			else
				be:add(Vida(x,y),"objetos")
			end

			be:remove(destruible,"destruible")
			be:replace_object(destruible,265)
		elseif destruible.hp< 1 and destruible.tipo=="pared" then
			local random={265,292}
			be:remove(destruible,"destruible")
			be:replace_tile(2,destruible,random[love.math.random(1,2)])
		end
	end
end

function game:ui()
	love.graphics.draw(spritesheet.img3,spritesheet.ui,100,525)
	local play=be.player
	local k=0

	for i=1,3,1 do
		love.graphics.draw(spritesheet.img2,spritesheet.balas[i],110,510+30*i)

		love.graphics.print(play.stock[i],130,510+30*i)

		love.graphics.print("X " .. play.municion[i],160,510+30*i)
	end

	love.graphics.draw(spritesheet.img3,spritesheet.ui,450,25,0,0.5,0.5)
	love.graphics.draw(spritesheet.img2,spritesheet.armas[play.arma],460,50)

	if play.hp>0 then
		love.graphics.draw(spritesheet.img3,spritesheet.hp[1],250,550,0,2,2)
	end

	k=11
	for i=1,8,1 do
		if play.hp>9-i then
			love.graphics.draw(spritesheet.img3,spritesheet.hp[2],250+k,550,0,2,2)
			k=k+31
		end
	end

	if play.hp>9 then
		love.graphics.draw(spritesheet.img3,spritesheet.hp[3],250+k,550,0,2,2)
	end

	love.graphics.draw(spritesheet.img3,spritesheet.mouse[1],love.mouse.getX()-18,love.mouse.getY()-18)

	love.graphics.draw(spritesheet.img,spritesheet.enemigo[1],150,30,0,0.5,0.5)

	love.graphics.print("X " .. play.score,170,35)
end

return game