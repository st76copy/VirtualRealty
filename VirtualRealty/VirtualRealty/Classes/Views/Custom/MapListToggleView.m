//
//  MapListToggleView.m
//  VirtualRealty
//
//  Created by christopher shanley on 11/26/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "MapListToggleView.h"
#import "UIColor+Extended.h"
@implementation MapListToggleView


@synthesize listButton = _listButton;
@synthesize state      = _state;
@synthesize mapButton  = _mapButton;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.frame = CGRectMake(0, 0, 320, 44);
    
        _listButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_listButton.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-300" size:15]];
        [_listButton setTitle:@"List" forState:UIControlStateNormal];
        [_listButton setTitleColor:[UIColor colorFromHex:@"ffffff"] forState:UIControlStateNormal];
        [_listButton setBackgroundColor:[UIColor colorFromHex:@"d56d14"]];
        [_listButton setFrame:CGRectMake(0, 0, 160, 44)];
        [_listButton setTag:0];
        
        [_listButton addTarget:self action:@selector(handleButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        _mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_mapButton.titleLabel setFont:[UIFont fontWithName:@"MuseoSans-300" size:15]];
        
        [_mapButton setTitle:@"Map" forState:UIControlStateNormal];
        [_mapButton setTitleColor:[UIColor colorFromHex:@"787878"] forState:UIControlStateNormal];
        [_mapButton setFrame:CGRectMake(160, 0, 160, 44)];
        [_mapButton addTarget:self action:@selector(handleButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [_mapButton setBackgroundColor:[UIColor colorFromHex:@"e6e6e6"]];
        [_mapButton setTag:1];
        
        
        [self addSubview:self.listButton];
        [self addSubview:self.mapButton];
        
    }
    return self;
}

-(void)handleButtonTouched:(id)sender
{
    UIButton *ref = (UIButton*)sender;
    
    switch (ref.tag)
    {
        case 0:
        {
            _state = kList;
            [UIView animateWithDuration:0.2 animations:^{
                [_listButton setTitleColor:[UIColor colorFromHex:@"ffffff"] forState:UIControlStateNormal];
                [_listButton setBackgroundColor:[UIColor colorFromHex:@"d56d14"]];
                
                [_mapButton setTitleColor:[UIColor colorFromHex:@"787878"] forState:UIControlStateNormal];
                [_mapButton setBackgroundColor:[UIColor colorFromHex:@"e6e6e6"]];
                
            }];
        }
        break;
        case 1:
        {
            _state = kMap;
            [UIView animateWithDuration:0.2 animations:^{
                
                [_listButton setTitleColor:[UIColor colorFromHex:@"787878"] forState:UIControlStateNormal];
                [_listButton setBackgroundColor:[UIColor colorFromHex:@"e6e6e6"]];
                
                [_mapButton setTitleColor:[UIColor colorFromHex:@"ffffff"] forState:UIControlStateNormal];
                [_mapButton setBackgroundColor:[UIColor colorFromHex:@"d56d14"]];
                

            }];
        }
        break;
    }
    [delegate viewStateRequestChange:self.state];
}
@end
