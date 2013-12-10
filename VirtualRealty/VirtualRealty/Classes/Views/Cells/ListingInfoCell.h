//
//  ListingInfoCell.h
//  VirtualRealty
//
//  Created by christopher shanley on 12/4/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "FormCell.h"
#import "Listing.h"
#import "PriceView.h"

@interface ListingInfoCell : FormCell

@property(nonatomic, strong)Listing *listing;
@property(nonatomic, strong, readonly)UIImageView *thumb;
@property(nonatomic, strong, readonly)PriceView   *priceView;
@property(nonatomic, strong, readonly)UIView      *stroke;
@property(nonatomic, strong, readonly)UILabel     *stateLabel;
@property(nonatomic, strong, readonly)UILabel     *addressLabel;
@property(nonatomic, strong, readonly)UILabel     *listingDetailsLabel;


@end
