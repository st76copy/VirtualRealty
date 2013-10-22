//
//  SearchFilterViewController.h
//  VirtualRealty
//
//  Created by christopher shanley on 10/15/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchFilters.h"
#import "Filter.h"

@protocol SearchFilterDelegate <NSObject>

-(void)filtersDoneWithOptions:(NSDictionary *)options;

@end

@interface SearchFilterViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak)id<SearchFilterDelegate> delegate;
@property(nonatomic, strong, readonly)NSMutableArray *tableData;
@property(nonatomic, strong, readonly)UITableView    *table;
@property(nonatomic, strong, readonly)NSIndexPath    *currentPath;
@property(nonatomic, assign, readonly)FormField       currentField;
@property(nonatomic, strong, readonly)SearchFilters  *filters;
@end
