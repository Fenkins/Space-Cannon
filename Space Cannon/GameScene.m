//
//  GameScene.m
//  Space Cannon
//
//  Created by Fenkins on 29/07/15.
//  Copyright (c) 2015 Fenkins. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene {
    SKNode *_mainLayer;
    SKNode *_cannon;
    BOOL _didShoot;
}

static const CGFloat SHOOT_SPEED = 1000.0f;

static inline CGVector radiansToVector(CGFloat radians) {
    CGVector vector;
    vector.dx = cosf(radians);
    vector.dy = sinf(radians);
    return vector;
}

-(void)didMoveToView:(SKView *)view {
    
    // Turning off the gravity
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    
    // Lets add some background
    SKSpriteNode *backGround = [SKSpriteNode spriteNodeWithImageNamed:@"Images/Starfield"];
    backGround.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    // Our image dont have an alpha layer so we could do some optimisation (default is SkBlendModeAlpha
    backGround.blendMode = SKBlendModeReplace;
    [self addChild:backGround];
    // Add main layer
    _mainLayer = [[SKNode alloc]init];
    [self addChild:_mainLayer];
    
    // Add cannon
    _cannon = [SKSpriteNode spriteNodeWithImageNamed:@"Images/Cannon"];
    _cannon.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame));
    [_mainLayer addChild:_cannon];
    
    // Create rotation actions
    // This will rotate the cannon for 180 to the left and back
    SKAction *rotation = [SKAction sequence:@[[SKAction rotateByAngle:M_PI duration:2],[SKAction rotateByAngle:-M_PI duration:2]]];
    [_cannon runAction:[SKAction repeatActionForever:rotation]];
    
}

-(void)shoot {
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"Images/Ball"];
    ball.name = @"ball";
    CGVector rotationVector = radiansToVector(_cannon.zRotation);
    ball.position = CGPointMake(_cannon.position.x + (_cannon.frame.size.width * 0.5 *rotationVector.dx),
                                _cannon.position.y + (_cannon.frame.size.height * 0.5 *rotationVector.dy));
    
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:6.0];
    ball.physicsBody.velocity = CGVectorMake(rotationVector.dx * SHOOT_SPEED, rotationVector.dy * SHOOT_SPEED);
    [_mainLayer addChild:ball];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        _didShoot = YES;
    }
}

// Minor optimisations. This will remove balls from the tree, that are no longer on the self.frame
-(void)didSimulatePhysics{
    if (_didShoot) {
        // Moving shooting here in order to catch up with rendering loop
        [self shoot];
        _didShoot = NO;
    }
    [_mainLayer enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
        // Exclamation mark means inverts the statement (if !yes = if not)
        if (!CGRectContainsPoint(self.frame, node.position)) {
            [node removeFromParent];
        }
    }];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
