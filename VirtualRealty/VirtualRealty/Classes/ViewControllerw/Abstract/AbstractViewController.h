//
//  SSIAbstractViewController.h
//  Shutterstock
//
//  Created by Chris on 6/12/13.
//  Copyright (c) 2013 Chris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AbstractViewController : UIViewController
{
    BOOL active;
}

-(void)toggleMenu;
-(void)setActive:(BOOL)value;


@end
