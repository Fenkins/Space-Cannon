//
//  GameScene.m
//  Space Cannon
//
//  Created by Fenkins on 29/07/15.
//  Copyright (c) 2015 Fenkins. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene {
    AVAudioPlayer *_audioPlayer;
    SKNode *_mainLayer;
    CCMenu *_menu;
    CCCannon *_cannon;
    CCCannon *_cannonGreen;
    SKSpriteNode *_ammoDisplay;
    SKSpriteNode *_pauseButton;
    SKSpriteNode *_resumeButton;
    SKLabelNode *_scoreLabel;
    SKLabelNode *_pointLabel;
    BOOL _didShoot;
    SKAction *_bounceSound;
    SKAction *_deepExplosionSound;
    SKAction *_explosionSound;
    SKAction *_laserSound;
    SKAction *_zapSound;
    SKAction *_shieldUPSound;
    BOOL _gameOver;
    NSUserDefaults *_userDefaults;
    int haloObjectsCoint;
    NSMutableArray *_shieldPool;
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
static const uint32_t kCCShieldUPCategory   = 0x1 << 5;
static const uint32_t kCCCannonUPCategory   = 0x1 << 6;

static NSString *const kCCKeyTopScore = @"TopScore";

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
    leftEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0.0, self.size.height + 100)];
    leftEdge.position = CGPointZero;
    leftEdge.physicsBody.categoryBitMask = kCCEdgeCategory;
    [self addChild:leftEdge];
    
    SKNode *rightEdge = [[SKNode alloc]init];
    rightEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0.0, self.size.height + 100)];
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
    _cannon = [CCCannon spriteNodeWithImageNamed:@"Images/Cannon"];
    _cannon.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame));
    [self addChild:_cannon];
    // Add green cannon
    _cannonGreen = [CCCannon spriteNodeWithImageNamed:@"Images/GreenCannon"];
    _cannonGreen.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame));
    [self addChild:_cannonGreen];
    _cannonGreen.hidden = YES;
    
    // Create rotation actions
    // This will rotate the cannon for 180 to the left and back
    SKAction *rotation = [SKAction sequence:@[[SKAction rotateByAngle:M_PI duration:2],[SKAction rotateByAngle:-M_PI duration:2]]];
    [_cannon runAction:[SKAction repeatActionForever:rotation]];
    [_cannonGreen runAction:[SKAction repeatActionForever:rotation]];
    
    // Create spawn halo actions
    SKAction *spawnHalo = [SKAction sequence:@[[SKAction waitForDuration:2 withRange:1],
                                               [SKAction performSelector:@selector(spawnHalo) onTarget:self]]];
    [self runAction:[SKAction repeatActionForever:spawnHalo]withKey:@"SpawnHalo"];
    
    // Create spawn shield powerup
    SKAction *spawnShieldPowerUP = [SKAction sequence:@[[SKAction waitForDuration:15 withRange:4],
                                                        [SKAction performSelector:@selector(spawnShieldPowerUp) onTarget:self]]];
    [self runAction:[SKAction repeatActionForever:spawnShieldPowerUP]];
    
    // Create spawn cannon powerup
    SKAction *spawnCannonPowerUP = [SKAction sequence:@[[SKAction waitForDuration:10 withRange:4],
                                                        [SKAction performSelector:@selector(spawnCannonPowerUp) onTarget:self]]];
    [self runAction:[SKAction repeatActionForever:spawnCannonPowerUP]];
    
    // Setup ammo
    _ammoDisplay = [SKSpriteNode spriteNodeWithImageNamed:@"Images/Ammo5"];
    _ammoDisplay.anchorPoint = CGPointMake(0.5, 0.0);
    _ammoDisplay.position = _cannon.position;
    [self addChild:_ammoDisplay];
    
    // Increasing ammo over time in case of powerUP is not active
    if (!_cannon.powerUpEnabled) {
        SKAction *incrementAmmo = [SKAction sequence:@[[SKAction waitForDuration:1],
                                                       [SKAction runBlock:^{
            self.ammo++;
        }]]];
        [self runAction:[SKAction repeatActionForever:incrementAmmo]withKey:@"ballIncrement"];
    }
    
    // Setup pause button
    _pauseButton = [SKSpriteNode spriteNodeWithImageNamed:@"Images/PauseButton"];
    _pauseButton.position = CGPointMake(self.size.width - 30, 20);
    [self addChild:_pauseButton];
    
    // Setup resume button
    _resumeButton = [SKSpriteNode spriteNodeWithImageNamed:@"Images/ResumeButton"];
    _resumeButton.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    [self addChild:_resumeButton];
    
    // Setup score display
    _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
    _scoreLabel.position = CGPointMake(15.0, 10.0);
    _scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _scoreLabel.fontSize = 15;
    [self addChild:_scoreLabel];
    
    // Setup score multiplyer label
    _pointLabel = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
    _pointLabel.position = CGPointMake(15.0, 30.0);
    _pointLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _pointLabel.fontSize = 15;
    [self addChild:_pointLabel];
    
    // Setup sounds
    _bounceSound = [SKAction playSoundFileNamed:@"Bounce.caf" waitForCompletion:NO];
    _deepExplosionSound = [SKAction playSoundFileNamed:@"DeepExplosion.caf" waitForCompletion:NO];
    _explosionSound = [SKAction playSoundFileNamed:@"Explosion.caf" waitForCompletion:NO];
    _laserSound = [SKAction playSoundFileNamed:@"Laser.caf" waitForCompletion:NO];
    _zapSound = [SKAction playSoundFileNamed:@"Zap.caf" waitForCompletion:NO];
    _shieldUPSound = [SKAction playSoundFileNamed:@"ShieldUp.caf" waitForCompletion:NO];
    
    // Setup menu
    _menu = [[CCMenu alloc]init];
    _menu.position = CGPointMake(self.size.width * 0.5, self.size.height - 220);
    [self addChild:_menu];
    
    // Set initial values
    // If we will not set it here, initialization of the scores in newGame method will come with a HUUUUGE delay
    self.ammo = 5;
    self.score = 0;
    self.pointValue = 1;
    _gameOver = YES;
    haloObjectsCoint = 0;
    
    _scoreLabel.hidden = YES;
    _pointLabel.hidden = YES;
    _pauseButton.hidden = YES;
    _resumeButton.hidden = YES;
    
    // Load top score
    _userDefaults = [NSUserDefaults standardUserDefaults];
    _menu.topScore = [_userDefaults integerForKey:kCCKeyTopScore];
    
    // Initializing shields
    _shieldPool = [[NSMutableArray alloc]init];
    // Setup shields
    for (int i=0; i<6; i++) {
        SKSpriteNode *shield = [SKSpriteNode spriteNodeWithImageNamed:@"Images/Block"];
        shield.name = @"shield";
        shield.position = CGPointMake(35+(50*i), 90);
        shield.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(shield.size.width, shield.size.height)];
        shield.physicsBody.categoryBitMask = kCCShieldCategory;
        // We dont want our shield to move
        shield.physicsBody.collisionBitMask = 0;
        [_shieldPool addObject:shield];
    }
    
    // Load the music
    NSURL *musicTrackUrl = [[NSBundle mainBundle]URLForResource:@"ObservingTheStar" withExtension:@"caf"];
    NSError *error = nil;
    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:musicTrackUrl error:&error];
    if (!_audioPlayer) {
        NSLog(@"Something goes wrong, audioPlayer is nil :(, %@",error);
    } else {
        _audioPlayer.numberOfLoops = -1; // Infinite loops
        _audioPlayer.volume = 0.8;
        [_audioPlayer play];
        _menu.isMusicPlaying = YES;
    }
}

