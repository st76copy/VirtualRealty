//
//  LoadingView.m
//  Contributor
//
//  Created by Chris on 8/19/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LoadingView

@synthesize activityBackground = _activityBackground, indicator = _indicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        _activityBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 80)];
        _activityBackground.center = self.center;
        _activityBackground.layer.masksToBounds = YES;
        _activityBackground.layer.cornerRadius  = 10.0f;
        
        [self.activityBackground setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9 ]];
        
        UILabel *loadingLable = [[UILabel alloc]initWithFrame:CGRectZero];
        [loadingLable setText:NSLocalizedString(@"Loading", @"Genereic : Loading text for loading view")];
        [loadingLable setBackgroundColor:[UIColor clearColor ]];
        [loadingLable sizeToFit];
        [loadingLable setTextColor:[UIColor whiteColor]];
        
        CGRect rect = loadingLable.frame;
        rect.origin.x = _activityBackground.frame.size.width * 0.5 - loadingLable.frame.size.width * 0.5;
        rect.origin.y = 5;
        loadingLable.frame = CGRectIntegral(rect);
        
        [self.activityBackground addSubview:loadingLable];
        
        
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicator.contentMode = UIViewContentModeCenter;
        _indicator.frame  = CGRectMake(self.activityBackground.frame.size.width * 0.5 - 10, (self.activityBackground.frame.size.height * 0.5 - 10) + 8, 20, 20);
        
        [self.activityBackground addSubview:self.indicator];
        
        [self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
        [self addSubview:_activityBackground];
    }
    return self;
}

-(void)show
{
    [self.indicator startAnimating];
    [self.indicator setHidden:NO];
    self.alpha = 0;
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 1.0;
    }];
}

-(void)hide
{
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self.indicator stopAnimating];
        [self removeFromSuperview];
    }];
}


@end
