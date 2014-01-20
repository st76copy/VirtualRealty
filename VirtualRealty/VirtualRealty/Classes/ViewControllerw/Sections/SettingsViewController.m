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
#import "UIColor+Extended.h"
#import "SectionTitleView.h"
#import "TourViewController.h"
#import <MessageUI/MessageUI.h>

@interface SettingsViewController ()<FormCellDelegate, MFMailComposeViewControllerDelegate>
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
    
    _table = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
    [_table setDataSource:self];
    [_table setDelegate:self];
    [_table setSeparatorColor:[UIColor clearColor]];
    [_table setSectionFooterHeight:0.0f];
    [_table setSectionHeaderHeight:44.0f];
    _table.backgroundColor = [UIColor colorFromHex:@"cbd5d9"];
    
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
    NSDictionary *info = [self.data objectAtIndex:section];
    NSArray *cells = info[@"cells"];
    return cells.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.data.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionInfo      = [self.data objectAtIndex:section];
    SectionTitleView *sectionTitle = [[SectionTitleView alloc]initWithTitle:sectionInfo[@"section-title"]];
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *section = [self.data objectAtIndex:indexPath.section];
    NSArray *cells = section[@"cells"];
    NSMutableDictionary *info = [cells[indexPath.row] mutableCopy];
    
    FormCell *cell = (FormCell *)[tableView dequeueReusableCellWithIdentifier:[info valueForKey:@"cell"]];
    
    if( info[@"field"])
    {
        [info setValue:[self getValueForFormField:[[info valueForKey:@"field"] intValue]] forKey:@"current-value"];
    }
    
    
    
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
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *section = [self.data objectAtIndex:indexPath.section];
    NSArray *cells = section[@"cells"];
    
    NSDictionary *info = [cells objectAtIndex:indexPath.row];
    float height = 38.0f;
    
    if( info[@"display-height"] )
    {
       height = [info[@"display-height"]floatValue];
    }
    
    return height;
}
 
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *section = [self.data objectAtIndex:indexPath.section];
    NSArray *cells = section[@"cells"];
    
    NSDictionary *info = [cells objectAtIndex:indexPath.row];
   
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)testEmail
{
    [PFCloud callFunctionInBackground:@"notifyAdmin" withParameters:@{ @"objectId": @"6jxl87h" } block:^(id object, NSError *error){
        NSLog(@"%@ testing email system : called notify admin \n%@ \n%@", self,object, error);
    }];
}

-(void)showSupport
{
    if( [MFMailComposeViewController canSendMail]  )
    {
        MFMailComposeViewController *vc = [[MFMailComposeViewController alloc]init];
        vc.mailComposeDelegate = self;
        [vc setToRecipients:@[@"support@virtualrealtynyc.com"]];
        [vc setSubject:@"Virtual Reality iOS Support"];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else
    {
        [[ErrorFactory getAlertCustomMessage:@"There are no email acounts on this device" andDelegateOrNil:nil andOtherButtons:nil]show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showTour
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    TourViewController *tourvc = [[TourViewController alloc]initWithNibName:nil bundle:nil];
    [app.window.rootViewController presentViewController:tourvc animated:YES completion:nil];
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
