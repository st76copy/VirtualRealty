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
        _delegates = [NSHashTable weakObjectsHashTable];
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
    [self.textfieldInFocus setUserInteractionEnabled:NO];
    _textfieldInFocus = nil;
    _isShowing = NO;
}

-(void)showWithFocusField:(UITextField *)field
{
    if( _isShowing == NO )
    {
        _textfieldInFocus = field;
        _isShowing = YES;
   
        if( [field isFirstResponder] == NO )
        {
            [self.textfieldInFocus becomeFirstResponder];
        }
    }
    else
    {
        if( [field isFirstResponder] == NO )
        {
            [field becomeFirstResponder];
        }
        _textfieldInFocus.userInteractionEnabled = NO;
        _textfieldInFocus = field;
    }
}

-(void)setTextfieldInFocus:(UITextField *)textfieldInFocus
{
    _isShowing = (textfieldInFocus) ? YES : NO;
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
