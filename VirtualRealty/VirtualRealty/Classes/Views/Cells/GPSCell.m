//
//  GPSCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 12/12/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "GPSCell.h"


@implementation GPSCell



-(void)render
{
    [super render];
    
    if( self.cellinfo[@"current-value"] )
    {
        self.detailTextLabel.text = self.cellinfo[@"current-value"];
    }
    else
    {
        if( [LocationManager shareManager].currentAddress != nil )
        {
            NSDictionary *address = [LocationManager shareManager].addressInfo;
            NSDictionary *info = @{
                                   @"city" : address[@"City"],
                                   @"street" : address[@"FormattedAddressLines"][0],
                                   @"borough" : [(NSString *)address[@"FormattedAddressLines"][1] componentsSeparatedByString:@","][0],
                                   @"neighborhood" : address[@"SubLocality"],
                                   @"zip" : address[@"ZIP"],
                                   @"state" : address[@"State"]
                                   };
            
            self.detailTextLabel.text = info[@"neighborhood"];
            
            
            [[LocationManager shareManager]removeDelegate:self];
            self.formValue = @{@"address" :[LocationManager shareManager].currentAddress, @"location" :[LocationManager shareManager].location, @"details" : info  };
            
            [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"geo"]intValue]];
            [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue]];
        }
        else
        {
            [[LocationManager shareManager]registerDelegate:self];
            [[LocationManager shareManager]startGettingLocations];
        }
    }
}

-(void)locationUpdated
{
    if( [LocationManager shareManager].currentAddress != nil )
    {
        NSDictionary *address = [LocationManager shareManager].addressInfo;
        NSDictionary *info = @{
                               @"city" : address[@"City"],
                               @"street" : address[@"FormattedAddressLines"][0],
                               @"borough" : [(NSString *)address[@"FormattedAddressLines"][1] componentsSeparatedByString:@","][0],
                               @"neighborhood" : address[@"SubLocality"],
                               @"zip" : address[@"ZIP"],
                               @"state" : address[@"State"]
                               };
        
        self.detailTextLabel.text = info[@"neighborhood"];
        
        [[LocationManager shareManager]removeDelegate:self];
        self.formValue =  info[@"neighborhood"];
        [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue]];
    }
}

@end
