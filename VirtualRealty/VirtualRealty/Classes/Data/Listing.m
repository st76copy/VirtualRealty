//
//  Listing.m
//  VirtualRealty
//
//  Created by on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "Listing.h"
#import <objc/runtime.h>
#import <Parse/Parse.h>
#import "User.h"
#import "DiscManager.h"


@interface Listing()
-(void)savePhoto;
-(void)saveVideo;
-(void)handleThumbLoaded:(NSArray *)results;

@end

@implementation Listing
@synthesize videoURL = _videoURL;
@synthesize errors = _errors;
@synthesize saveCompleteBlock;

-(id)initWithDefaults
{
    self = [super init];
    if( self != nil)
    {
        _errors = [NSMutableArray array];
        self.submitterID       = [User sharedUser].username;
        self.submitterObjectId = [User sharedUser].uid;
        
        self.outdoorSpace = [NSNumber numberWithBool:NO];
        self.dogs         = [NSNumber numberWithBool:NO];
        self.cats         = [NSNumber numberWithBool:NO];
        self.share        = [NSNumber numberWithBool:NO];
        self.washerDryer  = [NSNumber numberWithBool:NO];
        self.gym          = [NSNumber numberWithBool:NO];
        self.doorman      = [NSNumber numberWithBool:NO];
        self.pool         = [NSNumber numberWithBool:NO];
        self.brokerfee    = [NSNumber numberWithBool:NO];
        self.listingState = [NSNumber numberWithInt:kPending];
    }
    return  self;
}

-(id)initWithFullData:(NSDictionary *)info
{
    self = [super init];
    if( self != nil)
    {
        _errors = [NSMutableArray array];
        self.submitterObjectId = [info valueForKey:@"submitterObjectId"];
        self.submitterID  = [info valueForKey:@"submitterID"];
        self.contact      = [info valueForKey:@"submitterID"];
        self.address      = [info valueForKey:@"address"];
        self.unit         = [info valueForKey:@"unit"];
        self.neighborhood = [info valueForKey:@"neighborhood"];
        self.monthlyCost  = [info valueForKey:@"monthlyCost"];
        self.moveInCost   = [info valueForKey:@"moveInCost"];
        self.bathrooms    = [info valueForKey:@"bathrooms"];
        self.bedrooms     = [info valueForKey:@"bedrooms"];
        self.brokerfee    = [info valueForKey:@"brokerfee"];
        self.objectId     = [info valueForKey:@"objectId"];

        self.moveInDate   = [info valueForKey:@"moveInDate"];
        self.outdoorSpace = [info valueForKey:@"outdoorSpace"];
        self.dogs         = [info valueForKey:@"dogs"];
        self.cats         = [info valueForKey:@"cats"];
        self.share        = [info valueForKey:@"share"];
        self.washerDryer  = [info valueForKey:@"washerDryer"];
        self.gym          = [info valueForKey:@"gym"];
        self.doorman      = [info valueForKey:@"doorman"];
        self.pool         = [info valueForKey:@"pool"];
        self.listingState = [info valueForKey:@"listingState"];
        
        if( [[info valueForKey:@"keywords"] isKindOfClass:[NSArray class]])
        {
            self.keywords = [info valueForKey:@"keywords"];
        }

    }
    return  self;
}

-(id)initWithSQLData:(NSDictionary *)info
{
    self = [self initWithFullData:info];
    if( self != nil)
    {
        self.keywords = [[info valueForKey:@"keywords"]componentsSeparatedByString:@","];
    }
    return self;
}

-(NSMutableArray *)isValid
{
    [self.errors removeAllObjects];
    
    if( self.address == nil || [self.address isEqualToString:@""])
    {
        [self.errors addObject:[NSNumber numberWithInt:kAddress]];
    }
  
    if( self.unit == nil || [self.unit isEqualToString:@""])
    {
        [self.errors addObject:[NSNumber numberWithInt:kUnit]];
    }
    
    if( self.neighborhood == nil )
    {
        [self.errors addObject:[NSNumber numberWithInt:kNeightborhood]];
    }
    
    if( self.monthlyCost == nil )
    {
        [self.errors addObject:[NSNumber numberWithInt:kMonthlyRent]];
    }
    
    if( self.moveInCost == nil )
    {
        [self.errors addObject:[NSNumber numberWithInt:kMoveInCost]];
    }
    
    if( self.bedrooms == nil )
    {
        [self.errors addObject:[NSNumber numberWithInt:kBedrooms]];
    }
    
    if( self.bathrooms == nil )
    {
        [self.errors addObject:[NSNumber numberWithInt:kBathrooms]];
    }
    
    if( self.thumb == nil )
    {
    //    [self.errors addObject:[NSNumber numberWithInt:kThumbnail]];
    }
    
    if( self.video == nil )
    {
    //    [self.errors addObject:[NSNumber numberWithInt:kVideo]];
    }
    
    if( self.contact == nil )
    {
        [self.errors addObject:[NSNumber numberWithInt:kContact]];
    }
    
    if( self.moveInDate == nil )
    {
        [self.errors addObject:[NSNumber numberWithInt:kMoveInDate]];
    }
    
    return self.errors;
}

