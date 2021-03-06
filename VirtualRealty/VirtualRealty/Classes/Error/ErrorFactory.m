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
        case kNotReachable :
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
            message     = NSLocalizedString(@"Your listing is already in our database, please contact admin to resolve the issue.", @"Error : Listing media failed error body");
            cancelTitle = NSLocalizedString(@"Cancel", @"Genereic : Cancel ");
            break;

        case kListingMediaError:
            title       = NSLocalizedString(@"Sorry", @"Error : Invalid username error title");
            message     = NSLocalizedString(@"Your listing already exists", @"Error : Invalid listing error body");
            cancelTitle = NSLocalizedString(@"Cancel", @"Genereic : Cancel ");
            break;
        case kListingSavingError:
            title       = NSLocalizedString(@"Sorry", @"Error : Invalid username error title");
            message     = NSLocalizedString(@"There was an error saving your listing. Please try again later or contact support", @"Error : Invalid listing error body");
            cancelTitle = NSLocalizedString(@"Cancel", @"Genereic : Cancel ");
            break;
        case kListingGPSError:
            title       = NSLocalizedString(@"Sorry", @"Error : Invalid username error title");
            message     = NSLocalizedString(@"We are having problems finding your locations, please enter it manually", @"Error : GPS not working error");
            cancelTitle = NSLocalizedString(@"OK", @"Genereic : Cancel ");
            break;
        case kNoResultsError:
            title       = NSLocalizedString(@"Sorry", @"Error : Invalid username error title");
            message     = NSLocalizedString(@"There are no results for your term, filters or radius, try adjusting the filters or radius in settings", @"Error : GPS not working error");
            cancelTitle = NSLocalizedString(@"OK", @"Genereic : Cancel ");
            break;
        case kServerError:
            title       = NSLocalizedString(@"Sorry", @"Error : Invalid username error title");
            message     = NSLocalizedString(@"There was a server error, please try again soon", @"Error : GPS not working error");
            cancelTitle = NSLocalizedString(@"OK", @"Genereic : Cancel ");
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
        case kUserAddressNotSupported :
            title       = NSLocalizedString(@"Sorry", @"Error : Generic sorry");
            message     = NSLocalizedString(@"We are only supporting listings in the New York City area at this time.", @"Error : No media body");
            cancelTitle = NSLocalizedString(@"OK", @"Genereic : Cancel ");
            
            break;

        case kNotValidBrokerListing :
            title       = NSLocalizedString(@"Sorry", @"Error : Generic sorry");
            message     = NSLocalizedString(@"We are only supporting listings in the New York City area at this time.", @"Error : No media body");
            cancelTitle = NSLocalizedString(@"OK", @"Genereic : Cancel ");
            
            break;

        case kUserDeniedLocationServices :
            title       = NSLocalizedString(@"Sorry", @"Error : Generic sorry");
            message     = NSLocalizedString(@"You have disabled location services for this app, please go to the Settings App -> Privacey -> Locations Services and enable it for VirtualRealty", @"Error : User killed location services");
            cancelTitle = NSLocalizedString(@"OK", @"Genereic : Cancel ");
            break;
        case kGPSFailed :
            title       = NSLocalizedString(@"Sorry", @"Error : Generic sorry");
            message     = NSLocalizedString(@"Your GPS seems to not be responding please try again later", @"Error : User killed location services");
            cancelTitle = NSLocalizedString(@"OK", @"Genereic : Cancel ");
            break;

        case kUserCantEditListing :
            title       = NSLocalizedString(@"Sorry", @"Error : Generic sorry");
            message     = NSLocalizedString(@"You can edit content for this listing once it has been approve.", @"Error : User killed location services");
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
