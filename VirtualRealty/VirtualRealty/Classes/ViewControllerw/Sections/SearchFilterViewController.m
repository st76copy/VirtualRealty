//
//  SearchFilterViewController.m
//  VirtualRealty
//
//  Created by christopher shanley on 10/15/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "SearchFilterViewController.h"
#import "UIColor+Extended.h"
#import "Section.h"
#import "Row.h"
#import "FormCell.h"
#import "KeyboardManager.h"
#import "PickerManager.h"
#import "CheckCell.h"
#import "PickerManager.h"
#import "NSDate+Extended.h"
#import "SectionTitleView.h"
#import "SearchFilters.h"


@interface SearchFilterViewController ()<FormCellDelegate, PickerManagerDelegate, KeyboardManagerDelegate>

-(id)getValueForFormField:(FormField)field;
-(void)handleDone:(id)sender;
-(void)handleCancel:(id)sender;
-(void)handleClearFliters:(id)sender;
@end

@implementation SearchFilterViewController

@synthesize delegate;
@synthesize currentField = _currentField;
@synthesize currentPath  = _currentPath;

@synthesize tableData = _tableData;
@synthesize table     = _table;
@synthesize filters   = _filters;


-(id)initWithFilterOrNil:(SearchFilters *)filters
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        NSString *file = [[NSBundle mainBundle]pathForResource:@"search-filter" ofType:@"plist"];
        NSArray  *ref  = [[NSArray arrayWithContentsOfFile:file] mutableCopy];
        
        if( filters )
        {
            _filters = filters;
        }
        else
        {
            _filters = [[SearchFilters alloc]initWithDefaults];
        }
        
        _tableData = [NSMutableArray array];
        Section *section;
        Row     *row;
        
        for( NSDictionary *info in ref )
        {
            section = [[Section alloc]initWithTitle:[info valueForKey:@"section-title"]];
            for( NSDictionary *cell in [info valueForKey:@"cells"] )
            {
                row = [[Row alloc]initWithInfo:cell];
                [section.rows addObject:row];
            }
            
            [self.tableData addObject:section];
        }
    }
    return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.view.backgroundColor = [UIColor grayColor];
    CGRect rect = self.view.bounds;
    rect.size.height -= self.navigationController.navigationBar.frame.size.height;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleDone:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(handleCancel:)];
        
    _table = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
    [_table setDataSource:self];
    [_table setDelegate:self];
    [_table setSectionFooterHeight:0.0f];
    [_table setSectionHeaderHeight:44.0f];
    [_table setSeparatorColor:[UIColor clearColor]];
    [_table setBackgroundColor:[UIColor colorFromHex:@"cbd5d9"]];
    [self.view addSubview:_table];

    UIView *container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 101)];
    [container setBackgroundColor:[UIColor colorFromHex:@"cbd5d9"]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"footer-button-fill.png"] forState:UIControlStateNormal];
    [button setTitle:@"Clear Filters" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorFromHex:@"cbd5d9"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(handleClearFliters:) forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:15]];
    
    [button sizeToFit];
    
    rect = button.frame;
    rect.origin.x = 160 - button.frame.size.width * 0.5;
    rect.origin.y = 40  - button.frame.size.height * 0.5;
    button.frame = rect;
    [container addSubview:button];
    
    
    self.table.tableFooterView = container;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[KeyboardManager sharedManager]registerDelegate:self];
    [[PickerManager sharedManager]registerDelegate:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[KeyboardManager sharedManager]unregisterDelegate:self];
    [[PickerManager sharedManager]unregisterDelegate:self];
}



#pragma mark - table delegate and data
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Section *sectionInfo = [self.tableData objectAtIndex:section];
    return sectionInfo.title;
}

