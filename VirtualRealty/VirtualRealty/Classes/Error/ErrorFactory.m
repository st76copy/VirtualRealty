//
//  SSIErrorFactory.m
//  shutterstock-ios
//
//  Created by Chris on 6/25/13.
//
//

#import "ErrorFactory.h"

@implementation ErrorFactory


+(UIAlertView *)getAlertForType:(ErrorType)type andDelegateOrNil:(id<UIAlertViewDelegate>)delegate andOtherButtons:(NSArray *)otherButtons
{
    NSString       *title        = nil;
    NSString       *message      = nil;
    NSString       *cancelTitle  = nil;
    UIAlertView    *alertView    = nil;
    
    
    switch ( type )
    {
            
        case kDatabaseFailedToLoadError:
            break;
        case kUserDataLoaderror:
            break;
        case kUserLoginFailError:
            title       = NSLocalizedString(@"Sorry", @"Error : Invalid password error title");
            message     = NSLocalizedString(@"There was a problem logging in please check your username and password", @"Error : Invalid password error body");
            cancelTitle = NSLocalizedString(@"Ok", @"Genereic : Ok ");
            
            break;
       break;
        
        // reachable error
        case kNotReachableOnLogIn :
            title       = NSLocalizedString(@"Sorry", @"Error : Invalid password error title");
            message     = NSLocalizedString(@"There was a problem logging in please check your internet connection", @"Error : not reachable when login");
            cancelTitle = NSLocalizedString(@"Ok", @"Genereic : Ok ");

            break;
            
        // form errors
        case kInvalidPasswordError:
            title       = NSLocalizedString(@"Sorry", @"Error : Invalid password error title");
            message     = NSLocalizedString(@"Your password is invalid", @"Error : Invalid password error body");
            cancelTitle = NSLocalizedString(@"Cancel", @"Genereic : Cancel ");
            break;
        case kInvalidUsernameError:
            title       = NSLocalizedString(@"Sorry", @"Error : Invalid username error title");
            message     = NSLocalizedString(@"Your username is invalid", @"Error : Invalid username error body");
            cancelTitle = NSLocalizedString(@"Cancel", @"Genereic : Cancel ");
            break;
            
        case kListingExistsError:
            title       = NSLocalizedString(@"Sorry", @"Error : Invalid username error title");
            message     = NSLocalizedString(@"Your listing already exists", @"Error : Invalid listing error body");
            cancelTitle = NSLocalizedString(@"Cancel", @"Genereic : Cancel ");
            break;

        case kListingPendingError:
            title       = NSLocalizedString(@"Success", @"Error : Invalid username error title");
            message     = NSLocalizedString(@"You listing has been sent to a content moderator for approval.", @"Error : Invalid listing error body");
            cancelTitle = NSLocalizedString(@"OK", @"Genereic : Cancel ");
            break;

        case  kMediaNotAvailableError :
            title       = NSLocalizedString(@"Sorry", @"Error : Generic sorry");
            message     = NSLocalizedString(@"The media for this listing is not available", @"Error : No media body");
            cancelTitle = NSLocalizedString(@"OK", @"Genereic : Cancel ");
            
            break;

    }
    
    alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:nil];

    if( otherButtons )
    {
        for( NSString *title in otherButtons)
        {
            [alertView addButtonWithTitle:title];
        }
    }
    
    return alertView;
}

+(UIAlertView *)getAlertCustomMessage:(NSString *)error andDelegateOrNil:(id<UIAlertViewDelegate>)delegate andOtherButtons:(NSArray *)otherButtons
{
    
    NSString       *title        = @"Sorry";
    NSString       *message      = error;
    NSString       *cancelTitle  = @"OK";
    UIAlertView    *alertView    = nil;
    

    alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelTitle otherButtonTitles:nil];
    
    if( otherButtons )
    {
        for( NSString *title in otherButtons)
        {
            [alertView addButtonWithTitle:title];
        }
    }
    
    return alertView;

}

@end
