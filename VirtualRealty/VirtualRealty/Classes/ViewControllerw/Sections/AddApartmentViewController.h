//
//  AddApartmentViewController.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "AbstractViewController.h"
#import "FormCell.h"
#import "KeyboardManager.h"
#import "PickerManager.h"
#import "Listing.h"
#import "User.h"

@interface AddApartmentViewController : AbstractViewController<UITableViewDataSource, UITableViewDelegate, FormCellDelegate, KeyboardManagerDelegate, PickerManagerDelegate>
{
    BOOL editMode;
}

@property(nonatomic, strong, readonly)Listing        *listing;
@property(nonatomic, strong, readonly)UITableView    *table;
@property(nonatomic, strong, readonly)NSMutableArray *tableData;
@property(nonatomic, assign, readonly)FormField       currentField;
@property(nonatomic, retain, readonly)NSIndexPath    *currentIndexpath;
@end
