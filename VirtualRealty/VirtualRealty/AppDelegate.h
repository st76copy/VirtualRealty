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
#import "LoadingView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, strong, readonly)NavViewController *nav;
@property(nonatomic, strong, readonly)UINavigationController *section;
@property(nonatomic, strong, readonly)LoadingView   *loadingView;
-(void)showlogin;
-(void)showLoader;
-(void)showLoaderInView:(UIView *)view;
-(void)hideLoader;

@end
