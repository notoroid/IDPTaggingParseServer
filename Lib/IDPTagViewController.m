//
//  IDPTagViewController.m
//  IDPTaggingParseServer
//
//  Created by 能登 要 on 2016/07/07.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

#import "IDPTagViewController.h"
#import <UICollectionViewLeftAlignedLayout/UICollectionViewLeftAlignedLayout.h>
#import "IDPTagCell.h"
#import "IDPTagTitleView.h"
#import "IDPTagStyleKit.h"
#import "IDPTagColorViewController.h"
#import "IDPTagController.h"
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>
#import "IDPTagDriver.h"
#import "IDPTagDriverExistObject.h"
#import "IDPTagDriverNewObject.h"
#import "UIColor+IDPTag.h"

static NSDateFormatter *s_dateFormatterNormalized = nil;

@interface IDPTagViewController () <UICollectionViewDelegate,UICollectionViewDataSource,IDPTagCellDelegate,IDPTagColorViewControllerDelegate>
{
    __weak IBOutlet UICollectionView *_collectionView;
    __weak IBOutlet UICollectionViewLeftAlignedLayout *_layout;
    
    NSArray<IDPTagDriver *> *_selectedTags;
    NSArray<IDPTagDriver *> *_tags;
    NSArray<IDPTagDriver *> *_deletedTagas;
    
    IBOutlet UIBarButtonItem *_addBarItem;
    
    NSIndexPath *_menuIndexPath;
    
    NSArray<NSString *> *_tagColors;
    
    UIMenuController* _menu;
    
    BOOL _initialized;
}
@end

@implementation IDPTagViewController

+ (nonnull instancetype) tagViewControllerWithController
{
    return [IDPTagViewController tagViewControllerWithController:nil];
}

+ (nonnull instancetype) tagViewControllerWithController:(nullable IDPTagController *)controller
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TaggingParseServer" bundle:nil];
    IDPTagViewController *tagViewController = [storyboard instantiateViewControllerWithIdentifier:@"tagViewController"];
    if( controller != nil ){
        tagViewController.controller = controller;
    }
    return tagViewController;
}

- (NSArray<NSString *> *) tagColors
{
    if( _tagColors == nil ){
        _tagColors = @[  @"#EE1B5A"
                        ,@"#EF840F"
                        ,@"#52CC9D"
                        ,@"#0FA1E7"
                        ,@"#BB68D0"
                        ,@"#937451"
                        ,@"#CC5252"
                        ,@"#A6CC52"
                        ,@"#525BCC"
                        ,@"#CC52B0"
                        ,@"#CC9452"
                        ,@"#64CC52"
                        ,@"#52B9CC"
                        ,@"#8A52CC"
                        ,@"#5BC7C7"
                        ,@"#CA4849"
                        ,@"#DF9B5E"
                        ,@"#6267BB"
                        ,@"#4793C5"
                        ,@"#3CA07F"
                        ,@"#B3C265"
                        ,@"#92A3B2"
                        ,@"#D27F61"
                       ];
    }
    return _tagColors;
}

- (NSDate *) generateCreateAt:(NSInteger)minutes
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_dateFormatterNormalized = [[NSDateFormatter alloc] init];
        [s_dateFormatterNormalized setDateFormat:@"yyyy:MM:dd hh:mm:ss"];
    });
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSString *format = [NSString stringWithFormat:@"yyyy:MM:dd hh:%02ld:00",(long)minutes];
    [dateFormatter setDateFormat:format];
    NSString *string = [dateFormatter stringFromDate:[NSDate date]];
    NSDate *date = [s_dateFormatterNormalized dateFromString:string];
    return date;
}

