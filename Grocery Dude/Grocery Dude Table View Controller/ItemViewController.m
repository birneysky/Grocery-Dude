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
#import "LocationAtHome+CoreDataProperties.h"
#import "LocationAtShop+CoreDataProperties.h"
#import "UnitPickerTF.h"
#import "LocationAtHomePickerTF.h"
#import "LocationAtShopPickerTF.h"

@interface ItemViewController () <UITextFieldDelegate,CoreDataPickerTFDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;

@property (weak, nonatomic) IBOutlet UnitPickerTF *unitPickerTextField;

@property (weak, nonatomic) IBOutlet LocationAtHomePickerTF *locationAtHomePickerTextField;

@property (weak, nonatomic) IBOutlet LocationAtShopPickerTF *locationAtShopPickerTextField;
@end

@implementation ItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideKeyboardWhenBackgroundIsTapped];
    
    self.unitPickerTextField.delegate = self;
    self.unitPickerTextField.pickerDelegate = self;
    
    self.locationAtHomePickerTextField.delegate = self;
    self.locationAtHomePickerTextField.pickerDelegate = self;
    
    self.locationAtShopPickerTextField.delegate = self;
    self.locationAtShopPickerTextField.pickerDelegate = self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self ensureItemHomeLocationIsNotNUll];
    [self ensureItemShopLocationIsNotNULL];
    [self refreshInterface];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self ensureItemHomeLocationIsNotNUll];
    [self ensureItemShopLocationIsNotNULL];
      CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
    [cdh saveContext];
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

- (void)refreshInterface
{
    if (self.selectedItemID) {
        CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
        Item* item = [cdh.context existingObjectWithID:self.selectedItemID error:nil];
        self.nameTextField.text = item.name;
        self.quantityTextField.text = item.quantity.stringValue;
        self.unitPickerTextField.text = item.unit.name;
        self.locationAtHomePickerTextField.text = item.locationAtHome.storedin;
        self.locationAtShopPickerTextField.text = item.locationAtShop.aisle;
    }
}

- (void)ensureItemHomeLocationIsNotNUll
{
    if (self.selectedItemID) {
        CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
        Item* item = [cdh.context existingObjectWithID:self.selectedItemID error:nil];
        
        if (!item.locationAtHome) {
            NSFetchRequest* request = [cdh.model fetchRequestTemplateForName:@"UnknownLocationAtHome"];
            NSArray* fetchedObjects = [cdh.context executeFetchRequest:request error:nil];
            if (fetchedObjects.count > 0) {
                item.locationAtHome = [fetchedObjects objectAtIndex:0];
            }
            else{
                LocationAtHome* locationAtHome = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtHome" inManagedObjectContext:cdh.context];
                NSError* error = nil;
                if (![cdh.context obtainPermanentIDsForObjects:@[locationAtHome] error:&error]) {
                    DebugLog(@"Couldn't obtain a permanent Id for object %@",error);
                }
                locationAtHome.storedin = @"..Unknown Location..";
                item.locationAtHome = locationAtHome;
            }
        }
    }
}

- (void)ensureItemShopLocationIsNotNULL
{
    if (self.selectedItemID) {
       CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
        Item* item = [cdh.context existingObjectWithID:self.selectedItemID error:nil];
        if (!item.locationAtShop) {
            NSFetchRequest* request = [cdh.model fetchRequestTemplateForName:@"UnknownLocationAtShop"];
            NSArray* fetchedOBjects = [cdh.context executeFetchRequest:request error:nil];
            if (fetchedOBjects.count > 0) {
                item.locationAtShop = [fetchedOBjects firstObject];
            }
            else
            {
                LocationAtShop* locationShop = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtShop" inManagedObjectContext:cdh.context];
                NSError* error = nil;
                //将对象ID转化为永久ID
                if (![cdh.context obtainPermanentIDsForObjects:@[locationShop] error:&error]) {
                    DebugLog(@"Could not obtain a permant Id for object %@",error);
                }
                
                locationShop.aisle = @"..Unknown Location..";
                item.locationAtShop = locationShop;
            }
        }
    }
}

#pragma mark - *** Target Action ***
- (IBAction)done:(id)sender {
    
    [self hideKeyboard];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - *** TextField Delegate ***
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.nameTextField){
        if ([self.nameTextField.text isEqualToString:@"New Item"]) {
            self.nameTextField.text = @"";
        }
    }
    else if (textField == self.unitPickerTextField && self.unitPickerTextField.picker){
        [self.unitPickerTextField fetch];
        [self.unitPickerTextField.picker reloadAllComponents];
    }
    else if (textField == self.locationAtHomePickerTextField && self.locationAtHomePickerTextField.picker){
        [self.locationAtHomePickerTextField fetch];
        [self.locationAtHomePickerTextField.picker reloadAllComponents];
    }
    else if (textField == self.locationAtShopPickerTextField && self.locationAtShopPickerTextField.picker){
        [self.locationAtShopPickerTextField fetch];
        [self.locationAtShopPickerTextField.picker reloadAllComponents];
    }
        
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
    
    Item* item = [cdh.context existingObjectWithID:self.selectedItemID error:nil];
    
    if (textField == self.nameTextField) {
        if ([self.nameTextField.text isEqualToString:@""]) {
            self.nameTextField.text = @"New Item";
        }
        item.name = self.nameTextField.text;
    }
    else if (textField == self.quantityTextField){
        item.quantity = [NSNumber numberWithFloat:self.quantityTextField.text.floatValue];
    }
}

#pragma mark - *** CoreDataPickerTFDelegate ***
- (void)selectedObjectID:(NSManagedObjectID *)objectID changedForPickerTF:(CoreDataPickerTF *)pickerTF
{
    if (self.selectedItemID) {
        CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
        Item* item = [cdh.context existingObjectWithID:self.selectedItemID error:nil];
        
        NSError* error = nil;
        if (pickerTF == self.unitPickerTextField) {
            Unit* unit = [cdh.context existingObjectWithID:objectID error:&error];
            item.unit = unit;
            self.unitPickerTextField.text = item.unit.name;
        }
        else if (pickerTF == self.locationAtHomePickerTextField){
            LocationAtHome* locationAtHome = [cdh.context existingObjectWithID:objectID error:nil];
            item.locationAtHome = locationAtHome;
            self.locationAtHomePickerTextField.text = item.locationAtHome.storedin;
        }
        else if (pickerTF == self.locationAtShopPickerTextField){
            LocationAtShop* locationAtShop = [cdh.context existingObjectWithID:objectID error:nil];
            item.locationAtShop = locationAtShop;
            self.locationAtShopPickerTextField.text = item.locationAtShop.aisle;
        }
        
        [self refreshInterface];
    }
}

- (void)selectedObjectClearedForPickerTF:(CoreDataPickerTF *)pickerTF
{
    if (self.selectedItemID) {
        CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
        Item* item = [cdh.context existingObjectWithID:self.selectedItemID error:nil];
        if (pickerTF == self.unitPickerTextField) {
            item.unit = nil;
            self.unitPickerTextField.text = @"";
        }
        else if (pickerTF == self.locationAtHomePickerTextField){
            item.locationAtHome = nil;
            self.locationAtHomePickerTextField.text = @"";
        }
        else if (pickerTF == self.locationAtShopPickerTextField){
            item.locationAtShop = nil;
            self.locationAtShopPickerTextField.text = @"";
        }
        
        [self refreshInterface];
    }
}
@end
