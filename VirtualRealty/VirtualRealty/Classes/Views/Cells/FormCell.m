//
//  FormCell.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "FormCell.h"

@implementation FormCell

@synthesize formDelegate;
@synthesize formValue;
@synthesize errorView = _errorView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _errorView = [[UIView alloc]initWithFrame:CGRectZero];
        [self.errorView setBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.4]];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.errorView.frame = self.contentView.frame;
}
-(void)setFocus
{
    
}

-(void)killFocus
{
    
}

-(void)showError
{
    [self.contentView addSubview:self.errorView];
    [self.contentView sendSubviewToBack:self.errorView];
}

-(void)clearError
{
    if( [self.contentView.subviews containsObject:self.errorView] )
    {
        [self.errorView removeFromSuperview];
    }
}
@end
