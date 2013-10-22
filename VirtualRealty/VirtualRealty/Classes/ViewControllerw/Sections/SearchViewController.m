//
//  SearchViewController.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchFilterViewController.h"
#import <Parse/Parse.h>
#import "ListingCell.h"
#import "ListingDetailViewController.h"
#import "Listing.h"

@interface SearchViewController ()<SearchFilterDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
-(void)handleMakeFilter:(id)sender;
@end

@implementation SearchViewController

@synthesize searchBar = _searchBar;
@synthesize table     = _table;
@synthesize tableData = _tableData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _tableData = [NSMutableArray array];
        self.navigationItem.title = @"Search";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];

    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 250, 40)];
    self.navigationItem.titleView = _searchBar;
    self.searchBar.delegate = self;
   
    
    _table = [[UITableView alloc]initWithFrame:self.view.frame];
    self.table.separatorInset = UIEdgeInsetsZero;
    self.table.dataSource = self;
    self.table.delegate = self;
    [self.view addSubview:self.table];
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc]initWithTitle:@"filter" style:UIBarButtonItemStyleBordered target:self action:@selector(handleMakeFilter:)];
    self.navigationItem.rightBarButtonItem = filterButton;
}

-(void)handleDataLoaded:(NSArray *)data
{
    Listing *listing;
    
    for( NSDictionary *info in data)
    {
        listing = [[Listing alloc]initWithFullData:info];
        [self.tableData addObject:listing];
    }
    [self.table reloadData];
}

-(void)handleMakeFilter:(id)sender
{
    SearchFilterViewController *filters =[[SearchFilterViewController alloc]initWithNibName:nil bundle:nil];
    filters.delegate = self;
    UINavigationController *nc = [[UINavigationController alloc ]initWithRootViewController:filters];
    [self presentViewController:nc animated:YES completion:nil];
}

-(void)filtersDoneWithOptions:(NSDictionary *)options
{

    NSDictionary *params = nil;
    
    if( self.searchBar.text && [self.searchBar.text isEqualToString:@""] == NO )
    {
        params = @{@"filters" : options, @"keyword" : self.searchBar.text };
    }
    else
    {
        params = @{ @"filters" : options };
    }
    
    __block SearchViewController *blockself = self;
    
    [PFCloud callFunctionInBackground:@"search" withParameters:params block:^(id object, NSError *error)
    {
        [blockself handleDataLoaded:object];
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    __block SearchViewController *blockself = self;
    NSDictionary *params = @{ @"keyword" : [self.searchBar.text lowercaseString] };
    [PFCloud callFunctionInBackground:@"search" withParameters:params block:^(id object, NSError *error)
    {
        [blockself handleDataLoaded:object];
    }];
    [self.searchBar resignFirstResponder];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Listing *info      = [self.tableData objectAtIndex:indexPath.row];
    ListingCell * cell = [self.table dequeueReusableCellWithIdentifier:@"cell"];
    
    if( cell == nil )
    {
        cell = [[ListingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.listing = info;
    [cell render];
    
    return cell;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.table deselectRowAtIndexPath:indexPath animated:YES];
    Listing *listing = [self.tableData objectAtIndex:indexPath.row];
    ListingDetailViewController *details = [[ListingDetailViewController alloc]initWithListing:listing];
    [self.navigationController pushViewController:details animated:YES];
}


@end
