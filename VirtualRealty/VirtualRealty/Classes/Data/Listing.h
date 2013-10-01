//
//  Listing.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Listing : NSObject

-(id)initWithDefaults;
-(NSMutableArray *)isValid;
-(void)clearErrorForField:(FormField)field;
@property(nonatomic, strong, readonly)NSMutableArray *errors;

@property(nonatomic,strong )CLLocation *geo;

@property(nonatomic, strong)NSString *addresss;
@property(nonatomic, strong)NSString *neighborhood;

@property(nonatomic, strong)NSNumber *monthlyCost;
@property(nonatomic, strong)NSNumber *moveInCost;
@property(nonatomic, strong)NSNumber *brokerfee;

@property(nonatomic, strong)NSDate   *moveInDate;
@property(nonatomic, strong)NSString *contact;
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

@property(nonatomic, strong)UIImage *thumb;
@property(nonatomic, strong)id       video;



@end
