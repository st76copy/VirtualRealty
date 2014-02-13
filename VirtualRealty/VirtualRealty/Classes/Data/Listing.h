//
//  Listing.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


typedef void (^SaveMediaBlock) (BOOL success);
typedef void (^LoadMediaBlock) (BOOL success);
typedef void (^UpdateListingBlock) (BOOL success);

@interface Listing : NSObject

-(id)initWithDefaults;
-(id)initWithFullData:(NSDictionary *)info;
-(id)initWithSQLData:(NSDictionary *)info;
-(NSDictionary * )toDictionary;
-(NSMutableArray *)isValid;

-(void)loadThumb:( LoadMediaBlock )block;
-(void)loadVideo:( LoadMediaBlock )block;


-(void)clearErrorForField:(FormField)field;
-(void)saveMedia:( SaveMediaBlock )block;
-(void)update:(UpdateListingBlock)block;

-(void)compressVideo:( void (^) (BOOL success) ) block;
@property(nonatomic, strong, readonly)NSMutableArray *errors;

@property(nonatomic, strong)NSString *objectId;
@property(nonatomic, strong)NSString *submitterObjectId;
@property(nonatomic, copy)SaveMediaBlock saveCompleteBlock;
@property(nonatomic, copy)LoadMediaBlock loadCompleteBlock;
@property(nonatomic, copy)LoadMediaBlock updateCompleteBlock;

@property(nonatomic,strong )CLLocation *geo;

@property(nonatomic, strong)NSString *submitterID;
@property(nonatomic, strong)NSString *address;
@property(nonatomic, strong)NSString *unit;
@property(nonatomic, strong)NSString *neighborhood;

@property(nonatomic, strong)NSNumber *monthlyCost;
@property(nonatomic, strong)NSNumber *moveInCost;
@property(nonatomic, strong)NSNumber *brokerfee;

@property(nonatomic, strong)NSDate   *moveInDate;
@property(nonatomic, strong)NSString *email;
@property(nonatomic, strong)NSString *phone;
@property(nonatomic, strong)NSNumber *share;

@property(nonatomic, strong)NSNumber *bedrooms;
@property(nonatomic, strong)NSNumber *bathrooms;

@property(nonatomic, strong)NSNumber *dogs;
@property(nonatomic, strong)NSNumber *cats;
@property(nonatomic, strong)NSNumber *outdoorSpace;
@property(nonatomic, strong)NSNumber *washerDryer;
@property(nonatomic, strong)NSNumber *gym;
@property(nonatomic, strong)NSNumber *doorman;
@property(nonatomic, strong)NSNumber *pool;
@property(nonatomic, strong)NSNumber *listingState;

@property(nonatomic, strong)UIImage  *thumb;
@property(nonatomic, strong)NSData   *video;
@property(nonatomic, strong)NSString *videoName;
@property(nonatomic, strong)NSArray  *keywords;
@property(nonatomic, strong, readonly)NSURL *videoURL;
@property(nonatomic, strong)NSURL *localAssetPath;
@property(nonatomic, strong)NSURL *localVideoURL;
@property(nonatomic, strong)UIImage *videoFrame;


// extended properties
@property(nonatomic, strong)NSNumber *zip;
@property(nonatomic, strong)NSString *street;
@property(nonatomic, strong)NSString *city;
@property(nonatomic, strong)NSString *state;
@property(nonatomic, strong)NSString *borough;



@end
