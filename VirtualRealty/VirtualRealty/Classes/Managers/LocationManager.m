//
//  LocationManager.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/17/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//
#import "LocationManager.h"

@interface LocationManager()

-(void) handleFormatAddress:(NSDictionary *)addressInfo;

@end

@implementation LocationManager

@synthesize location        = _location;
@synthesize delegates       = _delegates;
@synthesize currentAddress  = _currentAddress;
@synthesize locationManager = _locationManager;
@synthesize renderQueue     = _renderQueue;

+(LocationManager *)shareManager
{
    static LocationManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        instance = [[LocationManager alloc]init];
    });
    return instance;
}

-(id)init
{
    self = [super init];
    if( self != nil )
    {
        _locationManager = [[CLLocationManager alloc]init];
        [_locationManager setDelegate:self];
        
        _renderQueue = dispatch_queue_create("com.vr.LocationManager", NULL);
        _delegates   = [NSMutableArray array];
    }
    return self;
}

-(void)removeDelegate:(id<LocationManagerDelegate>)obj
{
    [self.delegates removeObject:obj];
}

-(void)registerDelegate:(id<LocationManagerDelegate>)obj
{
    if( [self.delegates containsObject:obj] == NO )
    {
        [self.delegates addObject:obj];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    dispatch_async(self.renderQueue, ^{
        __block LocationManager *blockmanager = self;
        CLGeocoder *gc = [[CLGeocoder alloc] init];
        _location = [locations objectAtIndex:0];;
        
        
        [gc reverseGeocodeLocation:self.location completionHandler:^(NSArray *placemark, NSError *error)
        {
             CLPlacemark *pm = [placemark objectAtIndex:0];
             
             [blockmanager handleFormatAddress:pm.addressDictionary];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            for( id<LocationManagerDelegate> del in self.delegates )
            {
                [del locationUpdated];
            }
    
        });
    });
}

-(void) handleFormatAddress:(NSDictionary *)addressInfo
{
    NSString *street = [addressInfo valueForKey:@"Street"];
    NSString *city   = [addressInfo valueForKey:@"City"];
    NSString *zip    = [addressInfo valueForKey:@"ZIP"];
    NSString *state  = [addressInfo valueForKey:@"State"];
    
    _currentAddress = [NSString stringWithFormat:@"%@\n%@,%@ %@", street, city, state, zip];
}


    
-(void)geoCodeUsingAddress:(NSString *)address block:(void (^) (CLLocationCoordinate2D loc) )block
{
    _currentAddress = address;
    
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
        
        NSString *response = [NSString stringWithContentsOfURL: [NSURL URLWithString: req] encoding: NSUTF8StringEncoding error: NULL];
        NSData   *data  = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *googleResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSDictionary    *resultsDict = [googleResponse valueForKey:  @"results"];   // get the results dictionary
        NSDictionary   *geometryDict = [resultsDict valueForKey: @"geometry"];   // geometry dictionary within the  results dictionary
        NSDictionary   *locationDict = [geometryDict valueForKey: @"location"];   // location dictionary within the geometry dictionary
        
        NSArray *latArray = [locationDict valueForKey: @"lat"];
        NSString *latString = [latArray lastObject];     // (one element) array entries provided by the json parser
        
        NSArray *lngArray = [locationDict valueForKey: @"lng"];
        NSString *lngString = [lngArray lastObject];     // (one element) array entries provided by the json parser
        
        __block CLLocationCoordinate2D location;
        location.latitude = [latString doubleValue];// latitude;
        location.longitude = [lngString doubleValue]; //longitude;
        
        _location = [[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block( location );
        });
    });
}

-(void)getAddress:(NSString *)address block:(void (^) (CLLocationCoordinate2D loc) )block
{
    
}

-(void)stopGettingLocation
{
    [_locationManager stopUpdatingLocation];
}

-(void)startGettingLocations
{
    [_locationManager startUpdatingLocation];
}

@end
