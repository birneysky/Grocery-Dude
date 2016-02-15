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
    DebugLog(@"Runing %@ ",self.class);
    self = [super init];
    if (self) {
        
        /*mergedModelFromBundles 会使用 main boundle中的全部数据模型文件来初始化_model
         还有一个方法也能初始化托管对象， _model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"]];
         手工指定模型文件，于下面的方法相比，这种写法代码量多了一倍
         */
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
    DebugLog(@"Runing %@",self.class);
    
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
                                                        NSInferMappingModelAutomaticallyOption:@NO
                                                        } //禁用“数据库日志记录模式”
                                                error:&error];
    if (!_store) { DebugLog(@"Failed to add store Error: %@ ",error); abort();}
    else{ DebugLog(@"Sucessfully added store :%@",_store);}
    
}

- (void)setupCoreData
{
    DebugLog(@"Runing %@ ",self.class);
    [self loadStore];
}

#pragma mark - PATHS
- (NSString*)applicationDocumentsDirectory
{
    DebugLog(@"Runing %@ ",self.class);
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSURL*)applicationStoresDirectory
{
    DebugLog(@"Runing %@ ",self.class);

    NSURL* storesDirectory = [[NSURL fileURLWithPath:[self applicationDocumentsDirectory]] URLByAppendingPathComponent:@"Stores"];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[storesDirectory path]]) {
        NSError* err;
        
        if ([fileManager createDirectoryAtURL:storesDirectory
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:&err]) {
                TRACE(@"SucessFully Created Stores directory");
        }
        else
        {
            DebugLog(@"Failed to create Stores directory: %@",err);
        }
    }
    
    return storesDirectory;
}

/*返回持久化存储文件在文件系统中位置*/
- (NSURL*)stroreURL
{
    DebugLog(@"Runing %@ ",self.class);
    
    return [[self applicationStoresDirectory] URLByAppendingPathComponent:storeFileName];
}

#pragma mark - SAVING

- (void)saveContext
{
    DebugLog(@"Runing %@ ",self.class);
    
    if ([_context hasChanges]) {
        NSError* error = nil;
        if ([_context save:&error]) {
            TRACE(@"_context SAVED changed to persistent store ");
        }
        else
        {
            DebugLog(@"Failed to save _context: %@",error);
        }
    }
    else
    {
        TRACE(@"SKIPPED _context save, there are no changes");
    }
}

@end
