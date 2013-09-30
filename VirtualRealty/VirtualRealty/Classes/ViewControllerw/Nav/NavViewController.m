//
//  SSINavViewController.m
//  Shutterstock
//
//  Created by Chris on 6/12/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import "NavViewController.h"
#import "AbstractCell.h"

@interface NavViewController ()
-(void)handleLogin:(NSNotification* )note;
-(void)handleLogout:(NSNotification* )note;
@end

@implementation NavViewController


@synthesize table = _table;
@synthesize navData = _navData;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title = NSLocalizedString(@"Shutterstock", @"Temp title for main nav");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect rect = self.view.frame;
    rect.size.height -= ( self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height);
    rect.origin       = CGPointMake(0, 0);
    
    _table = [[UITableView alloc]initWithFrame:rect style:UITableViewStylePlain];
    [_table setDataSource:self];
    [_table setDelegate:self];
    [_table setContentInset:UIEdgeInsetsMake(20, -15, 0, 0)];
    [self.view addSubview:_table];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleLogin:) name:kLOGIN_NOTIFICATION_NAME object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleLogout:) name:kLOGOUT_NOTIFICATION_NAME object:nil];
}


-(void)loadNavigation
{
    NSString     *file = [[NSBundle mainBundle]pathForResource:@"nav" ofType:@"plist"];
    _navData  = [NSArray arrayWithContentsOfFile:file];
    [self.table reloadData];
}


#pragma mark - Table Managment
-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_navData count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuse = @"cell";
    
    NSDictionary *info = [_navData objectAtIndex:indexPath.row];

    AbstractCell *cell = (AbstractCell *)[tableView dequeueReusableCellWithIdentifier:reuse];
    
    if( cell == nil )
    {
        cell = [[NSClassFromString([info valueForKey:@"cell"]) alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuse];
    }
    cell.cellinfo = info;
    [cell render];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectBlock( [_navData objectAtIndex:indexPath.row] );
}

-(void)handleLogin:(NSNotification* )note
{
    [self.table reloadData];
}

-(void)handleLogout:(NSNotification* )note
{
    [self.table reloadData];
}

@end
