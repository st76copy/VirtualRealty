//
//  SocialLifeCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 12/4/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "SocialLifeCell.h"
#import <CoreLocation/CoreLocation.h>
#import "ErrorFactory.h"

@implementation SocialLifeCell

-(void)render
{
    if( [self.mapView superview] != nil )
    {
        return;
    }
    
    __block SocialLifeCell *blockself = self;
    
    _location = self.cellinfo[@"current-value"];
    
    _mapView = [[GMSMapView alloc]initWithFrame:CGRectMake(0, 0, 320, 240)];
    self.mapView.delegate = self;
    self.mapView.settings.scrollGestures = NO;
    self.mapView.settings.zoomGestures   = NO;
    self.mapView.settings.consumesGesturesInView = NO;
    self.mapView.myLocationEnabled = NO;
    
    [self.contentView addSubview:self.mapView];
    
 
    
    CLLocationDegrees lat  = _location.coordinate.latitude;
    CLLocationDegrees log  = _location.coordinate.longitude;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:log zoom:12];
    [self.mapView setCamera:camera];
     NSString *template = @"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@";
    NSString *url = [NSString stringWithFormat:template, _location.coordinate.latitude, _location.coordinate.longitude,@"200", @"restaurant%7cbar%7csubway_station%7cgrocery_or_supermarket", kGOOGLE_PLACES_KEY];
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
        NSMutableArray *markers = [NSMutableArray array];
        GMSMarker *marker;
        
        for( NSDictionary *info in [json valueForKey:@"results"] )
        {
            float longatude = [[[[info valueForKey:@"geometry"]valueForKey:@"location"]valueForKey:@"lng"]floatValue];
            float lat       = [[[[info valueForKey:@"geometry"]valueForKey:@"location"]valueForKey:@"lat"]floatValue];
            CLLocation *loc = [[CLLocation alloc]initWithLatitude:lat longitude:longatude];
            
            marker = [GMSMarker markerWithPosition:loc.coordinate];
            marker.map = self.mapView;
            marker.icon = [Utils getIconForBusinessTypes:info[@"types"]];
            marker.userData = info;
            marker.title = [info valueForKey:@"name"];
            marker.snippet =[info valueForKey:@"name"];
            marker.groundAnchor = CGPointMake(0.5, 0.5);
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
        camera = [self.mapView cameraForBounds:bounds insets:UIEdgeInsetsMake(40, 40, 40, 40)];
        
        if( camera.zoom  > 18 )
        {
            camera = [GMSCameraPosition cameraWithLatitude:camera.target.latitude longitude:camera.target.longitude zoom:18];
        }
        
        
        marker = [[GMSMarker alloc] init];
        marker.position = camera.target;
        marker.title = @"Me";
        marker.icon = [UIImage imageNamed:@"home-icon.png"];
        marker.map = self.mapView;
        

        [self.mapView setCamera:camera];
        [self.mapView startRendering];
    });
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    NSLog(@"%@ --- did tap %@ ", self, marker.userData);
    return YES;
}

@end
