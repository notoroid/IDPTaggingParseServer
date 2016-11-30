//
//  IDPTagColorViewController.m
//  IDPTaggingParseServer
//
//  Created by 能登 要 on 2016/07/10.
//  Copyright © 2016年 Irimasu Densan Planning. All rights reserved.
//

#import "IDPTagColorViewController.h"
#import "IDPTagColorCell.h"
#import "UIColor+IDPTag.h"

@interface IDPTagColorViewController () < IDPTagColorCellDelegate>
{
    BOOL _initialized;
    NSArray<NSString *> *_tagColors;
}
@property (readonly,nonatomic) NSArray<NSString *> *tagColors;
@end

@implementation IDPTagColorViewController

- (NSArray<NSString *> *) tagColors
{
    if( _tagColors == nil ){
        _tagColors = @[   @"#EE1B5A"
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

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL)animated
{
    if( _initialized != YES ){
        _initialized = YES;
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    
    [super viewDidAppear:animated];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88.0;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tagColors.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"colorCell" forIndexPath:indexPath];
    
     IDPTagColorCell *colorCell = [cell isKindOfClass:[ IDPTagColorCell class]] ? ( IDPTagColorCell *)cell : nil;
    
    NSString *tagColor = self.tagColors[indexPath.row];
    
    colorCell.colorButton.backgroundColor = [UIColor colorWithWebColor:tagColor];
    colorCell.delegate = self;
    colorCell.checkView.hidden = indexPath.row == _selectedIndex ? NO : YES;
    
    return cell;
}

- (void) colorCellDidSelect:( IDPTagColorCell *)colorCell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:colorCell];
    _selectedIndex = indexPath.row;

    NSArray *visibleCells = self.tableView.visibleCells;
    [visibleCells enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         IDPTagColorCell *colorCell = [obj isKindOfClass:[ IDPTagColorCell class]] ? ( IDPTagColorCell *)obj : nil;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:colorCell];
        
        colorCell.checkView.hidden = indexPath.row == _selectedIndex ? NO : YES;
    }];
    
    [_delegate colorViewControllerDidSelectColor:self];
}

- (IBAction)onCancel:(id)sender
{
    [_delegate colorViewControllerDidCancel:self];
}


@end
