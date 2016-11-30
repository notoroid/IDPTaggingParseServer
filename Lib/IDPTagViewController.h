//
//  IDPTagViewController.h
//  IDPTaggingParseServer
//
//  Created by 能登 要 on 2016/07/07.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IDPTagController;
@protocol IDPTagControllerDelegate;
@class IDPTagDriver;
@class PFObject;

@interface IDPTagViewController : UIViewController

+ (nonnull instancetype) tagViewControllerWithController;
+ (nonnull instancetype) tagViewControllerWithController:(nullable IDPTagController *)controller;

@property (strong, nonatomic, nonnull) IBOutlet IDPTagController *controller;
@property (weak,nonatomic,nullable) id<IDPTagControllerDelegate> delegate;

@end

@protocol IDPTagControllerDelegate <NSObject>

- (void) tagViewController:(nonnull IDPTagViewController *)tagViewController didDoneWithContainedInTags:(nonnull NSArray<PFObject *> *)containedInTags notContainedInTags:(nonnull NSArray<PFObject *> *)notContainedInTags;

- (void) tagViewController:(nonnull IDPTagViewController *)tagViewController didFailureWithError:(nullable NSError *)error;

@end

