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
#import "SectionTitleView.h"
#import "NSDate+Extended.h"
#import "UIColor+Extended.h"

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
        _currentField = -1;
        NSString *login  = [[NSBundle mainBundle]pathForResource:@"login" ofType:@"plist"];
        _loginArray      = [NSArray arrayWithContentsOfFile:login];
        
        NSString *signup = [[NSBundle mainBundle]pathForResource:@"signup" ofType:@"plist"];
        _signupArray     = [NSArray arrayWithContentsOfFile:signup];
        
        _state = kLogin;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andState:(LoginFormState)state
{
    self = [self initWithNibName:nil bundle:nil];
    if (self)
    {
        _state = state;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *title = ( self.state == kLogin ) ?  @"Log In" : @"Sign Up";
    self.navigationItem.title = title;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(handleCancelTouch:)];
    self.navigationController.navigationBar.translucent = NO;
    CGRect rect = self.view.bounds;
    rect.size.height -= self.navigationController.navigationBar.frame.size.height;
    
    _loginTabel = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
    [_loginTabel setDataSource:self];
    [_loginTabel setDelegate:self];
    [_loginTabel setSectionFooterHeight:0.0f];
    [_loginTabel setSectionHeaderHeight:44.0f];
    [_loginTabel setSeparatorColor:[UIColor clearColor]];
    //[_loginTabel setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
    [self.view addSubview:_loginTabel];

    _signupTabel = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
    [_signupTabel setDataSource:self];
    [_signupTabel setDelegate:self];
    [_signupTabel setSectionFooterHeight:0.0f];
    [_signupTabel setSectionHeaderHeight:44.0f];
    [_signupTabel setSeparatorColor:[UIColor clearColor]];
    
    
    UIView *container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 101)];
    [container setBackgroundColor:[UIColor colorFromHex:@"cbd5d9"]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"footer-button-fill.png"] forState:UIControlStateNormal];
    [button setTitle:@"Register" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:15]];
    
    [button setTitleColor:[UIColor colorFromHex:@"cbd5d9"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(handleLoginTouch:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    rect = button.frame;
    rect.origin.x = 160 - button.frame.size.width * 0.5;
    rect.origin.y = 40  - button.frame.size.height * 0.5;
    button.frame = rect;
    [container addSubview:button];
    
    _signupTabel.backgroundColor = [UIColor colorFromHex:@"cbd5d9"];
    _signupTabel.tableFooterView = container;
    
    container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 101)];
    [container setBackgroundColor:[UIColor colorFromHex:@"cbd5d9"]];
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"footer-button-fill.png"] forState:UIControlStateNormal];
    [button setTitle:@"Log In" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorFromHex:@"cbd5d9"] forState:UIControlStateHighlighted];
    [button.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-500" size:15]];
    
    [button addTarget:self action:@selector(handleLoginTouch:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    rect = button.frame;
    rect.origin.x = 160 - button.frame.size.width * 0.5;
    rect.origin.y = 40  - button.frame.size.height * 0.5;
    button.frame = rect;
    [container addSubview:button];
    _loginTabel.backgroundColor = [UIColor colorFromHex:@"cbd5d9"];
    _loginTabel.tableFooterView = container;

    [self.view addSubview:_signupTabel];
    
    if( _state == kLogin )
    {
        [self.view sendSubviewToBack:self.signupTabel];
    }
    
    
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


#pragma mark - table
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

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38.0f;
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
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    FormCell *cell  = (FormCell*)[tableView cellForRowAtIndexPath:indexPath];
    FormField field = [[cell.cellinfo valueForKey:@"field"]intValue];
    
    if( [KeyboardManager sharedManager].isShowing && [self isSameCell:indexPath] )
    {
        [[KeyboardManager sharedManager] close];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if( [PickerManager sharedManager].isShowing && [self isSameCell:indexPath] )
    {
        [[PickerManager sharedManager]hidePicker];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if( [cell.cellinfo valueForKey:@"field"] && self.currentField != [[cell.cellinfo valueForKey:@"field"] intValue])
    {
        _currentField      = [[cell.cellinfo valueForKey:@"field"]intValue];
        _currentIndexPath  = indexPath;
    }
    
    switch (field)
    {
        case kEmail:
        case kPassword:
        case kUserMaxRent:
            [[PickerManager sharedManager]hidePicker];
            [cell setFocus];
            break;
        case kUserActivelyLooking:
            [[PickerManager sharedManager]hidePicker];
            [[KeyboardManager sharedManager]close];
            break;
        case kUserMovinDate:
            [PickerManager sharedManager].type = kDate;
            [[PickerManager sharedManager]showPickerInView:self.view];
            break;
        case kUserMinBedrooms:
        case  kUserBrokerFirm:
            [PickerManager sharedManager].type = kStandard;
            [PickerManager sharedManager].pickerData = cell.cellinfo[@"picker-data"];
            [[PickerManager sharedManager]showPickerInView:self.view];
            break;

        default:
            break;
    }
    
    
    if( [cell.cellinfo valueForKey:@"custom-action"] )
    {
        SEL sel = NSSelectorFromString([cell.cellinfo valueForKey:@"custom-action"]);
        [self performSelector:sel];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormCell *cell  = (FormCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell killFocus];
    
    NSLog(@"%@ --- deselected cell %@ ", self, cell  );
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionInfo = ( _state == kLogin ) ? [_loginArray objectAtIndex:section] : [_signupArray objectAtIndex:section];
    return [sectionInfo valueForKey:@"section-title"];
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionInfo = ( _state == kLogin ) ? [_loginArray objectAtIndex:section] : [_signupArray objectAtIndex:section];
    NSString *title                = [sectionInfo valueForKey:@"section-title"];
    SectionTitleView *sectionTitle = [[SectionTitleView alloc]initWithTitle:title];
    return sectionTitle;
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

-(float)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

#pragma mark - form delegates
-(void)cell:(FormCell *)cell didStartInteract:(FormField)field
{
    if( [self isSameCell:cell.indexPath] == NO )
    {
        [self tableView:self.signupTabel didSelectRowAtIndexPath:cell.indexPath];
    }
}

-(void)cell:(FormCell *)cell didChangeForField:(FormField)field
{
    
    UITableView *view = ( self.state == kLogin ) ? self.loginTabel : self.signupTabel;
    FormCell *c = (FormCell *)[view cellForRowAtIndexPath:self.currentIndexPath];
    
    switch (field)
    {
        case kEmail:
            NSLog(@"%@ , got change for email %@ ", self, c.formValue);
            _username = c.formValue;
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
        case kUserIsBroker:
            [User sharedUser].isBroker = c.formValue;
            break;
        case kUserBrokerFirm:
            [User sharedUser].brokerFirm = c.formValue;
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
        case kUserIsBroker:
            value = [User sharedUser].isBroker;
            break;
        case kUserBrokerFirm:
            value = [User sharedUser].brokerFirm;
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
    
            _state = kSignup;
            _currentIndexPath = nil;
            break;
            
        case kSignup:
            [UIView transitionFromView:self.signupTabel toView:self.loginTabel duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
                
            }];
            self.navigationItem.title = @"Log In";

            _state = kLogin;
            _currentIndexPath = nil;
            break;
    }
    
    [[KeyboardManager sharedManager]close];
    [[PickerManager sharedManager]
     hidePicker];
    
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
    UITableView *view = ( self.state == kSignup ) ? self.signupTabel : self.loginTabel;
    CGRect rect = [view cellForRowAtIndexPath:self.currentIndexPath].frame;
    rect.size.height += 20;
    [view scrollRectToVisible:rect animated:YES];
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
    
    float height = [PickerManager sharedManager].container.frame.size.height;
    
    [UIView animateWithDuration:0.3  animations:^{
        self.signupTabel.contentInset =  UIEdgeInsetsMake(0, 0, height, 0);
    }];
    
    [self animateToCell];
}

-(void)pickerWillHide
{
    [UIView animateWithDuration:0.3  animations:^{
        self.signupTabel.contentInset =  UIEdgeInsetsMake(0, 0, 0, 0);
    }];
}

-(void)pickerDone
{
    FormCell *cell = (FormCell *)[self.signupTabel cellForRowAtIndexPath:self.currentIndexPath];
    int index = [cell.cellinfo[@"picker-index"] intValue];
    
    switch( [cell.cellinfo[@"field"] intValue] )
    {
        
        case kUserBrokerFirm:
        case kUserMinBedrooms:
            cell.formValue = [[PickerManager sharedManager] valueForComponent:index];
            cell.detailTextLabel.text = [[PickerManager sharedManager] valueForComponent:index];
            break;
            
        case kUserMovinDate :
            cell.formValue = [PickerManager sharedManager].datePicker.date;
            cell.detailTextLabel.text = [[PickerManager sharedManager].datePicker.date toString];
            break;
        default:
            break;
    }
    
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
    
    UITableView *table = (self.state == kSignup ) ? self.signupTabel : self.loginTabel;
    [UIView animateWithDuration:[KeyboardManager sharedManager ].animationTime animations:^
    {
         table.contentInset =  UIEdgeInsetsMake(0, 0, [KeyboardManager sharedManager].keyboardFrame.size.height + 50, 0);
    }];
    
    [self animateToCell];
    
}

-(void)keyboardWillHide
{
    [UIView animateWithDuration:0.3  animations:^{
        self.signupTabel.contentInset =  UIEdgeInsetsMake(0, 0, 0, 0);
    }];
}

#pragma mark - picker stuff


-(BOOL)shouldAutorotate
{
    return NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
@end
