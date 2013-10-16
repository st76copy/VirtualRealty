//
//  DateCell.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/28/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "DateCell.h"
#import "NSDate+Extended.h"
@implementation DateCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if( self != nil )
    {
        
    }
    return  self;
}

-(void)render
{
    
    self.backgroundView       = nil;
    self.textLabel.text       = [self.cellinfo valueForKey:@"label"];
    self.detailTextLabel.text = [[self.cellinfo valueForKey:@"current-value"]toShortString];
    [self.detailTextLabel sizeToFit];
}
@end
