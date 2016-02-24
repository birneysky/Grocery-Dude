//
//  CoreDataHelper.m
//  Grocery Dude
//
//  Created by zhangguang on 15/8/5.
//  Copyright (c) 2015年 com.v2tech. All rights reserved.
//

#import "CoreDataHelper.h"
#import "MigrationViewController.h"

@interface CoreDataHelper () <UIAlertViewDelegate>

@property (nonatomic,strong)MigrationViewController* migrationVC;

@property (nonatomic,strong) UIAlertView* importAlertView;

@end

@implementation CoreDataHelper

#define debug 1

#pragma mark - *** FILES Name ***
NSString* storeFileName = @"Grocery-Dude.sqlite";

#pragma mark - *** SETUP ***
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
        
        _importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_importContext performBlockAndWait:^{
            [_importContext setPersistentStoreCoordinator:_coordinator];
            [_importContext setUndoManager:nil];
        }];
    }
    
    return self;
}

- (void)loadStore
{
    DebugLog(@"Runing %@",self.class);
    
    if (_store) {
        return;
    }
    
    BOOL useMIgrationManager = NO;
    if (useMIgrationManager && [self isMigrationNecessaryForStore:[self stroreURL]]) {
        [self performBackgroundManagedMigrationForStore:[self stroreURL]];
    }
    else{
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
        if (!_store) { DebugLog(@"Failed to add store Error: %@ ",error); abort();}
        else{ DebugLog(@"Sucessfully added store :%@",_store);}
    }

    
}

- (void)setupCoreData
{
    DebugLog(@"Runing %@ ",self.class);
    [self loadStore];
    [self checkIfDefaultDataNeedsImporting];
}

#pragma mark - *** Helper ***
- (BOOL)isMigrationNecessaryForStore:(NSURL*)storeUrl
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self stroreURL].path]) {
        TRACE(@"SKIPPED MIGRATION: SOURCE DATABASE MISSING");
        return NO;
    }
    
    NSError* error = nil;
    NSDictionary* sourceMetaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeUrl error:&error];
    
    NSManagedObjectModel* destinationModel = _coordinator.managedObjectModel;
    //判断新模型是否与现有的存储区相兼容，如果兼容返回NO，不迁移数据
    if ([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetaData]) {
        TRACE(@"SKIPPED MIGRATION: source is already compatible");
        return NO;
    }
    
    return YES;
}

- (BOOL) migrateStore:(NSURL*)sourceStore
{
    BOOL sucess = NO;
    NSError* error = nil;
    /*step1.收集数据迁移所需要的信息
        原模型，sourceModel
        目标模型，destinModel
        映射模型,mappingModel
     */
    //从持久化数据区获取元数据
    NSDictionary* sourceMetaData = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                URL:sourceStore
                                                                            error:&error];
    //原模型
    NSManagedObjectModel* sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil
                                                        forStoreMetadata:sourceMetaData];
    //目标模型
    NSManagedObjectModel* destinModel = _model;
    
    // 映射模型
    NSMappingModel* mappingModel = [NSMappingModel mappingModelFromBundles:nil
                                                            forSourceModel:sourceModel
                                                           destinationModel:destinModel];
    
    /*step2.实际的迁移过程。先用原模型与目标模型创建NSMigrationManager实例,然后在调用migrateStoreFromURL之前，
     还需把目标存储区准备好，该存储区只是为了迁移而设的临时存储区。
     
     */
    
    if(mappingModel){
        NSError* error = nil;
        NSMigrationManager* migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destinModel];
        [migrationManager addObserver:self
                           forKeyPath:@"migrationProgress"
                             options:NSKeyValueObservingOptionNew
                             context:nil];
        
        NSURL* destinStoreUrl = [[self applicationStoresDirectory] URLByAppendingPathComponent:@"temp.sqlite"];
        sucess = [migrationManager migrateStoreFromURL:sourceStore
                                                  type:NSSQLiteStoreType
                                               options:nil
                                      withMappingModel:mappingModel
                                      toDestinationURL:destinStoreUrl
                                       destinationType:NSSQLiteStoreType
                                    destinationOptions:nil
                                                 error:&error];
        if (sucess) {
            /*step3.只有在顺利完成迁移时才出发。replaceStore方法用于在迁移完成后清理旧的存储区，
             执行完step2之后，目标位置上就会出现新的存储区了，但是必须把这个迁移过来的新存储区放回在原来的位置上，并且要把它的文件名和旧的存储区一样，
             这样CoreData 才能使用新的存储区。
             */
            if ([self replaceStore:sourceStore withStore:destinStoreUrl]) {
                DebugLog(@"SUCCESSFULLY MIGRATED %@ to the Current Model",sourceStore.path);
                [migrationManager removeObserver:self forKeyPath:@"migrationProgress"];
            }
            
        }
        else{
            DebugLog(@"FAILED MIGRATION: %@",error);
        }
    }
    else{
        TRACE(@"FAILED MIGRATION: Mapping Model is null");
    }
    
    return YES;
}

