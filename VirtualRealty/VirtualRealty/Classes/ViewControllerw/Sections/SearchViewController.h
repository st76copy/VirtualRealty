//
//  SearchViewController.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "AbstractViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface SearchViewController : AbstractViewController

@property(nonatomic, strong, readonly)GMSMapView     *mapView;
@property(nonatomic, strong, readonly)UISearchBar    *searchBar;
@property(nonatomic, strong, readonly)UITableView    *table;
@property(nonatomic, strong, readonly)NSMutableArray *tableData;
@end
