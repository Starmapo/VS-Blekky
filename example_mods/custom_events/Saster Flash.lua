function onEvent(n,v,b)
--setProperty('cameraSpeed',3)
	if n == 'Saster Flash' then
	cameraFlash('camGame','0x'..b,tonumber(v),true)
--	setProperty('camGame.zoom',getProperty('defaultCamZoom')-0.2)
	end
end

--300,500
--900,500