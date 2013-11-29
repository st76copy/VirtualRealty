//
//  SSIAbstractViewController.m
//  Shutterstock
//
//  Created by Chris on 6/12/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import "AbstractViewController.h"
#import "UIColor+Extended.h"
@interface AbstractViewController ()

@end

@implementation AbstractViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    active = YES;
    
    UIImage *buger = [UIImage imageNamed:@"menu.png"];
    [[UIBarButtonItem appearance]setTintColor:[UIColor colorFromHex:@"ffffff"]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:buger style:UIBarButtonItemStylePlain target:self action:@selector(toggleMenu)];
}


-(void)toggleMenu
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.navigationController.view.frame;
        
        if( rect.origin.x == 260 )
        {
            active = YES;
            rect.origin.x = 0;
        }
        else
        {
            active = NO;
            rect.origin.x = 260;
        }
        
        self.navigationController.view.frame = rect;
    }];
}

-(void)setActive:(BOOL)value
{
    active = value;
}

@end
