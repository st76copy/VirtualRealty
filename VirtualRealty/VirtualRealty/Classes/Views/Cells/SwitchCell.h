//
//  SwitchCell.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/19/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "FormCell.h"

@interface SwitchCell : FormCell
-(void)handleSwitchChanged:(id)sender;
@property(nonatomic, strong, readonly)UILabel  *stateLabel;
@property(nonatomic,strong,readonly)UISwitch *switchButton;
@end
