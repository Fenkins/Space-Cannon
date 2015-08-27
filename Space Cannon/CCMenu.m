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
}

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
        
        _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
        _scoreLabel.fontSize = 30;
        _scoreLabel.position = CGPointMake(-52, 50);
        [self addChild:_scoreLabel];
        
        _topScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"DIN Alternate"];
        _topScoreLabel.fontSize = 30;
        _topScoreLabel.position = CGPointMake(48, 50);
        [self addChild:_topScoreLabel];
        
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
    self.hidden = NO;
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
