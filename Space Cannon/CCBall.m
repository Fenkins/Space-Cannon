//
//  CCBall.m
//  Space Cannon
//
//  Created by Fenkins on 20/08/15.
//  Copyright (c) 2015 Fenkins. All rights reserved.
//

#import "CCBall.h"

@implementation CCBall

-(void)updateTrail {
    if (self.trail) {
        self.trail.position = self.position;
    }
}
// This method will ensure that SKEmitterNode(trail) will be removed only after all of the particles is gone
-(void)removeFromParent {
    if (self.trail) {
        self.trail.particleBirthRate = 0.0;
        SKAction *removeTrail = [SKAction sequence:@[[SKAction waitForDuration:self.trail.particleLifetime + self.trail.particleLifetimeRange],
                                                     [SKAction removeFromParent]]];
        [self runAction:removeTrail];
    }
    [super removeFromParent];
}

@end
