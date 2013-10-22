//
//  KeyWordsCell.m
//  VirtualRealty
//
//  Created by christopher shanley on 10/19/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "KeyWordsCell.h"

@implementation KeyWordsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self)
    {
    }
    return self;
}


-(void)render
{
    self.textLabel.text = [self.cellinfo valueForKey:@"label"];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if( [self.cellinfo valueForKey:@"current-value"] )
    {
        NSArray *temp = [self.cellinfo valueForKey:@"current-value"];
        self.detailTextLabel.text = [NSString stringWithFormat:@"%i keywords",temp.count];
    }
}

@end
