//
//  NavFooterView.m
//  VirtualRealty
//
//  Created by christopher shanley on 1/6/14.
//  Copyright (c) 2014 virtualrealty. All rights reserved.
//

#import "NavFooterView.h"
#import "UIColor+Extended.h"

@implementation NavFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 250)];
    if (self) {
        UIImageView *stroke = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"stroke.png"]];
        UIImageView *logo  = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"nav-table-footer.png"]];
    
        self.backgroundColor = [UIColor colorFromHex:@"212a2f"];
        
        [self addSubview:stroke];
        [self addSubview:logo];
        
        CGRect rect = logo.frame;
        rect.origin.x = (160.0f - logo.frame.size.width * 0.5) - 40;
        rect.origin.y = 125.0f - logo.frame.size.height * 0.5;
        logo.frame = CGRectIntegral(rect);
    }
    return self;
}


@end
