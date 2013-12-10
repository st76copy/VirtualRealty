//
//  SectionTitleView.m
//  VirtualRealty
//
//  Created by christopher shanley on 12/4/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "SectionTitleView.h"
#import "UIColor+Extended.h"

@implementation SectionTitleView

-(id)initWithTitle:(NSString *)string
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)];
    if (self)
    {
        self.backgroundColor = [UIColor colorFromHex:@"cbd5d9"];
        
        UIImage  *wedge = [UIImage imageNamed:@"rigth-wedge.png"];
        
        UIImageView *triangle = [[UIImageView alloc]initWithImage:wedge];
        [self addSubview:triangle];
        
        UIView *bg = [[UIView alloc]initWithFrame:CGRectZero];
        [bg setBackgroundColor:[UIColor colorFromHex:@"01aef0"]];
        [self addSubview:bg];
        
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.textColor = [UIColor whiteColor];
        label.text = string;
        label.font = [UIFont systemFontOfSize:14];
        [label sizeToFit];
        [self addSubview:label];
        
    
        CGRect rect;
        rect = bg.frame;
        rect.size.width  = label.frame.size.width + 10;
        rect.size.height = label.frame.size.height + 10;
        rect.origin.y    = self.frame.size.height - rect.size.height;
        bg.frame = rect;
        
        rect = label.frame;
        rect.origin.y = bg.frame.origin.y + 5;
        rect.origin.x = bg.frame.origin.x + 5;
        label.frame = rect;
        
        rect = triangle.frame;
        rect.size.height = bg.frame.size.height;
        rect.origin.x = bg.frame.size.width;
        rect.origin.y = self.frame.size.height - rect.size.height;
        triangle.frame = rect;
        
    }
    return self;
}


@end
