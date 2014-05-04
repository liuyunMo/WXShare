//
//  AppDelegate.m
//  ApiClient
//
//  Created by Tencent on 12-2-27.
//  Copyright (c) 2012年 Tencent. All rights reserved.
//

#import "AppDelegate.h"
static lua_State *C_L=nil;
@implementation AppDelegate

@synthesize window = _window;


static void printStack(lua_State *L)
{
    int top=lua_gettop(L);
    for (int i=1; i<=top; i++)
    {
        int t=lua_type(L, i);
        switch (t) {
            case LUA_TSTRING:
                NSLog(@"index:%d is string (%s)",i,lua_tostring(L, i));
                break;
            case LUA_TBOOLEAN:
                NSLog(@"index:%d is bool (%s)",i,lua_toboolean(L, i)?"true":"false");
                break;
            case LUA_TNUMBER:
                NSLog(@"index:%d is number (%g)",i,lua_tonumber(L, i));
                break;
            default:
                NSLog(@"other type:%s",lua_typename(L, i));
                break;
        }
    }
    NSLog(@"___________________");
}
static lua_State *getCurrentState()
{
    if (!C_L) {
        C_L=lua_open();
    }
    return C_L;
}
- (void)dealloc
{
    [_window release];
    [super dealloc];
}
static void lua_openWXShared(lua_State *L)
{
    lua_register(L, "share", lua_shareFunction);
    
    //
    lua_pushstring(L, "getImagePath");
    lua_pushcfunction(L, lua_getImagePathFunction);
    lua_settable(L, LUA_GLOBALSINDEX);
}
static int lua_getImagePathFunction(lua_State *L)
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"micro_messenger" ofType:@"png"];
    lua_pushstring(L, [path UTF8String]);
    return 1;
}
static int lua_shareFunction(lua_State *L)
{
    if (!lua_isstring(L, -1))
    {
        return lua_error(L);
    }
    if (!lua_isstring(L, -2)) {
        return lua_error(L);
    }
    const char *imagePath=lua_tostring(L, -2);
    const char *text     =lua_tostring(L, -1);
    sharedImageToWXWithPath([NSString stringWithUTF8String:imagePath], &shareResHandle);
    return 0;
}
static void lua_shareEnd(lua_State *L, int code){
    
    lua_getglobal(L, "shareRes");
    lua_pushnumber(L, code);
    lua_pcall(L, 1, 0, 0);
}

static void lua_testShare(lua_State *L)
{
    lua_getglobal(L, "test");
    int err=lua_pcall(L, 0, 0, 0);
    if (err!=0) {
        NSLog(@"errMsg:%s",luaL_checkstring(L, -1));
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor=[UIColor whiteColor];
    [self.window makeKeyAndVisible];
    lua_State *L=getCurrentState();
    luaL_openlibs(L);
    lua_openWXShared(L);
    
    
    //向微信注册
    [WXApi registerApp:@"wxd930ea5d5a258f4f" withDescription:@"demo 2.0"];
    
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn2 setTitle:@"发送Photo消息给微信" forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn2 setFrame:CGRectMake(50, 100, 220, 100)];
    [btn2 addTarget:self action:@selector(sendImageContent) forControlEvents:UIControlEventTouchUpInside];
    [self.window addSubview:btn2];
    
    return YES;
}


-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        if (SharedResRef) {
            SharedResRef(resp.errCode);
        }
    }
}



- (void) sendImageContent
{
    //sharedImageToWXWithPath([[NSBundle mainBundle] pathForResource:@"micro_messenger" ofType:@"png"],NULL);
    //sharedImageToWXWithPath([[NSBundle mainBundle] pathForResource:@"micro_messenger" ofType:@"png"],&shareResHandle);
    
    NSString *path=[[NSBundle mainBundle] pathForResource:@"testShare" ofType:@"lua"];
    lua_State *L=getCurrentState();
    int iErr=luaL_loadfile(L,[path UTF8String]);
    if (iErr==0&&!lua_pcall(L, 0, 0, 0)) {
        lua_testShare(L);
    }
}


static void shareResHandle(int code)
{
    NSString *strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", code];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
    
    lua_shareEnd(getCurrentState(), code);
}


static void sharedImageToWX(UIImage *image,SharedRes res)
{
    SharedResRef=res;
    
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:image];
    
    WXImageObject *ext = [WXImageObject object];
    
    ext.imageData = UIImagePNGRepresentation(image);
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
}
static void sharedImageToWXWithPath(NSString *imagePath,SharedRes res)
{
    sharedImageToWX([UIImage imageWithContentsOfFile:imagePath],res);
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL isSuc = [WXApi handleOpenURL:url delegate:self];
    NSLog(@"url %@ isSuc %d",url,isSuc == YES ? 1 : 0);
    return  isSuc;
}

@end
