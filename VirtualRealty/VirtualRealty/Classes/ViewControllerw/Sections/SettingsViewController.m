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

@interface SettingsViewController ()
-(void)toggleLogin;
@end

@implementation SettingsViewController

@synthesize table = _table;
@synthesize data  = _data;

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
    NSDictionary *info = [self.data objectAtIndex:indexPath.row];
    
    AbstractCell *cell = (AbstractCell *)[tableView dequeueReusableCellWithIdentifier:[info valueForKey:@"cell"]];
    
    if( cell == nil )
    {
        cell = [[NSClassFromString([info valueForKey:@"cell"]) alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[info valueForKey:@"cell"]];
    }
    cell.cellinfo = info;
    [cell render];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *info = [self.data objectAtIndex:indexPath.row];
    
    switch ([[info valueForKey:@"field"] intValue ] )
    {
        case kUser:
            [self toggleLogin];
            break;
        default:
            break;
    }
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

@end
