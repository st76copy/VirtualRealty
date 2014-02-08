//
//  PickerInputCell.h
//  VirtualRealty
//
//  Created by christopher shanley on 12/8/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "TextCell.h"

@interface PickerInputCell : TextCell
@property(nonatomic, strong)NSNumber     *pickerFontSize;
@property(nonatomic, strong)UIPickerView *picker;
@property(nonatomic, strong)NSArray      *pickerData;
@property(strong, nonatomic)UIView       *stroke;
@property(strong, nonatomic)UIView       *topStroke;
@end
