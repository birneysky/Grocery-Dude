//
//  LocationAtHomeViewController.m
//  Grocery Dude
//
//  Created by birneysky on 16/2/21.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import "LocationAtHomeViewController.h"
#import "AppDelegate.h"
#import "LocationAtHome+CoreDataProperties.h"

@interface LocationAtHomeViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end

@implementation LocationAtHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideKeyboardWhenBackgroundIsTapped];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshInterface];
}

#pragma mark - *** Helper ***
- (void)refreshInterface
{
    if (self.selectItemID) {
        CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
        LocationAtHome* locationAtHome = [cdh.context existingObjectWithID:self.selectItemID error:nil];
        self.nameTextField.text = locationAtHome.storedin;
    }
}

- (void)hideKeyboardWhenBackgroundIsTapped
{
    UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    [tgr setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tgr];
}

#pragma mark - *** Target Action ***
- (IBAction)done:(id)sender {
    [self hideKeyBoard];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - *** Gesture Selector ***
- (void)hideKeyBoard
{
    [self.view endEditing:YES];
}

#pragma mark - ***TextField Delegate ***
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.nameTextField == textField) {
        CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
        LocationAtHome* locationAtHome = [cdh.context existingObjectWithID:self.selectItemID error:nil];
        locationAtHome.storedin = self.nameTextField.text;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SomethingChanged" object:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
