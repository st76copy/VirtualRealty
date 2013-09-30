//
//  FormCell.h
//  VirtualRealty
//
//  Created by chrisshanley on 9/14/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "AbstractCell.h"

@class FormCell;
@protocol FormCellDelegate <NSObject>

-(void)cell:(FormCell *)cell didChangeForField:(FormField)field;
@optional
-(void)cell:(FormCell *)cell didStartInteract:(FormField)field;
-(void)cell:(FormCell *)cell didPressDone:(FormField)field;

@end

@interface FormCell : AbstractCell
@property(nonatomic, weak)id<FormCellDelegate> formDelegate;
@property(nonatomic, strong)id formValue;
@property(nonatomic, strong)UIView *errorView;
-(void)setFocus;
-(void)killFocus;
-(void)showError;
-(void)clearError;
@end
