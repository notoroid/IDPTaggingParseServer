//
//  IDPTagColorCell.m
//  LeftAlignedLayoutTest
//
//  Created by 能登 要 on 2016/07/10.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

#import "IDPTagColorCell.h"
#import "IDPTagColorCheckView.h"

@implementation IDPTagColorCell

- (void) awakeFromNib
{
    _checkView.hidden = YES;
    
    [_colorButton addTarget:self action:@selector(onTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_colorButton addTarget:self action:@selector(onTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_colorButton addTarget:self action:@selector(onTouchOutside:) forControlEvents:UIControlEventTouchUpOutside];
    
    [super awakeFromNib];
}

- (void) onTouchDown:(id)sender
{
    //    NSLog(@"onTouchDown: call");
    
    UIButton *button = [sender isKindOfClass:[UIButton class]] ? sender : nil;
    button.alpha = 0.5;
}

- (void) onTouchUpInside:(id)sender
{
    //    NSLog(@"onTouchUpInside: call");
    
    UIButton *button = [sender isKindOfClass:[UIButton class]] ? sender : nil;
    button.alpha = 1.0;
    
    [_delegate colorCellDidSelect:self];
}

- (void) onTouchOutside:(id)sender
{
    //    NSLog(@"onTouchOutside: call");
    
    UIButton *button = [sender isKindOfClass:[UIButton class]] ? sender : nil;
    button.alpha = 1.0;
}

@end
