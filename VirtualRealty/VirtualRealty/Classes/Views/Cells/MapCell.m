//
//  MapCell.m
//  VirtualRealty
//
//  Created by chrisshanley on 9/16/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "MapCell.h"


@implementation MapCell

@synthesize map = _map;
@synthesize textBackGround = _textBackGround;
@synthesize addresssLabel  = _addresssLabel;
@synthesize wrongAddressButton = _wrongAddressButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        _map = [[MKMapView alloc]initWithFrame:CGRectZero];
        [self.contentView addSubview:self.map];
        
        _textBackGround = [[UIView alloc]initWithFrame:CGRectZero];
        [self.textBackGround setBackgroundColor:[UIColor blackColor]];
        [self.textBackGround setAlpha:0.6f];
        [self.contentView addSubview:self.textBackGround];
        
        _addresssLabel = [[UITextField alloc]initWithFrame:CGRectZero];
        [self.addresssLabel setTextColor:[UIColor whiteColor]];
        [self.addresssLabel setBackgroundColor:[UIColor clearColor ]];
        [self.addresssLabel setAdjustsFontSizeToFitWidth:YES];
        [self.addresssLabel setText:@"Loading Address"];
        [self.addresssLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [self.addresssLabel setEnabled:NO];
        [self.contentView addSubview:self.addresssLabel];
        
        _wrongAddressButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_wrongAddressButton setTitle:@"wrong address" forState:UIControlStateNormal];
        [_wrongAddressButton sizeToFit];
        [_wrongAddressButton addTarget:self action:@selector(handleWrongAddresss:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_wrongAddressButton];
        
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
    [self.map setFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height)];
    
    CGRect rect = self.map.bounds;
    rect.size.height = 50;
    rect.origin.y = self.map.frame.size.height - rect.size.height;
    self.textBackGround.frame = rect;
    
    self.addresssLabel.frame = self.textBackGround.frame;
}

-(void)locationUpdated
{
    if( [LocationManager shareManager].currentAddress != nil )
    {
        [self.map setCenterCoordinate:[LocationManager shareManager].location.coordinate animated:YES];
        MKCoordinateRegion region;
        region.center = [LocationManager shareManager].location.coordinate;
        
        MKCoordinateSpan span;
        span.latitudeDelta  = 0.01;
        span.longitudeDelta = 0.01;
        region.span = span;
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:[LocationManager shareManager].location.coordinate];
        [self.map addAnnotation:annotation];
        
        [self.map setRegion:region animated:YES];
        [self.addresssLabel setText:[LocationManager shareManager].currentAddress];
        [[LocationManager shareManager]removeDelegate:self];
        self.formValue = [LocationManager shareManager].currentAddress;
        
        [self.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue]];
    }
}

-(void)handleWrongAddresss:(id)sender
{
    [self.addresssLabel setReturnKeyType:UIReturnKeyDone];
    [self.addresssLabel setEnabled:YES];
    [self.addresssLabel setText:@"enter address"];
    [self.addresssLabel becomeFirstResponder];
    [self.addresssLabel addTarget:self  action:@selector(textFieldFinished:)  forControlEvents:UIControlEventEditingDidEndOnExit];
   }

-(void)textFieldFinished:(id)sender
{
    __block MapCell *blockself = self;
    
    [[LocationManager shareManager]geoCodeUsingAddress:self.addresssLabel.text block:^(CLLocationCoordinate2D loc)
    {
    
        [blockself.map setCenterCoordinate:loc animated:YES];
        MKCoordinateRegion region;
        region.center = loc;
        
        MKCoordinateSpan span;
        span.latitudeDelta  = 0.01;
        span.longitudeDelta = 0.01;
        region.span = span;
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:loc];
        [self.map addAnnotation:annotation];
        
        [blockself.map setRegion:region animated:YES];
        blockself.formValue = [LocationManager shareManager].currentAddress;
        [blockself.formDelegate cell:self didChangeForField:[[self.cellinfo valueForKey:@"field"]intValue]];
    }];
}

-(void)render
{
    
}

@end
