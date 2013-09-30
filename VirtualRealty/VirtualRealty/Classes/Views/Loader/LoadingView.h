//
//  LoadingView.h
//  Contributor
//
//  Created by Chris on 8/19/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView

-(void)show;
-(void)hide;

@property(nonatomic, strong, readonly)UIActivityIndicatorView *indicator;
@property(nonatomic, strong, readonly)UIView *activityBackground;

@end
