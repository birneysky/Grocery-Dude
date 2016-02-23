//
//  UnitPickerTF.m
//  Grocery Dude
//
//  Created by zhangguang on 16/2/23.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import "UnitPickerTF.h"
#import "AppDelegate.h"
#import "Unit+CoreDataProperties.h"

@implementation UnitPickerTF

#pragma mark - *** UIPicker DataSource ***
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Unit* unit = [self.pickerData objectAtIndex:row];
    return unit.name;
}

#pragma mark - *** Helper ***
- (void)fetch
{
    CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    [request setFetchBatchSize:50];
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
        Unit* selectObject = [cdh.context existingObjectWithID:self.selectObjectID error:nil];
        [self.pickerData enumerateObjectsUsingBlock:^(Unit*  _Nonnull unit, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([unit.name compare:selectObject.name ] == NSOrderedSame) {
                [self.picker selectRow:idx inComponent:0 animated:NO];
                [self.pickerDelegate selectedObjectID:self.selectObjectID changedForPickerTF:self];
                *stop = YES;
            }
        }];
    }
}

@end
