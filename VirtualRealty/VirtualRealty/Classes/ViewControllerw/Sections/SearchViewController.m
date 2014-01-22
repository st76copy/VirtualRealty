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
#import "MapListToggleView.h"
#import "AppDelegate.h"
#import "CustomNavViewController.h"
#import "MapPriceTag.h"
#import "ListingCell.h"
#import "LocationManager.h"
#import "User.h"
#import "SearchFilters.h"
#import "ErrorFactory.h"
#import "UIColor+Extended.h"
#import "ReachabilityManager.h"

@interface SearchViewController ()<SearchFilterDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, GMSMapViewDelegate,ToggleDelegate>
{
    ListingCell *details;
    UIView *container;
    UIRefreshControl *refreshControl;

}

@property(nonatomic, strong)UITapGestureRecognizer *tap;
@property(nonatomic, strong)SearchFilters *currentFilters;

-(void)handleNavBarTap:(UITapGestureRecognizer *)sender;
-(void)handleRefresh:(id)sender;
-(ListingCell *)getDetails:(Listing *)listing;
-(void)handleMakeFilter:(id)sender;
-(void)handleShowMap:(id)sender;
-(void)handleShowList:(id)sender;
-(void)adjustMap:(GMSMarker *)marker;
-(void)resetMap;
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
    self.view.backgroundColor = [UIColor colorFromHex:@"cbd5d9"];
    
    _searchBar = [[UISearchBar alloc]init];
    [_searchBar sizeToFit];
    
    self.tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleNavBarTap:)];
   
    
    self.searchBar.placeholder = NSLocalizedString(@"Search Location", @"Copy for searchbar placeholder");
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.delegate           = self;
    self.searchBar.keyboardType       = UIReturnKeySearch;
    self.searchBar.translucent        = YES;
    self.searchBar.searchBarStyle     = UISearchBarStyleMinimal;
    self.searchBar.barTintColor       = [UIColor colorFromHex:@"cbd5d9"];
    
    CGRect rect;
    MapListToggleView *mapListToggle = [[MapListToggleView alloc]initWithFrame:CGRectZero];
    mapListToggle.delegate = self;
    rect = mapListToggle.frame;
    rect.origin.y = self.navigationController.navigationBar.frame.size.height;
   
    rect = self.view.frame;
    rect.origin.y = mapListToggle.frame.size.height;
    rect.size.height -= mapListToggle.frame.size.height + self.navigationController.navigationBar.frame.size.height + 20;
    
    container = [[UIView alloc]initWithFrame:rect];
    [self.view addSubview:container];
    
    _mapView = [[GMSMapView alloc]initWithFrame:container.bounds];
    self.mapView.delegate = self;
    
    refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    
    _table = [[UITableView alloc]initWithFrame:container.bounds];
    self.table.separatorInset = UIEdgeInsetsZero;
    self.table.dataSource = self;
    self.table.delegate = self;
    self.table.backgroundColor = [UIColor clearColor];
    self.table.tableHeaderView = self.searchBar;
    [self.table addSubview:refreshControl];
    
    [container addSubview:self.table];
    
    [self.view addSubview:mapListToggle];
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc]initWithTitle:@"Filter" style:UIBarButtonItemStyleBordered target:self action:@selector(handleMakeFilter:)];
    self.navigationItem.rightBarButtonItem = filterButton;
    
    __block AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if ( [ReachabilityManager sharedManager].currentStatus == NotReachable )
    {
        [refreshControl endRefreshing];
        [[ReachabilityManager sharedManager]showAlert];
        return;
    }
    
    if( self.currentFilters == nil )
    {
        [app showLoaderInView:self.view];
        __block SearchViewController *blockself = self;
        [PFCloud  callFunctionInBackground:@"allListings" withParameters:[NSDictionary dictionary] block:^(id object, NSError *error)
        {
            if( error )
            {
                [[ErrorFactory getAlertForType:kServerError andDelegateOrNil:nil andOtherButtons:nil]show];
            }
            else
            {
                [refreshControl endRefreshing];
                [blockself handleDataLoaded:object];
            }
            [app hideLoader];
        }];
    }
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    [self.navigationController.navigationBar addGestureRecognizer:self.tap];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //    [self.navigationController.navigationBar removeGestureRecognizer:self.tap];
}


