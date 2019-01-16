local Gamestate = require "libs.gamestate"
local menu = require "gamestate.menu"

function love.load()
	love.mouse.setVisible(false)
	Gamestate.registerEvents()
	Gamestate.switch(menu)

	love.graphics.setNewFont("assets/font/lunchds.ttf", 20)
end