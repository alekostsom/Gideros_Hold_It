menu = gideros.class(Sprite)

function menu:init()
	local logo = Bitmap.new(Texture.new("./ArtAssets/Images/Logo.png"))
	logo:setPosition(70, 50)
	self:addChild(logo)
	
	local playBtn = Button.new(Bitmap.new(Texture.new("./ArtAssets/Images/GUI/playBtnUP.png")), 
									Bitmap.new(Texture.new("./ArtAssets/Images/GUI/playBtnDOWN.png")))
	playBtn:setPosition(176, 400) 
	self:addChild(playBtn)
	
	playBtn:addEventListener("click",
		function()
			sceneManager:changeScene("level1", 1, SceneManager.fade, easing.linear)
		end)
	
end