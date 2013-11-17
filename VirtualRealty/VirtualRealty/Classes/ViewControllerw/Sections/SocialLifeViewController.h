//
//  SocialLifeViewController.h
//  VirtualRealty
//
//  Created by christopher shanley on 11/17/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "AbstractViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "LocationManager.h"
@interface SocialLifeViewController : UIViewController

-(id)initWithLocation:(CLLocation *)loc;
@property(nonatomic, strong, readonly)GMSMapView *mapView;

@end