- (IBAction)onAddButton:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"タグの追加" message:@"タグ名を指定してください。" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"タグ名";
    }];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __block NSString *alertMessage = nil;
        
        NSString *tagName = [alertController.textFields[0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if( tagName.length  > 0){
            NSMutableArray *mutableArray = [NSMutableArray array];
            [mutableArray addObjectsFromArray:_selectedTags];
            [mutableArray addObjectsFromArray:_tags];
            
            NSArray *array = [NSArray arrayWithArray:mutableArray];
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *dict = obj;
#define NAME_KEY @"name"
                NSString *existTagName = dict[NAME_KEY];
                if( [existTagName isEqualToString:tagName] ){
                    alertMessage = @"既に存在するタグ名を指定することできません。";
                    *stop = YES;
                }
            }];
        }else{
            alertMessage = @"タグ名は1文字以上必要です。";
        }
        
        if( alertMessage != nil ){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"タグの追加" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
 
            [self presentViewController:alertController animated:YES completion:^{
                
            }];
        }else{
//#define CREATED_AT_KEY @"createdAt"
//#define TAG_COLOR_KEY @"tagColor"
//            NSDictionary *dict = @{ NAME_KEY:tagName
//                                    ,TAG_COLOR_KEY:self.tagColors[_iterator]
//                                    ,CREATED_AT_KEY:[NSDate date]
//                                    };
            NSMutableArray<NSString *> *mutableArray = [NSMutableArray<NSString *> array];
            
            [_selectedTags enumerateObjectsUsingBlock:^(IDPTagDriver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *tagColor = [obj objectForKey:IDP_TAG_COLOR_KEY_NAME];
                [mutableArray addObject:tagColor];
            }];
            [_tags enumerateObjectsUsingBlock:^(IDPTagDriver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *tagColor = [obj objectForKey:IDP_TAG_COLOR_KEY_NAME];
                [mutableArray addObject:tagColor];
            }];

            NSMutableSet<NSString *> *setCandidateTagColors = [NSMutableSet<NSString *> setWithArray:self.tagColors];
            NSSet<NSString *> *setExistTagColors = [NSSet<NSString *> setWithArray:mutableArray];
            
            [setCandidateTagColors minusSet:setExistTagColors];
            
            NSString *tagColor = setCandidateTagColors.count > 0 ? setCandidateTagColors.anyObject : self.tagColors[0];
            
            IDPTagDriver *tag = [IDPTagDriver tagDriverWithTag:nil taggedObject:_controller.taggedObject from:IDPTagDriverFromContainedIn];
            tag[IDP_TAG_NAME_KEY_NAME] = tagName;
            tag[IDP_TAG_COLOR_KEY_NAME] = tagColor;
            
            NSMutableArray *mutavleArray = [NSMutableArray arrayWithArray:_selectedTags];
            [mutavleArray addObject:tag];
            _selectedTags = [NSArray arrayWithArray:mutavleArray];
            
            [_collectionView performBatchUpdates:^{
                [_collectionView insertItemsAtIndexPaths:@[ [NSIndexPath indexPathForRow:_selectedTags.count-1 inSection:0]]];
            } completion:^(BOOL finished) {
                
            }];
        }
        
    }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:^{
       
    }];
}

