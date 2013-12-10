//
//  SocialLifeCell.h
//  VirtualRealty
//
//  Created by christopher shanley on 12/4/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "FormCell.h"
#import <GoogleMaps/GoogleMaps.h>

@interface SocialLifeCell : FormCell<GMSMapViewDelegate>

@property(nonatomic, strong, readonly)GMSMapView *mapView;
@property(nonatomic, strong, readonly)CLLocation *location;

@end
