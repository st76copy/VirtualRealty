//
//  ListingCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 10/7/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "ListingCell.h"

@implementation ListingCell

@synthesize thumb = _thumb;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if( self != nil  )
    {
        _thumb = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 120)];
        [self.thumb setContentMode:UIViewContentModeScaleAspectFill];
        [self.thumb setClipsToBounds:YES];
        [self.contentView addSubview:self.thumb];
        [self.contentView sendSubviewToBack:self.thumb];
        
        UIView *bg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 40)];
        bg.backgroundColor = [UIColor whiteColor];
        bg.alpha = 0.4;
        [self.contentView addSubview:bg];
        
        UIButton *carrotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [carrotButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [carrotButton setTitle:@">" forState:UIControlStateNormal ];
        [carrotButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [carrotButton sizeToFit];
        float y = 20 - carrotButton.frame.size.height * 0.5;
        carrotButton.frame = CGRectMake(320 - carrotButton.frame.size.width + 5,y , carrotButton.frame.size.width, carrotButton.frame.size.height);
        [self.contentView addSubview:carrotButton];
    }
    return self;
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
}

-(void)render
{
    __block ListingCell *blockself = self;
    
    self.textLabel.text = self.listing.address;
    self.detailTextLabel.text = self.listing.objectId;
    
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
}
@end
