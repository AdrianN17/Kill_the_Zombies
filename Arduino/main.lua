local Gamestate = require "libs.gamestate"
local menu = require "gamestate.menu"


function love.load()
	love.mouse.setVisible(false)
	Gamestate.registerEvents()

	local file = io.open("data.txt", "r")

	if file==nil then
		love.window.showMessageBox("No se encontro conexion", "El archivo data no esta disponible.\nEjecute el lector Bluetooth e intentelo otra vez", "error")
		love.event.quit( )
	end

	Gamestate.switch(menu)

	love.graphics.setNewFont("assets/font/lunchds.ttf", 20)
	
end