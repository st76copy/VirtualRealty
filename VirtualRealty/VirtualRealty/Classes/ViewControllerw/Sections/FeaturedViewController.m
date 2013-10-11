//
//  FeaturedViewController.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "FeaturedViewController.h"
#import <Parse/Parse.h>
#import "Listing.h"
#import "ListingCell.h"
#import "User.h"

@interface FeaturedViewController ()

@end

@implementation FeaturedViewController

@synthesize table =_table;
@synthesize tableData =_tableData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _tableData = [NSMutableArray array];
        self.navigationItem.title = @"Recomended Listings";
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
    
    __block FeaturedViewController *blockself = self;
    [PFCloud  callFunctionInBackground:@"getFeaturedListings" withParameters:[NSDictionary dictionary] block:^(id object, NSError *error)
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
