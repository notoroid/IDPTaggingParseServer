//
//  IDPTagDriver.m
//  IDPTaggingParseServer
//
//  Created by 能登 要 on 2016/07/10.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

#import "IDPTagDriver.h"
#import "IDPTagDriverExistObject.h"
#import "IDPTagDriverNewObject.h"
#import <Parse/Parse.h>

@implementation IDPTagDriver

- (BOOL) isModified
{
    return FALSE;
}

- (NSDate *)createdAt
{
    return nil;
}

- (nullable id)objectForKey:(NSString *)key
{
    return nil;
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    
}

- (nullable id)objectForKeyedSubscript:(NSString *)key
{
    return [self objectForKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key
{
    [self setObject:object forKeyedSubscript:key];
}

+ (nonnull IDPTagDriver *) tagDriverWithTag:(nullable PFObject *)tag taggedObject:(nullable PFObject *)taggedObject from:(IDPTagDriverFrom)from
{
    IDPTagDriver *driver = nil;
    if( tag != nil ){
        driver = [[IDPTagDriverExistObject alloc] initWithObject:tag taggedObject:taggedObject from:from];
    }else{
        driver = [[IDPTagDriverNewObject alloc] initWithTaggedObject:taggedObject from:from];
    }
    return driver;
}

+ (nonnull NSArray<IDPTagDriver *> *) tagDriversWithTags:(nullable NSArray<PFObject *> *)tags taggedObject:(nullable PFObject *)taggedObject from:(IDPTagDriverFrom)from excludeTagObjectIDs:(nullable NSSet<NSString *> *)excludeTagObjectIDs
{
    NSMutableArray<IDPTagDriver *> *mutableArray = [NSMutableArray array];
    
    [tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PFObject *tag = obj;
        
        if( [excludeTagObjectIDs containsObject:tag.objectId] != YES ){
            IDPTagDriver *driver = [IDPTagDriver tagDriverWithTag:tag taggedObject:taggedObject from:from];
            [mutableArray addObject:driver];
        }
    }];
    
    return [NSArray<IDPTagDriver *> arrayWithArray:mutableArray];
}

- (nullable IDPTagController *) controllerWithSourceController:(nonnull IDPTagController *)sourceController
{
    return nil;
}

@end