- (IBAction)onDone:(id)sender
{
    NSArray<IDPTagDriverExistObject *> *deleteTagDrivers = nil;
    {
        NSMutableArray<IDPTagDriverExistObject *> *mutableDeleteTags = [NSMutableArray array];
        [_deletedTagas enumerateObjectsUsingBlock:^(IDPTagDriver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if( [obj isKindOfClass:[IDPTagDriverExistObject class]] ){
                [mutableDeleteTags addObject:(IDPTagDriverExistObject *)obj];
            }
        }];

        // 削除対象のタグ
        deleteTagDrivers = [NSArray<IDPTagDriverExistObject *> arrayWithArray:mutableDeleteTags];
    }
    
    // 保存に必要なクラスを作成
    __block NSArray<IDPTagDriver *> *selectedTagDrivers = nil;
    NSArray<IDPTagDriver *> *tagDrivers = nil;
    NSArray<IDPTagDriver *> *modifiedTagDrivers = nil;

    {
        NSMutableArray<IDPTagDriver *> *mutableModifiedTags = [NSMutableArray array];
        
        {
            NSMutableArray<IDPTagDriver *> *mutableSelectedTags = [NSMutableArray array];
            [_selectedTags enumerateObjectsUsingBlock:^(IDPTagDriver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if( [obj isKindOfClass:[IDPTagDriverNewObject class]] ){
                    [mutableSelectedTags addObject:obj];
                }else{
                    if( obj.from == IDPTagDriverFromNotContainedIn ){
                        [mutableSelectedTags addObject:obj];
                    }
                }
                
                if( obj.modified == YES ){
                    [mutableModifiedTags addObject:obj];
                }
            }];
            selectedTagDrivers = [NSArray<IDPTagDriver *> arrayWithArray:mutableSelectedTags];
        }
        
        
        {
            NSMutableArray<IDPTagDriver *> *mutableTags = [NSMutableArray array];
            [_tags enumerateObjectsUsingBlock:^(IDPTagDriver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if( [obj isKindOfClass:[IDPTagDriverNewObject class]] ){
                    
                }else{
                    if( obj.from == IDPTagDriverFromContainedIn ){
                        [mutableTags addObject:obj];
                    }
                }
                
                if( obj.modified == YES ){
                    [mutableModifiedTags addObject:obj];
                }
            }];
            tagDrivers = [NSArray<IDPTagDriver *> arrayWithArray:mutableTags];
        }
        
        modifiedTagDrivers = [NSArray<IDPTagDriver *> arrayWithArray:mutableModifiedTags];
    }
    
    __block BFTask *task = [BFTask taskWithResult:nil];
    if( deleteTagDrivers.count > 0 ){
        NSMutableArray<PFObject *> *mutableArray = [NSMutableArray<PFObject *> array];
        [deleteTagDrivers enumerateObjectsUsingBlock:^(IDPTagDriverExistObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [mutableArray addObject:obj.tagObject];
        }];
        
        task = [task continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
            BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];
            
            [PFObject deleteAllInBackground:[NSArray<PFObject *> arrayWithArray:mutableArray] block:^(BOOL succeeded, NSError * _Nullable error) {
               
                if( error == nil ){
                    [taskCompletionSource setResult:@{}];
                }else{
                    [taskCompletionSource setError:error];
                }
            }];
            return taskCompletionSource.task;
        }];
    }
    
    NSMutableArray<IDPTagDriver *> *mutableSelectedTagDrivers = [NSMutableArray arrayWithArray:selectedTagDrivers];

    if( modifiedTagDrivers.count ){
        [modifiedTagDrivers enumerateObjectsUsingBlock:^(IDPTagDriver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            // コントローラを設定
            IDPTagController *controller = [obj controllerWithSourceController:_controller];
            
            task = [task continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
                BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

                [controller commitTagWithCompletion:^(PFObject * _Nullable tag, NSError * _Nullable error) {
                    
                    if( error == nil ){
                        NSUInteger index = [mutableSelectedTagDrivers indexOfObject:obj];
                        if( index < mutableSelectedTagDrivers.count ){
                            mutableSelectedTagDrivers[index] = [IDPTagDriver tagDriverWithTag:tag taggedObject:_controller.taggedObject from:IDPTagDriverFromNotContainedIn];
                        }
                        [taskCompletionSource setResult:@{}];
                    }else{
                        [taskCompletionSource setError:error];
                    }
                }];
                
                return taskCompletionSource.task;
            }];
        }];
    }
    
    NSMutableArray<PFObject *> *mutableTags = [NSMutableArray<PFObject *> array];
    task = [task continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        selectedTagDrivers = [NSArray<IDPTagDriver *> arrayWithArray:mutableSelectedTagDrivers];
        
        NSMutableArray<PFObject *> *mutableSelectedTags = [NSMutableArray<PFObject *> array];
        [selectedTagDrivers enumerateObjectsUsingBlock:^(IDPTagDriver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            IDPTagDriverExistObject *tagDriverExistObject = [obj isKindOfClass:[IDPTagDriverExistObject class]] ? (IDPTagDriverExistObject *)obj : nil;
            
            PFObject *tagObject = tagDriverExistObject.tagObject;
            if( tagObject != nil ){
                [mutableSelectedTags addObject:tagObject];
            }
        }];
        
        [tagDrivers enumerateObjectsUsingBlock:^(IDPTagDriver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            IDPTagDriverExistObject *tagDriverExistObject = [obj isKindOfClass:[IDPTagDriverExistObject class]] ? (IDPTagDriverExistObject *)obj : nil;
            
            PFObject *tagObject = tagDriverExistObject.tagObject;
            if( tagObject != nil ){
                [mutableTags addObject:tagObject];
            }
        }];
        
        [_delegate tagViewController:self didDoneWithContainedInTags:[NSArray<PFObject *> arrayWithArray:mutableSelectedTags] notContainedInTags:[NSArray<PFObject *> arrayWithArray:mutableTags]];
        
        return nil;
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationItem setRightBarButtonItems:@[self.editButtonItem,_addBarItem] animated:YES];

    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    _selectedTags = @[];
    _tags = @[];
    _deletedTagas = @[];

    _collectionView.hidden = YES;

}

