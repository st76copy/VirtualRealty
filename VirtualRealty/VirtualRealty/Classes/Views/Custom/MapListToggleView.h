//
//  MapListToggleView.h
//  VirtualRealty
//
//  Created by christopher shanley on 11/26/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ToggleDelegate <NSObject>

-(void)viewStateRequestChange:(ListingViewingState)state;

@end

@interface MapListToggleView : UIView

@property(nonatomic, weak)id<ToggleDelegate>   delegate;
@property(nonatomic, strong, readonly)UIButton *listButton;
@property(nonatomic, strong, readonly)UIButton *mapButton;
@property(nonatomic, assign, readonly)ListingViewingState state;
-(void)handleButtonTouched:(id)sender;


@end
