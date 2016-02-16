//
//  AppDelegate.m
//  Grocery Dude
//
//  Created by zhangguang on 15/8/5.
//  Copyright (c) 2015年 com.v2tech. All rights reserved.
//

#import "AppDelegate.h"
#import "Item.h"
#import "Measurement.h"
#import "Amount.h"
#import "Unit.h"

#define debug 1

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize coreDataHelper = _coreDataHelper;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self.coreDataHelper saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self demo5];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self.coreDataHelper saveContext];
}



- (CoreDataHelper*)coreDataHelper
{
    if (!_coreDataHelper) {
        _coreDataHelper = [[CoreDataHelper alloc] init];
        [_coreDataHelper setupCoreData];
    }
    return _coreDataHelper;
}

- (void)demo
{

    DebugLog(@"Runing %@ ",self.class);

    
    NSArray* newItemsNames = @[@"Apples",@"Milk",@"Bread",@"Cheese",
                               @"Sausages",@"Butter",@"Orange Juice",
                               @"Ceral",@"Coffee",@"Eggs",@"Tomatoes",@"Fish"];
    for (NSString* each in newItemsNames) {
        //新建托管对象实例，并将其插入上下文
        Item* newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                                      inManagedObjectContext:self.coreDataHelper.context];
        newItem.name = each;
        DebugLog(@"Inserted New Managed object for '%@'",newItem.name);
    }
    
    
    /*想操作托管对象上下文中的现有数据，就必须先把它获取（fetch）过来。加入待获取的数据没有放在上下文里，那么coreData会从底层存储区中把它拿来，
     要执行获取操作就得有NSFetchRequest实例，该实例会返回一个NSArray，这个数组里面的元素都是托管对象，在执行获取操作时，
     NSFetchRequest会根据特定的实体，把每个托管对象都放在NSArray这个数组中，类似 Select 语句*/
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    
    //配置排序描述符 类似 ORDER BY 语句
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    //设置筛选过滤条件 类似于Where
    /*假如每次获取托管对象时都要手工编写谓词格式确实很蛋疼，幸好xcode的Data Model Designer有预定义获取请求的功能。这些可复用的模板比谓词更容易配置
     而且还能减少重复代码。只需要根据应用程序的模型来操作一系列下拉列表框以及文本框，即可配置好一份获取请求模板。但如果要自定义AND OR这样的逻辑组合，这个模板就无法满足要求了
     ，此时任然需要代码来指定谓词 .使用案例请参考Demo2 方法
     具体步骤
        1.选中 Model.xcdatamodel
        2.Editor-> Add Fetch Request
        3.设置求情模板的名称 如Test
        4.点击 ‘+’ 来配置名为Test的获取请求模板*/
    NSPredicate* filter = [NSPredicate predicateWithFormat:@"name != %@",@"Coffee"];
    [request setPredicate:filter];
    
    NSArray* fetchObjects = [self.coreDataHelper.context executeFetchRequest:request error:nil];
    for (Item* item in fetchObjects) {
        [self.coreDataHelper.context deleteObject:item];
         DebugLog(@" Fetch Object = %@",item.name);
    }

}

- (void)demo2
{
    
    DebugLog(@"Runing %@ ",self.class);
    
    
    NSArray* newItemsNames = @[@"Apples",@"Milk",@"Bread",@"Cheese",
                               @"Sausages",@"Butter",@"Orange Juice",
                               @"Ceral",@"Coffee",@"Eggs",@"Tomatoes",@"Fish"];
    for (NSString* each in newItemsNames) {
        //新建托管对象实例，并将其插入上下文
        Item* newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                                      inManagedObjectContext:self.coreDataHelper.context];
        newItem.name = each;
        DebugLog(@"Inserted New Managed object for '%@'",newItem.name);
    }
    

    
    
    NSFetchRequest* request = [[self.coreDataHelper.model fetchRequestTemplateForName:@"Test"] copy];
    
    //配置排序描述符 类似 ORDER BY 语句
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    

    
    NSArray* fetchObjects = [self.coreDataHelper.context executeFetchRequest:request error:nil];
    for (Item* item in fetchObjects) {
        [self.coreDataHelper.context deleteObject:item];
        DebugLog(@" Fetch Object = %@",item.name);
    }
    
}

- (void)demo3
{
    for (int i = 0; i < 50; i ++) {
        Amount* newMeasureMent = [NSEntityDescription insertNewObjectForEntityForName:@"Amount"
                                                                    inManagedObjectContext:self.coreDataHelper.context];
        newMeasureMent.xyz = [NSString stringWithFormat:@"-->> LOTS OF TEST DATA x%i",i];
    }
}

- (void)demo4
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
    [request setFetchLimit:50];
    NSError* error = nil;
    NSArray* objects = [self.coreDataHelper.context executeFetchRequest:request error:&error];
    if (error) {
        DebugLog(@"%@",error);
    }
    else
    {
        for (Measurement* measurement in objects) {
            //NSLog(@"")
        }
    }
}

- (void)demo5
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    [request setFetchLimit:50];
    NSError* error = nil;
    NSArray* objects = [self.coreDataHelper.context executeFetchRequest:request error:&error];
    if (error) {
        DebugLog(@"%@",error);
    }
    else
    {
        for (Unit* unit in objects) {
            DebugLog(@" Fetched object = %@",unit.name);
        }
    }
}

@end
