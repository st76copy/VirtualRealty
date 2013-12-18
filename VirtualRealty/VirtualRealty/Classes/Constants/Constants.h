//
//  Constants.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#ifndef VirtualRealty_Constants_h
#define VirtualRealty_Constants_h

#define kMaxRecentListings 20

#define kUSERNAME_KEY @"username-key"
#define kUID_KEY      @"uid-key"

#define kLOGIN_NOTIFICATION_NAME  @"login-notification-name"
#define kLOGOUT_NOTIFICATION_NAME @"logout-notification-name"
#define kGOOGLE_PLACES_KEY @"AIzaSyBklCiCoqPMyS84Bd2Zn4PxUFl8wIpHXQQ"

#pragma mark - Build device
typedef enum DeviceType
{
    kiPhone,
    kiPad,
    kiPodTouch
}DeviceType;

#pragma mark - Build Config
typedef enum BuildEnvironment
{
    kDebug,
    kDebugNoServer,
    kAdHocDev,
    kAdHocQA,
    kRelease
}BuildEnvironment;

typedef enum
{
    kUserValid,
    kUserExpired,
    kNoUser
}UserState;

typedef enum LoginFormState
{
    kLogin,
    kSignup
}LoginFormState;



typedef enum FormField
{
    kEmail = 0,
    kPassword = 1,
    
    kAddress = 2,
    kUnit  = 21,
    kNeightborhood = 3,
    
    kMonthlyRent = 4,
    kMoveInCost = 5,
    kBrokerFee = 6,
    
    
    kBedrooms = 7,
    kBathrooms = 8,
    kMoveInDate = 19,
    kContactEmail = 20,
    kContactPhone = 44,
    
    kStreet = 45,
    kBorough = 46,
    kZip = 47,
    kCity = 48,
    kState = 49,
  
    
    kShare = 9,
    kDogs = 10,
    kCats = 11,
    
    kOutdoorSpace = 12,
    kWasherDryer = 13,
    kDoorMan = 14,
    kGym = 15,
    kPool= 16,
    kVideo = 17,
    kThumbnail = 18,
    kKeywords  = 37,
    kGeo       = 38,

    
    // search filters
    kNeightborhoodFilter = 22,
    kMinCostFilter       = 23,
    kMaxCostFilter       = 24,
    kBrokerFeeFilter     = 25,
    kBedroomsFilter      = 26,
    kBathroomsFilter     = 27,
    kShareFilter         = 28,
    kDogsFilter          = 29,
    kCatsFilter          = 30,
    kMoveInFilter        = 31,
    kOutdoorSpaceFilter  = 32,
    kWasherDryerFilter   = 33,
    kDoormanFilter       = 34,
    kGymFilter           = 35,
    kPoolFilter          = 36,
    kBoroughFilter       = 50,
    
    // login extended
    kUserActivelyLooking = 39,
    kUserMovinDate       = 40,
    kUserMaxRent         = 41,
    kUserMinBedrooms     = 42,
    
    kSocial     = 43,
    kSearchRadius = 51
 
}FormField;

typedef enum SectionState
{
    kContracted,
    kExpanded
}SectionState;

typedef enum SettingsField
{
    kUser
}SettingsField;

typedef enum PickerType
{
    kStandard,
    kDate
}PickerType;

typedef enum
{
    kPending,
    kVacant,
    kRented
}ListingState;

typedef enum
{
    kListingExist,
    kSaveFailed,
    kSaveSuccess
}ServerError;

typedef enum
{
    kMap,
    kList
}ListingViewingState;

#define kFACEBOOK_USER @"facebook-user"

#endif
