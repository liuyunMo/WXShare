WXShare
=======

微信分享



——————————————————————————————
function test()
	local text="just for test from lua!"
	local imagePath=getImagePath();--
	share(imagePath,text)--调用分享函数
end

--分享结束后会调用此函数
function shareRes( code )
    print(code)
	if code==0 then
		print("share success!")
		else
			print("share fail!")
	end
end
