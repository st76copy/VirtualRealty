//
//  KeywordsViewController.m
//  VirtualRealty
//
//  Created by christopher shanley on 10/19/13.
//  Copyright (c) 2013 virtualrealty. All rights reserved.
//

#import "KeywordsViewController.h"
#import "KeyboardManager.h"
@interface KeywordsViewController ()<UITextViewDelegate>

@end

@implementation KeywordsViewController

@synthesize words     = _words;
@synthesize views     = _views;
@synthesize delegate;

-(id)initWithWords:(NSMutableArray *)array;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        _words = ( array == nil ) ? [NSMutableArray array] : array;
        _views = [NSMutableArray array];
        self.navigationItem.title = NSLocalizedString(@"Key Words", @"Generic : keyword nav title");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:nil action:@selector(textViewDidEndEditing:)];
    self.navigationItem.rightBarButtonItem = bbi;
    
    self.view.backgroundColor = [UIColor grayColor];
    UITextField *tf;
    for( int i = 0; i < 5; i ++ )
    {

        tf = [[UITextField alloc]initWithFrame:CGRectMake(10, 100 + 45 * i, 300, 40)];
        [self.view addSubview:tf];
        [tf setBackgroundColor:[UIColor whiteColor]];
        [tf setReturnKeyType:UIReturnKeyDone];
        [tf setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [tf setClearButtonMode:UITextFieldViewModeWhileEditing];
        if( self.words.count > i )
        {
            tf.text = self.words[i];
        }
        else
        {
            tf.placeholder = @"enter keyword or phrase";
        }
        
        [self.views addObject:tf];
    }
}

-(void)textViewDidEndEditing:(id )sender
{
    int i = 0;
    for( UITextField *v in self.views)
    {
        if( v.text != nil && [v.text isEqualToString:@""] == NO )
        {
            if( i < self.words.count )
            {
                [self.words replaceObjectAtIndex:i withObject:v.text];
            }
            else
            {
                [self.words addObject:v.text];
            }
           
        }
        else
        {
            if( i < self.words.count )
            {
                [self.words removeObjectAtIndex:i];
            }
        }
        i ++;
    }
    [self.delegate keywordsDone:self];
    [self.navigationController popViewControllerAnimated:YES];
}




@end
