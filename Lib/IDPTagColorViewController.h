//
//  IDPTagColorViewController.h
//  IDPTaggingParseServer
//
//  Created by 能登 要 on 2016/07/10.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IDPTagColorViewControllerDelegate;

@interface IDPTagColorViewController : UITableViewController

@property (assign,nonatomic) NSUInteger selectedIndex;
@property (weak,nonatomic) id<IDPTagColorViewControllerDelegate> delegate;

@end

@protocol IDPTagColorViewControllerDelegate <NSObject>

- (void) colorViewControllerDidSelectColor:(IDPTagColorViewController *)colorViewController;
- (void) colorViewControllerDidCancel:(IDPTagColorViewController *)colorViewController;

@end
