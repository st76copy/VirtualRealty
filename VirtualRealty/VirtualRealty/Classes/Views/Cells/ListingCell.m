//
//  ListingCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 10/7/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "ListingCell.h"
#import "NSDate+Extended.h"
#import "User.h"

@implementation ListingCell
@synthesize textBG = _textBG;
@synthesize thumb = _thumb;
@synthesize overlay = _overlay;
@synthesize priceLabel = _priceLabel;;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if( self != nil  )
    {
        _thumb = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 120)];
        [self.thumb setContentMode:UIViewContentModeScaleAspectFill];
        [self.thumb setClipsToBounds:YES];
        self.backgroundView = self.thumb;
        
        _overlay = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 120)];
        _overlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        _overlay.alpha = 0.0;
        [self.contentView addSubview:self.overlay];
    
        _textBG = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
        _textBG.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
        [self.contentView addSubview:_textBG];
        
        _stateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.stateLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [self.contentView addSubview:self.stateLabel];
        
        _priceLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.priceLabel setFont:[UIFont fontWithName:@"Baskerville-BoldItalic" size:12]];
        [self.contentView addSubview:self.priceLabel];
    }
    return self;
}

-(void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    float target = (selected )? 0.5 : 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        self.overlay.alpha = target;
    }];
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    self.thumb.image = nil;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect rect = self.textLabel.frame;
    rect.origin = CGPointMake(5, 5);
    self.textLabel.frame = rect;
    
    self.textLabel.font = [UIFont boldSystemFontOfSize:14];
    rect = self.detailTextLabel.frame;
    rect.origin = CGPointMake(5, self.textLabel.frame.size.height + 2);
    self.detailTextLabel.frame = rect;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    rect = self.priceLabel.frame;
    rect.origin.x = 320 - ( self.priceLabel.frame.size.width + 10 );
    rect.origin.y = 20 - ( self.priceLabel.frame.size.height * 0.5);
    self.priceLabel.frame = rect;
    
}

-(void)render
{
    __block ListingCell *blockself = self;
    
    self.textLabel.text       = self.listing.address;
    self.detailTextLabel.text = [NSString stringWithFormat:@"Available on : %@",[self.listing.moveInDate toShortString]];
    self.priceLabel.text      = [NSString stringWithFormat:@"$%0.2f per month", [self.listing.monthlyCost floatValue]];
    [self.priceLabel sizeToFit];
    
    if( self.listing.thumb == nil )
    {
        [self.listing loadThumb:^(BOOL success)
        {
            blockself.thumb.image = blockself.listing.thumb;
        }];
    }
    else
    {
        self.thumb.image = self.listing.thumb;
    }
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

@end
