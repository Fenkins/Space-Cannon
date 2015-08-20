//
//  CCBall.h
//  Space Cannon
//
//  Created by Fenkins on 20/08/15.
//  Copyright (c) 2015 Fenkins. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface CCBall : SKSpriteNode

@property (nonatomic) SKEmitterNode *trail;

-(void)updateTrail;

@end
