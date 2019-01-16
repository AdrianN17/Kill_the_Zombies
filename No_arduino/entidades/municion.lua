local Class = require "libs.class"
local base = require "gamestate.base"
local entidad = require "entidades.entidad"

local municion = Class{
	__includes = entidad
}

function municion:init(x,y)
	self.body=base.entidades.collider:circle(x,y,16)

	self.ox,self.oy=self.body:center()

	self.tipo=love.math.random(2,3)

	self.spritesheet=spritesheet.img2
	self.img=spritesheet.balas[self.tipo]

	if self.tipo==2 then
		self.cantidad=love.math.random(15,40)
	elseif self.tipo==3 then
		self.cantidad=love.math.random(10,30)
	end
end

function municion:draw()
	love.graphics.draw(self.spritesheet,self.img,self.ox,self.oy,0,2,2,8,8)
end

function municion:reload(tabla)
	local be=base.entidades

	if tabla.municion[self.tipo]+self.cantidad< tabla.max_municion[self.tipo] then
		tabla.municion[self.tipo]=tabla.municion[self.tipo]+self.cantidad
		self.cantidad=0
		be:remove(self,"objetos")
	else
		local muni=tabla.max_municion[self.tipo]-tabla.municion[self.tipo]
		tabla.municion[self.tipo]=tabla.municion[self.tipo]+muni
		self.cantidad=self.cantidad-muni
	end
end

return municion