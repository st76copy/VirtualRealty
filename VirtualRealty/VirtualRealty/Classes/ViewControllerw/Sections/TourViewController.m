//
//  TourViewController.m
//  VirtualRealty
//
//  Created by christopher shanley on 12/20/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "TourViewController.h"
#import "UIColor+Extended.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
@interface TourViewController ()<UIScrollViewDelegate>
@property(nonatomic, strong)UIScrollView  *scrollview;
@property(nonatomic, strong)UIPageControl *pageControl;
@end

@implementation TourViewController

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
    
    NSArray *images = @[@"tour-one.png", @"tour-two.png", @"tour-three.png", @"tour-four.png"];
    CGRect rect     = self.view.bounds;
    self.scrollview = [[UIScrollView alloc]initWithFrame:rect];
    int i = 0;
    
    for( NSString *name in images )
    {
        UIImage *img = [UIImage imageNamed:name];
        UIImageView *view = [[UIImageView alloc]initWithFrame:CGRectMake(i*rect.size.width, 0, rect.size.width, rect.size.height)];
        [self.scrollview addSubview:view];
        view.image = img;
        view.contentMode = UIViewContentModeScaleAspectFill;
        i++;
    }
    
    [self.view addSubview:self.scrollview];
    [self.scrollview setBounces:NO];
    [self.scrollview setPagingEnabled:YES];
    [self.scrollview setContentSize:CGSizeMake(rect.size.width * images.count, rect.size.height)];
    [self.scrollview setDelegate:self];
   
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Skip Tour" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(handleSkip:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    [button.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-300" size:15]];
    
    
    rect = button.frame;
    rect.origin.x = self.view.frame.size.width * 0.5 - rect.size.width * 0.5;
    rect.origin.y = self.view.frame.size.height - ( rect.size.height + 10 );
    button.frame = rect;
    [self.view addSubview:button];

    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"footer-button-fill.png"] forState:UIControlStateNormal];
    [button setTitle:@"Sign In" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorFromHex:@"cbd5d9"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(handleLogin:) forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:15]];
    [button sizeToFit];
    
    rect = button.frame;
    rect.origin.x = self.view.frame.size.width * 0.5 - rect.size.width * 0.5;
    rect.origin.y = self.view.frame.size.height - ( rect.size.height + 50 );
    button.frame = rect;
    [self.view addSubview:button];

    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"footer-button-fill.png"] forState:UIControlStateNormal];
    [button setTitle:@"Create An Account" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorFromHex:@"cbd5d9"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(handleSignUp:) forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:15]];
    [button sizeToFit];
    
    rect = button.frame;
    rect.origin.x = self.view.frame.size.width * 0.5 - rect.size.width * 0.5;
    rect.origin.y = self.view.frame.size.height - ( rect.size.height * 2 + 60 );
    button.frame = rect;
    [self.view addSubview:button];

    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, 80, 15)];
    self.pageControl.numberOfPages = 4;
    self.pageControl.currentPage   = 0;
    rect = self.pageControl.frame;
    rect.origin.x = self.view.frame.size.width * 0.5 - 40;
    rect.origin.y = button.frame.origin.y - (15 + 10);
    self.pageControl.frame = rect;
    [self.view addSubview:self.pageControl];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float percent =  scrollView.contentOffset.x / ( scrollView.contentSize.width - self.view.frame.size.width );
    int  index = percent * 4;
    self.pageControl.currentPage = index;
}


-(BOOL)shouldAutorotate
{
    return NO;
}

-(void)handleSkip:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)handleSignUp:(id)sender
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self dismissViewControllerAnimated:YES completion:^{
       
        LoginViewController *login = [[LoginViewController alloc]initWithNibName:nil bundle:nil andState:kSignup];
        UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:login];
        [app.window.rootViewController presentViewController:nc animated:YES completion:nil];
    }];
}

-(void)handleLogin:(id)sender
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        LoginViewController *login = [[LoginViewController alloc]initWithNibName:nil bundle:nil andState:kLogin];
        UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:login];
        [app.window.rootViewController presentViewController:nc animated:YES completion:nil];
    }];
}

@end
