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
#import "UIColor+Extended.h"

@implementation ListingCell

@synthesize thumb               = _thumb;
@synthesize priceView           = _priceView;
@synthesize addressLabel        = _addressLabel;
@synthesize listingDetailsLabel = _listingDetailsLabel;
@synthesize stroke              = _stroke;
@synthesize spinner             = _spinner;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if( self != nil  )
    {
        _thumb = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 125)];
        [self.thumb setContentMode:UIViewContentModeScaleAspectFill];
        [self.thumb setClipsToBounds:YES];
        [self.thumb setBackgroundColor:[UIColor colorFromHex:@"e6e6e6"]];
        
        [self.contentView addSubview:self.thumb];
        
        _stateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.stateLabel setFont:[UIFont boldSystemFontOfSize:10]];
        [self.contentView addSubview:self.stateLabel];
        
        _priceView = [[PriceView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:self.priceView];
        
        _addressLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.addressLabel setTextColor:[UIColor colorFromHex:@"424242"]];
        [self.addressLabel setFont:[UIFont systemFontOfSize:18]];
        
        
        _listingDetailsLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        [self.listingDetailsLabel setTextColor:[UIColor colorFromHex:@"424242"]];
        [self.listingDetailsLabel setFont:[UIFont systemFontOfSize:14]];
        
        _stroke = [[UIView alloc]initWithFrame:CGRectMake(0, 186, 181, 2)];
        [_stroke setBackgroundColor:[UIColor colorFromHex:@"c77732"]];
        
        _spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        _spinner.activityIndicatorViewStyle = UIActionSheetStyleBlackTranslucent;
        _spinner.center = self.thumb.center;
        [self.contentView addSubview:_spinner];
        
        
        [self.contentView addSubview:self.addressLabel];
        [self.contentView addSubview:self.listingDetailsLabel];
        [self.contentView addSubview:self.stroke];
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
    
    self.addressLabel.frame = CGRectMake(5, self.thumb.frame.size.height + 5, 320, 0);
    [self.addressLabel sizeToFit];
    
    if( self.addressLabel.frame.size.width > 320 )
    {
        self.addressLabel.adjustsFontSizeToFitWidth = YES;
        rect = self.addressLabel.frame;
        rect.size.width = 320;
        self.addressLabel.frame = rect;
    }
    
    float y = self.addressLabel.frame.size.height + self.addressLabel.frame.origin.y;
    self.listingDetailsLabel.frame = CGRectMake(5, y, 320, 28 );
}

-(void)render
{
    [self.spinner setHidden:NO];
    [self.spinner startAnimating];
    __block ListingCell *blockself = self;
    
    self.addressLabel.text = self.listing.street;
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
            [blockself.spinner stopAnimating];
            [blockself.spinner setHidden:YES];
            blockself.thumb.alpha = 0.0f;
            [UIView animateWithDuration:0.3 animations:^{
                blockself.thumb.alpha = 1.0f;
            }];
        }];
        
    }
    else
    {
        [blockself.spinner setHidden:YES];
        CGSize size  = blockself.listing.thumb.size;
        UIImage *img = [Utils resizeImage:blockself.listing.thumb toSize:CGSizeMake(size.width * 0.3, size.height * 0.3)];
        self.thumb.image = img;
        blockself.thumb.alpha = 0.0f;
        [UIView animateWithDuration:0.3 animations:^{
            blockself.thumb.alpha = 1.0f;
        }];

    }
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

-(void)showCloseWithTarget:(id)target andSEL:( SEL )selector
{
    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    [close addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [close setTitle:@"close" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor colorFromHex:@"424242"] forState:UIControlStateNormal];
    [close sizeToFit];
    [close.titleLabel setFont:[UIFont systemFontOfSize:10.0f]];
    CGRect rect = close.frame;
    rect.origin.x = self.contentView.frame.size.width - (rect.size.width );
    rect.origin.y = self.contentView.frame.size.height - (rect.size.height );
    close.frame = rect;
    
    [self.contentView addSubview:close];
}

@end
