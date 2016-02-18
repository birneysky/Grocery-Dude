//
//  ItemViewController.m
//  Grocery Dude
//
//  Created by zhangguang on 16/2/17.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import "ItemViewController.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "Item+CoreDataProperties.h"

@interface ItemViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;
@end

@implementation ItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideKeyboardWhenBackgroundIsTapped];
}


#pragma mark - *** Helper ***

- (void)hideKeyboardWhenBackgroundIsTapped
{
    UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [tgr setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tgr];
}

- (void)hideKeyboard
{
    [self.view endEditing:YES];
}

- (IBAction)done:(id)sender {
    
    
}


@end