- (BOOL)replaceStore:(NSURL*)old withStore:(NSURL*)new
{
    BOOL sucess = NO;
    NSError* error = nil;
    if ([[NSFileManager defaultManager] removeItemAtURL:old error:&error]) {
        error = nil;
        if ([[NSFileManager defaultManager] moveItemAtURL:new
            toURL:old error:&error]) {
            sucess = YES;
        }
        else{
            DebugLog(@"FAILED to re-home new strore %@",error);
        }
    }
    else{
        DebugLog(@"FAILED TO remove old store %@ : Error: %@",old,error);
    }
    return sucess;
}

- (BOOL)isDefaultDataAlreadyImportedForStoreWithURL:(NSURL*)url ofType:(NSString*)type
{
    NSError* error;
    NSDictionary* dictionary = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type URL:url error:&error];
    if (error) {
        DebugLog(@"Error reading persistent store metadata : %@",error.localizedDescription);
    }
    else{
        NSNumber* defaultDataAlreadyImported = [dictionary valueForKey:@"DefaultDataImported"];
        if (![defaultDataAlreadyImported boolValue]) {
            TRACE(@"Default Data has Not already been imported");
            return NO;
        }
    }
    
    TRACE(@"Default Data Has already been imported");
    
    return YES;
}

- (void)checkIfDefaultDataNeedsImporting
{
    if (![self isDefaultDataAlreadyImportedForStoreWithURL:[self stroreURL] ofType:NSSQLiteStoreType]) {
        self.importAlertView = [[UIAlertView alloc] initWithTitle:@"Import Default Data" message:@"If you've never used Grocery Dude before then some default data might help you understand how to use it. Tap 'Import' to import default data. Tap'Cancel' to skip the import,especially if you've done this before on other devices" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Import", nil];
        [self.importAlertView show];
    }
}

- (void)importFromXML:(NSURL*)url {

    [[NSNotificationCenter defaultCenter]postNotificationName:@"SomethingChanged" object:nil];
}

#pragma mark - *** Alert View Delegate ***
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.importAlertView) {
        if (1 == buttonIndex) {
            TRACE(@"Default Data Import Approved by User");
            [_importContext performBlock:^{
                
            }];
        }
        else {
            TRACE(@"Default Data Import Cancelled by User");
        }
    }
}

#pragma mark - *** KeyPath Observer ***
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"migrationProgress"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            self.migrationVC.progressView.progress = progress;
            int percentage = progress * 100;
            NSString* string = [NSString stringWithFormat:@"Migration Progress : %i%%",percentage];
            self.migrationVC.label.text = string;
            DebugLog(@"%@",string);
        });
    }
}

#pragma mark - *** Background Migrate ***
- (void)performBackgroundManagedMigrationForStore:(NSURL*)storeURL
{
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.migrationVC = [sb instantiateViewControllerWithIdentifier:@"migration"];
    UIApplication* app = [UIApplication sharedApplication];
    UINavigationController* nav = (UINavigationController*)app.keyWindow.rootViewController;
    [nav presentViewController:self.migrationVC animated:NO completion:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL done = [self migrateStore:storeURL];
        if (done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError* error = nil;
                _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                    configuration:nil
                                                              URL:[self stroreURL]
                                                          options:@{NSSQLitePragmasOption:@{@"journal_mode":@"DELETE"}}
                                                            error:&error];
                if (!_store) {
                    DebugLog(@"Failed to add a migrated store. Error : %@",error);
                    abort();
                }
                else{
                    DebugLog(@"Sucessfully added a migrated store : %@",_store);
                }
                
                [self.migrationVC dismissViewControllerAnimated:NO completion:nil];
                self.migrationVC = nil;
            });
        }
    });
}


#pragma mark - *** PATHS ***
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

#pragma mark - *** SAVING ***

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

- (void)showValidationError:(NSError*)anError
{
    if (anError && [anError.domain isEqualToString:@"NSCocoErrorDomain"]) {
        NSArray* errors = nil;
        NSString* text = @"";
        
        if (anError.code == NSValidationMultipleErrorsError) {
            errors = [anError.userInfo objectForKey:NSDetailedErrorsKey];
        }
        else{
            errors = [NSArray arrayWithObject:anError];
        }
        
        if (errors && errors.count > 0) {
            for (NSError* error in errors) {
                NSString* entity = [[[error.userInfo objectForKey:@"NSValidationErrorObject"] entity] name];
                NSString* property = [error.userInfo objectForKey:@"NSValidationErrorKey"];
                switch (error.code) {
                    case NSValidationRelationshipDeniedDeleteError:
                        text = [text stringByAppendingFormat:@"%@:delete was denied because there are associated %@\n(Error Code ☞ %li)\n\n",entity,property,error.code];
                        break;
                    case NSValidationRelationshipLacksMinimumCountError:
                        text = [text stringByAppendingFormat:@"the '%@' relationship count is too small (code %li)",property,error.code];
                        break;
                    case NSValidationRelationshipExceedsMaximumCountError:
                        text = [text stringByAppendingFormat:@"the '%@' relationship count is too large (code %li) ",property,error.code];
                        break;
                    case NSValidationMissingMandatoryPropertyError:
                        text = [text stringByAppendingFormat:@"the '%@' property is missing (code %li)",property,error.code];
                        break;
                    default:
                        text =[text stringByAppendingFormat:@"Unhandled error code %li in showValidationError method",error.code];
                        break;
                }
            }
        }
    }
}

@end
