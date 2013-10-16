//
//  ListingDetailViewController.h
//  VirtualRealty
//
//  Created by christopher shanley on 10/12/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Listing.h"

@interface ListingDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

-(id)initWithListing:(Listing *)listing;

@property(nonatomic, strong, readonly)Listing     *listing;
@property(nonatomic, strong, readonly)UITableView *table;
@property(nonatomic, strong, readonly)NSArray     *tableData;



@end
