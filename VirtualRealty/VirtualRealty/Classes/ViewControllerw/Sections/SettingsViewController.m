//
//  SettingsViewController.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "SettingsViewController.h"
#import "AbstractCell.h"
#import "User.h"
#import "AppDelegate.h"
#import "FormCell.h"
#import "ReachabilityManager.h"
#import "ErrorFactory.h"
#import <Parse/Parse.h>

@interface SettingsViewController ()<FormCellDelegate>
-(void)toggleLogin;
@end

@implementation SettingsViewController

@synthesize table = _table;
@synthesize data  = _data;
@synthesize currentIndexPath = _currentIndexPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.navigationItem.title = @"Settings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString     *file = [[NSBundle mainBundle]pathForResource:@"settings" ofType:@"plist"];
    _data  = [NSArray arrayWithContentsOfFile:file];
    
    CGRect rect = self.view.frame;
    rect.size.height -= ( self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height);
    rect.origin       = CGPointMake(0, 0);
    
    _table = [[UITableView alloc]initWithFrame:rect style:UITableViewStylePlain];
    [_table setDataSource:self];
    [_table setDelegate:self];
    [self.view addSubview:_table];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.table reloadData];
}

#pragma mark - cell managers

-(void)cell:(FormCell *)cell didStartInteract:(FormField)field
{
    [self tableView:self.table didSelectRowAtIndexPath:cell.indexPath];
}

-(void)cell:(FormCell *)cell didChangeForField:(FormField)field
{
    switch (field)
    {
        case kUserActivelyLooking:
            if( [ReachabilityManager sharedManager].currentStatus == NotReachable )
            {
                [[ReachabilityManager sharedManager]showAlert];
                cell.formValue = [User sharedUser].activelySearching;
                [cell render];
            }
            else
            {
                if( [User sharedUser].state == kUserValid )
                {
                    [User sharedUser].activelySearching = cell.formValue;
                    [[User sharedUser]update];
                }
                else
                {
                    [[ErrorFactory getAlertCustomMessage:@"Please register to adjust this setting" andDelegateOrNil:nil andOtherButtons:nil ]show];
                    cell.formValue = [User sharedUser].activelySearching;
                    [cell render];
                }
            }
            break;
            
        case kSearchRadius:
            [User sharedUser].searchRadius = cell.formValue;
            break;
        default:
            
            break;
    }
    
}

#pragma mark - Table Managment
-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *info = [[self.data objectAtIndex:indexPath.row]mutableCopy];
    
    FormCell *cell = (FormCell *)[tableView dequeueReusableCellWithIdentifier:[info valueForKey:@"cell"]];
    

    [info setValue:[self getValueForFormField:[[info valueForKey:@"field"] intValue]] forKey:@"current-value"];
    
    
    if( cell == nil )
    {
        cell = [[NSClassFromString([info valueForKey:@"cell"]) alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[info valueForKey:@"cell"]];
    }
    
    cell.cellinfo = info;
    cell.indexPath = indexPath;
    if( [cell isKindOfClass:[FormCell class]] )
    {
        cell.formDelegate = self;        
    }
    [cell render];
    return cell;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *info = [self.data objectAtIndex:indexPath.row];
    float height = 38.0f;
    
    if( info[@"display-height"] )
    {
       height = [info[@"display-height"]floatValue];
    }
    
    return height;
}
 
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *info = [self.data objectAtIndex:indexPath.row];
   
    if( [info valueForKey:@"custom-action"] )
    {
        [self performSelector:NSSelectorFromString([info valueForKey:@"custom-action"])];
    }
    else
    {
        switch ([[info valueForKey:@"field"] intValue ] )
        {
            case kUser:
                [self toggleLogin];
                break;
            default:
                break;
        }
    }
}

-(void)testEmail
{
    [PFCloud callFunctionInBackground:@"notifyAdmin" withParameters:@{ @"objectId": @"6jxl87h" } block:^(id object, NSError *error){
        NSLog(@"%@ testing email system : called notify admin \n%@ \n%@", self,object, error);
    }];
}

-(id)getValueForFormField:(FormField)field
{
    id value;
    switch ( field )
    {
        case kUserActivelyLooking:
            value = [User sharedUser].activelySearching;
            break;
        case kSearchRadius :
            value = [User sharedUser].searchRadius;
            break;
        default:
            break;
    }
    return value;
}

-(void)handleLogin:(NSNotification* )note
{
    [self.table reloadData];
}

-(void)handleLogpout:(NSNotification* )note
{
    [self.table reloadData];
}

-(void)toggleLogin
{
    if( [User sharedUser].state == kUserValid )
    {
        NSString *title = @"Log Out";
        NSString *message = @"Are you sure you'd like to log out";
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else
    {
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [app showlogin];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 1:
            [[User sharedUser]logout];
        break;
    }
    [self.table reloadData];
}

-(void)toggleMenu
{
    [super toggleMenu];
    self.table.scrollEnabled = active;
    self.table.userInteractionEnabled = active;
}

-(void)setActive:(BOOL)value
{
    active = value;
    self.table.scrollEnabled = active;
    self.table.userInteractionEnabled = active;
}


@end
