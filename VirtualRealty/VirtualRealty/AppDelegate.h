//
//  AppDelegate.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavViewController.h"
#import "FeaturedViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, strong, readonly)NavViewController *nav;
@property(nonatomic, strong, readonly)UINavigationController *section;

-(void)showlogin;

@end
