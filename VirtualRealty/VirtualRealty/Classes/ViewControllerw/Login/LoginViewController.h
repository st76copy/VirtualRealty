//
//  LoginViewController.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
@interface LoginViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, assign, readonly)FormField      currentField;
@property(nonatomic, strong, readonly)NSIndexPath    *currentIndexPath;
@property(nonatomic, strong, readonly)UITableView    *loginTabel;
@property(nonatomic, strong, readonly)UITableView    *signupTabel;
@property(nonatomic, strong, readonly)NSArray        *loginArray;
@property(nonatomic, strong, readonly)NSArray        *signupArray;
@property(nonatomic, assign, readonly)LoginFormState  state;
@property(nonatomic, strong, readonly)LoadingView    *loadingView;


@property(nonatomic, strong, readonly)NSString *username;
@property(nonatomic, strong, readonly)NSString *password;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andState:(LoginFormState)state;
@end
