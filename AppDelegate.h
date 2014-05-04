//
//  AppDelegate.h
//  ApiClient
//
//  Created by Tencent on 12-2-27.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

#include "lua.h"
#include "lualib.h"
#include "lapi.h"
#include "lauxlib.h"


@interface AppDelegate : UIResponder<UIApplicationDelegate,
UIAlertViewDelegate,WXApiDelegate>
{
    enum WXScene _scene;
}

@property (strong, nonatomic) UIWindow *window;

@end






typedef void(SharedRes)(int code);

// lua share function   : share(string imagePath,string text);\
lua share result function :shareRes(int code)
static void lua_openWXShared(lua_State *);
static int lua_shareFunction(lua_State *);

static void sharedImageToWX(UIImage *image,SharedRes res);
static void sharedImageToWXWithPath(NSString *imagePath,SharedRes res);

static void(*SharedResRef)(int code);



