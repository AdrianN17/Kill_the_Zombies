local Class = require "libs.class"
local base = require "gamestate.base"
local entidad = require "entidades.entidad"
local vector = require "libs.vector"

local balas = Class{
	__includes = entidad
}

function balas:init(x,y,tipo,velocidad,direccion,daño)

	self.body=base.entidades.collider:circle(x,y,8)


	self.spritesheet=spritesheet.img2

	self.imgbala=spritesheet.balas[tipo]

	self.ox,self.oy=self.body:center()

	self.daño=daño

	self.delta=vector(1,0)
	self.delta:rotateInplace(direccion)
	self.delta=self.delta*velocidad

end

function balas:draw()
	love.graphics.draw(self.spritesheet,self.imgbala,self.ox,self.oy,0,0.5,0.5,8,8)
end

function balas:update(dt)
	local be=base.entidades

	local delta=self.delta
	delta=delta*dt

	self.body:move(delta:unpack())
	self.ox,self.oy=self.body:center()

	if self.ox < be.limites.x or self.ox > be.limites.x + be.limites.w  or self.oy < be.limites.y  or self.oy > be.limites.y + be.limites.h then
		be:remove(self,"balas_p")
	end
end

return balas