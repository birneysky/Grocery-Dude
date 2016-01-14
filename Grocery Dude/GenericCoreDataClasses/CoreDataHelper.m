//
//  CoreDataHelper.m
//  Grocery Dude
//
//  Created by zhangguang on 15/8/5.
//  Copyright (c) 2015年 com.v2tech. All rights reserved.
//

#import "CoreDataHelper.h"

@implementation CoreDataHelper

#define debug 1

#pragma mark - FILES
NSString* storeFileName = @"Grocery-Dude.sqlite";

#pragma mark - SETUP
- (id)init
{
    if (debug == 1) {
        NSLog(@"Runing %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    self = [super init];
    if (self) {
        
        _model = [NSManagedObjectModel mergedModelFromBundles:nil];
        //初始化“持久化存储协调器”
        _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
        //让上下文环境在主线程队列中运行
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_context setPersistentStoreCoordinator:_coordinator];
    }
    
    return self;
}

- (void)loadStore
{
    if (debug == 1) {
        NSLog(@"Runing %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    if (_store) {
        return;
    }
    
    NSError* error;
    //讲Sqllite持久化存储区添加到_coordinator后，_strore 就是指向这个持久化存储区的指针
    _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                        configuration:nil
                                                  URL:[self stroreURL]
                                              options:@{NSSQLitePragmasOption:@{@"journal_mode":@"DELETE"},
                                                        NSMigratePersistentStoresAutomaticallyOption:@YES,
                                                        NSInferMappingModelAutomaticallyOption:@YES
                                                        } //禁用“数据库日志记录模式”
                                                error:&error];
    if (!_store) { NSLog(@"Failed to add store Error: %@ ",error); abort();}
    else{ if (debug == 1) {NSLog(@"Sucessfully added store :%@",_store);}}
    
}

- (void)setupCoreData
{
    if (debug == 1) {
        NSLog(@"Runing %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    [self loadStore];
}

#pragma mark - PATHS
- (NSString*)applicationDocumentsDirectory
{
    if (debug == 1) {
        NSLog(@"Runing %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    return [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSURL*)applicationStoresDirectory
{
    if (debug == 1) {
         NSLog(@"Runing %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    NSURL* storesDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Stores"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
        NSError* err;
        
        if ([fileManager createDirectoryAtURL:storesDirectory
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:&err]) {
            if (debug == 1) {
                NSLog(@"SucessFully Created Stores directory");
            }
        }
        else
        {
            NSLog(@"Failed to create Stores directory: %@",err);
        }
    }
    
    return storesDirectory;
}

- (NSURL*)stroreURL
{
    if (debug == 1) {
         NSLog(@"Runing %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    return [[self applicationStoresDirectory] URLByAppendingPathComponent:storeFileName];
}

#pragma mark - SAVING

- (void)saveContext
{
    if (debug == 1) {
        NSLog(@"Runing %@ '%@'",self.class,NSStringFromSelector(_cmd));
    }
    
    if ([_context hasChanges]) {
        NSError* error = nil;
        if ([_context save:&error]) {
            NSLog(@"_context SAVED changed to persistent store ");
        }
        else
        {
            NSLog(@"Failed to save _context: %@",error);
        }
    }
    else
    {
        NSLog(@"SKIPPED _context save, there are no changes");
    }
}

@end
