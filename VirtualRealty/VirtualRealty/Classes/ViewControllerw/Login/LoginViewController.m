//
//  LoginViewController.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "LoginViewController.h"
#import "FormCell.h"
#import "TextInputCell.h"
#import "ErrorFactory.h"
#import "Utils.h"
#import "User.h"

@interface LoginViewController ()<FormCellDelegate>

-(void)handleLoginTouch:(id)sender;
-(void)handleCancelTouch:(id)sender;
-(id)getValueForField:(FormField)field;
-(BOOL)validateForm;
-(void)facebookLogin;
@end

@implementation LoginViewController

@synthesize loginArray  = _loginArray;
@synthesize signupArray = _signupArray;
@synthesize loginTabel  = _loginTabel;
@synthesize signupTabel = _signupTabel;
@synthesize loadingView = _loadingView;

@synthesize username = _username;
@synthesize password = _password;

@synthesize state = _state;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        NSString *login  = [[NSBundle mainBundle]pathForResource:@"login" ofType:@"plist"];
        _loginArray      = [NSArray arrayWithContentsOfFile:login];
        
        NSString *signup = [[NSBundle mainBundle]pathForResource:@"signup" ofType:@"plist"];
        _signupArray     = [NSArray arrayWithContentsOfFile:signup];
        
        _state = kLogin;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"Login", @"Generic title : Login / Signup Screen");
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Log In" style:UIBarButtonItemStyleDone target:self action:@selector(handleLoginTouch:)];
   
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(handleCancelTouch:)];
    
    CGRect rect = self.view.bounds;
    _loginTabel = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
    [_loginTabel setDataSource:self];
    [_loginTabel setDelegate:self];
    [_loginTabel setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
    [self.view addSubview:_loginTabel];

    _signupTabel = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
    [_signupTabel setDataSource:self];
    [_signupTabel setDelegate:self];
    [_signupTabel setContentInset:UIEdgeInsetsMake(-20, 0, 0, 0)];
    [self.view addSubview:_signupTabel];
    [self.view sendSubviewToBack:self.signupTabel];
    
    _loadingView = [[LoadingView alloc]initWithFrame:self.view.frame];
    
}

-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionInfo = ( _state == kLogin ) ? [_loginArray objectAtIndex:section] : [_signupArray objectAtIndex:section];
    NSArray      *cells   = [sectionInfo valueForKey:@"cells"];
    return [cells count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ( _state == kLogin ) ? _loginArray.count : _signupArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuse = @"cell";
    
    NSDictionary *sectionInfo = ( _state == kLogin ) ? [_loginArray objectAtIndex:indexPath.section] : [_signupArray objectAtIndex:indexPath.section];
    NSArray      *cells       = [sectionInfo valueForKey:@"cells"];
    NSMutableDictionary *info = [[cells objectAtIndex:indexPath.row]mutableCopy];
    
    [info setValue:[self getValueForField:[[info valueForKey:@"field"] intValue]] forKey:@"current-value"];
    FormCell *cell = (FormCell *)[tableView dequeueReusableCellWithIdentifier:reuse];
    
    if( cell == nil )
    {
        cell = [[NSClassFromString([info valueForKey:@"class"]) alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
    }
    
    cell.formDelegate = self;
    cell.cellinfo = info;
    [cell render];
 
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormCell *cell = (FormCell*)[tableView cellForRowAtIndexPath:indexPath];
    if( [cell.cellinfo valueForKey:@"custom-action"] )
    {
        SEL sel = NSSelectorFromString([cell.cellinfo valueForKey:@"custom-action"]);
        [self performSelector:sel];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionInfo = ( _state == kLogin ) ? [_loginArray objectAtIndex:section] : [_signupArray objectAtIndex:section];
    return [sectionInfo valueForKey:@"section-title"];
}

-(void)cell:(FormCell *)cell didChangeForField:(FormField)field
{
    TextInputCell *c = nil;
    switch (field)
    {
        case kEmail:
            c = ( TextInputCell *)cell;
            _username = c.inputField.text;
            break;
        case kPassword:
            c = ( TextInputCell *)cell;
            _password = c.inputField.text;
            break;
    }
}

-(void)cell:(FormCell *)cell didPressDone:(FormField)field
{
    if( _password != nil && _username != nil )
    {
        [self handleLoginTouch:nil];
    }
}

-(id)getValueForField:(FormField)field
{
    id value;
    switch (field)
    {
        case kEmail:
            value = _username;
            break;
        case kPassword:
            value = _password;
            break;
    }
    return value;
}

-(void)handleLoginTouch:(id)sender
{
    
    
    if( [self validateForm] )
    {
        
        __block LoginViewController *blockself = self;
        switch (self.state )
        {
            case kLogin:
            {
                [self.view addSubview:self.loadingView];
                [self.loadingView show];
                [[User sharedUser]loginWithUsername:self.username andPassword:self.password andBlock:^(BOOL success) {
                    if( success )
                    {
                        [blockself.loadingView hide];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    else
                    {
                       
                    }
                }];
            }
            break;
            
            case kSignup:
            {
                [self.view addSubview:self.loadingView];
                [self.loadingView show];
                
                [[User sharedUser]signupWithUsername:self.username andPassword:self.password andBlock:^(BOOL success) {
                    if( success )
                    {
                        [blockself.loadingView hide];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    else
                    {
                        
                    }
                }];
            }
            break;
        }
    }
}

-(BOOL)validateForm
{
    BOOL valid = YES;
    
    if([Utils isValidEmail:self.username] == NO )
    {
        [[ErrorFactory getAlertForType:kInvalidUsernameError andDelegateOrNil:nil andOtherButtons:nil]show];
        return NO;
    }
    
    if([Utils isValidPassword:self.password] == NO )
    {
        [[ErrorFactory getAlertForType:kInvalidPasswordError andDelegateOrNil:nil andOtherButtons:nil]show];
        return NO;
    }
    
    return valid;
}

-(void)handleCancelTouch:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)toggleForm
{
    switch (self.state)
    {
        case kLogin:
            [UIView transitionFromView:self.loginTabel toView:self.signupTabel duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
                
            }];
            self.navigationItem.title = @"Sign up";
            self.navigationItem.rightBarButtonItem.title = @"Sign Up";
            
            _state = kSignup;
            break;
            
        case kSignup:
            [UIView transitionFromView:self.signupTabel toView:self.loginTabel duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
                
            }];
            self.navigationItem.title = @"Log In";
            self.navigationItem.rightBarButtonItem.title = @"Log In";

            _state = kLogin;
            break;
    }
    [_loginTabel reloadData];
    [_signupTabel reloadData];
    
}

-(void)facebookLogin
{
    __block LoginViewController *blockself = self;
    
    [self.view addSubview:self.loadingView];
    [self.loadingView show];
    
    [[User sharedUser] loginWithFacebook:^(BOOL success) {
        if( success )
        {
           [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            
        }
        [blockself.loadingView hide];
    }];
}


@end