-(void)setAmmo:(int)ammo {
    if (ammo >= 0 && ammo <= 5) {
        _ammo = ammo;
        _ammoDisplay.texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"Images/Ammo%d",ammo]];
    }
}

-(void)setScore:(int)score {
    _score = score;
    _scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
}

-(void)setPointValue:(int)pointValue {
    _pointValue = pointValue;
    _pointLabel.text = [NSString stringWithFormat:@"Points multiplier: %d",pointValue];
}

-(void)setGamePaused:(BOOL)gamePaused {
    if (!_gameOver) {
        _gamePaused = gamePaused;
        _pauseButton.hidden = gamePaused;
        _resumeButton.hidden = !gamePaused;
        self.paused = gamePaused;
        switch (gamePaused) {
            case YES:
                [_audioPlayer stop];
                break;
            case NO:
                [_audioPlayer play];
                break;
            default:
                break;
        }
    }
}

-(void)spawnHalo{
    // Increase spawn speed
    // This will give us action for key defined earlier
    SKAction *spawnHaloAction = [self actionForKey:@"SpawnHalo"];
    if (spawnHaloAction.speed < 1.5) {
        spawnHaloAction.speed += 0.01;
    }
    // Creating halo node
    SKSpriteNode *halo = [SKSpriteNode spriteNodeWithImageNamed:@"Images/Halo"];
    halo.name = @"halo";
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
    halo.physicsBody.contactTestBitMask = kCCBallCategory | kCCShieldCategory | kCCLifeBarCategory| kCCEdgeCategory;
    
    // Creating the random point multiplier
    if (!_gameOver && arc4random_uniform(6) == 0) {
        halo.texture = [SKTexture textureWithImageNamed:@"Images/HaloX"];
        halo.userData = [[NSMutableDictionary alloc]init];
        [halo.userData setValue:@YES forKey:@"Multiplier"];
    }
    
    // Creating the bomb
    if (!_gameOver && haloObjectsCoint >= 4) {
        halo.texture = [SKTexture textureWithImageNamed:@"Images/HaloBomb"];
        halo.userData = [[NSMutableDictionary alloc]init];
        [halo.userData setValue:@YES forKey:@"Explosive"];
    }
    
    // START of reference block
    // JUST FOR REFERENCE. We could also enumerate our halo nodes like this and count them all like so. (we could safely get rid of that block)
    int nodeCount = 1;
    for (SKNode *node in _mainLayer.children) {
        if ([node.name isEqualToString:@"halo"]) {
            nodeCount++;
        }
    }
    // END of reference block
    
    [_mainLayer addChild:halo];
    haloObjectsCoint++;
}

