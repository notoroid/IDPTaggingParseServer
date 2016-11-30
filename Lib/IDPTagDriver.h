//
//  IDPTagDriver.h
//  IDPTaggingParseServer
//
//  Created by 能登 要 on 2016/07/10.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFObject;
@class IDPTagController;

typedef NS_ENUM(NSInteger,IDPTagDriverFrom)
{
     IDPTagDriverFromContainedIn
    ,IDPTagDriverFromNotContainedIn
    ,IDPTagDriverFromOrdered
};

@interface IDPTagDriver : NSObject

@property (strong,nonatomic,nullable) PFObject *taggedObject;
@property (assign,nonatomic) IDPTagDriverFrom from;
@property (assign,nonatomic,getter=isModified) BOOL modified;

- (nullable NSDate *)createdAt;
- (nullable id)objectForKey:(nonnull NSString *)key;
- (void)setObject:(nonnull id)object forKey:(nonnull NSString *)key;
- (nullable id)objectForKeyedSubscript:(nonnull NSString *)key;
- (void)setObject:(nonnull id)object forKeyedSubscript:(nonnull NSString *)key;

- (nullable IDPTagController *) controllerWithSourceController:(nonnull IDPTagController *)sourceController;

+ (nonnull IDPTagDriver *) tagDriverWithTag:(nullable PFObject *)tag taggedObject:(nullable PFObject *)taggedObject from:(IDPTagDriverFrom)from;
+ (nonnull NSArray<IDPTagDriver *> *) tagDriversWithTags:(nullable NSArray<PFObject *> *)tags taggedObject:(nullable PFObject *)taggedObject from:(IDPTagDriverFrom)from excludeTagObjectIDs:(nullable NSSet<NSString *> *)excludeTagObjectIDs;

@end
