//
//  NavCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 11/26/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "NavCell.h"
#import "UIColor+Extended.h"

@implementation NavCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if( self != nil )
    {
        self.backgroundView = [[UIView alloc]initWithFrame:CGRectZero];
        self.backgroundView.backgroundColor = [UIColor colorFromHex:@"212a2f"];
        
        self.selectedBackgroundView = [[UIView alloc]initWithFrame:CGRectZero];
        self.selectedBackgroundView.backgroundColor = [UIColor colorFromHex:@"c57834"];
        
        self.textLabel.textColor = [UIColor whiteColor];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
}

-(void)render
{
    [super render];
    self.textLabel.text = [[self.cellinfo valueForKey:@"label"]uppercaseString];
}
@end