-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Section *sectionInfo = [self.tableData objectAtIndex:section];
    return [[sectionInfo activeRows]count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Section *sectionInfo = [self.tableData objectAtIndex:indexPath.section];
    NSArray      *cells  = [sectionInfo activeRows];
    Row          *row    = [cells objectAtIndex:indexPath.row];
    
    NSMutableDictionary *info = [row.info mutableCopy];
    FormField field           = [[info valueForKey:@"field"]intValue];
    
    
    if( [self getValueForFormField:field] )
    {
        [info setValue:[self getValueForFormField:field] forKey:@"current-value"];
    }
    
    FormCell *cell = (FormCell *)[tableView dequeueReusableCellWithIdentifier:[info valueForKey:@"class"]];
    
    NSLog(@"%@ ", info);
    
    if( cell == nil )
    {
        cell = [[NSClassFromString([info valueForKey:@"class"]) alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[info valueForKey:@"class"]];
    }
    
    cell.formDelegate = self;
    cell.indexPath = indexPath;
    cell.cellinfo = info;
    [cell render];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormCell *cell     = (FormCell*)[tableView cellForRowAtIndexPath:indexPath];

    if( [KeyboardManager sharedManager].isShowing && [self isSameCell:indexPath] )
    {
        [[KeyboardManager sharedManager] close];
        return;
    }
    
    if( [PickerManager sharedManager].isShowing && [self isSameCell:indexPath] )
    {
        [[PickerManager sharedManager]hidePicker];
        return;
    }
    
    if([self isSameCell:indexPath] )
    {
        _currentPath      = nil;
        _currentField     = -1;
        [self.table beginUpdates];
        [self.table endUpdates];
        [self.table deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }

    
    if( [cell.cellinfo valueForKey:@"field"] && self.currentField != [[cell.cellinfo valueForKey:@"field"] intValue] )
    {
        _currentField = [[cell.cellinfo valueForKey:@"field"]intValue];
        _currentPath  = indexPath;
    }
    
    switch (self.currentField)
    {
            
        case kBoroughFilter:
        case kBedroomsFilter:
        case kBathroomsFilter:
        case kStateFilter:
        case kCityFilter:
            [self.table beginUpdates];
            [self.table endUpdates];
            [cell setFocus];
            break;
        case kMoveInFilter :
            [PickerManager sharedManager].type = kDate;
            [[PickerManager sharedManager]showPickerInView:self.view];
            break;
        case kMinCostFilter:
        case kMaxCostFilter:
            [cell setFocus];
            break;
        default:
            [[PickerManager sharedManager]hidePicker];
            [[KeyboardManager sharedManager]close];
            break;
    }
    [self.table deselectRowAtIndexPath:indexPath animated:YES];
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Section *sec = [self.tableData objectAtIndex:indexPath.section];
    Row     *row = [sec.rows objectAtIndex:indexPath.row];
    
    NSLog(@"%@ ", self.currentPath);
    
    float height;
    if( [self isSameCell:indexPath] )
    {
        if( row.info[@"expanded-height"] )
        {
            height = [row.info[@"expanded-height"] floatValue];
        }
        else
        {
            height = ( [row.info valueForKey:@"display-height"] ) ? [[row.info valueForKey:@"display-height"] floatValue] : 38.0f;
        }
    }
    else
    {
        height = ( [row.info valueForKey:@"display-height"] ) ? [[row.info valueForKey:@"display-height"] floatValue] : 38.0f;
    }
    
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    Section *sectionInfo           = [self.tableData objectAtIndex:section];
    SectionTitleView *sectionTitle = [[SectionTitleView alloc]initWithTitle:sectionInfo.title];
    return sectionTitle;
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

-(float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - custom cell handlers
-(BOOL)isSameCell:(NSIndexPath *)path
{
    if( self.currentPath == nil )
    {
        return NO;
    }
    return ( self.currentPath.row == path.row && self.currentPath.section == path.section ) ? YES : NO;
}

-(void)animateToCell
{
    CGRect rect = [self.table cellForRowAtIndexPath:self.currentPath].frame;
    rect.size.height += 20;
    [self.table scrollRectToVisible:rect animated:YES];
}

#pragma mark - form delegates

-(void)cell:(FormCell *)cell didChangeForField:(FormField)field
{
    [self.filters setFilter:field withValue:cell.formValue];
}

-(void)cell:(FormCell *)cell didStartInteract:(FormField)field
{
    [self tableView:self.table didSelectRowAtIndexPath:cell.indexPath];
}

#pragma mark - model management
-(id)getValueForFormField:(FormField)field
{
    
    if( [[self.filters getValueForField:field] isKindOfClass:[NSString class]] )
    {
        return ( [[self.filters getValueForField:field] isEqualToString:@""] ) ? nil : [self.filters getValueForField:field];
    }
    else
    {
        return [self.filters getValueForField:field];
    }
}

#pragma mark - ui resonders
-(void)handleDone:(id)sender
{
    if( self.filters.isDefault == NO )
    {
        [self.delegate filtersDoneWithOptions:self.filters];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)handleCancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - keyboard delegate
-(void)keyboardWillShow
{
    if( [PickerManager sharedManager].isShowing)
    {
        [[PickerManager sharedManager]hidePicker];
    }
    
    [UIView setAnimationCurve:[KeyboardManager sharedManager].animationCurve ];
    
    [UIView animateWithDuration:[KeyboardManager sharedManager ].animationTime animations:^
     {
         self.table.contentInset =  UIEdgeInsetsMake(0, 0, [KeyboardManager sharedManager].keyboardFrame.size.height, 0);
     }];
    
    [self animateToCell];
    
}

-(void)keyboardWillHide
{
    [UIView animateWithDuration:0.3  animations:^{
        self.table.contentInset =  UIEdgeInsetsMake(64, 0, 0, 0);
    }];
}

#pragma mark - picker delegate
-(void)pickerWillShow
{
    if( [KeyboardManager sharedManager].isShowing )
    {
        [[KeyboardManager sharedManager]close];
    }
    
    [UIView animateWithDuration:0.4 animations:^
     {
         self.table.contentInset =  UIEdgeInsetsMake(0, 0,[PickerManager sharedManager].container.frame.size.height, 0);
     }];
    
    [self animateToCell];
}

-(void)pickerWillHide
{
    [UIView animateWithDuration:0.3  animations:^{
        self.table.contentInset =  UIEdgeInsetsMake(0, 0, 0, 0);
    }];
}

-(void)pickerCancel
{
    FormCell *cell = (FormCell *)[self.table cellForRowAtIndexPath:self.currentPath];
    
    switch ([PickerManager sharedManager].type) {
        case kStandard:
            cell.formValue  = nil;
            break;
            
        default:
            cell.formValue = nil;
            break;
    }
    
    [cell.formDelegate cell:cell didChangeForField:self.currentField];
    [self.table reloadRowsAtIndexPaths:@[self.currentPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[PickerManager sharedManager]hidePicker];

}

-(void)pickerDone
{
    FormCell *cell = (FormCell *)[self.table cellForRowAtIndexPath:self.currentPath];
    int index = [cell.cellinfo[@"picker-index"] intValue];
    
    switch ([PickerManager sharedManager].type) {
        case kStandard:
            cell.formValue            = [[PickerManager sharedManager] valueForComponent:index];
            cell.detailTextLabel.text = [[PickerManager sharedManager] valueForComponent:index];
            break;
            
        default:
            cell.formValue = [PickerManager sharedManager].datePicker.date;
            cell.detailTextLabel.text = [[PickerManager sharedManager].datePicker.date toString];
            break;
    }
    
    [cell.formDelegate cell:cell didChangeForField:self.currentField];
    [self.table reloadRowsAtIndexPaths:@[self.currentPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[PickerManager sharedManager]hidePicker];
}


-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)handleClearFliters:(id)sender
{
    [self.filters clear];
    [self.table reloadData];
    
    //[self.delegate clearFilters];
    //[self dismissViewControllerAnimated:YES completion:nil];
}


@end
