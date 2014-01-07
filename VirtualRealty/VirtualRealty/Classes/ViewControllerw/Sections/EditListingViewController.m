//
//  EditListingViewController.m
//  VirtualRealty
//
//  Created by christopher shanley on 1/5/14.
//  Copyright (c) 2014 virtualrealty. All rights reserved.
//

#import "EditListingViewController.h"
#import "SectionTitleView.h"
#import "FormCell.h"
#import "KeyboardManager.h"
#import "PickerManager.h"
#import "Listing.h"
#import "UIColor+Extended.h"
#import "NSDate+Extended.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "ReachabilityManager.h"
#import "ErrorFactory.h"
@interface EditListingViewController ()<UITableViewDataSource, UITableViewDelegate, FormCellDelegate, KeyboardManagerDelegate, PickerManagerDelegate>

@property(nonatomic, strong)Listing     *listing;
@property(nonatomic, strong)UITableView *table;
@property(nonatomic, strong)NSArray     *data;
@property(nonatomic, assign)FormField       currentField;
@property(nonatomic, retain)NSIndexPath    *currentIndexpath;

-(void)handleDeleteListing:(id)sender;
-(void)handleSaveListing:(id)sender;

@end

@implementation EditListingViewController

-(id)initWithListing:(Listing *)listing
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _listing = listing;
        NSString *temp = [[NSBundle mainBundle]pathForResource:@"editlisting" ofType:@"plist"];
        self.data      = [NSArray arrayWithContentsOfFile:temp];
        [[KeyboardManager sharedManager]registerDelegate:self];
        [[PickerManager sharedManager]registerDelegate:self];
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"edit";
    
    self.view.backgroundColor = [UIColor grayColor];
    CGRect rect = self.view.bounds;
    rect.size.height -= self.navigationController.navigationBar.frame.size.height;
    
    UIBarButtonItem *save = [[UIBarButtonItem alloc]initWithTitle:@"save" style:UIBarButtonItemStyleBordered target:self action:@selector(handleSaveListing:)];
    self.navigationItem.rightBarButtonItem = save;
    
    _table = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
    self.table.backgroundColor = [UIColor colorFromHex:@"cbd5d9"];
    
    [_table setDataSource:self];
    [_table setDelegate:self];
    [_table setSeparatorColor:[UIColor clearColor]];
    [_table setSectionFooterHeight:0.0f];
    [_table setSectionHeaderHeight:44.0f];
    [self.view addSubview:_table];
}


#pragma mark - form stuff

