//
//  CCCannon.m
//  Space Cannon
//
//  Created by Fenkins on 26/08/15.
//  Copyright (c) 2015 Fenkins. All rights reserved.
//

#import "CCCannon.h"

@implementation CCCannon
- (instancetype)init
{
    self = [super init];
    if (self) {
        _cannonPowerUpEnabled = NO;
    }
    return self;
}
@end
