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
#import "KeyboardManager.h"
#import "PickerManager.h"
#import "NSDate+Extended.h"

@interface LoginViewController ()<FormCellDelegate,KeyboardManagerDelegate,PickerManagerDelegate>

-(void)handleLoginTouch:(id)sender;
-(void)handleCancelTouch:(id)sender;
-(id)getValueForField:(FormField)field;
-(BOOL)validateForm;
-(void)facebookLogin;

@end

@implementation LoginViewController

@synthesize currentIndexPath = _currentIndexPath;
@synthesize loginArray       = _loginArray;
@synthesize signupArray      = _signupArray;
@synthesize loginTabel       = _loginTabel;
@synthesize signupTabel      = _signupTabel;
@synthesize loadingView      = _loadingView;

@synthesize username = _username;
@synthesize password = _password;

@synthesize currentField = _currentField;
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

-(void)viewDidAppear:(BOOL)animated
{
    [[KeyboardManager sharedManager]registerDelegate:self];
    [[PickerManager sharedManager]registerDelegate:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[KeyboardManager sharedManager]unregisterDelegate:self];
    [[PickerManager sharedManager]unregisterDelegate:self];
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
    NSDictionary *sectionInfo = ( _state == kLogin ) ? [_loginArray objectAtIndex:indexPath.section] : [_signupArray objectAtIndex:indexPath.section];
    NSArray      *cells       = [sectionInfo valueForKey:@"cells"];
    NSMutableDictionary *info = [[cells objectAtIndex:indexPath.row]mutableCopy];
    
    [info setValue:[self getValueForField:[[info valueForKey:@"field"] intValue]] forKey:@"current-value"];
    
    NSString *reuse = [info valueForKey:@"class"];
    FormCell *cell  = (FormCell *)[tableView dequeueReusableCellWithIdentifier:reuse];
    
    if( cell == nil )
    {
        cell = [[NSClassFromString([info valueForKey:@"class"]) alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
    }
    
    cell.indexPath    = indexPath;
    cell.formDelegate = self;
    cell.cellinfo     = info;
    [cell render];
 
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FormCell *cell  = (FormCell*)[tableView cellForRowAtIndexPath:indexPath];
    FormField field = [[cell.cellinfo valueForKey:@"field"]intValue];
   
    if( [KeyboardManager sharedManager].isShowing && [self isSameCell:indexPath] )
    {
        [[KeyboardManager sharedManager] close];
        return;
    }
    
    if( [PickerManager sharedManager].isShowing && [self isSameCell:indexPath] )
    {
        [[PickerManager sharedManager]hidePicker];
        return;
    }
    
    if( [cell.cellinfo valueForKey:@"field"] && self.currentField != [[cell.cellinfo valueForKey:@"field"] intValue])
    {
        _currentField      = [[cell.cellinfo valueForKey:@"field"]intValue];
    }
    
    if( [self isSameCell:indexPath] == NO || _currentIndexPath == nil)
    {
        _currentIndexPath = indexPath;
    }
    
    switch (field)
    {
        case kEmail:
        case kPassword:
            [cell setFocus];
            break;
        case kUserActivelyLooking:
            break;
        case kUserMovinDate:
            [PickerManager sharedManager].type = kDate;
            [[PickerManager sharedManager]showPickerInView:self.view];
            break;
        case kUserMinBedrooms:
        case kUserMaxRent:
            [cell setFocus];
            [self animateToCell];
            break;
            
        default:
            break;
    }
    
    
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

-(void)cell:(FormCell *)cell didStartInteract:(FormField)field
{
    if( [self isSameCell:cell.indexPath] == NO )
    {
        NSLog(@"%@ start interact ", self );
        [self tableView:self.signupTabel didSelectRowAtIndexPath:cell.indexPath];
    }
}

-(void)cell:(FormCell *)cell didChangeForField:(FormField)field
{
    
    UITableView *view = ( self.state == kLogin ) ? self.loginTabel : self.signupTabel;
    FormCell *c = (FormCell *)[view cellForRowAtIndexPath:self.currentIndexPath];
    
    NSLog(@"%@  did change %@ for field %i ", self,c, field);
    
    switch (field)
    {
        case kEmail:
            _username = c.formValue;
            NSLog(@"%@ setting current email %@ ", self, _username);
            break;
        case kPassword:
            _password = c.formValue;
            break;
        case kUserActivelyLooking :
            [User sharedUser].activelySearching = c.formValue;
            break;
        case kUserMaxRent :
            [User sharedUser].maxRent = c.formValue;
            break;
        case kUserMinBedrooms :
            [User sharedUser].minBedrooms = c.formValue;
            break;
        case kUserMovinDate :
            [User sharedUser].moveInAfter = c.formValue;
            break;
        default:
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
        case kUserActivelyLooking :
            value = [User sharedUser].activelySearching;
            break;
        case kUserMaxRent :
            value = [User sharedUser].maxRent;
            break;
        case kUserMinBedrooms :
            value = [User sharedUser].minBedrooms;
            break;
        case kUserMovinDate :
            value = [User sharedUser].moveInAfter;
            break;
        default:
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
                        [blockself dismissViewControllerAnimated:YES completion:nil];
                    }
                    else
                    {
                        [blockself.loadingView hide];
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
                        [blockself dismissViewControllerAnimated:YES completion:nil];
                    }
                    else
                    {
                        [blockself.loadingView hide];
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
    [[KeyboardManager sharedManager]close];
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
    switch ( self.state) {
        case kLogin:
        {
            __block LoginViewController *blockself = self;
            
            [self.view addSubview:self.loadingView];
            [self.loadingView show];
            [User sharedUser].username = _username;
            
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
        break;
        case kSignup :
            if( _username   )
            {
                __block LoginViewController *blockself = self;
                
                [self.view addSubview:self.loadingView];
                [self.loadingView show];
                [User sharedUser].username = _username;
                
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
            else
            {
                [[ErrorFactory getAlertForType:kInvalidUsernameError andDelegateOrNil:nil andOtherButtons:nil]show];
            }

        break;
    }
}


#pragma mark - utils;
-(void)animateToCell
{
    CGRect rect = [self.signupTabel cellForRowAtIndexPath:self.currentIndexPath].frame;
    [self.signupTabel scrollRectToVisible:rect animated:YES];
}

-(BOOL)isSameCell:(NSIndexPath *)path
{
    if( _currentIndexPath == nil )
    {
        return NO;
    }
    
    return ( self.currentIndexPath.row == path.row && self.currentIndexPath.section == path.section ) ? YES : NO;
}


#pragma mark - picker
-(void)pickerWillShow
{
    if( [KeyboardManager sharedManager].isShowing )
    {
        [[KeyboardManager sharedManager]close];
    }
    
    [UIView animateWithDuration:0.4 animations:^
     {
         self.signupTabel.contentInset =  UIEdgeInsetsMake(0, 0,[PickerManager sharedManager].container.frame.size.height, 0);
     }];
    
    [self animateToCell];
}

-(void)pickerWillHide
{
    [UIView animateWithDuration:0.3  animations:^{
        self.signupTabel.contentInset =  UIEdgeInsetsMake(64, 0, 0, 0);
    }];
}

-(void)pickerDone
{
    FormCell *cell = (FormCell *)[self.signupTabel cellForRowAtIndexPath:self.currentIndexPath];
    cell.formValue = [PickerManager sharedManager].datePicker.date;
    cell.detailTextLabel.text = [[PickerManager sharedManager].datePicker.date toString];
    [cell.formDelegate cell:cell didChangeForField:self.currentField];
    [self.signupTabel reloadRowsAtIndexPaths:@[self.currentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[PickerManager sharedManager]hidePicker];
}

#pragma mark - keyboard manager
-(void)keyboardWillShow
{
    if( [PickerManager sharedManager].isShowing)
    {
        [[PickerManager sharedManager]hidePicker];
    }
    
    [UIView setAnimationCurve:[KeyboardManager sharedManager].animationCurve ];
    
    [UIView animateWithDuration:[KeyboardManager sharedManager ].animationTime animations:^
     {
         self.signupTabel.contentInset =  UIEdgeInsetsMake(0, 0, [KeyboardManager sharedManager].keyboardFrame.size.height, 0);
     }];
    
    [self animateToCell];
    
}

-(void)keyboardWillHide
{
    [UIView animateWithDuration:0.3  animations:^{
        self.signupTabel.contentInset =  UIEdgeInsetsMake(64, 0, 0, 0);
    }];
}

-(BOOL)shouldAutorotate
{
    return NO;
}
@end
