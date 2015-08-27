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
        _playButton.position = CGPointMake(0, 0);
        [self addChild:_playButton];
        
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
    self.hidden = YES;
}

-(void)show {
    self.touchable = YES;
    _title.position = CGPointMake(0, 280);
    _title.alpha = 0;
    
    SKAction *fadeIn = [SKAction fadeInWithDuration:0.5];
    
    SKAction *animateTitle = [SKAction group:@[[SKAction moveToY:140 duration:0.5],
                                               fadeIn]];
    animateTitle.timingMode = SKActionTimingEaseOut;
    [_title runAction:animateTitle];
    self.hidden = NO;
    _scoreBoard.xScale = 4.0;
    _scoreBoard.yScale = 4.0;
    _scoreBoard.alpha = 0;
    SKAction *animateScoreBoard = [SKAction group:@[[SKAction scaleTo:1.0 duration:0.5],
                                                    fadeIn]];
    animateScoreBoard.timingMode = SKActionTimingEaseOut;
    [_scoreBoard runAction:animateScoreBoard];
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
