//
//  IDPTagColorCell.h
//  LeftAlignedLayoutTest
//
//  Created by 能登 要 on 2016/07/10.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IDPTagColorCheckView;

@protocol  IDPTagColorCellDelegate;

@interface  IDPTagColorCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *colorButton;
@property (weak, nonatomic) IBOutlet UIView *checkView;

@property (weak,nonatomic) id< IDPTagColorCellDelegate> delegate;

@end

@protocol  IDPTagColorCellDelegate <NSObject>

- (void) colorCellDidSelect:( IDPTagColorCell *)colorCell;

@end
