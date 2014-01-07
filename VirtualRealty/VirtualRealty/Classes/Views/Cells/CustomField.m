//
//  CustomField.m
//  VirtualRealty
//
//  Created by christopher shanley on 1/6/14.
//  Copyright (c) 2014 virtualrealty. All rights reserved.
//

#import "CustomField.h"
#import "UIColor+Extended.h"
@implementation CustomField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
    }
    return self;
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return CGRectMake(0,0,bounds.size.width,bounds.size. height); //Return your desired x,y position and width,height
}

-(void)drawPlaceholderInRect:(CGRect)rect
{
    UIFont *font = [UIFont fontWithName:@"MuseoSans-500" size:16];
    NSDictionary *textTreatment = @{NSForegroundColorAttributeName:[UIColor colorFromHex:@"aaaaaa"],
                                    NSFontAttributeName:font};
    
    CGSize size = [self.placeholder sizeWithAttributes:textTreatment];
    
    [[UIColor colorFromHex:@"aaaaaa"] setFill];
    
    rect.origin.x = rect.size.width - size.width;
    [[self placeholder] drawInRect:rect withAttributes:textTreatment];
}

@end
