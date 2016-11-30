//
//  IDPTagController.m
//  IDPTaggingParseServer
//
//  Created by 能登 要 on 2016/06/21.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

#import "IDPTagController.h"
#import <Parse/Parse.h>

@interface IDPTagController ()
{
     NSMutableDictionary *_dict;
    
    PFQuery *_query;
    
    NSSortDescriptor *_tagSortDescriptor;
}
@property(readonly,nonnull) NSSortDescriptor *tagSortDescriptor;
@end

@implementation IDPTagController

- (nonnull IDPTagController *) duplicateController
{
    IDPTagController *duplicateController = [[IDPTagController alloc] init];
    return duplicateController;
}

- (void) setupQuery:(nonnull PFQuery *)query
{
    // ここは空実装
}

- (void) applyQuery:(nonnull PFQuery *)query option:(PLTagControllerTagOption)option
{
    // ここは空実装
}

- (void) applyTag:(nonnull PFObject *)tag
{
    // ここは空実装
}

- (NSArray<NSNumber *> *) reservedTagOrders
{
    return @[];
}

- (nonnull  NSDictionary<NSNumber *,NSString *> *)tagNameByOrder
{
    return @{};
}

- (nonnull  NSDictionary<NSString *,NSString *> *)colorsByTagName
{
    return @{};
}

- (NSSortDescriptor *) tagSortDescriptor
{
    if( _tagSortDescriptor == nil ){
        _tagSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:IDP_TAG_ORDER_KEY_NAME ascending:NO];
    }
    return _tagSortDescriptor;
}

- (NSMutableDictionary *)dict
{
    if( _dict == nil ){
        _dict = [NSMutableDictionary dictionary];
    }
    return _dict;
}

- (instancetype) init
{
    self = [super init];
    if (self != nil ) {
        _sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    }
    return self;
}

- (void) findTagsWithOption:(PLTagControllerTagOption)option completion:(void (^)(NSArray<PFObject *> * _Nullable tags,NSError * _Nullable error))completion
{
    PFQuery *query = [PFQuery queryWithClassName:@"Tag"];
    
    [query orderBySortDescriptors:@[self.tagSortDescriptor,_sortDescriptor]];
    
    [self setupQuery:query];
    
    if( _taggedObject != nil ){
        [self applyQuery:query option:option];
        
    }else if(option == PLTagControllerTagOptionContainedIn ){
        dispatch_async(dispatch_get_main_queue(), ^{
            if( completion != nil ){
                completion(nil,nil);
            }
        });
        return;
    }
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if( completion != nil ){
            completion(objects,error);
        }
    }];
}

- (PFQuery *) findTagsWithCompletion:(nullable void (^)(NSArray<PFObject *> * _Nullable tags,NSError * _Nullable error))completion
{
    PFQuery *query = [PFQuery queryWithClassName:@"Tag"];
    
    [query orderBySortDescriptors:@[self.tagSortDescriptor,_sortDescriptor]];
    
    [self setupQuery:query];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if( completion != nil ){
            completion(objects,error);
        }
    }];
    
    return query;
}

- (void) findTagsWithKeyword:(nonnull NSString *)keyword completion:(nullable void (^)(NSArray * _Nullable tags,NSError * _Nullable error))completion
{
    [_query cancel];
    
    _query = [PFQuery queryWithClassName:@"Tag"];
    
    [_query orderBySortDescriptors:@[self.tagSortDescriptor,_sortDescriptor]];
    
    [self setupQuery:_query];
    
    [_query whereKey:IDP_TAG_NAME_KEY_NAME containsString:keyword];
    
    [_query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if( completion != nil ){
            completion(objects,error);
        }
    }];
}

- (void) findTagWithName:(nonnull NSString *)name completion:(nullable void (^)(PFObject * _Nullable tag,NSError * _Nullable error))completion
{
    [_query cancel];
    
    _query = [PFQuery queryWithClassName:@"Tag"];
    
    [_query orderBySortDescriptors:@[self.tagSortDescriptor,_sortDescriptor]];
    
    [self setupQuery:_query];
    
    [_query whereKey:IDP_TAG_NAME_KEY_NAME equalTo:name];
    
    [_query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if( completion != nil ){
            completion(objects.firstObject,error);
        }
    }];
}

- (void) commitTagWithCompletion:(nullable void (^)(PFObject * _Nullable tag,NSError * _Nullable error))completion
{
    dispatch_block_t applyBlock = ^{
        
    };
    
    BOOL newTag = NO;
    if( _tag == nil ){
        newTag = YES;
        _tag = [PFObject objectWithClassName:@"Tag" dictionary:_dict];

        [self applyTag:_tag];
        
        applyBlock();
    }else{
        [_dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            _tag[key] = obj;
        }];
        
        applyBlock();
    }
    
    [_tag saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        _dict = nil;
        
        if( completion != nil ){
            
            if (newTag) {
                [[NSNotificationCenter defaultCenter] postNotificationName:IDP_ADDED_TAG_NOTIFICATION_NAME object:nil userInfo:@{IDP_ADDED_TAG_NOTIFICATION_TAG:_tag}];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:IDP_COMMITED_TAG_NOTIFICATION_NAME object:nil userInfo:@{IDP_COMMITED_TAG_NOTIFICATION_TAG:_tag}];
            }
            completion(_tag,error);
        }
    }];
}

+ (void) addObjectWithTags:(nonnull NSArray<PFObject *> *)tags object:(nonnull PFObject *)object relationKey:(nonnull NSString *)relationKey completion:(nullable void (^)(NSError * _Nullable error))completion
{
    [tags enumerateObjectsUsingBlock:^(PFObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PFRelation *relation = [obj relationForKey:relationKey];
        [relation addObject:object];
    }];
    
    [PFObject saveAllInBackground:tags block:^(BOOL succeeded, NSError * _Nullable error) {
        if( completion != nil ){
            completion(error);
        }
    }];
}

+ (void) removeObjectWithTags:(nonnull NSArray<PFObject *> *)tags object:(nonnull PFObject *)object relationKey:(nonnull NSString *)relationKey completion:(nullable void (^)(NSError * _Nullable error))completion
{
    [tags enumerateObjectsUsingBlock:^(PFObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PFRelation *relation = [obj relationForKey:relationKey];
        [relation removeObject:object];
    }];
    
    [PFObject saveAllInBackground:tags block:^(BOOL succeeded, NSError * _Nullable error) {
        if( completion != nil ){
            completion(error);
        }
    }];
}

+ (nullable NSArray<PFObject *> *) filteredTagWithKeyword:(nonnull NSString *)keyword tags:(NSArray<PFObject *> *)tags
{
    NSMutableArray *mutableTags = [NSMutableArray array];
    [tags enumerateObjectsUsingBlock:^(PFObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = [obj[IDP_TAG_NAME_KEY_NAME] description];
        NSRange range = [name rangeOfString:keyword];
        if( range.length != 0 ){
            [mutableTags addObject:obj];
        }
    }];
    return [NSArray arrayWithArray:mutableTags];
}

@end