#pragma mark - uitableview
-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionInfo = [self.data objectAtIndex:section];
    NSArray *cells = sectionInfo[@"cells"];
    
    return cells.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.data.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *sectionInfo = [self.data objectAtIndex:indexPath.section];
    NSArray      *cells  = [sectionInfo valueForKey:@"cells"];
    NSDictionary *row    = [cells objectAtIndex:indexPath.row];
    
    NSMutableDictionary *info = [row mutableCopy];
    
    [info setValue:[self getValueForFormField:[[info valueForKey:@"field"] intValue]] forKey:@"current-value"];
    FormCell *cell = (FormCell *)[tableView dequeueReusableCellWithIdentifier:[info valueForKey:@"class"]];
 
    if( cell == nil )
    {
        cell = [[NSClassFromString([info valueForKey:@"class"]) alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[info valueForKey:@"class"]];
    }
    
    cell.formDelegate = self;
    cell.indexPath = indexPath;
    cell.cellinfo = info;
    [cell render];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormCell *cell     = (FormCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    if( [KeyboardManager sharedManager].isShowing && [self isSameCell:indexPath] )
    {
        [[KeyboardManager sharedManager] close];
        [self.table deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if( [PickerManager sharedManager].isShowing && [self isSameCell:indexPath] )
    {
        [[PickerManager sharedManager]hidePicker];
        [self.table deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if( [cell.cellinfo valueForKey:@"field"] && self.currentField != [[cell.cellinfo valueForKey:@"field"] intValue])
    {
        _currentField      = [[cell.cellinfo valueForKey:@"field"]intValue];
        _currentIndexpath  = indexPath;
    }
    
    switch (self.currentField)
    {
        case kMoveInDate :
            [PickerManager sharedManager].type = kDate;
            [[PickerManager sharedManager]showPickerInView:self.view];
            break;
        case kMonthlyRent:
        case kMoveInCost:
        case kBrokerFee:
            [cell setFocus];
            break;
        default:
            [[PickerManager sharedManager]hidePicker];
            [[KeyboardManager sharedManager]close];
            
            if( cell.cellinfo[@"custom-action"] )
            {
                NSString *selecorName =cell.cellinfo[@"custom-action"];
                [self performSelector:NSSelectorFromString(selecorName)withObject:nil ];
            }
            break;
    }
    [self.table deselectRowAtIndexPath:indexPath animated:YES];
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *sec = [self.data objectAtIndex:indexPath.section];
    NSDictionary *row = [sec[@"cells"] objectAtIndex:indexPath.row];
    return  ( [row valueForKey:@"display-height"] ) ? [[row valueForKey:@"display-height"] floatValue] : 38.0f;
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

#pragma mark - data
-(id)getValueForFormField:(FormField)field
{
    id value;

    switch( field )
    {
        case kVideo :
            value = self.listing;
            break;
        case kMonthlyRent:
            value = self.listing.monthlyCost;
            break;
        case kMoveInCost:
            value = self.listing.moveInCost;
            break;
        case kBrokerFee:
            value = self.listing.brokerfee;
            break;
        case kMoveInDate:
            value = self.listing.moveInDate;
            break;
        case kDogs:
            value = self.listing.dogs;
            break;
        case kCats:
            value = self.listing.dogs;
            break;
        case kListingStatus:
            value = ( [self.listing.listingState intValue] == kRented ) ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
            break;
        default:
            break;
    }
    return value;
}

#pragma mark - custom cell handlers

-(void)cell:(FormCell *)cell didChangeForField:(FormField)field
{
    FormCell *formcell = (FormCell *)[self.table cellForRowAtIndexPath:self.currentIndexpath];
    
    [self.listing clearErrorForField:field];
    switch( field )
    {
        case kMonthlyRent:
            _listing.monthlyCost  = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kMoveInCost:
            _listing.moveInCost   = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kBrokerFee:
            _listing.brokerfee    = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kMoveInDate:
            _listing.moveInDate   = formcell.formValue;
            break;
        case kDogs:
            _listing.dogs         = formcell.formValue;
            break;
        case kCats:
            _listing.cats         = formcell.formValue;
            break;
        case kListingStatus:
            self.listing.listingState = ( [formcell.formValue boolValue] == YES ) ? [NSNumber numberWithInt:kRented] : [NSNumber numberWithInt:kVacant];
        default:
            break;
    }
}

-(void)cell:(FormCell *)cell didStartInteract:(FormField)field
{
    [self tableView:self.table didSelectRowAtIndexPath:cell.indexPath];
}

-(BOOL)isSameCell:(NSIndexPath *)path
{
    return ( self.currentIndexpath.row == path.row && self.currentIndexpath.section == path.section ) ? YES : NO;
}


#pragma mark - keyboard
-(void)keyboardWillShow
{
    if( [PickerManager sharedManager].isShowing)
    {
        [[PickerManager sharedManager]hidePicker];
    }
    
    [UIView setAnimationCurve:[KeyboardManager sharedManager].animationCurve ];
    
    [UIView animateWithDuration:[KeyboardManager sharedManager ].animationTime animations:^
     {
         self.table.contentInset =  UIEdgeInsetsMake(0, 0, [KeyboardManager sharedManager].keyboardFrame.size.height + 50, 0);
     }];
    
    //  [self animateToCell];
    
}

-(void)keyboardWillHide
{
    [UIView animateWithDuration:0.3  animations:^{
        self.table.contentInset =  UIEdgeInsetsMake(0.0f, 0, 0, 0);
    }];
}

#pragma mark - picker delegate
-(void)pickerWillShow
{
    if( [KeyboardManager sharedManager].isShowing )
    {
        [[KeyboardManager sharedManager]close];
    }
    
    float height      = [PickerManager sharedManager].container.frame.size.height;
    
    [UIView animateWithDuration:0.3  animations:^{
        self.table.contentInset =  UIEdgeInsetsMake(0, 0, height, 0);
    }];
    [self animateToCell];
}

-(void)pickerWillHide
{
    [UIView animateWithDuration:0.3  animations:^{
        self.table.contentInset =  UIEdgeInsetsMake(0, 0, 0, 0);
    }];
}

-(void)pickerDone
{
    FormCell *cell = (FormCell *)[self.table cellForRowAtIndexPath:self.currentIndexpath];
    int index = [cell.cellinfo[@"picker-index"] intValue];
    
    switch ([PickerManager sharedManager].type) {
        case kStandard:
            cell.formValue = [[PickerManager sharedManager] valueForComponent:index];
            cell.detailTextLabel.text = [[PickerManager sharedManager] valueForComponent:index];
            break;
            
        default:
            cell.formValue = [PickerManager sharedManager].datePicker.date;
            cell.detailTextLabel.text = [[PickerManager sharedManager].datePicker.date toString];
            break;
    }
    
    [cell.formDelegate cell:cell didChangeForField:self.currentField];
    [self.table reloadRowsAtIndexPaths:@[self.currentIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[PickerManager sharedManager]hidePicker];
}

-(void)animateToCell
{
    CGRect rect = [self.table cellForRowAtIndexPath:self.currentIndexpath].frame;
    rect.size.height += 20;
    [self.table scrollRectToVisible:rect animated:YES];
}

-(void)handleSaveListing:(id)sender
{
    if( [ReachabilityManager sharedManager ].currentStatus == NotReachable )
    {
        NSString *msg = @"Sorry an internet connection is needed for this action, your settings will not be updated";
        [[ErrorFactory getAlertCustomMessage:msg andDelegateOrNil:nil andOtherButtons:nil]show];
        return;
    }
    __block AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showLoaderInView:self.view];
    
    [self.listing update:^(BOOL success)
    {
        [delegate hideLoader];
    }];
}

#pragma mark - delete listing
-(void)handleDeleteListing:(id)sender
{
    NSString *title = NSLocalizedString(@"Delete Listing", @"Generic : alert view delete title");
    NSString *message = NSLocalizedString(@"Are you sure you want to delete this listing, this cannot be undone.", @"Generic : alert view delete message");
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    [av show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            [self deleteObject];
            break;
    }
}

-(void)deleteObject
{
    __block EditListingViewController *blockself = self;
    NSDictionary *params = @{@"objectId":self.listing.objectId};
    [PFCloud callFunctionInBackground:@"deleteListing" withParameters:params block:^(id object, NSError *error)
    {
         if( [object intValue ] == 1 )
         {
             [blockself.navigationController popViewControllerAnimated:YES];
         }
         else
         {
             NSString *title = NSLocalizedString(@"Sorry", @"Generic : alert view delete title");
             NSString *message = NSLocalizedString(@"There was an error deleting your listing", @"Generic : alert view delete message");
             UIAlertView *av = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [av show];
         }
     }];
}


@end
