//
//  PickerManager.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/20/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "PickerManager.h"
@interface PickerManager()

-(void)changeDateInLabel:(id)sender;
-(void)doneTouched:(id)sender;
-(void)cancelTouched:(id)sender;
@end;


@implementation PickerManager

@synthesize container      = _container;
@synthesize datePicker     = _datePicker;
@synthesize type           = _type;
@synthesize standardPicker = _standardPicker;
@synthesize pickerData     = _pickerData;;
@synthesize isShowing      = _isShowing;

+(PickerManager *)sharedManager
{
    static PickerManager   *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        instance = [[PickerManager alloc]init];
    });
    return instance;
}

-(id)init
{
    self = [super init];
    if( self != nil )
    {
        _delegates = [NSHashTable weakObjectsHashTable  ];
        _container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 294)];
        [self.container setBackgroundColor:[UIColor whiteColor]];
        UINavigationBar *bar = [[UINavigationBar alloc]  initWithFrame:CGRectMake(0, 0, 320, 44)];
        [bar setTranslucent:NO];
        
        UIButton    *done = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [done setTitle:@"Done" forState:UIControlStateNormal];
        [done.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-300" size:17]];
        [done setTintColor:[UIColor whiteColor]];
        [done sizeToFit];
        [done addTarget:self action:@selector(doneTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton    *cancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(cancelTouched:) forControlEvents:UIControlEventTouchUpInside];
        [cancel.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-300" size:17]];
        [cancel setTintColor:[UIColor whiteColor]];
        [cancel sizeToFit];
        
        [self.container addSubview:bar];
        
        CGRect rect = done.frame;
        rect.origin.x = bar.frame.size.width - ( done.frame.size.width + 5 );
        rect.origin.y = bar.frame.size.height * 0.5 - done.frame.size.height * 0.5;
        done.frame = rect;
        [self.container addSubview:done];
        
        rect = cancel.frame;
        rect.origin.x = 5;
        rect.origin.y = bar.frame.size.height * 0.5 - done.frame.size.height * 0.5;
        cancel.frame = rect;
        [self.container addSubview:cancel];
        
        _datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 44, 320, 250)];
        _standardPicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 44, 320, 250)];
    
        self.datePicker.datePickerMode = UIDatePickerModeDate;
        
        [self.container addSubview:_datePicker];
        [self.container addSubview:_standardPicker];
        [self.container sendSubviewToBack:self.standardPicker];
        [self.standardPicker setHidden:YES];
        [self.standardPicker setUserInteractionEnabled:NO];
        self.type = kDate;
    }
    return self;
}

-(void)setPickerData:(NSArray *)pickerData
{
    _pickerData = pickerData;
    if( self.type == kStandard )
    {
        [self.standardPicker reloadAllComponents];
    }
}

-(void)setType:(PickerType)value
{
    if( self.type != value )
    {
        _type = value;
        switch (self.type)
        {
            case kDate:
                
                [self.standardPicker setHidden:YES];
                [self.standardPicker setUserInteractionEnabled:NO];
                [self.standardPicker setDelegate:nil];
                [self.standardPicker setDataSource:nil];
                [self.standardPicker reloadAllComponents];
                
                [self.container bringSubviewToFront:self.datePicker];
                [self.datePicker setHidden:NO];
                [self.datePicker setUserInteractionEnabled:YES];
                [_datePicker addTarget:self action:@selector(changeDateInLabel:) forControlEvents:UIControlEventValueChanged];
               
                break;
                
            case kStandard:

                [self.datePicker setHidden:YES];
                [self.datePicker setUserInteractionEnabled:NO];
                
                [self.container bringSubviewToFront:self.standardPicker];
                [self.standardPicker setHidden:NO];
                [self.standardPicker setUserInteractionEnabled:YES];
                [self.standardPicker setDataSource:self];
                [self.standardPicker setDelegate:self];
                [self.standardPicker reloadAllComponents];
                break;
        }
    }
}


-(void)showPickerInView:(UIView *)view
{
    if( _isShowing == NO )
    {
        _isShowing = YES;
        [self.container removeFromSuperview];
        
        CGRect rect = self.container.frame;
        rect.origin.y = view.frame.size.height;
        rect.origin.x = 0;
        self.container.frame = rect;
        
        rect.origin.y = view.frame.size.height - rect.size.height;
        
        [UIView animateWithDuration:0.4 animations:^{
            self.container.frame = rect;
        }];
        
        [view addSubview:self.container];
        
        for( id<PickerManagerDelegate> obj in self.delegates )
        {
            [obj pickerWillShow];
        }
    }
    else
    {
        if( self.type == kStandard )
        {
            [self.standardPicker reloadAllComponents];
        }
    }
}

-(void)hidePicker
{
    if( self.isShowing )
    {
        CGRect rect = self.container.frame;
        rect.origin.y = [self.container superview].frame.size.height;
        
        [UIView animateWithDuration:0.4 animations:^{
            [self.container setFrame:rect ];
        }completion:^(BOOL finished) {
            [self.container removeFromSuperview];
        }];
        
        for( id<PickerManagerDelegate> obj in self.delegates )
        {
            [obj pickerWillHide];
        }
        _isShowing = NO;
    }
}

-(void)registerDelegate:( id<PickerManagerDelegate> )object
{
    if( [self.delegates containsObject:object ] == NO)
    {
        [self.delegates addObject:object];
    }
}

-(void)unregisterDelegate:( id<PickerManagerDelegate> )object
{
    [self.delegates removeObject:object];
}

#pragma mark - delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.pickerData.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *comp = [self.pickerData objectAtIndex:component];
    return comp[row][@"label"];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *comp = [self.pickerData objectAtIndex:component];
    return comp.count;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

-(id)valueForComponent:(int)compIndex
{
    int rowIndex  = [self.standardPicker selectedRowInComponent:compIndex];
    NSDictionary *info = self.pickerData[compIndex][rowIndex];
    return info[@"value"];
}

#pragma mark - ui responders
-(void)changeDateInLabel:(id)sender
{
    
}

-(void)doneTouched:(id)sender
{
    for( id<PickerManagerDelegate> obj in self.delegates )
    {
        [obj pickerDone];
    }
}

-(void)cancelTouched:(id)sender
{
    [self hidePicker];
}

@end
