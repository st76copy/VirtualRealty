//
//  NearMeViewController.m
//  VirtualRealty
//
//  Created by christopher shanley on 11/17/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "NearMeViewController.h"
#import "LocationManager.h"
#import "Listing.h"
#import "ListingDetailViewController.h"
#import <Parse/Parse.h>

@interface NearMeViewController ()<LocationManagerDelegate>

-(void)handleDataLoaded:(NSArray *)data;

@end

@implementation NearMeViewController
@synthesize distance = _distance;

@synthesize mapView = _mapView;
@synthesize distanceLabel = _distanceLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Near Me";
    _mapView = [[GMSMapView alloc]initWithFrame:self.view.frame];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
 
    UIView *bg = [[UIView alloc]initWithFrame:CGRectMake(0, 65, 320, 80)];
    [bg setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.8]];
    [self.view addSubview:bg];
    
    _distance = 0.5f;
    
    _distanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 110, 320, 20)];
    [self.distanceLabel setBackgroundColor:[UIColor clearColor]];
    [self.distanceLabel setText:@"0.5 miles"];
    [self.distanceLabel setTextColor:[UIColor blackColor]];
    [self.distanceLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.distanceLabel];
    
    UISlider *distanceSlider = [[UISlider alloc]initWithFrame:CGRectMake(20, 80, 280, 20)];
    distanceSlider.minimumValue = 0.5;
    distanceSlider.maximumValue = 2.0;
    [distanceSlider addTarget:self action:@selector(handleSliderChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:distanceSlider];
    
    UIBarButtonItem *updateButton = [[UIBarButtonItem alloc]initWithTitle:@"Update" style:UIBarButtonItemStyleBordered target:self action:@selector(handleUpdate:)];
    self.navigationItem.rightBarButtonItem = updateButton;
}

-(void)viewDidAppear:(BOOL)animated
{
    CLLocationDegrees lat  = [LocationManager shareManager].location.coordinate.latitude;
    CLLocationDegrees log  = [LocationManager shareManager].location.coordinate.longitude;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:log zoom:12];
    [self.mapView setCamera:camera];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = camera.target;
    marker.title = @"Me";
    marker.map = self.mapView;
    
    
    __block NearMeViewController *blockself = self;
    
    CLLocation *loc = [LocationManager shareManager].location;
    NSDictionary *params = @{ @"long":[NSNumber numberWithDouble:loc.coordinate.longitude], @"latt":[NSNumber numberWithDouble:loc.coordinate.latitude], @"distance":[NSNumber numberWithFloat:self.distance] };
    [PFCloud callFunctionInBackground:@"nearMe" withParameters:params block:^(id object, NSError *error)
    {
         [blockself handleDataLoaded:object];
    }];
}

-(void)handleSliderChange:(id)sender
{
    UISlider *temp = (UISlider *)sender;
    self.distanceLabel.text = [NSString stringWithFormat:@"%0.2f miles", temp.value ];
    _distance = temp.value;
}

-(void)handleDataLoaded:(NSArray *)data
{
    GMSCameraPosition *camera;
    GMSMarker *marker;
    NSMutableArray *temp = [NSMutableArray array];
    
    if( data.count == 0 )
    {
        NSLog(@"%@ no results ", self );
        return;
    }
    
    for( NSDictionary *info in data )
    {
        [temp addObject:[[Listing alloc]initWithFullData:info]];
    }
    
    
    [self.mapView clear];
    for( Listing *listing in temp )
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
    camera = [self.mapView cameraForBounds:bounds insets:UIEdgeInsetsMake(110, 30, 110, 30)];
    
    if( camera.zoom  > 18 )
    {
        camera = [GMSCameraPosition cameraWithLatitude:camera.target.latitude longitude:camera.target.longitude zoom:18];
    }
    
    [self.mapView setCamera:camera];
    [self.mapView startRendering];
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    ListingDetailViewController *details = [[ListingDetailViewController alloc]initWithListing:(Listing *)marker.userData];
    [self.navigationController pushViewController:details animated:YES];

    return YES;
}

-(void)handleUpdate:(id)sender
{
    __block NearMeViewController *blockself = self;
    CLLocation *loc = [LocationManager shareManager].location;
    
    NSDictionary *params = @{ @"long":[NSNumber numberWithDouble:loc.coordinate.longitude],
                              @"latt":[NSNumber numberWithDouble:loc.coordinate.latitude],
                              @"distance":[NSNumber numberWithFloat:self.distance]
                            };
    
    [PFCloud callFunctionInBackground:@"nearMe" withParameters:params block:^(id object, NSError *error)
    {
         [blockself handleDataLoaded:object];
    }];
}


@end
