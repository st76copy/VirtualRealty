//
//  FilterViewController.h
//  VirtualRealty
//
//  Created by christopher shanley on 10/12/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Filter.h"
#import "SearchFilters.h"

@class FilterViewController;
@class SearchFilters;
@protocol FilterViewControllerDelegate <NSObject>
-(void)viewcontroller:(FilterViewController*)vc didFinishFilterSet:(SearchFilters *)filters;
@end

@interface FilterViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong, readonly)NSArray *tableData;
@property(nonatomic, strong, readonly)UITableView *table;

@end
