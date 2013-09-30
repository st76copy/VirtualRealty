//
//  AbstractCell.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AbstractCell : UITableViewCell

@property(nonatomic, strong)NSDictionary *cellinfo;
@property(nonatomic, strong)NSIndexPath  *indexPath;
-(void)render;

@end
