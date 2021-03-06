//
//  SocialLifeViewController.m
//  VirtualRealty
//
//  Created by christopher shanley on 11/17/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "SocialLifeViewController.h"
#import "JSONService.h"
#import "AFHTTPClient.h"
#import "ErrorFactory.h"
@interface SocialLifeViewController ()<GMSMapViewDelegate>
{
    CLLocation *location;
}
@end

@implementation SocialLifeViewController


@synthesize mapView = _mapView;

-(id)initWithLocation:(CLLocation *)loc
{
    self = [super initWithNibName:nil bundle:nil];
    if( self != nil )
    {
        
        location = loc;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    __block SocialLifeViewController *blockself = self;
    
    self.navigationItem.title = @"Bars and Restaurants";
    
    _mapView = [[GMSMapView alloc]initWithFrame:self.view.frame];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    CLLocationDegrees lat  = location.coordinate.latitude;
    CLLocationDegrees log  = location.coordinate.longitude;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:log zoom:12];
    [self.mapView setCamera:camera];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = camera.target;
    marker.title = @"Me";
    marker.map = self.mapView;
    
    NSString *template = @"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@";
    NSString *url = [NSString stringWithFormat:template, location.coordinate.latitude, location.coordinate.longitude,@"1609", @"restaurant%7cbar", kGOOGLE_PLACES_KEY];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];

    NSURLSessionDataTask *task;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    task = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
       if( error )
       {
           [[ErrorFactory getAlertCustomMessage:@"Goggle Places Failed" andDelegateOrNil:nil andOtherButtons:nil]show];
       }
       else
       {
           [blockself handleDataLoaded:data];
       }
        
    }];
    [task resume];
   
}

-(void)handleDataLoaded:(NSData *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@ loaded places %@ ", self , json );
        NSMutableArray *markers = [NSMutableArray array];
        GMSMarker *marker;
        for( NSDictionary *info in [json valueForKey:@"results"] )
        {
            float longatude = [[[[info valueForKey:@"geometry"]valueForKey:@"location"]valueForKey:@"lng"]floatValue];
            float lat       = [[[[info valueForKey:@"geometry"]valueForKey:@"location"]valueForKey:@"lat"]floatValue];
            CLLocation *loc = [[CLLocation alloc]initWithLatitude:lat longitude:longatude];
            
            marker = [GMSMarker markerWithPosition:loc.coordinate];
            marker.map = self.mapView;
            marker.title = [info valueForKey:@"name"];
            [markers addObject:marker];
        }
        
        
        GMSCameraPosition *camera;
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
    });
    
}

@end
