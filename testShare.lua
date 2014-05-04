function test()
	local text="just for test from lua!"
	local imagePath=getImagePath();--
	share(imagePath,text)
end

function shareRes( code )
    print(code)
	if code==0 then
		print("share success!")
		else
			print("share fail!")
	end
end
