//
//  KeywordsViewController.h
//  VirtualRealty
//
//  Created by christopher shanley on 10/19/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeywordsViewController;
@protocol KeyWordDelegate <NSObject>

-(void)keywordsDone:(KeywordsViewController *)vc;

@end
@interface KeywordsViewController : UIViewController

-(id)initWithWords:(NSMutableArray *)array;


@property(nonatomic, strong, readonly)NSMutableArray  *views;
@property(nonatomic, weak)id<KeyWordDelegate>         delegate;
@property(nonatomic, strong, readonly)NSMutableArray  *words;

@end
