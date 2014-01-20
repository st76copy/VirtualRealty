//
//  SSIErrorFactory.h
//  shutterstock-ios
//
//  Created by Chris on 6/25/13.
//
//

#import <Foundation/Foundation.h>

typedef enum ErrorType
{
    // system error
    kDatabaseFailedToLoadError,
    
    // reachable error
    kNotReachableOnLogIn,
    kNotReachable,
    
    // user error
    kUserLoginFailError,
    kUserDataLoaderror,
    kUserAddressNotSupported,
    
    // data errors
    kListingExistsError,
    kListingPendingError,
    kListingMediaError,
    kListingSavingError,
    kListingGPSError,
    kServerError,
    // form errors
    kNoResultsError,
    //media errors,
    kMediaNotAvailableError,
    
    kInvalidUsernameError,
    kInvalidPasswordError,
    kNotValidBrokerListing
}ErrorType;


@interface ErrorFactory : NSObject

+(UIAlertView *)getAlertForType:(ErrorType)type andDelegateOrNil:(id<UIAlertViewDelegate>)delegate andOtherButtons:(NSArray *)otherButtons;
+(UIAlertView *)getAlertCustomMessage:(NSString *)error andDelegateOrNil:(id<UIAlertViewDelegate>)delegate andOtherButtons:(NSArray *)otherButtons;

@end
