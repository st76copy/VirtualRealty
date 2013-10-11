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

@end
