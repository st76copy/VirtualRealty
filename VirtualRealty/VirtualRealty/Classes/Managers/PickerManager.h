
@protocol PickerManagerDelegate <NSObject>
-(void)pickerWillShow;
-(void)pickerWillHide;
-(void)pickerDone;
@end

@interface PickerManager : NSObject<UIPickerViewDataSource, UIPickerViewDelegate>

+(PickerManager *)sharedManager;

@property(nonatomic, strong, readonly)UIView         *container;
@property(nonatomic, strong, readonly)UIDatePicker   *datePicker;
@property(nonatomic, strong, readonly)UIPickerView   *standardPicker;
@property(nonatomic, strong, readonly)NSHashTable    *delegates;
@property(nonatomic, assign, readonly)BOOL            isShowing;

@property(nonatomic, strong)NSArray      *pickerData;
@property(nonatomic, assign)PickerType    type;

-(id)valueForComponent:(int)compIndex;
-(void)showPickerInView:(UIView *)view;
-(void)hidePicker;
-(void)registerDelegate:( id<PickerManagerDelegate> )object;
-(void)unregisterDelegate:( id<PickerManagerDelegate> )object;
@end
