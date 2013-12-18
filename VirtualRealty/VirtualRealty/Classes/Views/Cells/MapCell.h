//
//  MapCell.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/16/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "FormCell.h"
#import <GoogleMaps/GoogleMaps.h>
#import "LocationManager.h"
@interface MapCell : FormCell<LocationManagerDelegate>

-(void)handleWrongAddresss:(id)sender;

@property(nonatomic, strong, readonly)GMSMapView  *map;
@property(nonatomic, strong, readonly)UIView      *textBackGround;
@property(nonatomic, strong, readonly)UITextField *addresssLabel;


@end
