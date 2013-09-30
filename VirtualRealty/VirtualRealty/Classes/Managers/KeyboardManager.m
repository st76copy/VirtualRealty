//
//  KeyboardManager.m
//  Contributor
//
//  Created by Chris on 9/19/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import "KeyboardManager.h"

@implementation KeyboardManager

@synthesize isShowing        = _isShowing;
@synthesize delegates        = _delegates;
@synthesize textfieldInFocus = _textfieldInFocus;
@synthesize keyboardFrame    = _keyboardFrame;
@synthesize animationCurve   = _animationCurve;
@synthesize animationTime    = _animationTime;

+(KeyboardManager *)sharedManager
{
    static KeyboardManager *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
    {
        instance = [[KeyboardManager alloc]init];
    });
    
    return instance;
}

-(id)init
{
    self = [super init];
    if( self !=  nil )
    {
        _delegates = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

-(void)close
{
    if ( _isShowing == NO)
    {
        return;
    }
    
    [self.textfieldInFocus resignFirstResponder];
    self.textfieldInFocus = nil;
    _isShowing = NO;
}

-(void)showWithFocusField:(UITextField *)field
{
    self.textfieldInFocus = field;
    _isShowing = YES;
    [self.textfieldInFocus becomeFirstResponder];
}

-(void)setTextfieldInFocus:(UITextField *)textfieldInFocus
{
    _isShowing = YES;
    _textfieldInFocus = textfieldInFocus;
}

-(void)registerDelegate:( id<KeyboardManagerDelegate> )object
{
    if( [self.delegates containsObject:object ] == NO)
    {
        [self.delegates addObject:object];
    }
}

-(void)unregisterDelegate:( id<KeyboardManagerDelegate> )object
{
    [self.delegates removeObject:object];
}

-(void)handleKeyboardWillShow:(NSNotification *)note;
{
    NSDictionary *userinfo = note.userInfo;
    _keyboardFrame  = [[userinfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _animationTime  = [[userinfo valueForKey:UIKeyboardAnimationDurationUserInfoKey]floatValue];
    _animationCurve = [[userinfo valueForKey:UIKeyboardAnimationCurveUserInfoKey]intValue];
    
    for( id<KeyboardManagerDelegate> obj in self.delegates )
    {
        [obj keyboardWillShow];
    }
}

-(void)handleKeyboardWillHide:(NSNotification *)note
{
    for( id<KeyboardManagerDelegate> obj in self.delegates )
    {
        [obj keyboardWillHide];
    }
    _keyboardFrame = CGRectZero;

}

@end
