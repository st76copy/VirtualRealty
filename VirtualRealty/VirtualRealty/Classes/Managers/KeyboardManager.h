//
//  KeyboardManager.h
//  Contributor
//
//  Created by Chris on 9/19/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KeyboardManagerDelegate <NSObject>

-(void)keyboardWillShow;
-(void)keyboardWillHide;

@end

@interface KeyboardManager : NSObject

+(KeyboardManager *)sharedManager;

-(BOOL)isShowing;
-(void)close;
-(void)showWithFocusField:(UITextField *)field;
-(void)registerDelegate:( id<KeyboardManagerDelegate> )object;
-(void)unregisterDelegate:( id<KeyboardManagerDelegate> )object;
-(void)handleKeyboardWillShow:(NSNotification *)note;
-(void)handleKeyboardWillHide:(NSNotification *)note;

@property(nonatomic, assign, readonly)float                 animationTime;
@property(nonatomic, assign, readonly)UIViewAnimationCurve  animationCurve;

@property(nonatomic, assign, readonly)CGRect          keyboardFrame;
@property(nonatomic, assign, readonly)BOOL            isShowing;
@property(nonatomic, strong)UITextField              *textfieldInFocus;
@property(nonatomic, strong, readonly)NSHashTable    *delegates;

@end
