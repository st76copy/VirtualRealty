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
#import "KeywordsViewController.h"
#import "SectionTitleView.h"
#import "LocationManager.h"
#import "UIColor+Extended.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AddApartmentViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate, KeyWordDelegate, UIAlertViewDelegate, LocationManagerDelegate, UIActionSheetDelegate>
-(void)handleListingComplete;
-(void)animateToCell;
-(id)getValueForFormField:(FormField)field;
-(void)addRows;
-(BOOL)isSameCell:(NSIndexPath *)path;
-(void)pickerWillShow;
-(void)pickerWillHide;
-(void)handleSubmitListing:(id)sender;
-(void)handleCaptureMedia;
-(void)showKeywords;

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
        
        _listing = [[Listing alloc]initWithDefaults];
        _listing.email = [User sharedUser].username;
        
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
    rect.size.height -= self.navigationController.navigationBar.frame.size.height;
    
   // self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(handleSubmitListing:)];
    
    self.navigationItem.title = @"Add A Listing";
    
    _table = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
    [_table setDataSource:self];
    [_table setDelegate:self];
    [_table setSeparatorInset:UIEdgeInsetsZero];
    [_table setSectionFooterHeight:0.0f];
    [_table setSectionHeaderHeight:44.0f];
    [_table setSeparatorColor:[UIColor clearColor]];
    [self.view addSubview:_table];
    
    UIView *container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 101)];
    [container setBackgroundColor:[UIColor colorFromHex:@"cbd5d9"]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"footer-button-fill.png"] forState:UIControlStateNormal];
    [button setTitle:@"Submit Listing" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorFromHex:@"cbd5d9"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(handleSubmitListing:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    
    rect = button.frame;
    rect.origin.x = 160 - button.frame.size.width * 0.5;
    rect.origin.y = 40  - button.frame.size.height * 0.5;
    button.frame = rect;
    [container addSubview:button];
    
    self.table.backgroundColor = [UIColor colorFromHex:@"cbd5d9"];
    self.table.tableFooterView = container;

}

-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
    
    if(  [ReachabilityManager sharedManager].currentStatus == NotReachable )
    {
        [[ReachabilityManager sharedManager]showAlert];
        return;
    }
    
    [[KeyboardManager sharedManager]registerDelegate:self];
    [[PickerManager sharedManager]registerDelegate:self];
    
    if( self.listing.neighborhood == nil )
    {
        [self getLocation];
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [app showLoaderInView:self.view];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[KeyboardManager sharedManager]unregisterDelegate:self];
    [[PickerManager sharedManager]unregisterDelegate:self];
 }

#pragma mark - location 
-(void)getLocation
{
    [[LocationManager shareManager]registerDelegate:self];
    [[LocationManager shareManager]startGettingLocations];
}

