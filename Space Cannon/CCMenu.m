//
//  CCMenu.m
//  Space Cannon
//
//  Created by Fenkins on 16/08/15.
//  Copyright (c) 2015 Fenkins. All rights reserved.
//

#import "CCMenu.h"

@implementation CCMenu {
    SKLabelNode *_scoreLabel;
    SKLabelNode *_topScoreLabel;
    SKSpriteNode *_title;
    SKSpriteNode *_scoreBoard;
    SKSpriteNode *_playButton;
    SKSpriteNode *_musicButton;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _title = [SKSpriteNode spriteNodeWithImageNamed:@"Images/Title"];
        _title.position = CGPointMake(0, 140);
        [self addChild:_title];
        
        _scoreBoard = [SKSpriteNode spriteNodeWithImageNamed:@"Images/ScoreBoard"];
        _scoreBoard.position = CGPointMake(0, 70);
        [self addChild:_scoreBoard];
        
        _playButton = [SKSpriteNode spriteNodeWithImageNamed:@"Images/PlayButton"];
        _playButton.name = @"Play";
        _playButton.position = CGPointMake(-30, 0);
        [self addChild:_playButton];
        
        _musicButton = [SKSpriteNode spriteNodeWithImageNamed:@"Images/MusicOnButton"];
        _musicButton.name = @"MusicOnOff";
        _musicButton.position = CGPointMake(75, 0);
        [self addChild:_musicButton];
        
        _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
        _scoreLabel.fontSize = 30;
        _scoreLabel.position = CGPointMake(-52, -20);
        [_scoreBoard addChild:_scoreLabel];
        
        _topScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
        _topScoreLabel.fontSize = 30;
        _topScoreLabel.position = CGPointMake(48, -20);
        [_scoreBoard addChild:_topScoreLabel];
        
        self.score = 0;
        self.topScore = 0;
        self.touchable = YES;
    }
    return self;
}

-(void)hide {
    self.touchable = NO;
    
    SKAction *animateMenu = [SKAction scaleTo:0.0 duration:0.5];
    animateMenu.timingMode = SKActionTimingEaseIn;
    [self runAction:animateMenu completion:^{
        self.hidden = YES;
        self.xScale = 1.0;
        self.yScale = 1.0;
    }];
}

-(void)show {
    self.hidden = NO;
    self.touchable = NO;
    _title.position = CGPointMake(0, 280);
    _title.alpha = 0;
    
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.5];
    
    SKAction *animateTitle = [SKAction group:@[[SKAction moveToY:140 duration:0.5],
                                               fadeIn]];
    animateTitle.timingMode = SKActionTimingEaseOut;
    [_title runAction:animateTitle];
    _scoreBoard.xScale = 4.0;
    _scoreBoard.yScale = 4.0;
    _scoreBoard.alpha = 0;
    SKAction *animateScoreBoard = [SKAction group:@[[SKAction scaleTo:1.0 duration:0.5],
                                                    fadeIn]];
    animateScoreBoard.timingMode = SKActionTimingEaseOut;
    [_scoreBoard runAction:animateScoreBoard];
    
    _playButton.alpha = 0;
    SKAction *fadeInAnimation = [SKAction fadeInWithDuration:2.0];
    fadeInAnimation.timingMode = SKActionTimingEaseIn;
    [_playButton runAction:fadeInAnimation completion:^{
        self.touchable = YES;
    }];

    _musicButton.alpha = 0;
    [_musicButton runAction:fadeInAnimation completion:^{
        self.touchable = YES;
    }];
}

-(void)setIsMusicPlaying:(BOOL)isMusicPlaying {
    // First we should make sure we actually setted the value
    _isMusicPlaying = isMusicPlaying;

    switch (isMusicPlaying) {
        case YES:
            _musicButton.texture = [SKTexture textureWithImageNamed:@"Images/MusicOnButton"];
            break;
        case NO:
            _musicButton.texture = [SKTexture textureWithImageNamed:@"Images/MusicOffButton"];
            break;
        default:
            break;
    }
}

-(void)setScore:(int)score {
    _score = score;
    _scoreLabel.text = [[NSNumber numberWithInt:score]stringValue];
}

-(void)setTopScore:(int)topScore {
    _topScore = topScore;
    _topScoreLabel.text = [[NSNumber numberWithInt:topScore]stringValue];
}

@end
