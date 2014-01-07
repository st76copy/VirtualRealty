//
//  ListingStateView.h
//  VirtualRealty
//
//  Created by christopher shanley on 1/5/14.
//  Copyright (c) 2014 virtualrealty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListingStateView : UIView

{
    NSString *stateName;
    UIColor  *color;
    UIImage  *wedge;
    
    UILabel  *label ;
    UIView   *bg ;
    UIImageView *imageView;
    
}
-(void) setState:(ListingState)state;
@end
