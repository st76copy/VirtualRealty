//
//  FeaturedViewController.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "AbstractViewController.h"


@interface FeaturedViewController : AbstractViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong,readonly)NSMutableArray *tableData;
@property(nonatomic, strong,readonly)UITableView    *table;
@end
