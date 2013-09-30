//
//  Section.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/16/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Section : NSObject

@property(nonatomic, assign)SectionState  state;
@property(nonatomic, strong, readonly)NSMutableArray *rows;
@property(nonatomic, strong, readonly)NSString       *title;

-(id)initWithTitle:(NSString *)title;
-(void)toggleRows;
-(int)animatableRows;
-(NSArray *)activeRows;


@end
