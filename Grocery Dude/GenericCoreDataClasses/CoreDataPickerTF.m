//
//  CoreDataPickerTF.m
//  Grocery Dude
//
//  Created by zhangguang on 16/2/23.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import "CoreDataPickerTF.h"

@interface CoreDataPickerTF () 

@end

@implementation CoreDataPickerTF

#pragma mark - *** Initializer ***
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.inputView = [self createInputView];
        self.inputAccessoryView = [self createInputAccessoryView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.inputView = [self createInputView];
        self.inputAccessoryView = [self createInputAccessoryView];
    }
    return self;
}

- (UIView*)createInputView
{
    self.picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.picker.showsSelectionIndicator = YES;
    self.picker.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.picker.dataSource = self;
    self.picker.delegate = self;
    [self fetch];
    return self.picker;
}

- (UIView*)createInputAccessoryView
{
    self.showToolbar = YES;
    if (!self.toolbar && self.showToolbar) {
        self.toolbar = [[UIToolbar alloc] init];
        self.toolbar.barStyle = UIBarStyleBlackTranslucent;
        self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.toolbar sizeToFit];
        CGRect frame = self.toolbar.frame;
        frame.size.height = 44.0f;
        self.toolbar.frame = frame;
        
        UIBarButtonItem* clearBtn = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clear)];
        UIBarButtonItem* spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
        self.toolbar.items = @[clearBtn,spacer,doneBtn];
    }
    return self.toolbar;
}

#pragma mark - *** Target Action ***
- (void)done
{
    [self resignFirstResponder];
}

- (void)clear
{
    [self.pickerDelegate selectedObjectClearedForPickerTF:self];
    [self resignFirstResponder];
}

#pragma mark - *** UIPicker DataSource ***
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerData.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44.0f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 280.0f;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.pickerData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSManagedObject* object = [self.pickerData objectAtIndex:row];
    [self.pickerDelegate selectedObjectID:[object objectID] changedForPickerTF:self];
}

#pragma mark - *** Helper ***
- (void)fetch
{
    [NSException raise:NSInternalInconsistencyException format:@"You must override the '%@' method to provide data to the picker",NSStringFromSelector(_cmd)];
}

- (void)selectDefaultRow
{
    [NSException raise:NSInternalInconsistencyException format:@"You must override the '%@' method to set the default picker row",NSStringFromSelector(_cmd)];
}

- (void)deviceDidRotate:(NSNotification*)notification
{
    [self.picker setNeedsLayout];
}

@end
