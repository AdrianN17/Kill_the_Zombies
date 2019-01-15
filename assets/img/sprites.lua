local sprites={}

	sprites["img"]= love.graphics.newImage("assets/img/spritesheet_characters.png")

	sprites["player"]={}
	sprites["player"][1]= love.graphics.newQuad(458,88,33,43, sprites["img"]:getDimensions())
	sprites["player"][2]= love.graphics.newQuad(423,44,35,43, sprites["img"]:getDimensions())
	sprites["player"][3]= love.graphics.newQuad(306,88,39,43, sprites["img"]:getDimensions())
	sprites["player"][4]= love.graphics.newQuad(164,44,49,43, sprites["img"]:getDimensions())
	sprites["player"][5]= love.graphics.newQuad(55,176,54,43, sprites["img"]:getDimensions())
	sprites["player"][6]= love.graphics.newQuad(166,0,49,43, sprites["img"]:getDimensions())

	sprites["enemigo"]={}
	sprites["enemigo"][1]= love.graphics.newQuad(460,0,33,43, sprites["img"]:getDimensions())
	sprites["enemigo"][2]= love.graphics.newQuad(424,0,35,43, sprites["img"]:getDimensions())
	sprites["enemigo"][3]= love.graphics.newQuad(346,88,39,43, sprites["img"]:getDimensions())
	sprites["enemigo"][4]= love.graphics.newQuad(163,132,49,43, sprites["img"]:getDimensions())
	sprites["enemigo"][5]= love.graphics.newQuad(57,88,54,43, sprites["img"]:getDimensions())
	sprites["enemigo"][6]= love.graphics.newQuad(162,176,49,43, sprites["img"]:getDimensions())

	sprites["img2"]= love.graphics.newImage("assets/img/sprites.png")

	sprites["armas"]={}
	sprites["armas"][1]= love.graphics.newQuad(45,207,19,10,sprites["img2"]:getDimensions())
	sprites["armas"][2]= love.graphics.newQuad(0,222,25,10,sprites["img2"]:getDimensions())
	sprites["armas"][3]= love.graphics.newQuad(0,207,33,10,sprites["img2"]:getDimensions())

	sprites["balas"]={}
	sprites["balas"][1]= love.graphics.newQuad(24,93,16,16,sprites["img2"]:getDimensions())
	sprites["balas"][2]= love.graphics.newQuad(24,162,16,16,sprites["img2"]:getDimensions())
	sprites["balas"][3]= love.graphics.newQuad(24,24,16,16,sprites["img2"]:getDimensions())

	sprites["img3"]= love.graphics.newImage("assets/img/sprites_2.png")

	sprites["vida"] = love.graphics.newQuad(155,153,24,24,sprites["img3"]:getDimensions())

	sprites["hp"]={}
	sprites["hp"][1]= love.graphics.newQuad(196,75,6,26,sprites["img3"]:getDimensions())
	sprites["hp"][2]= love.graphics.newQuad(184,151,16,26,sprites["img3"]:getDimensions())
	sprites["hp"][3]= love.graphics.newQuad(196,106,6,26,sprites["img3"]:getDimensions())

	sprites["ui"]= love.graphics.newQuad(50,75,100,100,sprites["img3"]:getDimensions())

	sprites["mouse"]={}
	sprites["mouse"][1]= love.graphics.newQuad(155,75,36,36,sprites["img3"]:getDimensions())
	sprites["mouse"][2]= love.graphics.newQuad(157,116,30,30,sprites["img3"]:getDimensions())

	sprites["pausa"]=love.graphics.newImage("assets/img/pausa.png")
	sprites["titulo"]=love.graphics.newImage("assets/img/title.png")
	sprites["boton"]=love.graphics.newImage("assets/img/button.png")
	sprites["muerte"]=love.graphics.newImage("assets/img/muerte.png")

	sprites["fondo"]=love.graphics.newImage("assets/img/fondo.png")

return sprites