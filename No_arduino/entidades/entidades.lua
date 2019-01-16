

local entidades = {
	map=nil,
	cam=nil,
	collider=nil,
	player=nil,
	enemigos={},
	timer_player=nil,
	timer_enemigo=nil,
	solidos={},
	destruible={},
	objetos={},
	balas={},
	limites={},
	respawn_enemigos={},
	cantidad_zombies=0
}

function entidades:enter(map,cam,collider,timer_player,timer_enemigo)
	self.map=map
	self.cam=cam
	self.collider=collider
	self.timer_player=timer_player
	self.timer_enemigo=timer_enemigo
end

function entidades:actor(actor)
	self.player=actor
end

function entidades:add(e,tipo)
	if tipo == "enemigos" then
		table.insert(self.enemigos,e)
	elseif tipo == "solidos" then
		table.insert(self.solidos,e)
	elseif tipo == "destruible" then
		table.insert(self.destruible,e)
	elseif tipo == "objetos" then
		table.insert(self.objetos,e)
	elseif tipo == "balas" then
		table.insert(self.balas,e)
	end
end

function entidades:remove(e,tipo)
	if tipo == "enemigos" then
		for i, ob in ipairs(self.enemigos) do
			if ob == e then
				self.collider:remove(e.body)
				table.remove(self.enemigos,i)
				return
			end
		end
	elseif tipo == "solidos" then
		for i, ob in ipairs(self.solidos) do
			if ob == e then
				self.collider:remove(e.body)
				table.remove(self.solidos,i)
				return
			end
		end
	elseif tipo == "destruible" then
		for i, ob in ipairs(self.destruible) do
			if ob == e then
				self.collider:remove(e.body)
				table.remove(self.destruible,i)
				return
			end
		end
	elseif tipo == "objetos" then
		for i, ob in ipairs(self.objetos) do
			if ob == e then
				self.collider:remove(e.body)
				table.remove(self.objetos,i)
				return
			end
		end
	elseif tipo == "balas" then
		for i, ob in ipairs(self.balas) do
			if ob == e then

				self.collider:remove(e.body)
				table.remove(self.balas,i)
				return
			end
		end
	end
end

function entidades:clear()
	self.collider:remove(self.player.body)
	
	self.map=nil
	self.player=nil
	self.enemigos={}
	self.solidos={}
	self.destruible={}
	self.objetos={}
	self.balas={}
	self.limites={}
	self.respawn_enemigos={}
	self.cantidad_zombies=0

	self.collider:resetHash()
	
	

	collectgarbage()
end

function entidades:position()
	return self.player.ox,self.player.oy
end

-- para actualizar mapa
function entidades:player_draw()
	self.player:draw()

end

function entidades:player_update(dt)
	self.player:update(dt)

	self.timer_player:update(dt)
	
end

function entidades:enemigos_draw()
	for _, e in ipairs(self.enemigos) do
		e:draw()
	end
end

function entidades:enemigos_update(dt)
	self.timer_enemigo:update(dt)

	for _, e in ipairs(self.enemigos) do
		e:update(dt)
	end
end

function entidades:objetos_draw()
	for _, e in ipairs(self.objetos) do
		e:draw()
	end
end

function entidades:objetos_update(dt)

end

function entidades:balas_draw()
	for _, e in ipairs(self.balas) do
		e:draw()
	end
end

function entidades:balas_update(dt)
	for _, e in ipairs(self.balas) do
		e:update(dt)
	end
end

function entidades:getmouseposition()
	return self.cam:toWorld(love.mouse.getX( ),love.mouse.getY( ))	
end

function entidades:limit(table)
	self.limites = table
end


function entidades:camera_visible(table_1)
	if table_1.ox > self.limites.x and table_1.ox < self.limites.x + self.limites.w  and table_1.oy > self.limites.y  and table_1.oy < self.limites.y + self.limites.h then
		return true
	else
		return false
	end
end

function entidades:seek_player()
	self.timer_enemigo:every(0.5, function() 
		for _, zombie in ipairs(self.enemigos) do
			if zombie.visible then
				zombie.radio=math.atan2(self.player.oy-zombie.oy,self.player.ox-zombie.ox)
				zombie.delta.y=math.sin(zombie.radio)
				zombie.delta.x=math.cos(zombie.radio)
			end
		end
	end)

	self.timer_enemigo:every(0.5, function() 
		for _, zombie in ipairs(self.enemigos) do
			if not zombie.collision then
				zombie.velocidad=zombie.max_velocidad
			end
		end
	end)
end

--colisiones

