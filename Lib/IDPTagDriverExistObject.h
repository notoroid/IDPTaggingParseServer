//
//  IDPTagDriverExistObject.h
//  IDPTaggingParseServer
//
//  Created by 能登 要 on 2016/07/10.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

#import "IDPTagDriver.h"

@interface IDPTagDriverExistObject : IDPTagDriver

- (nonnull instancetype) initWithObject:(nonnull PFObject *)object taggedObject:(nullable PFObject *)taggedObject from:(IDPTagDriverFrom)from;

- (nullable NSDate *)createdAt;
- (nullable id)objectForKey:(nonnull NSString *)key;
- (void)setObject:(nonnull id)object forKey:(nonnull NSString *)key;
- (nullable id)objectForKeyedSubscript:(nonnull NSString *)key;
- (void)setObject:(nonnull id)object forKeyedSubscript:(nonnull NSString *)key;

@property(readonly,nonatomic,nonnull) PFObject *tagObject;

@end