- (void) viewDidAppear:(BOOL)animated
{
    if( _initialized != YES ){
        _initialized = YES;
        
        BFTask *task = [BFTask taskWithResult:nil];

        NSSet<NSString *> *setExcludeTagObjectIDs = nil;
        {
            NSMutableArray<NSString *> *mutableArray = [NSMutableArray<NSString *> array];
            [_controller.containedInTags enumerateObjectsUsingBlock:^(PFObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [mutableArray addObject:obj.objectId];
            }];
            
            [_controller.notContainedInTags enumerateObjectsUsingBlock:^(PFObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [mutableArray addObject:obj.objectId];
            }];
            
            /*NSSet<NSString *> **/setExcludeTagObjectIDs = [NSSet<NSString *> setWithArray:mutableArray];
        }
        
        task = [task continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

            [_controller findTagsWithOption:PLTagControllerTagOptionContainedIn completion:^(NSArray<PFObject *> *tags, NSError *error) {
                
                if( error == nil ){
                    _selectedTags = [IDPTagDriver tagDriversWithTags:tags taggedObject:_controller.taggedObject from:IDPTagDriverFromContainedIn excludeTagObjectIDs:setExcludeTagObjectIDs];
//#define PL_TAG_SELECTED_TAGS @"selectedTags"
                    [taskCompletionSource setResult:@{/*PL_TAG_SELECTED_TAGS:tags*/}];
                }else{
                    [taskCompletionSource setError:error];
                }
            }];
            
            return taskCompletionSource.task;
        }];

        task = [task continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            
            BFTaskCompletionSource *taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

            [_controller findTagsWithOption:PLTagControllerTagOptionNotContainedIn completion:^(NSArray<PFObject *> *tags, NSError *error) {
                
//                [tags enumerateObjectsUsingBlock:^(PFObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    NSLog(@"tag.name=%@",obj[IDP_TAG_NAME_KEY_NAME]);
//                }];
                
                if( error == nil ){
                    NSArray<NSNumber *> *reservedTagOrders = [_controller reservedTagOrders];
                    
                    NSMutableSet *setReservedTagOrders = [NSMutableSet setWithArray:reservedTagOrders];
                    
                    NSMutableArray<IDPTagDriver *> *containedTags = [NSMutableArray<IDPTagDriver *> arrayWithArray:_selectedTags];
                    [containedTags addObjectsFromArray:[IDPTagDriver tagDriversWithTags:_controller.containedInTags taggedObject:_controller.taggedObject from:IDPTagDriverFromNotContainedIn excludeTagObjectIDs:nil]];

                    // 選択済みタグに含まれるオーダー順番付きタグを削除
                    [containedTags enumerateObjectsUsingBlock:^(IDPTagDriver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                       IDPTagDriver *tagDriver = obj;
                        
                        NSNumber *order = tagDriver[IDP_TAG_ORDER_KEY_NAME];
                        if( [setReservedTagOrders containsObject:order] ){
                            [setReservedTagOrders removeObject:order];
                        }
                    }];
                    

                    // 特殊な操作
                    // order付きTagは存在するものとして扱う(実際は生成時に決定)
                    
                    NSMutableArray<IDPTagDriver *> *mutableTags = [NSMutableArray<IDPTagDriver *> arrayWithArray:[IDPTagDriver tagDriversWithTags:tags taggedObject:_controller.taggedObject from:IDPTagDriverFromNotContainedIn excludeTagObjectIDs:setExcludeTagObjectIDs]];
                    
                    NSMutableDictionary<NSNumber *,IDPTagDriver *> *orderedTagDriversByOrder = [NSMutableDictionary<NSNumber *,IDPTagDriver *> dictionary];
                        // オーダー付きタグ
                    [mutableTags enumerateObjectsUsingBlock:^(IDPTagDriver * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSNumber *order = obj[IDP_TAG_ORDER_KEY_NAME];
                        if( order != nil ){
                            // オーダー付きは除外対象
                            orderedTagDriversByOrder[order] = obj;
                        }
                    }];
                    
                    [mutableTags removeObjectsInArray:orderedTagDriversByOrder.allValues];
                        // オーダー対象を一時除外
                    
                    // オーダー順に配置
                    NSMutableArray<IDPTagDriver *> *mutableOrderedTagDrivers = [NSMutableArray<IDPTagDriver *> array];
                    [reservedTagOrders enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSNumber *order = obj;

                        // 選択済みタグ以外を対象とするためsetReservedTagOrders に含まれているかを確認する
                        if( [setReservedTagOrders containsObject:order] ){
                            IDPTagDriver *tagDriver = orderedTagDriversByOrder[order];
                            
                            // 作成済みのタグがない場合は追加しておく 
                            if( tagDriver == nil ){
                                NSString *tagName = [_controller tagNameByOrder][order];
//                                NSLog(@"tagName=%@",tagName);
                                
                                if( tagName != nil ){
                                    tagDriver = [IDPTagDriver tagDriverWithTag:nil taggedObject:_controller.taggedObject from:IDPTagDriverFromNotContainedIn];
                                    tagDriver[IDP_TAG_NAME_KEY_NAME] = tagName;
                                    tagDriver[IDP_TAG_ORDER_KEY_NAME] = order;
                                        // オーダー番号とタグ名を設定
                                    
                                    NSString *tagColor = [_controller colorsByTagName][tagName];
                                    if( tagColor !=nil ){
                                        tagDriver[IDP_TAG_COLOR_KEY_NAME] = tagColor;
                                    }
                                }
                            }
                            
                            [mutableOrderedTagDrivers addObject:tagDriver];
                        }else{
                            
                        }
                    }];
                    
                    if( mutableOrderedTagDrivers.count > 0 ){
                        _tags = [NSArray<IDPTagDriver *> arrayWithArray:mutableOrderedTagDrivers];
                        _tags = [_tags arrayByAddingObjectsFromArray:mutableTags];
                    }else{
                        _tags = [NSArray<IDPTagDriver *> arrayWithArray:mutableTags];
                    }
                    
                    [taskCompletionSource setResult:@{}];
                }else{
                    [taskCompletionSource setError:error];
                }
            }];
            
            return taskCompletionSource.task;
        }];
 
        task = [task continueWithExecutor:[BFExecutor mainThreadExecutor] withSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            
            NSMutableArray<IDPTagDriver *> *mutableArray = [NSMutableArray<IDPTagDriver *> arrayWithArray:_selectedTags];
            [mutableArray addObjectsFromArray:[IDPTagDriver tagDriversWithTags:_controller.containedInTags taggedObject:_controller.taggedObject from:IDPTagDriverFromNotContainedIn excludeTagObjectIDs:nil]];
            _selectedTags = [NSArray<IDPTagDriver *> arrayWithArray:mutableArray];
            
            /*NSMutableArray<IDPTagDriver *> **/ mutableArray = [NSMutableArray<IDPTagDriver *> arrayWithArray:_tags];
            [mutableArray addObjectsFromArray:[IDPTagDriver tagDriversWithTags:_controller.notContainedInTags taggedObject:_controller.taggedObject from:IDPTagDriverFromContainedIn excludeTagObjectIDs:nil]];
            _tags = [NSArray<IDPTagDriver *> arrayWithArray:mutableArray];
            
            [_collectionView reloadData];
            _collectionView.hidden = NO;
            
            return nil;
        }];
    }
    
    [super viewDidAppear:animated];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:(BOOL)animated];
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    [_selectedTags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutableArray addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
    }];
    [_tags enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       [mutableArray addObject:[NSIndexPath indexPathForRow:idx inSection:1]];
    }];
    
    [_collectionView performBatchUpdates:^{
        [_collectionView reloadItemsAtIndexPaths:mutableArray];
    } completion:^(BOOL finished) {
       
    }];
    
    
    if( editing ){
        [self.navigationController setToolbarHidden:YES animated:YES];
    }else{
        [self.navigationController setToolbarHidden:NO animated:YES];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger number = 0;
    switch (section) {
        case 0:
            number = _selectedTags.count;
            break;
        case 1:
            number = _tags.count;
            break;
        default:
            break;
    }
    
    return number;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tagCell" forIndexPath:indexPath];
    IDPTagCell *tagCell = [cell isKindOfClass:[IDPTagCell class]] ? (IDPTagCell *)cell : nil;
    
    switch (indexPath.section) {
        case 0:
        {
            IDPTagDriver *tag = _selectedTags[indexPath.row];
            NSString *tagColor = tag[IDP_TAG_COLOR_KEY_NAME];
            
            tagCell.titleLabel.text = [tag[IDP_TAG_NAME_KEY_NAME] description];
            tagCell.tagBackgroundView.backgroundColor = [UIColor colorWithWebColor:tagColor];
        }
            break;
        case 1:
        {
            IDPTagDriver *tag = _tags[indexPath.row];
            NSString *tagColor = tag[IDP_TAG_COLOR_KEY_NAME];
            
            tagCell.titleLabel.text = [tag[IDP_TAG_NAME_KEY_NAME] description];
            tagCell.tagBackgroundView.backgroundColor = [UIColor colorWithWebColor:tagColor];
        }
            break;
        default:
            break;
    }
 
    [tagCell.informationButton setTitle:nil forState:UIControlStateNormal];
    [tagCell.informationButton setImage:[IDPTagStyleKit imageOfTagInformation] forState:UIControlStateNormal];
    
    if( self.editing ){
        tagCell.informationButtonWidthConstraint.constant = tagCell.originalInformationButtonWidthConstraint;
        tagCell.informationButtonLeadingConstraint.constant = tagCell.originalInformationButtonLeadingConstraint;
        tagCell.titleLabelLeadingConstraint.constant = tagCell.originalTitleLabelLeadingConstraint;
    }else{
        tagCell.informationButtonWidthConstraint.constant = 0;
        tagCell.informationButtonLeadingConstraint.constant = 0;
        tagCell.titleLabelLeadingConstraint.constant = 0;
    }
    
    tagCell.delegate = self;
    
    
    return cell;
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    
    if( [kind isEqualToString:UICollectionElementKindSectionHeader] ){
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"titleView" forIndexPath:indexPath];
        IDPTagTitleView *titleView = [reusableView isKindOfClass:[IDPTagTitleView class]] ? (IDPTagTitleView *)reusableView : nil;
        titleView.titleLabel.text = indexPath.section == 0 ? @"タグ付け済み" : @"未タグ付け";
    }
    
    return reusableView;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 8;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(8, 8, 8, 8);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *textContent = nil;
    switch (indexPath.section) {
        case 0:
        {
            IDPTagDriver *tag = _selectedTags[indexPath.row];
            textContent = [tag[IDP_TAG_NAME_KEY_NAME] description];
        }
            break;
        case 1:
        {
            IDPTagDriver *tag = _tags[indexPath.row];
            textContent = [tag[IDP_TAG_NAME_KEY_NAME] description];
        }
            break;
        default:
            break;
    }
    
    CGRect textRect = CGRectMake(0, 0, CGFLOAT_MAX, CGFLOAT_MAX);

    static NSDictionary*s_textFontAttributes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableParagraphStyle* textStyle = [NSMutableParagraphStyle new];
        textStyle.alignment = NSTextAlignmentLeft;
         s_textFontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize: UIFont.labelFontSize], NSForegroundColorAttributeName: UIColor.blackColor, NSParagraphStyleAttributeName: textStyle};
    });
    CGFloat width = [textContent boundingRectWithSize: CGSizeMake(textRect.size.width, INFINITY)  options: NSStringDrawingUsesLineFragmentOrigin attributes:s_textFontAttributes context: nil].size.width;
    
    CGSize size = CGSizeMake(width + 22 + 16, 30);
    return size;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if( self.editing != YES ){
        NSMutableArray<IDPTagDriver *> *mutableArrayTagged = [NSMutableArray<IDPTagDriver *> arrayWithArray:_selectedTags];
        NSMutableArray<IDPTagDriver *> *mutableArray = [NSMutableArray<IDPTagDriver *> arrayWithArray:_tags];
        
        switch (indexPath.section) {
            case 0:
            {
                IDPTagDriver *tag = mutableArrayTagged[indexPath.row];
                [mutableArrayTagged removeObject:tag];
                
                [mutableArray addObject:tag];
                [mutableArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    IDPTagDriver *tag1 = obj1;
                    IDPTagDriver *tag2 = obj2;
                    
                    return [tag1.createdAt compare:tag2.createdAt];
                }];
                NSInteger row = [mutableArray indexOfObject:tag];
                NSIndexPath *indexPathAdded = [NSIndexPath indexPathForRow:row inSection:1];
                
                _selectedTags = [NSArray<IDPTagDriver *> arrayWithArray:mutableArrayTagged];
                _tags = [NSArray<IDPTagDriver *> arrayWithArray:mutableArray];
                
                [collectionView performBatchUpdates:^{
                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                    [collectionView insertItemsAtIndexPaths:@[indexPathAdded]];
                } completion:^(BOOL finished) {
                   
                }];
            }
                break;
            case 1:
            {
                IDPTagDriver *tag = mutableArray[indexPath.row];
                [mutableArray removeObject:tag];
                
                [mutableArrayTagged addObject:tag];
                [mutableArrayTagged sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                    IDPTagDriver *tag1 = obj1;
                    IDPTagDriver *tag2 = obj2;
                    
                    return [tag1.createdAt compare:tag2.createdAt];
                }];
                NSInteger row = [mutableArrayTagged indexOfObject:tag];
                NSIndexPath *indexPathAdded = [NSIndexPath indexPathForRow:row inSection:0];

                _selectedTags = [NSArray arrayWithArray:mutableArrayTagged];
                _tags = [NSArray arrayWithArray:mutableArray];
                
                [collectionView performBatchUpdates:^{
                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                    [collectionView insertItemsAtIndexPaths:@[indexPathAdded]];
                } completion:^(BOOL finished) {
                    
                }];
            }
                break;
            default:
                break;
        }
    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (BOOL) canBecomeFirstResponder
{
    return YES;
}

