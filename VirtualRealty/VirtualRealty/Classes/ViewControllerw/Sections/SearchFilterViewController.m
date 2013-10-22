//
//  SearchFilterViewController.m
//  VirtualRealty
//
//  Created by christopher shanley on 10/15/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "SearchFilterViewController.h"
#import "Section.h"
#import "Row.h"
#import "FormCell.h"
#import "KeyboardManager.h"
#import "PickerManager.h"
#import "CheckCell.h"
#import "PickerManager.h"
#import "NSDate+Extended.h"

@interface SearchFilterViewController ()<FormCellDelegate, PickerManagerDelegate, KeyboardManagerDelegate>

-(id)getValueForFormField:(FormField)field;
-(void)handleDone:(id)sender;
-(void)handleCancel:(id)sender;
@end

@implementation SearchFilterViewController

@synthesize delegate;
@synthesize currentField = _currentField;
@synthesize currentPath  = _currentPath;

@synthesize tableData = _tableData;
@synthesize table     = _table;
@synthesize filters   = _filters;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSString *file = [[NSBundle mainBundle]pathForResource:@"search-filter" ofType:@"plist"];
        NSArray  *ref  = [[NSArray arrayWithContentsOfFile:file] mutableCopy];
        
        _filters = [[SearchFilters alloc]initWithDefaults];
        
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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(handleDone:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(handleCancel:)];
        
    _table = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
    [_table setDataSource:self];
    [_table setDelegate:self];
    [self.view addSubview:_table];
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
    
    [info setValue:[self getValueForFormField:field] forKey:@"current-value"];
    
    
    FormCell *cell = (FormCell *)[tableView dequeueReusableCellWithIdentifier:[info valueForKey:@"class"]];
    
    if( cell == nil )
    {
        cell = [[NSClassFromString([info valueForKey:@"class"]) alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[info valueForKey:@"class"]];
    }
    
    cell.formDelegate = self;
    cell.indexPath = indexPath;
    cell.cellinfo = info;
    [cell render];
    
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
    
    if( [cell.cellinfo valueForKey:@"field"] && self.currentField != [[cell.cellinfo valueForKey:@"field"] intValue] )
    {
        _currentField = [[cell.cellinfo valueForKey:@"field"]intValue];
        _currentPath  = indexPath;
    }
    
    switch (self.currentField)
    {
            
        case kNeightborhoodFilter:
        {
            CheckCell *c = (CheckCell *)[self.table cellForRowAtIndexPath:indexPath];
            NSMutableDictionary *info = [[c cellinfo]mutableCopy];
            
            if( [c isKindOfClass:[CheckCell class]] )
            {
                [self.filters setFilter:kNeightborhoodFilter withValue:[info valueForKey:@"label"]];
                [self.table reloadRowsAtIndexPaths:@[self.currentPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
                [info setValue:[self getValueForFormField:[[info valueForKey:@"field"] intValue]] forKey:@"current-value"];
                [c setCellinfo:info];
                [c render];
            }
            [[KeyboardManager sharedManager] close];
            [self addRows];
        }
            break;
        case kMoveInFilter :
            [PickerManager sharedManager].type = kDate;
            [[PickerManager sharedManager]showPickerInView:self.view];
            break;
        case kMinCostFilter:
        case kMaxCostFilter:
        case kBedroomsFilter:
        case kBathroomsFilter:
            [cell setFocus];
            break;
        default:
            break;
    }
    [self.table deselectRowAtIndexPath:indexPath animated:YES];
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Section *sec = [self.tableData objectAtIndex:indexPath.section];
    Row     *row = [sec.rows objectAtIndex:indexPath.row];
    return  ( [row.info valueForKey:@"display-height"] ) ? [[row.info valueForKey:@"display-height"] floatValue] : 50.0f;
}


#pragma mark - custom cell handlers
-(BOOL)isSameCell:(NSIndexPath *)path
{
    return ( self.currentPath.row == path.row && self.currentPath.section == path.section ) ? YES : NO;
}

-(void)addRows
{
    Section *secion = [self.tableData objectAtIndex:self.currentPath.section];
    [secion toggleRows];
    
    NSMutableArray *paths = [NSMutableArray array];
    NSIndexPath    *path;
    
    for( int i = 1; i <= [secion animatableRows]; i ++ )
    {
        path = [NSIndexPath indexPathForRow:self.currentPath.row + i inSection:self.currentPath.section];
        [paths addObject:path];
    }
    
    if( secion.state == kContracted )
    {
        [self.table deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
        [self.table scrollToRowAtIndexPath:self.currentPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else
    {
        [self.table insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
    }
}

-(void)animateToCell
{
    CGRect rect = [self.table cellForRowAtIndexPath:self.currentPath].frame;
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
    return [self.filters getValueForField:field];
}


#pragma mark - ui resonders

-(void)handleDone:(id)sender
{
    [self.delegate filtersDoneWithOptions:[self.filters getActiveFilters]];
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
        self.table.contentInset =  UIEdgeInsetsMake(64, 0, 0, 0);
    }];
}

-(void)pickerDone
{
    FormCell *cell = (FormCell *)[self.table cellForRowAtIndexPath:self.currentPath];
    cell.formValue = [PickerManager sharedManager].datePicker.date;
    cell.detailTextLabel.text = [[PickerManager sharedManager].datePicker.date toString];
    [cell.formDelegate cell:cell didChangeForField:self.currentField];
    [self.table reloadRowsAtIndexPaths:@[self.currentPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[PickerManager sharedManager]hidePicker];
}


@end
