//
//  CCMenu.m
//  Space Cannon
//
//  Created by Fenkins on 16/08/15.
//  Copyright (c) 2015 Fenkins. All rights reserved.
//

#import "CCMenu.h"

@implementation CCMenu

- (instancetype)init
{
    self = [super init];
    if (self) {
        SKSpriteNode *title = [SKSpriteNode spriteNodeWithImageNamed:@"Images/Title"];
        title.position = CGPointMake(0, 140);
        [self addChild:title];
        
        SKSpriteNode *scoreBoard = [SKSpriteNode spriteNodeWithImageNamed:@"Images/ScoreBoard"];
        scoreBoard.position = CGPointMake(0, 70);
        [self addChild:scoreBoard];
        
        SKSpriteNode *playButton = [SKSpriteNode spriteNodeWithImageNamed:@"Images/PlayButton"];
        playButton.name = @"Play";
        playButton.position = CGPointMake(0, 0);
        [self addChild:playButton];
    }
    return self;
}

@end
