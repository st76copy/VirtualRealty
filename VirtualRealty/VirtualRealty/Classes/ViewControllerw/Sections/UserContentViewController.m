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
#import "UserListingCell.h"
#import "SectionTitleView.h"

@interface UserContentViewController ()

-(void)handleDataLoaded:(NSArray *)data;


@end

@implementation UserContentViewController

@synthesize table     = _table;
@synthesize tableData = _tableData;
@synthesize listing   = _listing;

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
        
        self.navigationItem.title = [NSString stringWithFormat: @"Welcome %@", [User sharedUser].username];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    CGRect rect = self.view.bounds;
    rect.size.height -= self.navigationController.navigationBar.frame.size.height;
    
    _table = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
    self.table.separatorInset = UIEdgeInsetsZero;
    self.table.dataSource = self;
    self.table.delegate = self;
    
    [_table setSeparatorColor:[UIColor clearColor]];
    [_table setSectionFooterHeight:0.0f];
    [_table setSectionHeaderHeight:44.0f];
    

    [self.view addSubview:self.table];
    

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    __block UserContentViewController *blockself = self;
    [PFCloud callFunctionInBackground:@"getListingsForUser" withParameters:@{@"userID":[User sharedUser].uid} block:^(id object, NSError *error)
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
                Listing *listing = [[Listing alloc]initWithSQLData:info];
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
  
    NSMutableArray *myListings = [self.tableData objectAtIndex:0];
    [myListings removeAllObjects];
    
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
    NSString *reuse = ( indexPath.section == 0 ) ? @"user-cell" : @"cell";
    
    NSArray *section   = [self.tableData objectAtIndex:indexPath.section];
    Listing *info      = [section objectAtIndex:indexPath.row];
    
    
    ListingCell * cell = [self.table dequeueReusableCellWithIdentifier:reuse];
    
    if( cell == nil )
    {
        switch (indexPath.section)
        {
            case 0:
                cell = [[UserListingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
                break;
           
            case 1:
                cell = [[ListingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
                break;

        }
    }
    
    cell.listing = info;
    [cell render];
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    switch (section)
    {
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
    return 215.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *group = [self.tableData objectAtIndex:indexPath.section];
    _listing = [group objectAtIndex:indexPath.row];
    
    [self.table deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *section = [self.tableData objectAtIndex:indexPath.section];
    Listing *listing = [section objectAtIndex:indexPath.row];
    
    
    ListingDetailViewController *details = [[ListingDetailViewController alloc]initWithListing:listing];
    [self.navigationController pushViewController:details animated:YES];
    
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    switch (section)
    {
        case 0:
            title = NSLocalizedString( @"My Listings", @"Title for user uploaded listings");
            break;
        case 1:
            title = NSLocalizedString( @"My Favorites", @"Title for user selected listings");
            break;
    }
    SectionTitleView *sectionTitle = [[SectionTitleView alloc]initWithTitle:title];
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
