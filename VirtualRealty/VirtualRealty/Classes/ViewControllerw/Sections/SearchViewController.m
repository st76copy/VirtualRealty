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


@interface SearchViewController ()<SearchFilterDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, GMSMapViewDelegate>
-(void)handleMakeFilter:(id)sender;
-(void)handleShowMap:(id)sender;
-(void)handleShowList:(id)sender;
@end

@implementation SearchViewController

@synthesize searchBar = _searchBar;
@synthesize table     = _table;
@synthesize tableData = _tableData;
@synthesize mapView   = _mapView;

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
    self.searchBar.keyboardType = UIReturnKeySearch;
    
    _mapView = [[GMSMapView alloc]initWithFrame:self.view.frame];
    self.mapView.delegate = self;
    
    _table = [[UITableView alloc]initWithFrame:self.view.frame];
    self.table.separatorInset = UIEdgeInsetsZero;
    self.table.dataSource = self;
    self.table.delegate = self;
    [self.view addSubview:self.table];
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc]initWithTitle:@"filter" style:UIBarButtonItemStyleBordered target:self action:@selector(handleMakeFilter:)];
    UIBarButtonItem *mapButton = [[UIBarButtonItem alloc]initWithTitle:@"map" style:UIBarButtonItemStyleBordered target:self action:@selector(handleShowMap:)];
    
    self.navigationItem.rightBarButtonItems = @[mapButton, filterButton];
    
    __block SearchViewController *blockself = self;
    [PFCloud  callFunctionInBackground:@"allListings" withParameters:[NSDictionary dictionary] block:^(id object, NSError *error)
    {
         [blockself handleDataLoaded:object];
    }];

}

-(void)handleDataLoaded:(NSArray *)data
{
    Listing *listing;
    
    [self.tableData removeAllObjects];
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

    if( options == nil )
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
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
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [self showDetails:listing];
}

-(void)showDetails:(Listing *)listing
{
    ListingDetailViewController *details = [[ListingDetailViewController alloc]initWithListing:listing];
    [self.navigationController pushViewController:details animated:YES];
}

#pragma mark - map
-(void )handleShowMap:(id)sender
{
    [UIView transitionFromView:self.table toView:self.mapView duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        
    }];
    UIBarButtonItem *item = (UIBarButtonItem *)sender;
    item.title            = @"List";
    item.action           = @selector(handleShowList:);

    
    GMSCameraPosition *camera;
    GMSMarker *marker;
    
    [self.mapView clear];
    for( Listing *listing in self.tableData )
    {
        marker = [GMSMarker markerWithPosition:listing.geo.coordinate];
        marker.map = self.mapView;
        marker.userData = listing;
    }
    
    float mostNorth = marker.position.latitude;
    float mostSouth = marker.position.latitude;
    float mostEast  = marker.position.longitude;
    float mostWest  = marker.position.longitude;
    
    for( GMSMarker *marker in self.mapView.markers )
    {
        if( marker.position.latitude < mostSouth)
        {
            mostSouth = marker.position.latitude;
        }
        
        if( marker.position.latitude > mostNorth)
        {
            mostNorth = marker.position.latitude;
        }
        
        if( marker.position.longitude < mostWest )
        {
            mostWest =  marker.position.longitude;
        }
        
        if( marker.position.longitude > mostEast )
        {
            mostEast = marker.position.longitude;
        }
    }
    
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(mostNorth, mostEast);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(mostSouth, mostWest);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]initWithCoordinate:northEast coordinate:southWest];
    camera = [self.mapView cameraForBounds:bounds insets:UIEdgeInsetsMake(110, 10, 10, 10)];
    [self.mapView setCamera:camera];
    [self.mapView startRendering];
}

-(void)handleShowList:(id)sender
{
    [UIView transitionFromView:self.mapView toView:self.table duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        
    }];
    UIBarButtonItem *item = (UIBarButtonItem *)sender;
    item.title            = @"Map";
    item.action           = @selector(handleShowMap:);

}

#pragma mark - map view 
-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    [self showDetails:(Listing *)marker.userData];
    return YES;
}

@end
