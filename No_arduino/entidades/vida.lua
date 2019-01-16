local Class = require "libs.class"
local base = require "gamestate.base"
local entidad = require "entidades.entidad"

local vida = Class{
	__includes = entidad
}

function vida:init(x,y)
	self.body=base.entidades.collider:circle(x,y,12)

	self.ox,self.oy=self.body:center()

	self.spritesheet=spritesheet.img3
	self.img=spritesheet.vida
end

function vida:draw()
	love.graphics.draw(self.spritesheet,self.img,self.ox,self.oy,0,2,2,12,12)
end

function vida:reload(tabla)

	if tabla.hp < 10 then
		tabla.hp=tabla.hp+2

		if tabla.hp>10 then
			tabla.hp=10
		end

		local be=base.entidades

		be:remove(self,"objetos")
	end

end

return vida