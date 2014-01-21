//
//  User.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "UserCell.h"
#import "User.h"
#import "UIColor+Extended.h"
@implementation UserCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.textColor = [UIColor colorFromHex:@"434343"];
    CGRect rect = self.textLabel.frame;
    rect.origin.y = self.contentView.frame.size.height * 0.5 - rect.size.height * 0.5;
    self.textLabel.textColor = [UIColor colorFromHex:@"434343"];
    self.textLabel.frame = rect;
    
    [self.detailTextLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:16]];
    [self.detailTextLabel setTextAlignment:NSTextAlignmentLeft];
    [self.detailTextLabel sizeToFit];
    [self.detailTextLabel setTextColor:[UIColor colorFromHex:@"00aeef"]];
    
    rect = self.detailTextLabel.frame;
    rect.origin.x = self.contentView.frame.size.width - (self.detailTextLabel.frame.size.width + 10);
    rect.origin.y = self.contentView.frame.size.height * 0.5 - rect.size.height * 0.5;
    self.detailTextLabel.frame = rect;
}

-(void)render
{
    self.textLabel.font = [UIFont systemFontOfSize:12];
    switch ([User sharedUser].state )
    {
        case kNoUser:
            self.textLabel.text = @"Please Log In";
            self.detailTextLabel.text = nil;
            break;
            
        default:
            self.textLabel.text =  @"Logged In As";
            self.detailTextLabel.text = [User sharedUser].username;
            break;
    }
}

@end
