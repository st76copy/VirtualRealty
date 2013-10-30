
//
//  UserListingCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 10/21/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "UserListingCell.h"
#import "User.h"
#import <QuartzCore/QuartzCore.h>

@implementation UserListingCell



-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self)
    {
    }
    return self;
}

-(void) render
{
    [super render];
    
    if( [self.listing.submitterObjectId isEqualToString:[User sharedUser].uid] )
    {
        switch ( [self.listing.listingState intValue] )
        {
            case kVacant:
                self.stateLabel.text = @"Vacant";
                [self.stateLabel sizeToFit];
                [self.stateLabel setTextColor:[UIColor greenColor]];
                break;
            case kRented:
                self.stateLabel.text = @"Rented";
                [self.stateLabel sizeToFit];
                [self.stateLabel setTextColor:[UIColor blueColor]];
                break;
            case kPending:
                self.stateLabel.text = @"Pending";
                [self.stateLabel sizeToFit];
                [self.stateLabel setTextColor:[UIColor redColor]];
                break;
        }
        
        CGRect rect = self.stateLabel.frame;
        rect.origin.x = 320 - ( self.stateLabel.frame.size.width + 10 );
        rect.origin.y = 20 - ( self.stateLabel.frame.size.height * 0.5);
        self.stateLabel.frame = rect;
    }

}

@end