-(void)createBallWithTrail {
    CCBall *ball = [CCBall spriteNodeWithImageNamed:@"Images/Ball"];
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
    ball.physicsBody.collisionBitMask = kCCEdgeCategory;
    ball.physicsBody.contactTestBitMask = kCCEdgeCategory | kCCShieldUPCategory | kCCCannonUPCategory;
    [self runAction:_laserSound];
    
    // Creating trail
    NSString *trailPath = [[NSBundle mainBundle]pathForResource:@"BallTrail" ofType:@"sks"];
    SKEmitterNode *ballTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:trailPath];
    // Throwing our particles to the mainLayer, not the ball itself
    ballTrail.targetNode = _mainLayer;
    
    [_mainLayer addChild:ballTrail];
    ball.trail = ballTrail;
    
    [_mainLayer addChild:ball];
}

-(void)shoot {
    if (self.ammo > 0) {
        self.ammo--;
        [self performSelector:@selector(createBallWithTrail)];
        // Cannon PowerUP block
        if (_cannon.powerUpEnabled) {
            SKAction *shootTheBall = [SKAction sequence:@[[SKAction performSelector:@selector(createBallWithTrail) onTarget:self],
                                                          [SKAction waitForDuration:0.1]]];
            SKAction *shootFourMoreBalls = [SKAction repeatAction:shootTheBall count:5];
            [self runAction:shootFourMoreBalls];
            // PowerUP ended, ran out of ammo
            if (self.ammo == 0) {
                _cannon.powerUpEnabled = NO;
                SKAction *incrementAmmo = [SKAction sequence:@[[SKAction waitForDuration:1],
                                                               [SKAction runBlock:^{
                    self.ammo++;
                }]]];
                [self runAction:[SKAction repeatActionForever:incrementAmmo]withKey:@"ballIncrement"];
                _cannon.hidden = NO;
                _cannonGreen.hidden = YES;
            }
        }
    }
}

-(void)spawnShieldPowerUp {
    if (_shieldPool.count > 0) {
        SKSpriteNode *shieldUP = [SKSpriteNode spriteNodeWithImageNamed:@"Images/Block"];
        shieldUP.name = @"shieldUP";
        shieldUP.position = CGPointMake(self.size.width + shieldUP.size.width, randomInRange(150, self.size.height-100));
        shieldUP.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(42, 9)];
        shieldUP.physicsBody.categoryBitMask = kCCShieldUPCategory;
        shieldUP.physicsBody.velocity = CGVectorMake(-100, randomInRange(-40, 40));
        shieldUP.physicsBody.angularVelocity = M_PI;
        shieldUP.physicsBody.linearDamping = 0.0;
        shieldUP.physicsBody.collisionBitMask = 0;
        [_mainLayer addChild:shieldUP];
    }
}

