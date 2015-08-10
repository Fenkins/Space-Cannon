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
// Halo angle in rads
static const CGFloat kCCHaloLowAngle = 200.0 * M_PI / 180;
static const CGFloat kCCHaloHighAngle = 340.0 * M_PI /180;
static const CGFloat kCCHaloSpeed = 100.0;

static const uint32_t kCCHaloCategory = 0x1 << 0;
static const uint32_t kCCBallCategory = 0x1 << 1;
static const uint32_t kCCEdgeCategory = 0x1 << 2;

static inline CGVector radiansToVector(CGFloat radians) {
    CGVector vector;
    vector.dx = cosf(radians);
    vector.dy = sinf(radians);
    return vector;
}

// This is called static inline method
static inline CGFloat randomInRange (CGFloat low, CGFloat high) {
    // Random number betweet 0 and 1
    CGFloat value = arc4random_uniform(UINT32_MAX) / (CGFloat)UINT32_MAX;
    // This will convert our random number to the number from the given range
    return value * (high - low) + low;
}

-(void)didMoveToView:(SKView *)view {
    
    // Turning off the gravity
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    // Setting the contacts listener to self
    self.physicsWorld.contactDelegate = self;
    
    // Adding edges
    SKNode *leftEdge = [[SKNode alloc] init];
    leftEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0.0, self.size.height)];
    leftEdge.position = CGPointZero;
    leftEdge.physicsBody.categoryBitMask = kCCEdgeCategory;
    [self addChild:leftEdge];
    
    SKNode *rightEdge = [[SKNode alloc]init];
    rightEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0.0, self.size.height)];
    rightEdge.position = CGPointMake(self.size.width, 0.0);
    leftEdge.physicsBody.categoryBitMask = kCCEdgeCategory;
    [self addChild:rightEdge];
    
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
    
    // Create spown halo actions
    SKAction *spawnHalo = [SKAction sequence:@[[SKAction waitForDuration:2 withRange:1],
                                               [SKAction performSelector:@selector(spawnHalo) onTarget:self]]];
    [self runAction:[SKAction repeatActionForever:spawnHalo]];
}

-(void)spawnHalo{
    // Creating halo node
    SKSpriteNode *halo = [SKSpriteNode spriteNodeWithImageNamed:@"Images/Halo"];
    halo.position = CGPointMake(randomInRange(halo.size.width * 0.5, self.size.width-halo.size.width * 0.5), self.size.height + halo.size.height * 0.5);
    halo.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:16.0];
    CGVector direction = radiansToVector(randomInRange(kCCHaloLowAngle, kCCHaloHighAngle));
    halo.physicsBody.velocity = CGVectorMake(direction.dx * kCCHaloSpeed, direction.dy * kCCHaloSpeed);
    halo.physicsBody.restitution = 1.0;
    halo.physicsBody.linearDamping = 0.0;
    halo.physicsBody.friction = 0.0;
    
    halo.physicsBody.categoryBitMask = kCCHaloCategory;
    halo.physicsBody.collisionBitMask = kCCEdgeCategory | kCCHaloCategory;
    // We want to be notified about collission with cannon ball
    halo.physicsBody.contactTestBitMask = kCCBallCategory;
    [_mainLayer addChild:halo];
}

-(void)shoot {
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"Images/Ball"];
    ball.name = @"ball";
    CGVector rotationVector = radiansToVector(_cannon.zRotation);
    ball.position = CGPointMake(_cannon.position.x + (_cannon.frame.size.width * 0.5 *rotationVector.dx),
                                _cannon.position.y + (_cannon.frame.size.height * 0.5 *rotationVector.dy));
    
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:6.0];
    ball.physicsBody.velocity = CGVectorMake(rotationVector.dx * SHOOT_SPEED, rotationVector.dy * SHOOT_SPEED);
    ball.physicsBody.restitution = 1.0;
    ball.physicsBody.linearDamping = 0.0;
    ball.physicsBody.friction = 0.0;

    ball.physicsBody.categoryBitMask = kCCBallCategory;
    [_mainLayer addChild:ball];
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody;
    SKPhysicsBody *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    if (firstBody.categoryBitMask == kCCHaloCategory && secondBody.categoryBitMask == kCCBallCategory) {
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
//    for (UITouch *touch in touches) {
//        _didShoot = YES;
//    }
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
