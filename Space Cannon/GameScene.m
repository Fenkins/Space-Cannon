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
    SKSpriteNode *_ammoDisplay;
    BOOL _didShoot;
}

static const CGFloat SHOOT_SPEED = 1000.0f;
// Halo angle in rads
static const CGFloat kCCHaloLowAngle = 200.0 * M_PI / 180;
static const CGFloat kCCHaloHighAngle = 340.0 * M_PI /180;
static const CGFloat kCCHaloSpeed = 100.0;

static const uint32_t kCCHaloCategory       = 0x1 << 0;
static const uint32_t kCCBallCategory       = 0x1 << 1;
static const uint32_t kCCEdgeCategory       = 0x1 << 2;
static const uint32_t kCCShieldCategory     = 0x1 << 3;
static const uint32_t kCCLifeBarCategory    = 0x1 << 4;

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
    rightEdge.physicsBody.categoryBitMask = kCCEdgeCategory;
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
    
    // Create spawn halo actions
    SKAction *spawnHalo = [SKAction sequence:@[[SKAction waitForDuration:2 withRange:1],
                                               [SKAction performSelector:@selector(spawnHalo) onTarget:self]]];
    [self runAction:[SKAction repeatActionForever:spawnHalo]];
    
    // Setup ammo
    _ammoDisplay = [SKSpriteNode spriteNodeWithImageNamed:@"Images/Ammo5"];
    _ammoDisplay.anchorPoint = CGPointMake(0.5, 0.0);
    _ammoDisplay.position = _cannon.position;
    [_mainLayer addChild:_ammoDisplay];
    self.ammo = 5;
    
    SKAction *incrementAmmo = [SKAction sequence:@[[SKAction waitForDuration:1],
                                                   [SKAction runBlock:^{
        self.ammo++;
    }]]];
    [self runAction:[SKAction repeatActionForever:incrementAmmo]];
    
    // Setup shields
    for (int i=0; i<6; i++) {
        SKSpriteNode *shield = [SKSpriteNode spriteNodeWithImageNamed:@"Images/Block"];
        shield.position = CGPointMake(35+(50*i), 90);
        [_mainLayer addChild:shield];
        shield.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(shield.size.width, shield.size.height)];
        shield.physicsBody.categoryBitMask = kCCShieldCategory;
        // We dont want our shield to move
        shield.physicsBody.collisionBitMask = 0;
    }
    
    // Setup life bar
    SKSpriteNode *lifeBar = [SKSpriteNode spriteNodeWithImageNamed:@"Images/BlueBar"];
    lifeBar.position = CGPointMake(self.size.width * 0.5, 70);
    lifeBar.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(-lifeBar.size.width * 0.5, 0) toPoint:CGPointMake(lifeBar.size.width * 0.5, 0)];
    lifeBar.physicsBody.categoryBitMask = kCCLifeBarCategory;
    [_mainLayer addChild:lifeBar];
}

-(void)setAmmo:(int)ammo {
    if (ammo >= 0 && ammo <= 5) {
        _ammo = ammo;
        _ammoDisplay.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"Images/Ammo%d",ammo]];
    }
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
    halo.physicsBody.collisionBitMask = kCCEdgeCategory;
    // We want to be notified about collissions from: (halo and ball) and (halo and shield)
    halo.physicsBody.contactTestBitMask = kCCBallCategory | kCCShieldCategory | kCCLifeBarCategory;
    [_mainLayer addChild:halo];
}

-(void)shoot {
    if (self.ammo > 0) {
        self.ammo--;
        
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
        ball.physicsBody.collisionBitMask = kCCHaloCategory | kCCEdgeCategory;
        ball.physicsBody.contactTestBitMask = kCCEdgeCategory;
        [_mainLayer addChild:ball];
    }
    
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
        // Collision between halo and the ball
        [self addExplosion:firstBody.node.position withName:@"HaloExplosion"];
        
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
    }
    if (firstBody.categoryBitMask == kCCHaloCategory && secondBody.categoryBitMask == kCCShieldCategory) {
        // Collision between halo and the shield
        [self addExplosion:firstBody.node.position withName:@"HaloExplosion"];
        
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
    }
    if (firstBody.categoryBitMask == kCCHaloCategory && secondBody.categoryBitMask == kCCLifeBarCategory) {
        // Collision between halo and the lifeBar
        [self addExplosion:firstBody.node.position withName:@"HaloExplosion"];
        [self addExplosion:secondBody.node.position withName:@"LifeBarExplosion"];
        
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
    }
    if (firstBody.categoryBitMask == kCCBallCategory && secondBody.categoryBitMask == kCCEdgeCategory) {
        // Collision between ball and the edge
        [self addExplosion:contact.contactPoint withName:@"BallEdgeBounce"];
    }
}

-(void)addExplosion:(CGPoint)position withName:(NSString *)name {
    NSString *explosionPath = [[NSBundle mainBundle] pathForResource:name ofType:@"sks"];
    SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
    explosion.position = position;
    [_mainLayer addChild:explosion];
    
    SKAction *removeAction = [SKAction sequence:@[[SKAction waitForDuration:1.5],
                                                 [SKAction removeFromParent]]];
    [explosion runAction:removeAction];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//     Called when a touch begins 
    
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
