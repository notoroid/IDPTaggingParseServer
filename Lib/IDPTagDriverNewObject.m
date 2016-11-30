//
//  IDPTagDriverNewObject.m
//  IDPTaggingParseServer
//
//  Created by 能登 要 on 2016/07/10.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

#import "IDPTagDriverNewObject.h"
#import "IDPTagController.h"

@interface IDPTagDriverNewObject ()
{
    NSDate *_createdAt;
    NSMutableDictionary *_dict;
}
@property (readonly,nonatomic,nonnull) NSMutableDictionary *dict;
@end

@implementation IDPTagDriverNewObject

- (BOOL) isModified
{
    return self.dict.allValues.count > 0 ? YES : NO;
}

- (NSMutableDictionary *)dict
{
    if( _dict == nil ){
        _dict = [NSMutableDictionary dictionary];
    }
    return _dict;
}

- (nonnull instancetype) initWithTaggedObject:(nullable PFObject *)taggedObject from:(IDPTagDriverFrom)from
{
    self = [super init];
    if( self != nil ){
        self.taggedObject = taggedObject;
        self.from = from;
        _createdAt = [NSDate date];
    }
    return self;
}

- (NSDate *)createdAt
{
    return _createdAt;
}

- (nullable id)objectForKey:(NSString *)key
{
    return self.dict[key];
}

- (void)setObject:(nonnull id)object forKey:(NSString *)key
{
    self.dict[key] = object;
}

- (nullable id)objectForKeyedSubscript:(NSString *)key
{
    return [self objectForKey:key];
}

- (void)setObject:(nonnull id)object forKeyedSubscript:(NSString *)key
{
    [self setObject:object forKey:key];
}

- (nullable IDPTagController *) controllerWithSourceController:(nonnull IDPTagController *)sourceController
{
    IDPTagController *controller = [sourceController duplicateController];
    
    [self.dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        controller.dict[key] = obj;
    }];
    
    return controller;
}

@end
