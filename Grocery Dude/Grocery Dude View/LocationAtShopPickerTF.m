//
//  LocationAtShopPickerTF.m
//  Grocery Dude
//
//  Created by zhangguang on 16/2/23.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import "LocationAtShopPickerTF.h"
#import "LocationAtShop+CoreDataProperties.h"
#import "AppDelegate.h"

@implementation LocationAtShopPickerTF

- (void)fetch
{
    CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"LocationAtShop"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"aisle" ascending:YES]];
    NSError* error = nil;
    self.pickerData = [cdh.context executeFetchRequest:request error:&error];
    
    if (error) {
        DebugLog(@"Error populating picker %@, %@",error,error.localizedDescription);
    }
    [self selectDefaultRow];
}

- (void)selectDefaultRow
{
    if (self.selectObjectID && self.pickerData.count > 0) {
        CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
        LocationAtShop* selectObject = [cdh.context existingObjectWithID:self.selectObjectID error:nil];
        [self.pickerData enumerateObjectsUsingBlock:^(LocationAtShop*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.aisle compare:selectObject.aisle ] == NSOrderedSame) {
                [self.picker selectRow:idx inComponent:0 animated:NO];
                [self.pickerDelegate selectedObjectID:self.selectObjectID changedForPickerTF:self];
                *stop = YES;
            }
        }];
    }
}

@end
