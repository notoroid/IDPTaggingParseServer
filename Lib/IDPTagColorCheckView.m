//
//  IDPTagColorCheckView.m
//  IDPTaggingParseServer
//
//  Created by 能登 要 on 2016/07/10.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

#import "IDPTagColorCheckView.h"
#import "IDPTagStyleKit.h"

@implementation IDPTagColorCheckView

- (void) drawRect:(CGRect)rect
{
    [IDPTagStyleKit drawCheckColor];
}

@end
