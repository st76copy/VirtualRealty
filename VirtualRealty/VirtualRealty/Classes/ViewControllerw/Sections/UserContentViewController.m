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
#import "SQLiteManager.h"
#import "SQLRequest.h"
#import "QueryFactory.h"
#import "ListingDetailViewController.h"

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
        NSMutableArray *myListings = [NSMutableArray array];
        NSMutableArray *favorites  = [NSMutableArray array];
       
        [self.tableData addObject:myListings];
        [self.tableData addObject:favorites];
        
        self.navigationItem.title = @"My Listings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    _table = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.table.separatorInset = UIEdgeInsetsZero;
    self.table.dataSource = self;
    self.table.delegate = self;

    [self.view addSubview:self.table];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    __block UserContentViewController *blockself = self;
    [PFCloud callFunctionInBackground:@"getListingsForUser" withParameters:@{@"userID":[User sharedUser].username} block:^(id object, NSError *error)
    {
        [blockself handleDataLoaded:object];
    }];
    
    NSString *query = [QueryFactory getFavoritesForUser:[User sharedUser]];
    __block SQLRequest *req = [[SQLRequest alloc]initWithQuery:query andType:kSelect andName:@"get-favorites"];
    [req runSelectOnDatabaseManager:[SQLiteManager sharedDatabase] WithBlock:^(BOOL success) {
        if( success )
        {
            NSMutableArray *favs = [blockself.tableData objectAtIndex:1];
            [favs removeAllObjects];
            for( NSDictionary *info in req.results )
            {
                Listing *listing = [[Listing alloc]initWithFullData:info];
                [favs addObject:listing];
            }
        }
        [blockself.table reloadData];
    }];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)handleDataLoaded:(NSArray *)data
{
    Listing *listing;
    NSMutableArray *userListings = [self.tableData objectAtIndex:0];
    for( NSDictionary *info in data)
    {
        listing = [[Listing alloc]initWithFullData:info];
        [userListings addObject:listing];
    }
    [self.table reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableData.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *group = [self.tableData objectAtIndex:section];
    return group.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *section   = [self.tableData objectAtIndex:indexPath.section];
    Listing *info      = [section objectAtIndex:indexPath.row];
    ListingCell * cell = [self.table dequeueReusableCellWithIdentifier:@"cell"];
    
    if( cell == nil )
    {
        cell = [[ListingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.listing = info;
    [cell render];
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    switch (section) {
        case 0:
            title = NSLocalizedString( @"My Listings", @"Title for user uploaded listings");
            break;
        case 1:
            title = NSLocalizedString( @"My Favorites", @"Title for user selected listings");
            break;
    }
    return title;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.table deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *section = [self.tableData objectAtIndex:indexPath.section];
    Listing *listing = [section objectAtIndex:indexPath.row];
    
    
    ListingDetailViewController *details = [[ListingDetailViewController alloc]initWithListing:listing];
    [self.navigationController pushViewController:details animated:YES];
}

-(void)toggleMenu
{
    [super toggleMenu];
    self.table.scrollEnabled = active;
    self.table.userInteractionEnabled = active;
}

-(void)setActive:(BOOL)value
{
    active = value;
    self.table.scrollEnabled = active;
    self.table.userInteractionEnabled = active;
}

@end
