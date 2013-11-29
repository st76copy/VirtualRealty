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
#import "ListingDetailViewController.h"
#import "MapListToggleView.h"
#import "AppDelegate.h"

@interface FeaturedViewController ()<ToggleDelegate, GMSMapViewDelegate>
{
    UIView *container;
}
-(void)showDetails:(Listing *)listing;
-(void )handleShowMap;
@end

@implementation FeaturedViewController

@synthesize mapView = _mapView;
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
   
    
    
    CGRect rect;
    MapListToggleView *mapListToggle = [[MapListToggleView alloc]initWithFrame:CGRectZero];
    mapListToggle.delegate = self;
    rect = mapListToggle.frame;
    rect.origin.y = self.navigationController.navigationBar.frame.size.height;
    [self.view addSubview:mapListToggle];
    
    rect = self.view.frame;
    rect.origin.y = mapListToggle.frame.size.height;
    rect.size.height -= mapListToggle.frame.size.height + self.navigationController.navigationBar.frame.size.height + 20;
    
    container = [[UIView alloc]initWithFrame:rect];
    [self.view addSubview:container];
    
    _table = [[UITableView alloc]initWithFrame:container.bounds style:UITableViewStylePlain];
    self.table.separatorInset = UIEdgeInsetsZero;
    self.table.dataSource = self;
    self.table.delegate = self;
    [container addSubview:self.table];
   
    _mapView = [[GMSMapView alloc]initWithFrame:container.bounds];
    self.mapView.delegate = self;
    
    __block FeaturedViewController *blockself = self;
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [app showLoaderInView:self.view];
    [PFCloud  callFunctionInBackground:@"getFeaturedListings" withParameters:[NSDictionary dictionary] block:^(id object, NSError *error)
    {
         [blockself handleDataLoaded:object];
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app hideLoader];
    
    [super viewDidDisappear:animated];
}

-(void)handleDataLoaded:(NSArray *)data
{
    Listing *listing;
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app hideLoader];
    
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
    return 215.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Listing *listing = [self.tableData objectAtIndex:indexPath.row];
    [self showDetails:listing];
}

-(void)showDetails:(Listing *)listing
{
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

-(BOOL)shouldAutorotate
{
    return NO;
}

-(void)viewStateRequestChange:(ListingViewingState)state
{
    switch (state) {
        case kMap:
            [self handleShowMap];
            break;
        case kList:
            [UIView transitionFromView:self.mapView toView:self.table duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
            break;
    }
}

#pragma mark - map view
-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    [self showDetails:(Listing *)marker.userData];
    return YES;
}

-(void )handleShowMap
{
    [UIView transitionFromView:self.table toView:self.mapView duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
    
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


@end
