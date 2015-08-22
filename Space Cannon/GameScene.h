//
//  GameScene.h
//  Space Cannon
//

//  Copyright (c) 2015 Fenkins. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "CCMenu.h"
#import "CCBall.h"

@interface GameScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic) int ammo;
@property (nonatomic) int score;
@property (nonatomic) int pointValue;

@end
