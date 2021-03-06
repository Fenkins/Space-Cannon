//
//  AppDelegate.m
//  Space Cannon
//
//  Created by Fenkins on 29/07/15.
//  Copyright (c) 2015 Fenkins. All rights reserved.
//

#import "AppDelegate.h"
#import "SpriteKit/SpriteKit.h"
#import "GameScene.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    // This is casting, this is allowing us to acces our view and our scene
    SKView *view = (SKView*)self.window.rootViewController.view;
    ((GameScene*)view.scene).gamePaused = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    SKView *view = (SKView*)self.window.rootViewController.view;
    ((GameScene*)view.scene).gamePaused = NO;
    // So the thing is, once application didBecomeActive - spritekit will resume the scene for us anyway.
    // So what are we doing here - is setting up gamePaused to no - so our "Resume" button and other stuff will behave properly
    // If you do want for game to be onhold even after this method executed
    // visit http://stackoverflow.com/questions/27576448/spritekit-autoresumes-and-auto-pauses-ios8 for possible solution
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
