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

@end



@interface LocationManager : NSObject<CLLocationManagerDelegate>

+(LocationManager *)shareManager;

-(void)removeDelegate:(id<LocationManagerDelegate>)obj;
-(void)registerDelegate:(id<LocationManagerDelegate>)obj;
-(void)getAddress:(NSString *)address block:(void (^) (CLLocationCoordinate2D loc) )block;
-(void)stopGettingLocation;
-(void)startGettingLocations;

-(void)geoCodeUsingAddress:(NSString *)address block:(void (^) (CLLocationCoordinate2D loc) )block;
@property(nonatomic, strong, readonly)dispatch_queue_t renderQueue;
@property(nonatomic, strong, readonly)CLLocation     *location;
@property(nonatomic, strong, readonly)NSString       *currentAddress;
@property(nonatomic, strong, readonly)NSMutableArray *delegates;
@property(nonatomic, strong, readonly)CLLocationManager *locationManager;

@end
