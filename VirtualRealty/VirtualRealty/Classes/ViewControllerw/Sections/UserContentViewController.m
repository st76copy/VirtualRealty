//
//  UserContentViewController.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "Listing.h"
#import "UserContentViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "ListingCell.h"

@interface UserContentViewController ()

-(void)handleDataLoaded:(NSArray *)data;
@end

@implementation UserContentViewController

@synthesize table     = _table;
@synthesize tableData = _tableData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _tableData = [NSMutableArray array];
        self.navigationItem.title = @"My Listings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    _table = [[UITableView alloc]initWithFrame:self.view.frame];
    self.table.separatorInset = UIEdgeInsetsZero;
    self.table.dataSource = self;
    self.table.delegate = self;
    [self.view addSubview:self.table];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableData removeAllObjects];

    
    __block UserContentViewController *blockself = self;
    [PFCloud callFunctionInBackground:@"getListingsForUser" withParameters:@{@"userID":[User sharedUser].username} block:^(id object, NSError *error)
    {
        [blockself handleDataLoaded:object];
    }];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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


@end