function entidades:collisions()
	for _,solido in ipairs(self.solidos) do
		local dx,dy,collision=0,0,false
		collision,dx,dy= self.player.body:collidesWith(solido.body) 

		if collision then
			self.player.body:move(dx,dy)
		end

		for _,zombie in ipairs(self.enemigos) do
			local dx,dy,collision=0,0,false
			collision,dx,dy= zombie.body:collidesWith(solido.body) 

			if collision then
				zombie.velocidad=50
				zombie.collision=true
			end
		end

		for _,bala in ipairs(self.balas) do

			local dx,dy,collision=0,0,false
			collision,dx,dy=solido.body:collidesWith(bala.body) 

			if collision then
				self:remove(bala,"balas")
			end
		end
	end

	for _,destruible in ipairs(self.destruible) do
		local dx,dy,collision=0,0,false
		collision,dx,dy= self.player.body:collidesWith(destruible.body) 

		if collision then
			self.player.body:move(dx,dy)
		end

		for _,bala in ipairs(self.balas) do
			local dx,dy,collision=0,0,false
			collision,dx,dy=destruible.body:collidesWith(bala.body) 

			if collision then
				destruible.hp=destruible.hp-bala.daño
				self:remove(bala,"balas")
			end
		end

		for _,zombie in ipairs(self.enemigos) do
			local dx,dy,collision=0,0,false
			collision,dx,dy=zombie.body:collidesWith(destruible.body) 

			if collision then
				zombie.body:move(dx,dy)

				if  not zombie.atacando then
					destruible.hp=destruible.hp-zombie.daño
					zombie.atacando=true

					self.timer_enemigo:after(1, function () zombie.atacando=false end)
				end
			end
		end
	end

	for _,zombie_1 in ipairs(self.enemigos) do
		local dx,dy,collision=0,0,false
		collision,dx,dy= self.player.body:collidesWith(zombie_1.body) 

		if collision and not self.player.estado.inmunidad then
			self.player:damage(zombie_1)
		end

		for _,zombie_2 in ipairs(self.enemigos) do
			local dx,dy,collision=0,0,false
			collision,dx,dy= zombie_1.body:collidesWith(zombie_2.body) 

			if collision then
				zombie_1.body:move(dx,dy)
			end
		end

		for _,bala in ipairs(self.balas) do

			local dx,dy,collision=0,0,false
			collision,dx,dy=zombie_1.body:collidesWith(bala.body) 

			if collision then
				zombie_1:damage(bala)
			end
		end
	end

	for _, objeto in ipairs(self.objetos) do
		local dx,dy,collision=0,0,false
		collision,dx,dy= self.player.body:collidesWith(objeto.body) 

		if collision then
			objeto:reload(self.player)
		end
	end

end

--logica enemigos

function entidades:script()

	for _, zombie in ipairs(self.enemigos) do
		if self:camera_visible(zombie) and not zombie.visible then
			zombie:start()
		end
	end
end

function entidades:respawn_all(objeto)
	for _, posicion in ipairs(self.respawn_enemigos) do
		self:add(objeto(posicion.x,posicion.y),"enemigos")
	end

	self.cantidad_zombies=self.cantidad_zombies+7
end

function entidades:respawn_random(objeto)
	local seed = love.math.random(1,7)
	local tabla=self.respawn_enemigos[seed]
	self:add(objeto(tabla.x,tabla.y) ,"enemigos")

	self.cantidad_zombies=self.cantidad_zombies+1
end

function entidades:keypressed(key)
	self.player:keypressed(key)
end

function entidades:keyreleased(key)
	self.player:keyreleased(key)
end

function entidades:mousepressed(x, y, button)
	self.player:mousepressed(x, y, button)
end

function entidades:mousereleased(x, y, button)
	self.player:mousereleased(x, y, button)
end

function entidades:replace_tile(layer, tile, newTileGid)
	local x=(tile.x/self.map.tilewidth)+1
	local y=(tile.y/self.map.tileheight)+1

	layer = self.map.layers[layer]
	for i, instance in ipairs(self.map.tileInstances[layer.data[y][x].gid]) do
		if instance.layer == layer and instance.x == tile.x and instance.y == tile.y then
		  instance.batch:set(instance.id, self.map.tiles[newTileGid].quad, instance.x, instance.y)
		  break
		end
	end
end

function entidades:replace_object(object,gid_tile)
	for i, instance in ipairs(self.map.tileInstances[object.gid]) do
  		if object.x == instance.x and object.y  == instance.y then
      		instance.batch:set(instance.id, self.map.tiles[gid_tile].quad, object.x,object.y)
      		break
      	end
  	end
end

return entidades