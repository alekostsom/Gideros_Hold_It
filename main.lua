--[[ 

This example demonstrates physics collisions by Alexandros Tsompolis - demo

]]

--Scene Manager
sceneManager = SceneManager.new({
	["menu"] = menu,
	["level1"] = level1,
})

sceneManager:addEventListener("transitionBegin", function() print("manager - transition begin") end)
sceneManager:addEventListener("transitionEnd", function() print("manager - transition end") end)

--add created scene to stage or sceneManager

stage:addChild(sceneManager)

sceneManager:changeScene("menu")