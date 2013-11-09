//
//  SettingsViewController.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "AbstractViewController.h"

@interface SettingsViewController : AbstractViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property(nonatomic, strong, readonly)UITableView *table;
@property(nonatomic, strong, readonly)NSArray     *data;
@property(nonatomic, strong, readonly)NSIndexPath *currentIndexPath;
@end
