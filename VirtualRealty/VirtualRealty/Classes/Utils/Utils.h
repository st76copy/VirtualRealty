//
//  ShutterstockUtils.h
//  shutterstock-ios
//
//  Created by Chris on 3/27/13.
//
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject


/* METHOD : getCurrentBuildEnvironment
   returns the currentbuild configuration as a BuildEnvironment constant
   requires "configuration" plist setting
 
    key   : Configuration
    value : ${CONFIGURATION}
*/



+(BuildEnvironment)getCurrentBuildEnvironment;
+(UIImage *)resizeImage:(UIImage *)img toSize:(CGSize)size;
/* Short hand method for ducments directory */
+(NSString *)getDocsDirectory;

+(id) blockSafeInstanceOf:(id) _object;

+(DeviceType)getDevice;

+(NSString *)urlEncodeString:(NSString *)unencoded;

+(BOOL)isValidEmail:(NSString *)checkString;
+(BOOL)isValidPassword:(NSString *)checkString;
+(UIImage *)getIconForBusinessTypes:(NSArray *)value;
@end