-(void)clearErrorForField:(FormField)field
{
    NSNumber *remove;
    for( NSNumber *num in self.errors)
    {
        if( [num intValue] == field )
        {
            remove = num;
        }
    }
    [self.errors removeObject:remove];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"address : %@ \n"
                                    "neightborhood : %@ \n"
                                    "montly cost : %0.2f \n"
                                    "move in cost : %0.2f \n"
                                    "broker : %d \n"
                                    "move in date : %@ \n"
                                    "bedrooms  : %i \n"
                                    "bathroom  : %i \n"
                                    "contact : %@  \n"
                                    "share : %d \n"
                                    "dogs : %d \n"
                                    "cats : %d \n"
                                    "outdoor : %d \n"
                                    "washer dryer : %d \n"
                                    "gym : %d \n"
                                    "doorman : %d \n"
                                    "pool : %d \n"
                                    "thumb : %@ \n",
            _address,
            _neighborhood,
            [_monthlyCost floatValue],
            [_moveInCost floatValue],
            [_brokerfee boolValue],
            _moveInDate,
            [_bedrooms intValue ],
            [_bathrooms intValue],
            _contact,
            [_share boolValue],
            [_dogs boolValue],
            [_cats boolValue   ],
            [_outdoorSpace boolValue],
            [ _washerDryer boolValue],
            [_gym boolValue],
            [_doorman boolValue],
            [_pool boolValue ],
            _thumb
            ];
    
}

-(NSDictionary *) toDictionary
{
    unsigned int propertyCount = 0;
    objc_property_t * properties = class_copyPropertyList([self class], &propertyCount);
    
    NSArray *ommissionList = @[@"errors", @"geo", @"thumb", @"saveCompleteBlock", @"video", @"videoURL", @"keywords"];
    NSString *key = nil;
    NSMutableDictionary *temp = [NSMutableDictionary dictionary];
    
    for (unsigned int i = 0; i < propertyCount; ++i)
    {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        
        key = [NSString stringWithUTF8String:name];
        
        if( [ommissionList containsObject:key] == NO )
        {
            if( [self valueForKey:key] != nil )
            {
                [temp setObject:[self valueForKey:key] forKey:key ];
            }
        }
    }
    
    if( self.geo )
    {
        [temp setValue:[NSNumber numberWithDouble:self.geo.coordinate.latitude] forKey:@"lat"];
        [temp setValue:[NSNumber numberWithDouble:self.geo.coordinate.longitude] forKey:@"long"];
    }
    
    return temp;
}

-(void)saveMedia:(SaveMediaBlock)block
{
    self.saveCompleteBlock = block;
    [self savePhoto];
}

-(void)savePhoto
{
    __block Listing *blocklisting = self;
    NSData *imageData      = UIImageJPEGRepresentation(self.thumb, 0.05f);
    __block NSString *name = [self.address stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    
    PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@%@", name, @".jpg"] data:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if( succeeded )
        {
            PFObject *userPhoto = [PFObject objectWithClassName:@"ListingImage"];
            [userPhoto setObject:imageFile                  forKey:@"bitmap"];
            [userPhoto setObject:name                       forKey:@"name"];
            [userPhoto setObject:blocklisting.objectId      forKey:@"listingID"];
            [userPhoto setObject:[User sharedUser].username forKey:@"username"];
            
            [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error)
                {
                    [blocklisting saveVideo];
                }
                else
                {
                    blocklisting.saveCompleteBlock( NO );
                }
            }];
        }
        else
        {
            blocklisting.saveCompleteBlock( NO );
        }
    }];
}

-(void)saveVideo
{
    __block Listing *blocklisting = self;
    __block NSString *name = [self.address stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    
    PFFile *videoFile = [PFFile fileWithName:[NSString stringWithFormat:@"%@%@", name, @".mov"] data:self.video];
    
    [videoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if( succeeded )
        {
            PFObject *userVideo = [PFObject objectWithClassName:@"ListingVideo"];
            [userVideo setObject:videoFile forKey:@"videofile"];
            [userVideo setObject:name      forKey:@"name"];
            [userVideo setObject:[User sharedUser].username forKey:@"username"];
            [userVideo setObject:blocklisting.objectId      forKey:@"listingID"];
    
            [userVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error)
                {
                    blocklisting.saveCompleteBlock(YES);
                }
                else
                {
                    blocklisting.saveCompleteBlock( NO );
                }
            }];
        }
        else
        {
            blocklisting.saveCompleteBlock( NO );
        }
    }];
}

-(void)loadThumb:( LoadMediaBlock )block
{
    
    __block Listing *blockList = self;
    self.loadCompleteBlock = block;

    PFQuery  *query            = [PFQuery queryWithClassName:@"ListingImage"];
    [query whereKey:@"listingID" equalTo:self.objectId];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if( error == nil && objects.count == 1 )
        {
            [blockList handleThumbLoaded:objects];
        }
        else
        {
            blockList.loadCompleteBlock( NO );
        }
    }];
}

-(void)handleThumbLoaded:(NSArray *)results
{
    NSDictionary *info = [results objectAtIndex:0];
    PFFile       *file = [info valueForKey:@"bitmap"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        self.thumb         = [UIImage imageWithData:[file getData]];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loadCompleteBlock( YES );
        });
    });
}

-(void)loadVideo:( LoadMediaBlock )block
{
    
    __block Listing *blockList = self;
    self.loadCompleteBlock = block;
    
    PFQuery  *query            = [PFQuery queryWithClassName:@"ListingVideo"];
    [query whereKey:@"listingID" equalTo:self.objectId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
         if( error == nil && objects.count == 1 )
         {
             [blockList handleVideoLoaded:objects];
         }
         else
         {
             blockList.loadCompleteBlock( NO );
         }
    }];
}

-(void)handleVideoLoaded:(NSArray *)results
{
    if( results.count > 0 )
    {
        PFFile *file = [[results objectAtIndex:0] valueForKey:@"videofile"];
        _videoURL    = [NSURL URLWithString:file.url];
    }
    
    if( self.videoURL )
    {
        self.loadCompleteBlock(YES);
    }
    else
    {
        self.loadCompleteBlock(NO);
    }
}



@end
