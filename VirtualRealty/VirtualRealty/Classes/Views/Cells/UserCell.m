//
//  User.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "UserCell.h"
#import "User.h"
@implementation UserCell

-(void)render
{
    self.textLabel.font = [UIFont systemFontOfSize:12];
    switch ([User sharedUser].state )
    {
        case kNoUser:
            self.textLabel.text = @"Please Log In";
            break;
            
        default:
            self.textLabel.text = [NSString stringWithFormat:@"Logged In As %@ ", [User sharedUser].username];
            break;
    }
}

@end