-(void)spawnCannonPowerUp {
    if (_score > 10) {
        SKSpriteNode *cannonUP = [SKSpriteNode spriteNodeWithImageNamed:@"Images/MultiShotPowerUp"];
        cannonUP.name = @"cannonUP";
        cannonUP.position = CGPointMake(self.size.width + cannonUP.size.width, randomInRange(150, self.size.height-100));
        cannonUP.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:cannonUP.size.width/2];
        cannonUP.physicsBody.categoryBitMask = kCCCannonUPCategory;
        cannonUP.physicsBody.velocity = CGVectorMake(-100, randomInRange(-40, 40));
        cannonUP.physicsBody.angularVelocity = randomInRange(-M_PI, M_PI);
        cannonUP.physicsBody.linearDamping = 0.0;
        cannonUP.physicsBody.collisionBitMask = 0;
        [_mainLayer addChild:cannonUP];
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
        self.score += _pointValue;
        haloObjectsCoint--;
        [self addExplosion:firstBody.node.position withName:@"HaloExplosion"];
        [self runAction:_explosionSound];
        
        // Checkin if the ball hits powerUP
        if ([[firstBody.node.userData valueForKey:@"Multiplier"]boolValue]) {
            self.pointValue++;
        }
        
        // Checkin if the ball hits bomb
        if ([[firstBody.node.userData valueForKey:@"Explosive"]boolValue]) {
            firstBody.node.name = nil;
            [self removeAllHalos];
        }
        
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
    }
    if (firstBody.categoryBitMask == kCCHaloCategory && secondBody.categoryBitMask == kCCShieldCategory) {
        // Collision between halo and the shield
        [self addExplosion:firstBody.node.position withName:@"HaloExplosion"];
        [self runAction:_explosionSound];

        // Resetting multiplier upon the shield impact
        self.pointValue = 1;
        haloObjectsCoint--;
        
        if ([[firstBody.node.userData valueForKey:@"Explosive"]boolValue]) {
            [self gameOver];
        }
        
        // This line will drop halo collision detection after it hits the shield, so it wont hit another one before its being removed.
        // So to summerize - this line makes halo remove only one shield at a time
        firstBody.categoryBitMask = 0;
        
        [firstBody.node removeFromParent];
        [_shieldPool addObject:secondBody.node];
        [secondBody.node removeFromParent];
    }
    if (firstBody.categoryBitMask == kCCHaloCategory && secondBody.categoryBitMask == kCCLifeBarCategory) {
        // Collision between halo and the lifeBar
        [self addExplosion:secondBody.node.position withName:@"LifeBarExplosion"];
        [self runAction:_deepExplosionSound];

        [secondBody.node removeFromParent];
        [self gameOver];
    }
    if (firstBody.categoryBitMask == kCCBallCategory && secondBody.categoryBitMask == kCCEdgeCategory) {
        // Collision between ball and the edge
        
        if ([firstBody.node isKindOfClass:[CCBall class]]) {
            // This is downcasting. Yea, ObjC has that thing too
            ((CCBall*)firstBody.node).bounces++;
            if (((CCBall*)firstBody.node).bounces > 3) {
                [firstBody.node removeFromParent];
            }
        }
        
        [self addExplosion:contact.contactPoint withName:@"BallEdgeBounce"];
        [self runAction:_laserSound];
    }
    if (firstBody.categoryBitMask == kCCHaloCategory && secondBody.categoryBitMask == kCCEdgeCategory) {
        // Halo is bouncing off the edge
        [self runAction:_zapSound];
    }
    if (firstBody.categoryBitMask == kCCBallCategory && secondBody.categoryBitMask == kCCShieldUPCategory) {
        // We just hit the shield powerUP
        if (_shieldPool.count > 0) {
            int randomIndex = arc4random_uniform((int)_shieldPool.count);
            [_mainLayer addChild:[_shieldPool objectAtIndex:randomIndex]];
            // Keep in mind that each time we are adding the shield from the pool, we should aways remove one from it
            [_shieldPool removeObjectAtIndex:randomIndex];
            [self runAction:_shieldUPSound];
        }
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
    }
    if (firstBody.categoryBitMask == kCCBallCategory && secondBody.categoryBitMask == kCCCannonUPCategory) {
        // We just hit the cannon powerUP
        _cannon.powerUpEnabled = YES;
        self.ammo = 5;
        _cannon.hidden = YES;
        _cannonGreen.hidden = NO;
        // Turning off the ammo incrementation
        [self removeActionForKey:@"ballIncrement"];
        [firstBody.node removeFromParent];
        [secondBody.node removeFromParent];
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

-(void)gameOver {
    [_mainLayer enumerateChildNodesWithName:@"halo" usingBlock:^(SKNode *node, BOOL *stop) {
        [self addExplosion:node.position withName:@"HaloExplosion"];
        [node removeFromParent];
    }];
    [_mainLayer enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    [_mainLayer enumerateChildNodesWithName:@"shield" usingBlock:^(SKNode *node, BOOL *stop) {
        [_shieldPool addObject:node];
        [node removeFromParent];
    }];
    [_mainLayer enumerateChildNodesWithName:@"LifeBar" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    [_mainLayer enumerateChildNodesWithName:@"shieldUP" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    
    _menu.score = self.score;
    if (self.score > _menu.topScore) {
        _menu.topScore = self.score;
        [_userDefaults setInteger:self.score forKey:kCCKeyTopScore];
        [_userDefaults synchronize];
    }
    _gameOver = YES;
    _scoreLabel.hidden = YES;
    _pointLabel.hidden = YES;
    _pauseButton.hidden = YES;
    [self runAction:[SKAction waitForDuration:1.0]completion:^{
        [_menu show];
    }];
}

-(void)removeAllHalos {
    [_mainLayer enumerateChildNodesWithName:@"halo" usingBlock:^(SKNode *node, BOOL *stop) {
        [self addExplosion:node.position withName:@"HaloExplosion"];
        [node removeFromParent];
    }];
    haloObjectsCoint = 0;
}

-(void)newGame {
    
    [_mainLayer removeAllChildren];
    
    // Adding shields from the array
    while (_shieldPool.count > 0) {
        [_mainLayer addChild:[_shieldPool objectAtIndex:0]];
        [_shieldPool removeObjectAtIndex:0];
    }
    
    // Setting up the life bar
    SKSpriteNode *lifeBar = [SKSpriteNode spriteNodeWithImageNamed:@"Images/BlueBar"];
    lifeBar.name = @"LifeBar";
    lifeBar.position = CGPointMake(self.size.width * 0.5, 70);
    lifeBar.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(-lifeBar.size.width * 0.5, 0) toPoint:CGPointMake(lifeBar.size.width * 0.5, 0)];
    lifeBar.physicsBody.categoryBitMask = kCCLifeBarCategory;
    [_mainLayer addChild:lifeBar];
    
    // Set initial values
    [self actionForKey:@"SpawnHalo"].speed = 1.0;
    self.ammo = 5;
    self.score = 0;
    self.pointValue = 1;
    _pointLabel.hidden = NO;
    _scoreLabel.hidden = NO;
    _cannon.hidden = NO;
    _cannonGreen.hidden = YES;
    _cannon.powerUpEnabled = NO;
    _pauseButton.hidden = NO;
    _gameOver = NO;
    [_menu hide];
    haloObjectsCoint = 0;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//     Called when a touch begins 
    
    for (UITouch *touch in touches) {
        if (!_gameOver && !self.gamePaused) {
            // We dont want to shoot when we touching the pause button
            if (![_pauseButton containsPoint:[touch locationInNode:_pauseButton.parent]]) {
                _didShoot = YES;
            }
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (_gameOver && _menu.touchable) {
            SKNode *n = [_menu nodeAtPoint:[touch locationInNode:_menu]];
            if ([n.name isEqualToString:@"Play"]) {
                [self newGame];
            } else if ([n.name isEqualToString:@"MusicOnOff"]) {
                switch ([_audioPlayer isPlaying]) {
                    case YES:
                        _menu.isMusicPlaying = NO;
                        [_audioPlayer pause];
                        break;
                    case NO:
                        _menu.isMusicPlaying = YES;
                        [_audioPlayer play];
                        break;
                    default:
                        break;
                }
            }
        // Pause - resume game section block
        } else if (!_gameOver) {
            if (self.gamePaused) {
                if ([_resumeButton containsPoint:[touch locationInNode:_resumeButton.parent]]) {
                    self.gamePaused = NO;
                }
            } else {
                if ([_pauseButton containsPoint:[touch locationInNode:_pauseButton.parent]]) {
                    self.gamePaused = YES;
                }
            }
        }
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
        // We need this block in order to update trail position using CCBall custom class
        if ([node respondsToSelector:@selector(updateTrail)]) {
            [node performSelector:@selector(updateTrail) withObject:nil afterDelay:0.0];
        }
    }];
    
    [_mainLayer enumerateChildNodesWithName:@"shieldUP" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x + node.frame.size.width < 0) {
            [node removeFromParent];
        }
    }];
    
    [_mainLayer enumerateChildNodesWithName:@"cannonUP" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x + node.frame.size.width < 0) {
            [node removeFromParent];
        }
    }];
    
    [_mainLayer enumerateChildNodesWithName:@"halo" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x + node.frame.size.height < 0) {
            [node removeFromParent];
        }
    }];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