-(void)locationUpdated
{
    [[LocationManager shareManager]stopGettingLocation];
    [[LocationManager shareManager]removeDelegate:self];
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app hideLoader];
    
    NSDictionary *address = [LocationManager shareManager].addressInfo;
    
    if( address == nil )
    {
        [[ErrorFactory getAlertForType:kListingGPSError andDelegateOrNil:nil andOtherButtons:nil]show];
    }
    else
    {
        NSDictionary *info = @{
                               @"city" : address[@"City"],
                               @"street" : address[@"FormattedAddressLines"][0],
                               @"borough" : [(NSString *)address[@"FormattedAddressLines"][1] componentsSeparatedByString:@","][0],
                               @"neighborhood" : address[@"SubLocality"],
                               @"zip" : address[@"ZIP"],
                               @"state" : address[@"State"]
                               };
        
        NSString *addressString = [NSString stringWithFormat:@"%@\n%@, %@ %@", info[@"street"],info[@"borough"],info[@"state"],info[@"zip"]];
        NSString *title         = @"Hello";
        NSString *message       = [NSString stringWithFormat:@"Is this the appartment your trying to list\n%@", addressString];
        UIAlertView *av         = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",@"Almost", nil];
        [av show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary *address = [LocationManager shareManager].addressInfo;
    NSDictionary *info = @{@"city" : address[@"City"],
                           @"street" : address[@"FormattedAddressLines"][0],
                           @"borough" : [(NSString *)address[@"FormattedAddressLines"][1] componentsSeparatedByString:@","][0],
                           @"neighborhood" : address[@"SubLocality"],
                           @"zip" : address[@"ZIP"],
                           @"state" : address[@"State"]
                           };
    
    switch (buttonIndex)
    {
        case 0:
            break;
        case  1:
            self.listing.street = info[@"street"];
            self.listing.borough = info[@"borough"];
            self.listing.neighborhood = info[@"neighborhood"];
            self.listing.zip = info[@"zip"];
            self.listing.geo = [[LocationManager shareManager].location copy];
            self.listing.city = info[@"city"];
            self.listing.state = info[@"state"];
            
            [self.table reloadData];
        
            break;

        case  2:
            self.listing.borough = info[@"borough"];
            self.listing.neighborhood = info[@"neighborhood"];
            self.listing.zip = info[@"zip"];
            self.listing.city = info[@"city"];
            self.listing.state = info[@"state"];
            
            [self.table reloadData];
            break;
}
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
    NSLog(@"%@ failing on cell %@ ", self, info[@"class"]);
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
        case kContactPhone:
        case kContactEmail:
        case kUnit:
        case kBrokerFee:
        case kZip :
        case kStreet :
            [cell setFocus];
            break;
        case kVideo:
        case kThumbnail:
            [self handleCaptureMedia];
            break;
        case kKeywords:
            [self showKeywords];
            break;
        case kBedrooms:
        case kBathrooms:
        case kNeightborhood:
        case kBorough:
            [PickerManager sharedManager].type = kStandard;
            [PickerManager sharedManager].pickerData = cell.cellinfo[@"picker-data"];
            [[PickerManager sharedManager]showPickerInView:self.view];
            break;
            
        default:
            [[PickerManager sharedManager]hidePicker];
            [[KeyboardManager sharedManager]close];
        break;
    }
    [self.table deselectRowAtIndexPath:indexPath animated:YES];
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Section *sec = [self.tableData objectAtIndex:indexPath.section];
    Row     *row = [sec.rows objectAtIndex:indexPath.row];
    return  ( [row.info valueForKey:@"display-height"] ) ? [[row.info valueForKey:@"display-height"] floatValue] : 38.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    Section *sectionInfo           = [self.tableData objectAtIndex:section];
    SectionTitleView *sectionTitle = [[SectionTitleView alloc]initWithTitle:sectionInfo.title];
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
    rect.size.height += 20;
    [self.table scrollRectToVisible:rect animated:YES];
}


