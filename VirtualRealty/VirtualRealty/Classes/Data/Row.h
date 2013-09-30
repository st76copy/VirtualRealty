//
//  Row.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/16/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Row : NSObject

-(id)initWithInfo:(NSDictionary *)info;

@property(nonatomic, assign)          BOOL          visible;
@property(nonatomic, assign, readonly)BOOL          animatable;
@property(nonatomic, strong, readonly)NSDictionary *info;
@property(nonatomic, assign)SectionState            state;


@end
