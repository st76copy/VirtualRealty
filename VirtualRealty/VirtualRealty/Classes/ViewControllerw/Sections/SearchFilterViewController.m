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


@interface SearchFilterViewController ()<FormCellDelegate>

-(id)getValueForFormField:(FormField)field;

@end

@implementation SearchFilterViewController

@synthesize currentField = _currentField;
@synthesize currentPath  = _currentPath;

@synthesize tableData = _tableData;
@synthesize table     = _table;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSString *file = [[NSBundle mainBundle]pathForResource:@"search-filter" ofType:@"plist"];
        NSArray  *ref  = [[NSArray arrayWithContentsOfFile:file] mutableCopy];
        
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
    
    [info setValue:[self getValueForFormField:[[info valueForKey:@"field"] intValue]] forKey:@"current-value"];
    
    
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


#pragma mark - model management
-(id)getValueForFormField:(FormField)field
{
    id value;
    
    switch( field )
    {
        default:
            break;
    }

    return value;
}


#pragma mark - form cell delegates
-(void)cell:(FormCell *)cell didChangeForField:(FormField)field
{
    FormCell *formcell = (FormCell *)[self.table cellForRowAtIndexPath:self.currentPath];
    
    switch( field )
    {

        default:
            break;
    }
    
}

@end