-(void)handleNavBarTap:(UITapGestureRecognizer *)sender
{
    [self.table scrollRectToVisible:CGRectMake(0, 0, self.table.frame.size.width, self.table.frame.size.height) animated:YES];
}
#pragma mark - search bar delegates
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc]initWithTitle:@"Filter" style:UIBarButtonItemStyleBordered target:self action:@selector(handleMakeFilter:)];
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self.navigationItem setRightBarButtonItems:@[filterButton] animated:YES];
}


-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar setText:nil];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
    __block AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app showLoaderInView:self.view];
    
    __block SearchViewController *blockself = self;
    
    [[LocationManager shareManager]requestGeoFromString:[NSString stringWithFormat:@"%@, NYC",[self.searchBar.text lowercaseString]] block:^(CLLocationCoordinate2D loc, NSDictionary *results) {
        
        NSDictionary *params = @{@"long":[NSNumber numberWithDouble:loc.longitude],
                                 @"latt":[NSNumber numberWithDouble:loc.latitude],
                                 @"distance":[User sharedUser].searchRadius
                                 };
        
        [PFCloud callFunctionInBackground:@"search" withParameters:params block:^(id object, NSError *error)
        {
            if( error )
            {
                [[ErrorFactory getAlertForType:kServerError andDelegateOrNil:nil andOtherButtons:nil]show];
            }
            else
            {
                [blockself handleDataLoaded:object];
            }
            [app hideLoader];
        }];
        [blockself.searchBar resignFirstResponder];
    }];
}


#pragma mark - ui refresh
-(void)handleRefresh:(id)sender
{
    NSLog(@"%@ --- handle refresh " , self);
    
    __block AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.searchBar resignFirstResponder];
    
    if ( [ReachabilityManager sharedManager].currentStatus == NotReachable )
    {
        [refreshControl endRefreshing];
        [[ReachabilityManager sharedManager]showAlert];
        return;
    }
    
    if( self.currentFilters )
    {
        [self filtersDoneWithOptions:self.currentFilters];
    }
    else
    {
        if( self.searchBar.text == nil || [self.searchBar.text isEqualToString:@""] )
        {
            [app showLoaderInView:self.view];
            __block UIRefreshControl *blockRefresh = refreshControl;
            __block SearchViewController *blockself = self;
            [PFCloud  callFunctionInBackground:@"allListings" withParameters:[NSDictionary dictionary] block:^(id object, NSError *error)
             {
                 if( error )
                 {
                     [blockRefresh endRefreshing];
                     [[ErrorFactory getAlertForType:kServerError andDelegateOrNil:nil andOtherButtons:nil]show];
                 }
                 else
                 {
                     [blockRefresh endRefreshing];
                     [blockself handleDataLoaded:object];
                 }
                 [app hideLoader];
             }];
    
        }
        else
        {
            [self searchBarSearchButtonClicked:self.searchBar];
        }
    }
}


-(void)toggleMenu
{
    [self.searchBar resignFirstResponder];
    [super toggleMenu];
}


-(void)handleDataLoaded:(NSArray *)data
{
    Listing *listing;
    
    [refreshControl endRefreshing];
    
    if( data.count == 0 )
    {
        [[ErrorFactory getAlertForType:kNoResultsError andDelegateOrNil:nil andOtherButtons:nil]show];
        return;
    }
    
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
    SearchFilterViewController *filters =[[SearchFilterViewController alloc]initWithFilterOrNil:self.currentFilters];
    filters.delegate = self;
    CustomNavViewController *nc = [[CustomNavViewController alloc ]initWithRootViewController:filters];
    filters.navigationItem.title = ([self.searchBar.text isEqualToString:@""]) ?  @"Filters" : [NSString stringWithFormat:@"Filters For %@", self.searchBar.text];
    [self presentViewController:nc animated:YES completion:nil];
}


-(void)showDetails:(Listing *)listing
{
    ListingDetailViewController *detailsVC = [[ListingDetailViewController alloc]initWithListing:listing];
    [self.navigationController pushViewController:detailsVC animated:YES];
}