#pragma mark - model management
-(id)getValueForFormField:(FormField)field
{
    id value;
    
    switch( field )
    {
        case kStreet :
            value = self.listing.street;
            break;
        case kBorough:
            value = self.listing.borough;
            break;
        case kNeightborhood:
            value = self.listing.neighborhood;
            break;
        case kState:
            value = self.listing.state;
            break;
        case kCity :
            value = self.listing.city;
            break;
        case kZip:
            value = self.listing.zip;
            break;
        case kUnit:
            value = self.listing.unit;
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
        case kContactEmail:
            value = self.listing.email;
            break;
        case kContactPhone :
            value = self.listing.phone;
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
            value = self.listing.videoFrame  ;
            break;
        case kThumbnail:
            value = self.listing.thumb;
            break;
        case kKeywords:
            return self.listing.keywords;
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
        case kStreet:
            self.listing.street = cell.formValue;
            break;
        case kBorough:
            self.listing.borough  =  formcell.detailTextLabel.text;
            break;
        case kUnit:
            self.listing.unit     = cell.formValue;
            break;
        case kZip :
            self.listing.zip      = cell.formValue;
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
            _listing.bedrooms     = formcell.formValue;
            break;
        case kBathrooms:
            _listing.bathrooms    = formcell.formValue;
            break;
        case kShare:
            _listing.share        = [NSNumber numberWithFloat:[formcell.formValue floatValue]];
            break;
        case kMoveInDate:
            _listing.moveInDate   = formcell.formValue;
            break;
        case kContactEmail:
            _listing.email      = formcell.formValue;
            break;
        case kContactPhone:
            _listing.phone      = formcell.formValue;
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

#pragma mark - ui
-(void)handleSubmitListing:(id)sender
{
    __block AddApartmentViewController *blockself = self;
    
    if( [ReachabilityManager sharedManager].currentStatus == NotReachable )
    {
        [[ReachabilityManager sharedManager]showAlert];
        return;
    }

    if( self.listing.geo == nil )
    {
        NSString *addressString = [NSString stringWithFormat:@"%@ %@, %@, %i", self.listing.street, self.listing.borough, self.listing.state, [self.listing.zip intValue]];
        [[LocationManager shareManager]setCurrentLocationByString:addressString block:^(CLLocationCoordinate2D loc) {
            blockself.listing.geo = [[CLLocation alloc]initWithLatitude:loc.latitude longitude:loc.longitude];
            [blockself saveListing];
        }];
    }
    else
    {
        [self saveListing];
    }
}

-(void)saveListing
{
    __block AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    __block AddApartmentViewController *blockself = self;
    
    if( [self.listing isValid].count == 0 )
    {
        [delegate showLoader];
        
        [PFCloud callFunctionInBackground:@"saveListing" withParameters:[self.listing toDictionary] block:^(id object, NSError *error)
        {
            switch ([[object valueForKey:@"code"] intValue]) {
                case kSaveFailed:
                    [[ErrorFactory getAlertForType:kListingSavingError andDelegateOrNil:nil andOtherButtons:nil] show];
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
                            [[ErrorFactory getAlertForType:kListingMediaError andDelegateOrNil:nil andOtherButtons:nil] show];
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
    
    NSString *title = @"Choose Media";
    NSString *optionOne = nil;
    NSString *optionTwo = nil;
    
    switch (self.currentField)
    {
        case kVideo:
            optionOne = @"Take a Video";
            optionTwo = @"Choose from Library";
            break;
        case kThumbnail:
            optionOne = @"Take a Photo";
            optionTwo = @"Choose from Library";
            break;
        default:
            break;
    }
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:optionOne, optionTwo, nil];
    [sheet showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2 )
    {
        return;
    }
    
    UIImagePickerControllerSourceType type;
    switch (self.currentField) {
        case kThumbnail:
            type = ( buttonIndex == 0 ) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        case kVideo:
            type = ( buttonIndex == 0 ) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
            break;
        default:
            break;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = type;
    imagePicker.delegate   = self;
    
    switch (self.currentField)
    {
        case kThumbnail:
            imagePicker.mediaTypes        = @[(NSString *) kUTTypeImage];
            if( type == UIImagePickerControllerSourceTypeCamera )
            {
                imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                imagePicker.showsCameraControls = YES;
            }
            break;
        case kVideo:
            imagePicker.mediaTypes        = @[(NSString *) kUTTypeMovie];
            imagePicker.videoMaximumDuration = 60 * 1;
            if( type == UIImagePickerControllerSourceTypeCamera )
            {
                imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
                imagePicker.showsCameraControls = YES;
            }
            break;
        default:
            break;
    }

    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)handleListingComplete
{
    _listing = [[Listing alloc]initWithDefaults];
    _listing.email = [User sharedUser].username;
    [self.table reloadData];
    [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - image picker delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *source;
    switch (self.currentField)
    {
        case kThumbnail:
            source = [info valueForKey:UIImagePickerControllerOriginalImage];
            self.listing.thumb = [Utils resizeImage:source toSize:CGSizeMake(source.size.width * 0.3, source.size.height * 0.3 )];
            break;
        case kVideo:
        {
            self.listing.videoName  = self.listing.address;
            self.listing.video      = [NSData dataWithContentsOfURL:[info valueForKey:UIImagePickerControllerMediaURL]];
            self.listing.videoFrame = [Utils getImagefromVideoURL:[info valueForKey:UIImagePickerControllerMediaURL]];
            break;
        }
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.table reloadRowsAtIndexPaths:@[self.currentIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
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

#pragma mark - keywords
-(void)showKeywords
{
    KeywordsViewController *keywords = [[KeywordsViewController alloc]initWithWords:[self.listing.keywords mutableCopy]];
    keywords.delegate = self;
    [self.navigationController pushViewController:keywords animated:YES];
}

-(void)keywordsDone:(KeywordsViewController *)vc
{
    self.listing.keywords = [vc.words copy];
    [self.table reloadRowsAtIndexPaths:@[self.currentIndexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
    FormCell *temp = (FormCell*)[self.table cellForRowAtIndexPath:self.currentIndexpath];
 
    NSMutableDictionary *info = [temp.cellinfo mutableCopy];
    [info setValue:[self getValueForFormField:[[info valueForKey:@"field"] intValue]] forKey:@"current-value"];
    [temp setCellinfo:info];
    [temp render];
}

-(void)dealloc
{
    NSLog(@"%@ deallocated ", [self class] );
}

@end
