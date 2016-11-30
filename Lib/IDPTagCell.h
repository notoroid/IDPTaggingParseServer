//
//  IDPTagCell.h
//  IDPTaggingParseServer
//
//  Created by 能登 要 on 2016/07/07.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IDPTagCellDelegate;

@interface IDPTagCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *informationButton;
@property (weak, nonatomic) IBOutlet UIView *tagBackgroundView;

@property (assign,nonatomic) CGFloat originalInformationButtonLeadingConstraint;
@property (assign,nonatomic) CGFloat originalInformationButtonWidthConstraint;
@property (assign,nonatomic) CGFloat originalTitleLabelLeadingConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *informationButtonLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *informationButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelLeadingConstraint;

@property (weak, nonatomic) id<IDPTagCellDelegate> delegate;

@end

@protocol IDPTagCellDelegate <NSObject>

- (void) tagCellDidSelectInformation:(IDPTagCell *)tagCell;

@end
