//
//  LocationManager.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/17/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationManagerDelegate <NSObject>

-(void)locationUpdated;
-(void)locationFailed;
@end



@interface LocationManager : NSObject<CLLocationManagerDelegate>

+(LocationManager *)shareManager;

-(void)removeDelegate:(id<LocationManagerDelegate>)obj;
-(void)registerDelegate:(id<LocationManagerDelegate>)obj;
-(void)stopGettingLocation;
-(void)startGettingLocations;
-(void)setCurrentLocationByString:(NSString *)address block:(void (^) (CLLocationCoordinate2D loc) )block;
-(void)requestGeoFromString:(NSString *)term block:(void (^) (CLLocationCoordinate2D loc, NSDictionary *results) )block;

@property(nonatomic, strong, readonly)dispatch_queue_t renderQueue;
@property(nonatomic, strong, readonly)CLLocation     *location;
@property(nonatomic, strong, readonly)NSString       *currentAddress;
@property(nonatomic, strong, readonly)NSHashTable    *delegates;
@property(nonatomic, strong, readonly)CLLocationManager *locationManager;
@property(nonatomic, strong, readonly)NSDictionary      *addressInfo;

@end
