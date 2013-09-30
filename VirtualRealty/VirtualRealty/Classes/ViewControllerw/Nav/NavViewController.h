//  Created by Chris on 6/12/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^NavSelectedBlock) (NSDictionary *info);
@interface NavViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong)UITableView  *table;
@property(nonatomic, strong)NSArray      *navData;
@property(nonatomic, copy)NavSelectedBlock selectBlock;
-(void)loadNavigation;

@end
