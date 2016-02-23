//
//  LocationAtHomePickerTF.m
//  Grocery Dude
//
//  Created by zhangguang on 16/2/23.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import "LocationAtHomePickerTF.h"
#import "LocationAtHome+CoreDataProperties.h"
#import "AppDelegate.h"

@implementation LocationAtHomePickerTF

#pragma mark - *** Helper ***
- (void)fetch
{
    CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"LocationAtHome"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"storedin" ascending:YES]];
    [request setFetchBatchSize:50];
    NSError* erro = nil;
    self.pickerData = [cdh.context executeFetchRequest:request error:&erro];
    if (erro) {
        DebugLog(@"Error populating picker %@, %@",erro,erro.localizedDescription);
    }
    [self selectDefaultRow];
}

- (void)selectDefaultRow
{
    if (self.selectObjectID && self.pickerData.count) {
        CoreDataHelper* cdh = [(AppDelegate*)[[UIApplication sharedApplication] delegate] coreDataHelper];
        LocationAtHome* selectObject = [cdh.context existingObjectWithID:self.selectObjectID error:nil];
        [self.pickerData enumerateObjectsUsingBlock:^(LocationAtHome*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.storedin compare: selectObject.storedin] == NSOrderedSame) {
                [self.picker selectRow:idx inComponent:0 animated:NO];
                [self.pickerDelegate selectedObjectID:[selectObject objectID] changedForPickerTF:self];
                *stop = YES;
            }
        }];
    }
}

@end
