//
//  ListingCell.h
//  VirtualRealty
//
//  Created by christopher shanley on 10/7/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "AbstractCell.h"
#import "Listing.h"
#import "PriceView.h"
#import "ListingStateView.h"
@interface ListingCell : AbstractCell

@property(nonatomic, strong)Listing *listing;
@property(nonatomic, strong, readonly)UIImageView *thumb;
@property(nonatomic, strong, readonly)PriceView   *priceView;
@property(nonatomic, strong, readonly)UIView      *stroke;
@property(nonatomic, strong, readonly)ListingStateView     *stateView;
@property(nonatomic, strong, readonly)UILabel     *addressLabel;
@property(nonatomic, strong, readonly)UILabel     *listingDetailsLabel;
@property(nonatomic, strong, readonly)UIActivityIndicatorView     *spinner;

-(void)showCloseWithTarget:(id)target andSEL:( SEL )selector;

@end
