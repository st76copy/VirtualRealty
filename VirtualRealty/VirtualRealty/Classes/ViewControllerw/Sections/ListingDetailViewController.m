//
//  ListingDetailViewController.m
//  VirtualRealty
//
//  Created by christopher shanley on 10/12/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "ListingDetailViewController.h"
#import "FormCell.h"
#import "SQLiteRequestQueue.h"
#import "SQLRequest.h"
#import "QueryFactory.h"
#import "SQLiteManager.h"
#import "User.h"

@interface ListingDetailViewController ()

-(void)enableFavoriteButton:(NSArray *)results;
-(void)saveFavorite:(id)sender;
-(void)deleteFavorite:(id)sender;
-(void)handleFavoriteSaved;
-(void)handleDeleteComplete;

@end

@implementation ListingDetailViewController

@synthesize listing   = _listing;
@synthesize table     = _table;
@synthesize tableData = _tableData;

-(id)initWithListing:(Listing *)listing
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _listing = listing;
        NSString *temp = [[NSBundle mainBundle]pathForResource:@"listingdetails" ofType:@"plist"];
        _tableData     = [NSArray arrayWithContentsOfFile:temp];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    CGRect rect = self.view.bounds;
    
    
    
    _table = [[UITableView alloc]initWithFrame:rect style:UITableViewStyleGrouped];
    [_table setDataSource:self];
    [_table setDelegate:self];
    [self.view addSubview:_table];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if( [[User sharedUser]valid] )
    {
        __block ListingDetailViewController *blockself = self;
        
        NSString   *sql = [QueryFactory getListing:self.listing andUser:[User sharedUser]];
        __block SQLRequest *req = [[SQLRequest alloc]initWithQuery:sql andType:kSelect andName:@"select-favorite"];
        
        [req runSelectOnDatabaseManager:[SQLiteManager sharedDatabase] WithBlock:^(BOOL success) {
            if( success  )
            {
                [blockself enableFavoriteButton:[req.results copy]];
            }
        }];
    }
}

-(void)enableFavoriteButton:(NSArray *)results
{
    
    if( results.count == 0 )
    {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithTitle:@"add favorite" style:UIBarButtonItemStylePlain target:self action:@selector(saveFavorite:)];
        self.navigationItem.rightBarButtonItem = saveButton;
        
    }
    else
    {
        
        UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc]initWithTitle:@"remove favorite" style:UIBarButtonItemStylePlain target:self action:@selector(deleteFavorite:)];
        self.navigationItem.rightBarButtonItem = deleteButton;
    }
}

#pragma mark - table data and delegates
#pragma mark - table delegate and data
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionInfo = [self.tableData objectAtIndex:section];
    return [sectionInfo valueForKey:@"section-title"];
}

-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionInfo = [self.tableData objectAtIndex:section];
    NSArray      *cells       = [sectionInfo valueForKey:@"cells"];
    return cells.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableData.count;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *sectionInfo = [self.tableData objectAtIndex:indexPath.section];
    NSArray      *cells       = [sectionInfo valueForKey:@"cells"];
    NSDictionary *info        = [cells objectAtIndex:indexPath.row];
    float height;
    
    if( [info valueForKey:@"display-height"] )
    {
        height = [[info valueForKey:@"display-height"]floatValue];
    }
    else
    {
        height = 50.0f;
    }
    
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *sectionInfo = [self.tableData objectAtIndex:indexPath.section];
    NSArray      *cells       = [sectionInfo valueForKey:@"cells"];
    NSMutableDictionary *info = [[cells objectAtIndex:indexPath.row] mutableCopy];
    
    [info setValue:[self getValueForFormField:[[info valueForKey:@"field"] intValue]] forKey:@"current-value"];
    
    FormCell *cell = (FormCell *)[tableView dequeueReusableCellWithIdentifier:[info valueForKey:@"class"]];
    
    if( cell == nil )
    {
        cell = [[NSClassFromString([info valueForKey:@"class"]) alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[info valueForKey:@"class"]];
    }
    
    cell.indexPath = indexPath;
    cell.cellinfo = info;
    [cell render];
    
    return cell;
}

#pragma - get model data
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

#pragma mark - saving and deleteing
-(void)saveFavorite:(id)sender
{
    __block ListingDetailViewController *blockself = self;
    NSString *sql = [QueryFactory getSaveListingQuery:self.listing];
    SQLRequest *req = [[SQLRequest alloc]initWithQuery:sql andType:kSelect andName:@"save-favorite"];
    [req runInsertOnDatabaseManager:[SQLiteManager sharedDatabase] WithBlock:^(BOOL success)
    {
        [blockself handleFavoriteSaved];
    }];
}

-(void)handleFavoriteSaved
{
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc]initWithTitle:@"remove favorite" style:UIBarButtonItemStylePlain target:self action:@selector(deleteFavorite:)];
    self.navigationItem.rightBarButtonItem = deleteButton;
    
    NSString *title   = NSLocalizedString( @"Saved", @"Genereic : Saved object");
    NSString *message = NSLocalizedString( @"This listing has been saved to your favorites", @"Genereic : Saved listing messagea");
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)deleteFavorite:(id)sender
{
    __block ListingDetailViewController *blockself = self;
    
    NSString   *sql = [QueryFactory getSaveListingQuery:self.listing];
    SQLRequest *req = [[SQLRequest alloc]initWithQuery:sql andType:kSelect andName:@"delete-favorite"];
    
    [req runDeleteOnDatabaseManager:[SQLiteManager sharedDatabase] WithBlock:^(BOOL success)
    {
        if( success )
        {
            [blockself handleDeleteComplete];
        }
        else
        {
            // show error
        }
    }];
}

-(void)handleDeleteComplete
{
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithTitle:@"add favorite" style:UIBarButtonItemStylePlain target:self action:@selector(saveFavorite:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    NSString *title   = NSLocalizedString( @"Removed", @"Genereic : Saved object");
    NSString *message = NSLocalizedString( @"This listing has been removed to your favorites", @"Genereic : removed listing messagea");
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}



@end
