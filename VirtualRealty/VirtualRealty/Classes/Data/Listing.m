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

@end

@implementation Listing
@synthesize errors = _errors;
@synthesize saveCompleteBlock;

-(id)initWithDefaults
{
    self = [super init];
    if( self != nil)
    {
        _errors = [NSMutableArray array];
        self.submitterID  = [User sharedUser].username;
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
    
    NSArray *ommissionList = @[@"errors", @"geo", @"thumb", @"saveCompleteBlock", @"video"];
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
            [userPhoto setObject:imageFile forKey:@"bitmap"];
            [userPhoto setObject:name      forKey:@"name"];
            [userPhoto setObject:[User sharedUser].username forKey:@"username"];
            
            userPhoto.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
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
            PFObject *userPhoto = [PFObject objectWithClassName:@"ListingVideo"];
            [userPhoto setObject:videoFile forKey:@"videofile"];
            [userPhoto setObject:name      forKey:@"name"];
            [userPhoto setObject:[User sharedUser].username forKey:@"username"];
            
            userPhoto.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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


@end
