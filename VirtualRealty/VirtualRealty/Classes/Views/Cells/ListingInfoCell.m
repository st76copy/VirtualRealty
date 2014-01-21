//
//  ListingInfoCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 12/4/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "ListingInfoCell.h"
#import "UIColor+Extended.h"

@implementation ListingInfoCell

@synthesize thumb               = _thumb;
@synthesize priceView           = _priceView;
@synthesize addressLabel        = _addressLabel;
@synthesize listingDetailsLabel = _listingDetailsLabel;
@synthesize stroke              = _stroke;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if( self != nil  )
    {
        _thumb = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 125)];
        [self.thumb setContentMode:UIViewContentModeScaleAspectFill];
        [self.thumb setClipsToBounds:YES];
        [self.contentView addSubview:self.thumb];
        
        _stateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.stateLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [self.contentView addSubview:self.stateLabel];
        
        _priceView = [[PriceView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:self.priceView];
        
        _addressLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.addressLabel setTextColor:[UIColor colorFromHex:@"424242"]];
        _addressLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:18];
        
        _listingDetailsLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.listingDetailsLabel setTextColor:[UIColor colorFromHex:@"424242"]];
        [self.listingDetailsLabel setFont:[UIFont systemFontOfSize:14]];
        
        _stroke = [[UIView alloc]initWithFrame:CGRectMake(0, 190, 181, 2)];
        [_stroke setBackgroundColor:[UIColor colorFromHex:@"00aeef"]];
        
        UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [playButton setImage:[UIImage imageNamed:@"play-button.png"] forState:UIControlStateNormal];
        [playButton sizeToFit];
        
        CGRect rect = playButton.frame;
        rect.origin.x = self.thumb.frame.size.width * 0.5 - rect.size.width * 0.5;
        rect.origin.y = self.thumb.frame.size.height * 0.5 - rect.size.height * 0.5;
        playButton.frame = rect;
        
        [self.contentView addSubview:self.addressLabel];
        [self.contentView addSubview:self.listingDetailsLabel];
        [self.contentView addSubview:self.stroke];
        [self.contentView addSubview:playButton];
    }
    return self;
}


-(void)prepareForReuse
{
    [super prepareForReuse];
    self.thumb.image = nil;
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect rect = self.priceView.frame;
    rect.origin.x = self.contentView.frame.size.width - self.priceView.frame.size.width;
    rect.origin.y = self.thumb.frame.size.height - rect.size.height;
    self.priceView.frame = rect;
    
    self.addressLabel.frame = CGRectMake(5, self.thumb.frame.size.height + 9, 320, 0);
    [self.addressLabel sizeToFit];
    
    if( self.addressLabel.frame.size.width > 320 )
    {
        self.addressLabel.adjustsFontSizeToFitWidth = YES;
        rect = self.addressLabel.frame;
        rect.size.width = 320;
        self.addressLabel.frame = rect;
    }
    
    float y = self.addressLabel.frame.size.height + self.addressLabel.frame.origin.y;
    self.listingDetailsLabel.frame = CGRectMake(5, y - 2, 320, 28 );
}

-(void)render
{
    _listing = self.cellinfo[@"current-value"];
    __block ListingInfoCell *blockself = self;

    NSString *borough = ( self.listing.borough == nil ) ? self.listing.city : self.listing.borough;
    self.addressLabel.text = [NSString stringWithFormat:@"%@, %@ %@",self.listing.street, borough, [NSString stringWithFormat:@"%i",[self.listing.zip intValue]]];
    
    NSString *detailsText = [NSString stringWithFormat:@"%@, %@ in %@", self.listing.bedrooms, self.listing.bathrooms, self.listing.neighborhood];
    self.listingDetailsLabel.text = detailsText;
    
    [self.priceView setPrice:[self.listing.monthlyCost floatValue]];
    
    if( self.listing.thumb == nil )
    {
        [self.listing loadThumb:^(BOOL success)
         {
             CGSize size  = blockself.listing.thumb.size;
             UIImage *img = [Utils resizeImage:blockself.listing.thumb toSize:CGSizeMake(size.width * 0.3, size.height * 0.3)];
             blockself.thumb.image = img;
         }];
    }
    else
    {
        CGSize size  = blockself.listing.thumb.size;
        UIImage *img = [Utils resizeImage:blockself.listing.thumb toSize:CGSizeMake(size.width * 0.3, size.height * 0.3)];
        self.thumb.image = img;
    }
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
