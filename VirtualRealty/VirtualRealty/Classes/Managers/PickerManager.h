
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
@property(nonatomic, strong, readonly)NSArray        *pickerData;
@property(nonatomic, strong, readonly)NSMutableArray *delegates;
@property(nonatomic, assign, readonly)BOOL          isShowing;

@property(nonatomic, assign)PickerType    type;

-(void)showPickerInView:(UIView *)view;
-(void)hidePicker;
-(void)registerDelegate:( id<PickerManagerDelegate> )object;
-(void)unregisterDelegate:( id<PickerManagerDelegate> )object;
@end
