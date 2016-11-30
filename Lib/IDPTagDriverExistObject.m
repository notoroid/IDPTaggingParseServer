//
//  IDPTagDriverExistObject.m
//  IDPTaggingParseServer
//
//  Created by 能登 要 on 2016/07/10.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

#import "IDPTagDriverExistObject.h"
#import <Parse/Parse.h>
#import "IDPTagController.h"

@interface IDPTagDriverExistObject ()
{
    PFObject *_tag;
    NSMutableDictionary *_dict;
}
@property (readonly,nonatomic,nonnull) NSMutableDictionary *dict;
@end

@implementation IDPTagDriverExistObject

- (PFObject *)tagObject
{
    return _tag;
}

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

- (instancetype) initWithObject:(PFObject *)object taggedObject:(PFObject *)taggedObject from:(IDPTagDriverFrom)from
{
    self = [super init];
    if( self != nil ){
        _tag = object;
        self.taggedObject = taggedObject;
        self.from = from;
    }
    return self;
}

- (NSDate *)createdAt
{
    return _tag.createdAt;
}

- (nullable id)objectForKey:(NSString *)key
{
    return self.dict[key] != nil ? self.dict[key] : [_tag objectForKey:key];
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
    
    controller.tag = _tag;
    
    [self.dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        controller.dict[key] = obj;
    }];
    
    return controller;
}


@end