#pragma mark - filter delegate
-(void)filtersDoneWithOptions:(SearchFilters *)filters
{
    
    if ( [ReachabilityManager sharedManager].currentStatus == NotReachable )
    {
        [refreshControl endRefreshing];
        [[ReachabilityManager sharedManager]showAlert];
        return;
    }
    
    if( filters == nil )
    {

        return;
    }
    
    self.currentFilters = filters;
    
    NSDictionary *options = [self.currentFilters getActiveFilters];
    
    if( options == nil )
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self clearFilters];
        return;
    }
    
    __block AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app showLoaderInView:self.view];
    
    
    NSDictionary *params = nil;
    
    if( self.searchBar.text && [self.searchBar.text isEqualToString:@""] == NO )
    {
        if( options )
        {
            params = @{@"filters" : options, @"keyword" : self.searchBar.text };
        }
        else
        {
            params = @{ @"keyword" : self.searchBar.text };
        }
        
    }
    else
    {
        if( options )
        {
            params = @{ @"filters" : options };
        }
    }
    
    __block SearchViewController *blockself = self;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    __block UIRefreshControl *blockrefresh = refreshControl;
    
    if( self.searchBar.text && [self.searchBar.text isEqualToString:@""] == NO )
    {
        [[LocationManager shareManager]requestGeoFromString:[NSString stringWithFormat:@"%@, NYC",[self.searchBar.text lowercaseString]] block:^(CLLocationCoordinate2D loc, NSDictionary *results) {
            
            
            NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:[params mutableCopy]];
            temp[@"long"]     = [NSNumber numberWithDouble:loc.longitude];
            temp[@"latt"]     = [NSNumber numberWithDouble:loc.latitude];
            temp[@"distance"] = [User sharedUser].searchRadius;
            
            [PFCloud callFunctionInBackground:@"search" withParameters:temp block:^(id object, NSError *error)
            {
                if( error == nil )
                {
                    [blockself handleDataLoaded:object];
                }
                else
                {
                    [[ErrorFactory getAlertForType:kServerError andDelegateOrNil:nil andOtherButtons:nil]show];
                }
                [blockrefresh endRefreshing];
                [app hideLoader];
            }];
            [blockself.searchBar resignFirstResponder];
        }];
    }
    else
    {
        [PFCloud callFunctionInBackground:@"search" withParameters:params block:^(id object, NSError *error)
        {
            if( error )
            {
                [[ErrorFactory getAlertForType:kServerError andDelegateOrNil:nil andOtherButtons:nil]show];
            }
            else
            {
                [blockself handleDataLoaded:object];
            }
            [blockrefresh endRefreshing];
            [app hideLoader];
        }];
    }
}


-(void)clearFilters
{
    if ( [ReachabilityManager sharedManager].currentStatus == NotReachable )
    {
        [refreshControl endRefreshing];
        [[ReachabilityManager sharedManager]showAlert];
        return;
    }

    __block AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [app showLoaderInView:self.view];
    __block SearchViewController *blockself = self;
    [PFCloud  callFunctionInBackground:@"allListings" withParameters:[NSDictionary dictionary] block:^(id object, NSError *error)
    {
        if( error == nil )
        {
            [blockself handleDataLoaded:object];
        }
        else
        {
            [[ErrorFactory getAlertForType:kServerError andDelegateOrNil:nil andOtherButtons:nil]show];
        }
        [app hideLoader];
    }];
}



#pragma mark - table delegate
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
    [self.table deselectRowAtIndexPath:indexPath animated:YES];
    Listing *listing = [self.tableData objectAtIndex:indexPath.row];
    [self showDetails:listing];
}