- (void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"collectionView: didDeselectItemAtIndexPath: call");
//    NSLog(@"indexPath=%@",indexPath);
}

- (void) onTagColor:(id)sender
{
    [self performSegueWithIdentifier:@"tagColorSegue" sender:nil];
    
}

- (void) onDeleteTag:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"タグの削除" message:@"タグを削除してもよろしいでしょうか?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"削除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        switch (_menuIndexPath.section) {
            case 0:
            {
                NSMutableArray<IDPTagDriver *> *mutableArray= [NSMutableArray<IDPTagDriver *> arrayWithArray:_selectedTags];
                IDPTagDriver *tag = [mutableArray objectAtIndex:_menuIndexPath.row];
                [mutableArray removeObject:tag];
                _selectedTags = [NSArray<IDPTagDriver *> arrayWithArray:mutableArray];
                
                /*NSMutableArray<IDPTagDriver *> **/mutableArray = [NSMutableArray<IDPTagDriver *> arrayWithArray:_deletedTagas];
                [mutableArray addObject:tag];
                _deletedTagas = [NSArray<IDPTagDriver *> arrayWithArray:mutableArray];
                
                
                [_collectionView performBatchUpdates:^{
                    [_collectionView deleteItemsAtIndexPaths:@[_menuIndexPath]];
                } completion:^(BOOL finished) {
                   
                }];
            }
                break;
            case 1:
            {
                NSMutableArray<IDPTagDriver *> *mutableArray= [NSMutableArray<IDPTagDriver *> arrayWithArray:_tags];
                IDPTagDriver *tag = [mutableArray objectAtIndex:_menuIndexPath.row];
                [mutableArray removeObject:tag];
                _tags = [NSArray arrayWithArray:mutableArray];
                
                /*NSMutableArray<IDPTagDriver *> **/mutableArray = [NSMutableArray<IDPTagDriver *> arrayWithArray:_deletedTagas];
                [mutableArray addObject:tag];
                _deletedTagas = [NSArray<IDPTagDriver *> arrayWithArray:mutableArray];
                
                [_collectionView performBatchUpdates:^{
                    [_collectionView deleteItemsAtIndexPaths:@[_menuIndexPath]];
                } completion:^(BOOL finished) {
                    
                }];
            }
                break;
            default:
                break;
        }
    }]];
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"キャンセル" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        
    }]];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if( [segue.identifier isEqualToString:@"tagColorSegue"] ){
        UINavigationController *navigationController = [segue.destinationViewController isKindOfClass:[UINavigationController class]] ? (UINavigationController *)segue.destinationViewController : nil;
        
        IDPTagColorViewController *colorViewController = [navigationController.topViewController isKindOfClass:[IDPTagColorViewController class]] ? (IDPTagColorViewController *)navigationController.topViewController : nil;
        colorViewController.delegate = self;

        __block NSString *tagColor = nil;
        switch (_menuIndexPath.section) {
            case 0:
            {
                IDPTagDriver *tag = [_selectedTags objectAtIndex:_menuIndexPath.row];
                tagColor = tag[IDP_TAG_COLOR_KEY_NAME];
            }
                break;
            case 1:
            {
                IDPTagDriver *tag = [_tags objectAtIndex:_menuIndexPath.row];
                tagColor = tag[IDP_TAG_COLOR_KEY_NAME];
            }
                break;
            default:
                break;
        }

        __block NSUInteger selectedIndex = 0;
        [self.tagColors enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIColor *color = obj;
            if( [tagColor isEqual:color] ){
                selectedIndex = idx;
            }
        }];
        
        colorViewController.selectedIndex = selectedIndex;
    }
    
}

