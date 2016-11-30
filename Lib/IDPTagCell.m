//
//  IDPTagCell.m
//  IDPTaggingParseServer
//
//  Created by 能登 要 on 2016/07/07.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

#import "IDPTagCell.h"

@implementation IDPTagCell

- (void) awakeFromNib
{
    _originalInformationButtonLeadingConstraint = _informationButtonLeadingConstraint.constant;
    _originalInformationButtonWidthConstraint = _informationButtonWidthConstraint.constant;
    _originalTitleLabelLeadingConstraint = _titleLabelLeadingConstraint.constant;
    
    [super awakeFromNib];
}

- (void) setSelected:(BOOL)selected
{
//    _titleLabel.alpha = selected ? 0.5 : 1.0;
    
    
    [super setSelected:selected];
}

- (IBAction)onInformation:(id)sender
{
    [_delegate tagCellDidSelectInformation:self];
}

@end
