//
//  AddApartmentViewController.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "AddApartmentViewController.h"
#import "User.h"
#import "Section.h"
#import "Row.h"
#import "KeyboardManager.h"
#import "PickerManager.h"
#import "CheckCell.h"
#import "NSDate+Extended.h"
#import "AppDelegate.h"
#import "ReachabilityManager.h"
#import <Parse/Parse.h>
#import "ErrorFactory.h"

@interface AddApartmentViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
-(void)handleListingComplete;
-(void)animateToCell;
-(id)getValueForFormField:(FormField)field;
-(void)addRows;
-(BOOL)isSameCell:(NSIndexPath *)path;
-(void)pickerWillShow;
-(void)pickerWillHide;
-(void)handleSubmitListing:(id)sender;
-(void)handleCaptureMedia;
@end

@implementation AddApartmentViewController

@synthesize currentField = _currentField;
@synthesize table        = _table;
@synthesize tableData    = _tableData;
@synthesize listing      = _listing;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {

        NSString *temp = [[NSBundle mainBundle]pathForResource:@"newlisting" ofType:@"plist"];
        NSArray  *ref  = [[NSArray arrayWithContentsOfFile:temp] mutableCopy];
        
        _tableData = [NSMutableArray array];
        Section *section;
        Row     *row;
        
        for( NSDictionary *info in ref )
        {
            section = [[Section alloc]initWithTitle:[info valueForKey:@"section-title"]];
            for( NSDictionary *cell in [info valueForKey:@"cells"] )
            {
                row = [[Row alloc]initWithInfo:cell];
                [section.rows addObject:row];
            }
            
            [self.tableData addObject:section];
        }
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    CGRect rect = self.view.bounds;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(handleSubmitListing:)];
    
    _table = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
    [_table setDataSource:self];
    [_table setDelegate:self];
    [self.view addSubview:_table];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[KeyboardManager sharedManager]registerDelegate:self];
    [[PickerManager sharedManager]registerDelegate:self];
    
    if( [User sharedUser].currentListing == nil )
    {
        _listing = [[Listing alloc]initWithDefaults];
        [User sharedUser].currentListing = self.listing;
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[KeyboardManager sharedManager]unregisterDelegate:self];
    [[PickerManager sharedManager]unregisterDelegate:self];
}

#pragma mark - table delegate and data
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Section *sectionInfo = [self.tableData objectAtIndex:section];
    return sectionInfo.title;
}

