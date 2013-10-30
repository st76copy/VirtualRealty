//
//  ListingCell.h
//  VirtualRealty
//
//  Created by christopher shanley on 10/7/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "AbstractCell.h"
#import "Listing.h"
@interface ListingCell : AbstractCell

@property(nonatomic, strong)Listing *listing;
@property(nonatomic, strong, readonly)UIImageView *thumb;
@property(nonatomic, strong, readonly)UIView      *overlay;
@property(nonatomic, strong, readonly)UIView      *textBG;
@property(nonatomic, strong, readonly)UILabel     *stateLabel;
@property(nonatomic, strong, readonly)UILabel     *priceLabel;;


@end
