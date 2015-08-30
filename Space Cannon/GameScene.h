//
//  GameScene.h
//  Space Cannon
//

//  Copyright (c) 2015 Fenkins. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "CCMenu.h"
#import "CCBall.h"
#import "CCCannon.h"
#import <AVFoundation/AVFoundation.h>

@interface GameScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic) int ammo;
@property (nonatomic) int score;
@property (nonatomic) int pointValue;
@property (nonatomic) BOOL gamePaused;

@end
