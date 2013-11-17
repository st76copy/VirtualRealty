//
//  NearMeViewController.h
//  VirtualRealty
//
//  Created by christopher shanley on 11/17/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "AbstractViewController.h"
#import <GoogleMaps/GoogleMaps.h>


@interface NearMeViewController : AbstractViewController<GMSMapViewDelegate>

@property(nonatomic, assign, readonly)float      distance;
@property(nonatomic, strong, readonly)GMSMapView *mapView;
@property(nonatomic, strong, readonly)UILabel    *distanceLabel;

@end
