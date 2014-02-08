
//
//  MapCell.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/16/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "MapCell.h"
#import "UIColor+Extended.h"
#import "KeyboardManager.h"

@interface MapCell()
-(void)textFieldChanged:(id)sender;
@end


@implementation MapCell

@synthesize map = _map;
@synthesize textBackGround = _textBackGround;
@synthesize addresssLabel  = _addresssLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        _map = [[GMSMapView alloc]initWithFrame:CGRectZero];
        [self.map setUserInteractionEnabled:NO];
        [self.contentView addSubview:self.map];
        [self.map setHidden:YES];
        
        
        _textBackGround = [[UIView alloc]initWithFrame:CGRectZero];
        [self.textBackGround setBackgroundColor:[UIColor whiteColor]];
        [self.textBackGround setAlpha:0.6f];
        [self.contentView addSubview:self.textBackGround];
        
        _addresssLabel = [[UITextField alloc]initWithFrame:CGRectZero];
        [self.addresssLabel setTextColor:[UIColor colorFromHex:@"434343"]];
        [self.addresssLabel setBackgroundColor:[UIColor clearColor ]];
        [self.addresssLabel setAdjustsFontSizeToFitWidth:YES];
        [self.addresssLabel setText:@"Loading Address"];
        [self.addresssLabel setFont:[UIFont systemFontOfSize    :17]];
        [self.addresssLabel setPlaceholder:@"address"];
        [self.addresssLabel addTarget:self  action:@selector(textFieldFinished:)  forControlEvents:UIControlEventEditingDidBegin];
        [self.addresssLabel addTarget:self  action:@selector(textFieldFinished:)  forControlEvents:UIControlEventEditingDidEndOnExit];
        [self.addresssLabel addTarget:self  action:@selector(textFieldChanged:)  forControlEvents:UIControlEventEditingChanged];
        
        
        [self.contentView addSubview:self.addresssLabel];
        
        
        [[LocationManager shareManager]registerDelegate:self];

    }
    return self;
}

-(void) prepareForReuse
{
    [[LocationManager shareManager]removeDelegate:self];
    [super prepareForReuse];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.textBackGround.frame = CGRectMake(0, 0, 320, 38);
    self.addresssLabel.frame  = CGRectMake(15, 0, 320, 38);
}

-(void)locationUpdated
{
    if( [LocationManager shareManager].currentAddress != nil )
    {
        NSDictionary *address = [LocationManager shareManager].addressInfo;
        NSDictionary *info = @{
            @"city" : address[@"City"],
            @"street" : address[@"FormattedAddressLines"][0],
            @"borough" : [(NSString *)address[@"FormattedAddressLines"][1] componentsSeparatedByString:@","][0],
            @"neighborhood" : address[@"SubLocality"],
            @"zip" : address[@"ZIP"],
            @"state" : address[@"State"]
        };
        
        NSString *addressString = [NSString stringWithFormat:@"%@\n%@, %@ %@", info[@"street"],info[@"borough"],info[@"state"],info[@"zip"]];
        self.addresssLabel.text = addressString;
        
        NSLog(@"%@ ", addressString);
        [[LocationManager shareManager]removeDelegate:self];
        self.formValue = @{@"address" :[LocationManager shareManager].currentAddress, @"location" :[LocationManager shareManager].location, @"details" : info  };
        
        [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"geo"]intValue]];
        [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue]];
    }
}

-(void)handleWrongAddresss:(id)sender
{
    NSDictionary *params =@{NSForegroundColorAttributeName: [UIColor colorFromHex:@"CCCCCC"]};
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:@"enter address" attributes:params];
    [self.addresssLabel setReturnKeyType:UIReturnKeyDone];
    [self.addresssLabel setEnabled:YES];
    [self.addresssLabel setText:@""];
    [self.addresssLabel setPlaceholder:@"enter address"];
    [self.addresssLabel setAttributedPlaceholder:string];
    [self.addresssLabel becomeFirstResponder];

}


-(void)inputFieldBegan:(id)sender
{
    if( self.selected )
    {
        return;
    }
    
    if([self.formDelegate respondsToSelector:@selector(cell:didStartInteract:)] )
    {
        [[KeyboardManager sharedManager]showWithFocusField:self.addresssLabel];
        [self.formDelegate cell:self didStartInteract:[[self.cellinfo valueForKey:@"field"]intValue]];
    }
}


-(void)textFieldChanged:(id)sender
{
    [super clearError];
    __block MapCell *blockself = self;
    
    [[LocationManager shareManager]setCurrentLocationByString:self.addresssLabel.text block:^(CLLocationCoordinate2D loc)
    {
        NSDictionary *address = [LocationManager shareManager].addressInfo;
        self.formValue = @{@"address" :[LocationManager shareManager].currentAddress, @"location" :[LocationManager shareManager].location, @"details" :  address };
        [blockself.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue]];
    }];

    [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue] ];
}

-(void)textFieldFinished:(id)sender
{
    __block MapCell *blockself = self;
    
    [[LocationManager shareManager]setCurrentLocationByString:self.addresssLabel.text block:^(CLLocationCoordinate2D loc)
    {
        blockself.formValue = @{@"address" :[LocationManager shareManager].currentAddress, @"location" :[LocationManager shareManager].location  };
        [blockself.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue]];
    }];
}

-(void)render
{
    __block MapCell *blockself = self;
    
    if( [self.cellinfo valueForKey:@"current-value"] )
    {
        self.addresssLabel.text = [[self.cellinfo valueForKey:@"current-value"] valueForKey:@"address"];
    }
    else
    {
        [[LocationManager shareManager]startGettingLocations];
        
        if( [self.cellinfo valueForKey:@"current-value"] )
        {
            [[LocationManager shareManager]removeDelegate:self];
            [[LocationManager shareManager]setCurrentLocationByString:[[self.cellinfo valueForKey:@"current-value"] valueForKey:@"address"] block:^(CLLocationCoordinate2D loc)
             {
                 NSDictionary *address = [LocationManager shareManager].addressInfo;
                 NSDictionary *info = @{@"city" : address[@"City"],
                                        @"street" : address[@"FormattedAddressLines"][0],
                                        @"borough" : [(NSString *)address[@"FormattedAddressLines"][1] componentsSeparatedByString:@","][0],
                                        @"neighborhood" : address[@"SubLocality"],
                                        @"zip" : address[@"ZIP"],
                                        @"state" : address[@"State"]
                                        };
                 
                 NSString *addressString = [NSString stringWithFormat:@"%@\n%@,%@ %@", info[@"street"],info[@"borough"],info[@"state"],info[@"zip"]];
                 self.addresssLabel.text = addressString;
                 
                 if( self.formDelegate )
                 {
                     [blockself.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue]];
                     [blockself.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"geo"]intValue]];
                 }
             }];
        }
        
        if( [[self.cellinfo valueForKey:@"read-only"] boolValue ] )
        {
            [self.contentView setUserInteractionEnabled:NO];
            [self.map setUserInteractionEnabled:NO];
        }
    }
}

-(void)locationFailed
{
    
}

@end
