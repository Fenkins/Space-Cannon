//
//  GameScene.m
//  Space Cannon
//
//  Created by Fenkins on 29/07/15.
//  Copyright (c) 2015 Fenkins. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    
    // Lets add some background
    SKSpriteNode *backGround = [SKSpriteNode spriteNodeWithImageNamed:@"Images/Starfield"];
    backGround.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    // Our image dont have an alpha layer so we could do some optimisation (default is SkBlendModeAlpha
    backGround.blendMode = SKBlendModeReplace;
    [self addChild:backGround];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
//    for (UITouch *touch in touches) {
//        
//    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
