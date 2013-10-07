//
//  UserContentViewController.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "UserContentViewController.h"
#import <Parse/Parse.h>
#import "User.h"

@interface UserContentViewController ()

@end

@implementation UserContentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"My Listings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    [PFCloud callFunctionInBackground:@"getListingsForUser" withParameters:@{@"userID":[User sharedUser].username} block:^(id object, NSError *error)
    {
        //NSDictionary *info =
        NSLog(@"loaded :: %@ " , object );
    }];
    
}


@end