#pragma mark - map
-(void )handleShowMap:(id)sender
{
    [UIView transitionFromView:self.table toView:self.mapView duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        
    }];
    GMSCameraPosition *camera;
    GMSMarker *marker;
    MapPriceTag *priceTag;
    
    [self.mapView clear];
    for( Listing *listing in self.tableData )
    {
        priceTag = [[MapPriceTag alloc]initWithFrame:CGRectZero];
        [priceTag setPrice:[listing.monthlyCost floatValue]];
        marker = [GMSMarker markerWithPosition:listing.geo.coordinate];
        marker.map = self.mapView;
        marker.icon = [priceTag toBitmap];
        marker.groundAnchor = CGPointMake(1, 1);
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
    
    camera = [self.mapView cameraForBounds:bounds insets:UIEdgeInsetsMake(110, 40, 10, 10)];
    [self.mapView setCamera:camera];
    [self.mapView startRendering];
}

-(void)handleShowList:(id)sender
{
    [UIView transitionFromView:self.mapView toView:self.table duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        
    }];
}

-(void)viewStateRequestChange:(ListingViewingState)state
{
    switch (state)
    {
        case kMap:
            [self handleShowMap:nil];
            break;
            
        case kList:
            [self handleShowList:nil];
            break;
    }
}

#pragma mark - map view 
-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]initWithCoordinate:marker.position coordinate:marker.position];
    
    if( details )
    {
        [UIView animateWithDuration:0.2 animations:^{
            details.alpha = 0;
        } completion:^(BOOL finished) {
            
            [details removeFromSuperview];
            details = nil;
            ListingCell *cell = [self getDetails:(Listing *)marker.userData];
            [self.mapView addSubview:cell];
            CGRect rect = cell.frame;
            rect.origin.y = 0;
            details = cell;
            
            [UIView animateWithDuration:0.3 animations:^{
                cell.frame = rect;
            }];
            [self adjustMap:marker];
            
        }];
    }
    else
    {
        ListingCell *cell = [self getDetails:(Listing *)marker.userData];
        [container addSubview:cell];
      
        CGRect rect = cell.frame;
        rect.origin.y = 0;
        details = cell;
        
        [UIView animateWithDuration:0.3 animations:^{
            cell.frame = rect;
        }];
        [self adjustMap:marker];
        
    }
    return YES;
}

-(ListingCell *)getDetails:(Listing *)listing
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(detailsTouched:)];
    
    ListingCell *cell = [[ListingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    
    cell.frame = CGRectMake(0, 0, 320, 215);
    cell.listing = listing;
    [cell render];
    [cell layoutSubviews];
    [cell setBackgroundColor:[UIColor whiteColor]];
    [cell addGestureRecognizer:tap];
    
    CGRect rect = cell.frame;
    rect.origin.y = cell.frame.size.height * -1;
    cell.frame = rect;

    cell.layer.masksToBounds = NO;
    cell.layer.shadowOpacity = 0.5f;
    cell.layer.shadowRadius  = 5.0f;
    cell.layer.shadowOffset  = CGSizeMake(0, 5.0f);
    cell.layer.shadowColor   = [UIColor blackColor].CGColor;
    cell.layer.shadowPath    = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
    
    

    return cell;
}

-(void)adjustMap:(GMSMarker *)marker
{
    
    CGPoint point = [self.mapView.projection pointForCoordinate:marker.position];
    float offsetx = point.x - 160;
    float offsety = point.y - 280;
    
    GMSCameraUpdate *cam = [GMSCameraUpdate scrollByX:offsetx Y:offsety];
    [self.mapView animateWithCameraUpdate:cam];
}

-(void)resetMap
{
    GMSCameraPosition *camera;
    
    GMSMarker *marker = [self.mapView.markers objectAtIndex:0];
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
    GMSCameraUpdate     *update = [GMSCameraUpdate fitBounds:bounds withEdgeInsets:UIEdgeInsetsMake(110, 10, 10, 10)];
    [self.mapView animateWithCameraUpdate:update];
    [self.mapView startRendering];
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    if( details )
    {
        [self handleClosePanel:nil];
    }
}

-(void)handleClosePanel:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        details.alpha = 0;
    } completion:^(BOOL finished) {
        
        [details removeFromSuperview];
        details = nil;
    }];
    [self resetMap];
}

-(void)detailsTouched:(UITapGestureRecognizer *)sender
{
    ListingCell *cell = (ListingCell *)sender.view;
    [self showDetails:cell.listing];
}

@end
