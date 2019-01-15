local Class = require "libs.class"
local base = require "gamestate.base"
local entidad = require "entidades.entidad"
local vector = require "libs.vector"

local Bala= require "entidades.balas"

local player = Class{
	__includes = entidad
}

function player:init(x,y,w,h)
	self.body=base.entidades.collider:rectangle(x,y,w,h)
	self.w,self.h=w,h
	self.ox,self.oy=self.body:center()

	self.point=base.entidades.collider:point(self.ox,self.oy+150)
	self.px,self.py=self.point:center()

	self.radio=0
	self.velocidad=500
	self.hp=10

	self.estado={ correr = false, inmunidad = false, vida = true, disparo=false, recarga=false, visible=true}

	self.direccion={a = false, s = false, d = false, w = false}

	self.spritesheet=spritesheet

	self.posicion=1

	self.arma=1
	self.municion={7,0,0}
	self.stock={7,0,0}
	self.max_municion={"infinito",100,60}
	self.max_stock={7,25,20}

	self.vel_bala={700,1000,1200}

	self.recarga_vel={0.5,0.8,1}
	self.daño={1,2.5,5}

	self.max_velocidad=self.velocidad

	self.score=0

	sonido.pistola:setPitch(2)
	sonido.rifle:setPitch(2)

	base.entidades.timer_player:every(0.15, function() 
		if not self.estado.disparo then
			if self.direccion.a or self.direccion.d or self.direccion.s or self.direccion.w then
				if self.arma == 1 then
					self.posicion=2
				else
					self.posicion=3
				end
			else
				self.posicion=1
			end
		elseif  self.estado.disparo then
			if self.arma==1 then
				self.posicion=4
				self.estado.disparo=false
			elseif self.arma==2 then
				self.posicion=5
			elseif self.arma==3 then
				self.posicion=6
			end
		end

		if self.estado.disparo and self.arma==2 then
			self:create_bullet()
		end

		if self.estado.inmunidad then
			self.estado.visible=not self.estado.visible
		end
 	end)

 	base.entidades.timer_player:every(0.1, function()
 		if self.estado.disparo and self.arma==3 then
			self:create_bullet()
		end

		if self.estado.recarga then
			sonido.recarga:play()
		end
 	end)

	 base.entidades.timer_player:every(0.2, function() 
	 	if self.estado.disparo and self.arma==1 then
			self:create_bullet()
		end
	 end)

end

function player:draw()
	if self.estado.vida then
		if self.estado.visible then
			love.graphics.draw(self.spritesheet.img,self.spritesheet.player[self.posicion],self.ox,self.oy,self.radio,1,1,self.w/2,self.h/2)
			love.graphics.draw(self.spritesheet.img3,spritesheet.mouse[1],self.px,self.py,0,1,1,18,18)
		end
	end
end

function player:update(dt)
	if self.estado.vida then
		local delta = vector(0,0)

		local be=base.entidades


		if self.direccion.a and self.ox > be.limites.x then
			delta.x=-1
		elseif self.direccion.d and self.ox < be.limites.x + be.limites.w then
			delta.x=1
		end

		if self.direccion.w and self.oy > be.limites.y then
			delta.y=-1
		elseif self.direccion.s and self.oy < be.limites.y + be.limites.h then
			delta.y=1
		end

		delta:normalizeInplace()

		delta=delta+ delta * self.velocidad *dt


		self.body:move(delta:unpack())
		self.point:move(delta:unpack())

		self.body:setRotation(self.radio)

		self.ox,self.oy=self.body:center()

		self.point:setRotation(self.radio-math.pi/2,self.ox,self.oy)

		self.px,self.py=self.point:center()


		if self.estado.correr then
			if self.estado.disparo then
				self.estado.correr=false
			else
				self.velocidad=650
			end
		else
			self.velocidad=500
		end

	end

	if self.hp<4 then
		self.velocidad=300
	else
		self.velocidad=self.max_velocidad
	end
end

function player:disparo()
	if self.estado.vida then
		self.estado.disparo=true
		self.estado.recarga=false
	end
end

function player:recarga()
	if self.estado.vida then
		if self.stock[self.arma] < self.max_stock[self.arma] and not self.estado.recarga and self.municion[self.arma]>0 then
			self.estado.recarga=true

			base.entidades.timer_player:after(self.recarga_vel[self.arma] , function() 

				if self.estado.recarga then

					if self.max_municion[self.arma] == "infinito" then
						self.stock[self.arma]=self.max_stock[self.arma]
					else
						if self.municion[self.arma] + self.stock[self.arma] < self.max_stock[self.arma] then
							self.stock[self.arma]=self.municion[self.arma]+self.stock[self.arma]
							self.municion[self.arma]=0
						else
							local carga=self.max_stock[self.arma]-self.stock[self.arma]
							self.stock[self.arma]=self.stock[self.arma]+carga
							self.municion[self.arma]=self.municion[self.arma]-carga
						end
					end
					self.estado.recarga=false
				end
			end)
		end
	end
end

function player:create_bullet()
	if self.stock[self.arma] > 0 then
		if self.arma==1 then
			sonido.pistola:play()
		else
			sonido.rifle:play()
		end

		base.entidades:add(Bala(self.ox,self.oy,self.arma,self.vel_bala[self.arma],self.radio,self.daño[self.arma]),"balas")
		self.stock[self.arma]= self.stock[self.arma] -1
	end
end

function player:damage(agresor)

	self.hp=self.hp-agresor.daño

	if self.hp<1 then
		self.estado.vida=false
	end

	self.estado.inmunidad=true

	base.entidades.timer_player:after(1, function() self.estado.inmunidad=false self.estado.visible=true end)
end

function player:no_move()
	self.direccion.a=false
	self.direccion.d=false
	self.direccion.w=false
	self.direccion.s=false
end

function player:change_weapon()
	if self.arma<3 then
		self.arma=self.arma+1
	else
		self.arma=1
	end
end

return player