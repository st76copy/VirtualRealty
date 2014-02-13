//
//  DatePickerCell.h
//  VirtualRealty
//
//  Created by christopher shanley on 2/8/14.
//  Copyright (c) 2014 virtualrealty. All rights reserved.
//

#import "TextCell.h"
#import "DatePickerSource.h"
@interface DatePickerCell : TextCell

@property(nonatomic, strong)UIDatePicker *datePicker;

@property(nonatomic, strong)NSNumber     *pickerFontSize;
@property(nonatomic, strong)UIPickerView *picker;
@property(nonatomic, strong)NSArray      *pickerData;
@property(nonatomic, strong)DatePickerSource *dataSource;
@end
