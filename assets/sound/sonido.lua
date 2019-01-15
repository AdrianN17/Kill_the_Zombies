local sonido={}

sonido["pistola"]=love.audio.newSource("assets/sound/pistol.wav","static")
sonido["rifle"]=love.audio.newSource("assets/sound/cg1.wav","static")
sonido["recarga"]=love.audio.newSource("assets/sound/reload.wav","static")

return sonido