- (void) colorViewControllerDidSelectColor:(IDPTagColorViewController *)colorViewController
{
    NSString *tagColor = self.tagColors[colorViewController.selectedIndex];
    
    UICollectionViewCell *cell = [_collectionView cellForItemAtIndexPath:_menuIndexPath];
    IDPTagCell *tagCell = [cell isKindOfClass:[IDPTagCell class]] ? (IDPTagCell *)cell : nil;
    tagCell.tagBackgroundView.backgroundColor = [UIColor colorWithWebColor:tagColor];
    
    switch (_menuIndexPath.section) {
        case 0:
        {
            IDPTagDriver *tag = _selectedTags[_menuIndexPath.row];
            tag[IDP_TAG_COLOR_KEY_NAME] = tagColor;
        }
            break;
        case 1:
        {
            IDPTagDriver *tag = _tags[_menuIndexPath.row];
            tag[IDP_TAG_COLOR_KEY_NAME] = tagColor;
        }
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void) colorViewControllerDidCancel:(IDPTagColorViewController *)colorViewController
{
    [self dismissViewControllerAnimated:YES completion:^{
       
    }];
}

#pragma mark - Tag delegate method(s)

- (void) tagCellDidSelectInformation:(IDPTagCell *)tagCell
{
    _menuIndexPath = [_collectionView indexPathForCell:tagCell];
    _menu = [UIMenuController sharedMenuController];
    
    CGRect minRect = CGRectNull;
    minRect.origin = [self.view convertPoint:CGPointMake(CGRectGetMidX(tagCell.informationButton.frame),CGRectGetMidY(tagCell.informationButton.frame)) fromView:tagCell];
    
    
    [_menu setTargetRect:minRect inView:self.view];
    
    _menu.menuItems = @[  [[UIMenuItem alloc] initWithTitle:@"色変更" action:@selector(onTagColor:)]
                          ,[[UIMenuItem alloc] initWithTitle:@"削除" action:@selector(onDeleteTag:)]
                          ];
    
    [_menu setMenuVisible:YES animated:YES];
}

@end
