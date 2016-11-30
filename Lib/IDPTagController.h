//
//  IDPTagController.h
//  IDPTaggingParseServer
//
//  Created by 能登 要 on 2016/06/21.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

#import <UIKit/UIKit.h>


#define IDP_TAG_NAME_KEY_NAME @"name"
#define IDP_TAG_COLOR_KEY_NAME @"color"
#define IDP_TAG_ORDER_KEY_NAME @"order"

#define IDP_ADDED_TAG_NOTIFICATION_NAME @"com.irimasu.AddedTag"
#define IDP_ADDED_TAG_NOTIFICATION_TAG @"tag"

#define IDP_COMMITED_TAG_NOTIFICATION_NAME @"com.irimasu.CommitedTag"
#define IDP_COMMITED_TAG_NOTIFICATION_TAG @"tag"

typedef NS_ENUM(NSInteger,PLTagControllerTagOption)
{
     PLTagControllerTagOptionContainedIn
    ,PLTagControllerTagOptionNotContainedIn
};

@class PFObject;
@class PFRelation;
@class PFQuery;

@interface IDPTagController : NSObject

@property (strong,nonatomic,nullable) PFObject *tag;

@property (strong,nonatomic,nullable) PFObject *taggedObject;

@property (strong,nonatomic,nullable) NSArray<PFObject *> *containedInTags;
@property (strong,nonatomic,nullable) NSArray<PFObject *> *notContainedInTags;
@property (strong,nonatomic,nullable) NSArray<PFObject *> *reservedTags;

@property (readonly,nonatomic,nonnull) NSMutableDictionary *dict;
@property (strong,nonatomic,nonnull) NSSortDescriptor *sortDescriptor;

- (void) findTagsWithOption:(PLTagControllerTagOption)option completion:(nullable void (^)(NSArray<PFObject *> * _Nullable tags,NSError * _Nullable error))completion;
- (nonnull PFQuery *) findTagsWithCompletion:(nullable void (^)(NSArray<PFObject *> * _Nullable tags,NSError * _Nullable error))completion;

- (void) findTagsWithKeyword:(nonnull NSString *)keyword completion:(nullable void (^)(NSArray * _Nullable tags,NSError * _Nullable error))completion;
- (void) findTagWithName:(nonnull NSString *)name completion:(nullable void (^)(PFObject * _Nullable tag,NSError * _Nullable error))completion;

- (void) commitTagWithCompletion:(nullable void (^)(PFObject * _Nullable tag,NSError * _Nullable error))completion;

+ (void) addObjectWithTags:(nonnull NSArray<PFObject *> *)tags object:(nonnull PFObject *)object relationKey:(nonnull NSString *)relationKey completion:(nullable void (^)(NSError * _Nullable error))completion;
+ (void) removeObjectWithTags:(nonnull NSArray<PFObject *> *)tags object:(nonnull PFObject *)object relationKey:(nonnull NSString *)relationKey completion:(nullable void (^)(NSError * _Nullable error))completion;

+ (nullable NSArray<PFObject *> *) filteredTagWithKeyword:(nonnull NSString *)keyword tags:(nullable NSArray<PFObject *> *)tags;

#pragma mark - Override methods

- (nonnull IDPTagController *) duplicateController;

- (nonnull NSArray<NSNumber *> *) reservedTagOrders;
- (nonnull  NSDictionary<NSNumber *,NSString *> *)tagNameByOrder;
- (nonnull  NSDictionary<NSString *,NSString *> *)colorsByTagName;

- (void) setupQuery:(nonnull PFQuery *)query;
- (void) applyQuery:(nonnull PFQuery *)query option:(PLTagControllerTagOption)option;
- (void) applyTag:(nonnull PFObject *)tag;

@end
