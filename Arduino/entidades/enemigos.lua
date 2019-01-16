local Class = require "libs.class"
local base = require "gamestate.base"
local entidad = require "entidades.entidad"
local vector = require "libs.vector"

local enemigos = Class{
	__includes = entidad
}

function enemigos:init(x,y)

	self.body=base.entidades.collider:rectangle(x,y,35,43)

	self.velocidad=650

	self.spritesheet=spritesheet.img
	self.imgs=spritesheet.enemigo

	self.posicion=1

	self.radio=0

	self.hp=6

	self.ox,self.oy=self.body:center()

	self.visible=false

	self.delta = vector(0,0) 

	self.collision=false

	self.daño=2

	self.atacando=false

	self.max_velocidad=self.velocidad

end

function enemigos:draw()
	love.graphics.draw(self.spritesheet,self.imgs[self.posicion],self.ox,self.oy,self.radio,1,1,35/2,43/2)
end

function enemigos:update(dt)
	local delta= self.delta * self.velocidad *dt



	self.body:move(delta:unpack())

	self.body:setRotation(self.radio)

	self.ox,self.oy=self.body:center()

	self.collision=false
	
end

function enemigos:start()

	self.visible=true

	base.entidades.timer_enemigo:after(1, function() self.posicion=2 end)
end

function enemigos:damage(agresor)

	local be=base.entidades

	self.hp=self.hp-agresor.daño

	be:remove(agresor,"balas")

	if self.hp<1 then
		be:remove(self,"enemigos")
		be.cantidad_zombies=be.cantidad_zombies-1
		be.player.score=be.player.score+1
	end
end

return enemigos