-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Section *sectionInfo = [self.tableData objectAtIndex:section];
    return [[sectionInfo activeRows]count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Section *sectionInfo = [self.tableData objectAtIndex:indexPath.section];
    NSArray      *cells  = [sectionInfo activeRows];
    Row          *row    = [cells objectAtIndex:indexPath.row];
    
    NSMutableDictionary *info = [row.info mutableCopy];
    
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
 
    if( [self.listing.errors containsObject:[info valueForKey:@"field"]] )
    {
        [cell showError];
    }
    else
    {
        [cell clearError];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormCell *cell     = (FormCell*)[tableView cellForRowAtIndexPath:indexPath];

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
        _currentIndexpath  = indexPath;
    }
    
    switch (self.currentField)
    {
        case kAddress:
            break;
            
        case kNeightborhood:
        {
            CheckCell *c = (CheckCell *)[self.table cellForRowAtIndexPath:indexPath];
            NSMutableDictionary *info = [[c cellinfo]mutableCopy];
            if( [c isKindOfClass:[CheckCell class]] )
            {
                [self.listing clearErrorForField:kNeightborhood];
                self.listing.neighborhood = [c.cellinfo valueForKey:@"label"];
                [info setValue:[self getValueForFormField:[[info valueForKey:@"field"] intValue]] forKey:@"current-value"];
                [self.table reloadRowsAtIndexPaths:@[self.currentIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [c setCellinfo:info];
                [c render];
            }
            [[KeyboardManager sharedManager] close];
            [self addRows];
        }
        break;
        case kMoveInDate :
            [PickerManager sharedManager].type = kDate;
            [[PickerManager sharedManager]showPickerInView:self.view];
            break;
        case kMonthlyRent:
        case kMoveInCost:
        case kBedrooms:
        case kBathrooms:
        case kContact:
        case kUnit:
            [cell setFocus];
            break;
        case kVideo:
        case kThumbnail:
            [self handleCaptureMedia];
            break;
        default:
        break;
    }
    [self.table deselectRowAtIndexPath:indexPath animated:YES];
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Section *sec = [self.tableData objectAtIndex:indexPath.section];
    Row     *row = [sec.rows objectAtIndex:indexPath.row];
    return  ( [row.info valueForKey:@"display-height"] ) ? [[row.info valueForKey:@"display-height"] floatValue] : 50.0f;
}


#pragma mark - custom cell handlers
-(BOOL)isSameCell:(NSIndexPath *)path
{
    return ( self.currentIndexpath.row == path.row && self.currentIndexpath.section == path.section ) ? YES : NO;
}

-(void)addRows
{
    Section *secion = [self.tableData objectAtIndex:self.currentIndexpath.section];
    [secion toggleRows];
    
    NSMutableArray *paths = [NSMutableArray array];
    NSIndexPath    *path;
    
    for( int i = 1; i <= [secion animatableRows]; i ++ )
    {
        path = [NSIndexPath indexPathForRow:self.currentIndexpath.row + i inSection:self.currentIndexpath.section];
        [paths addObject:path];
    }
 
    if( secion.state == kContracted )
    {
        [self.table deleteRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationBottom];
        [self.table scrollToRowAtIndexPath:self.currentIndexpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else
    {
        [self.table insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
    }
}

-(void)animateToCell
{
    CGRect rect = [self.table cellForRowAtIndexPath:self.currentIndexpath].frame;
    [self.table scrollRectToVisible:rect animated:YES];
}


#pragma mark - model management
-(id)getValueForFormField:(FormField)field
{
    id value;
    
    switch( field )
    {
        case kAddress:
            value = self.listing.address;
            break;
        case kUnit:
            value = self.listing.unit;
            break;
        case kNeightborhood:
            value = self.listing.neighborhood;
            break;
        case kMonthlyRent:
            value = self.listing.monthlyCost;
            break;
        case kMoveInCost:
            value = self.listing.moveInCost;
            break;
        case kBedrooms:
            value = self.listing.bedrooms;
            break;
        case kBathrooms:
            value = self.listing.bathrooms;
            break;
        case kBrokerFee:
            value = self.listing.brokerfee;
            break;
        case kContact:
            value = self.listing.contact;
            break;
        case kShare:
            value = self.listing.share;
            break;
        case kMoveInDate:
            value = self.listing.moveInDate;
            break;
        case kDoorMan:
            value = self.listing.doorman;
            break;
        case kPool:
            value = self.listing.pool;
            break;
        case kGym:
            value = self.listing.gym;
            break;
        case kDogs:
            value = self.listing.dogs;
            break;
        case kCats:
            value = self.listing.cats;
            break;
        case kOutdoorSpace:
            value = self.listing.outdoorSpace;
            break;
        case kWasherDryer:
            value = self.listing.washerDryer;
            break;
        case kVideo :
            value = self.listing.video;
            break;
        case kThumbnail:
            value = self.listing.thumb;
            break;
            
        default:
            break;
    }
    return value;
}


#pragma mark - form cell delegates
-(void)cell:(FormCell *)cell didChangeForField:(FormField)field
{
    FormCell *formcell = (FormCell *)[self.table cellForRowAtIndexPath:self.currentIndexpath];
    
    [self.listing clearErrorForField:field];
    switch( field )
    {
        case kAddress:
            self.listing.address  = cell.formValue;
            break;
            
        case kUnit:
            self.listing.unit     = cell.formValue;
            break;
        case kNeightborhood:
            _listing.neighborhood = formcell.detailTextLabel.text;
            break;
        case kMonthlyRent:
            _listing.monthlyCost  = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kMoveInCost:
            _listing.moveInCost   = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kBrokerFee:
            _listing.brokerfee    = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kBedrooms:
            _listing.bedrooms     = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kBathrooms:
            _listing.bathrooms    = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kShare:
            _listing.share        = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kMoveInDate:
            _listing.moveInDate   = formcell.formValue;
            break;
        case kContact:
            _listing.contact      = formcell.formValue;
            break;
        case kDogs:
            _listing.dogs         = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kCats:
            _listing.cats         = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kGym :
            _listing.gym          = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kDoorMan :
            _listing.doorman      = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kOutdoorSpace:
            _listing.outdoorSpace = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kWasherDryer:
            _listing.washerDryer  = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kPool:
            _listing.pool         = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kVideo :
            break;
        case kThumbnail:
            break;
        default:
            break;
    }
    
    NSLog(@"%@ current listing \n%@ ",self,  self.listing);
}

-(void)cell:(FormCell *)cell didStartInteract:(FormField)field
{
   [self tableView:self.table didSelectRowAtIndexPath:cell.indexPath];
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
        self.table.contentInset =  UIEdgeInsetsMake(0, 0, [KeyboardManager sharedManager].keyboardFrame.size.height, 0);
    }];

    [self animateToCell];

}

-(void)keyboardWillHide
{
    [UIView animateWithDuration:0.3  animations:^{
        self.table.contentInset =  UIEdgeInsetsMake(64, 0, 0, 0);
    }];
}

#pragma mark - picker delegate
-(void)pickerWillShow
{
    if( [KeyboardManager sharedManager].isShowing )
    {
        [[KeyboardManager sharedManager]close];
    }
    
    [UIView animateWithDuration:0.4 animations:^
    {
         self.table.contentInset =  UIEdgeInsetsMake(0, 0,[PickerManager sharedManager].container.frame.size.height, 0);
    }];
    
    [self animateToCell];
}

-(void)pickerWillHide
{
    [UIView animateWithDuration:0.3  animations:^{
        self.table.contentInset =  UIEdgeInsetsMake(64, 0, 0, 0);
    }];
}

-(void)pickerDone
{
    FormCell *cell = (FormCell *)[self.table cellForRowAtIndexPath:self.currentIndexpath];
    cell.formValue = [PickerManager sharedManager].datePicker.date;
    cell.detailTextLabel.text = [[PickerManager sharedManager].datePicker.date toString];
    [cell.formDelegate cell:cell didChangeForField:self.currentField];
    [self.table reloadRowsAtIndexPaths:@[self.currentIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[PickerManager sharedManager]hidePicker];
}

#pragma mark - ui
-(void)handleSubmitListing:(id)sender
{
    __block AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    __block AddApartmentViewController *blockself = self;
    
    if( [ReachabilityManager sharedManager].currentStatus == NotReachable )
    {
        [[ReachabilityManager sharedManager]showAlert];
        return;
    }
    
    
    if( [self.listing isValid].count == 0 )
    {
        [delegate showLoader];
        
        [PFCloud callFunctionInBackground:@"saveListing" withParameters:[self.listing toDictionary] block:^(id object, NSError *error)
        {
            switch ([[object valueForKey:@"code"] intValue]) {
                case kSaveFailed:
                    break;
                case kSaveSuccess:
                    
                    self.listing.objectId = [[object valueForKey:@"data"] valueForKey:@"objectId"];
                    [self.listing saveMedia:^(BOOL success) {
                        if( success )
                        {
                            [blockself handleListingComplete];
                            [delegate hideLoader];
                            [[ErrorFactory getAlertForType:kListingPendingError andDelegateOrNil:nil andOtherButtons:nil] show];
                        }
                        else
                        {
                            [delegate hideLoader];
                        }
                    }];
                    
                    break;
                case kListingExist:
                    [[ErrorFactory getAlertForType:kListingExistsError andDelegateOrNil:Nil andOtherButtons:nil]show];
                    [delegate hideLoader];
                    break;
            }
        }];

    }
    else
    {
        
        NSString *title = NSLocalizedString(@"Sorry",@"Generic : sorry");
        NSString *message = NSLocalizedString( @"Some of the required fields are missing and are show in red, please complete the form to proceed", @"Genereic : error for failed listing submission");
        UIAlertView *failed = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [failed show];
        [self.table reloadData];
    }
}


-(void)handleCaptureMedia
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate   = self;

    switch (self.currentField)
    {
        case kThumbnail:

            imagePicker.mediaTypes        = @[(NSString *) kUTTypeImage];
            imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            break;
        case kVideo:
            
            imagePicker.mediaTypes        = @[(NSString *) kUTTypeMovie];
            imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
            break;
        default:
            break;
    }
    imagePicker.showsCameraControls = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)handleListingComplete
{
    _listing = [[Listing alloc]initWithDefaults];
    [User sharedUser].currentListing = _listing;
    
    [self.table reloadData];
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - image picker delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    switch (self.currentField)
    {
        case kThumbnail:
            self.listing.thumb = [info valueForKey:UIImagePickerControllerOriginalImage];
            break;
        case kVideo:
            self.listing.video = [NSData dataWithContentsOfURL:[info valueForKey:UIImagePickerControllerMediaURL]];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.table reloadData];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
