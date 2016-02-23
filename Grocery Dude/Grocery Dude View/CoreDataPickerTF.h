//
//  CoreDataPickerTF.h
//  Grocery Dude
//
//  Created by zhangguang on 16/2/23.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class CoreDataPickerTF;

@protocol CoreDataPickerTFDelegate <NSObject>

- (void)selectedObjectID:(NSManagedObjectID*)objectID changedForPickerTF:(CoreDataPickerTF*)pickerTF;

@optional

- (void)selectedObjectClearedForPickerTF:(CoreDataPickerTF*)pickerTF;

@end

@interface CoreDataPickerTF : UITextField

/*当用户选中Picker中的某一行时，系统将向其发送消息，把用户所选的内容告诉委托*/
@property (nonatomic,weak) id<CoreDataPickerTFDelegate> pickerDelegate;

@property (nonatomic,strong) UIPickerView* picker;

@property (nonatomic,strong) NSArray* pickerData;

@property (nonatomic,strong) UIToolbar* toolbar;

@property (nonatomic,assign) BOOL showToolbar;

@property (nonatomic,strong) NSManagedObjectID* selectObjectID;

@end
