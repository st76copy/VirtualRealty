//
//  NavViewController.m
//  VirtualRealty
//
//  Created by christopher shanley on 11/26/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "CustomNavViewController.h"
#import "UIColor+Extended.h"
#import <QuickLook/QuickLook.h>

@interface CustomNavViewController ()

@end

@implementation CustomNavViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self)
    {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorFromHex:@"334046"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.translucent = NO;
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowOpacity = 0.5f;
    self.view.layer.shadowRadius  = 5.0f;
    self.view.layer.shadowOffset  = CGSizeMake(-10, 0);
    self.view.layer.shadowColor   = [UIColor blackColor].CGColor;
    self.view.layer.shadowPath    = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
   
    NSDictionary *textTreatment = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSBackgroundColorAttributeName:[UIColor whiteColor]};
    [[UINavigationBar appearance] setTitleTextAttributes:textTreatment];
}


@end
