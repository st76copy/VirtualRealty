//
//  NSData+Additions.h
//  WheresTheParty
//
//  Created by Dave on 09/03/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

// Methods added to NSData for use by NSString+additions (used by Twitter classes)
@interface NSData(Additions)

+ (NSData *) dataWithBase64EncodedString:(NSString *) string;
- (id) initWithBase64EncodedString:(NSString *) string;

- (NSString *) base64Encoding;
- (NSString *) base64EncodingWithLineLength:(unsigned int) lineLength;

- (BOOL) hasPrefix:(NSData *) prefix;
- (BOOL) hasPrefixBytes:(void *) prefix length:(unsigned int) length;

- (NSData *) encryptWithKey:(NSData *) aSymmetricKey;
- (NSData *) decryptWithKey:(NSData *) aSymmetricKey;

- (NSData *) doCipherWithKey:(NSData *) symmetricKey context:(CCOperation) encryptOrDecrypt;

@end
