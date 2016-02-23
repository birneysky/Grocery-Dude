//
//  AppDelegate.m
//  Grocery Dude
//
//  Created by zhangguang on 15/8/5.
//  Copyright (c) 2015年 com.v2tech. All rights reserved.
//

#import "AppDelegate.h"
#import "Item+CoreDataProperties.h"
#import "Measurement.h"
#import "Amount.h"
#import "Unit.h"
#import "LocationAtHome+CoreDataProperties.h"
#import "LocationAtShop+CoreDataProperties.h"

#define debug 1

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize coreDataHelper = _coreDataHelper;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    /*UIScreen类代表了屏幕
     UIView继承自UIResponder,如果说把window比作画框的话,它是负责显示的画布
     我们就是不断地在画框上移除、更换或者叠加画布,或者在画布上叠加其他画布，大小当然 由绘画者来决定了。
     
     UIWindow,UIWindow继承自UIView，关于这一点可能有点逻辑障碍,画框怎么继承自画布呢？
     不要过于去专牛角尖，画框的形状不就是跟画布一样吗？拿一块画布然后用一些方法把它加强，是不是可以当一个画框用呢？这也是为什么 一个view可以直接加到另一个view上去的原因了
     */
    self.window.backgroundColor = [UIColor whiteColor];
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
    //[self demo8];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self.coreDataHelper saveContext];
}

#pragma mark - *** Properties ****

- (CoreDataHelper*)coreDataHelper
{
    if (!_coreDataHelper) {
        //防止多个线程同时实例化CoreDataHelper
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            _coreDataHelper = [[CoreDataHelper alloc] init];
              [_coreDataHelper setupCoreData];
        });
    }
    return _coreDataHelper;
}

#pragma mark - *** Demo ***
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

- (void)demo6
{
    Unit* kg = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:self.coreDataHelper.context];
    
    Item* oranges = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:self.coreDataHelper.context];
    
    Item* bananas = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:self.coreDataHelper.context];
    
    LocationAtHome* locationAtHome = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtHome" inManagedObjectContext:self.coreDataHelper.context];
    
    LocationAtShop* locationAtShop = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtShop" inManagedObjectContext:self.coreDataHelper.context];
    
    locationAtHome.summary = @"home";
    locationAtHome.storedin = @"xxxxhome";
    
    locationAtShop.summary = @"shop";
    locationAtShop.aisle = @"xxxxshop";
    
    
    kg.name = @"Kg";
    oranges.name = @"Oranges";
    bananas.name = @"Bananas";
    
    oranges.quantity = [NSNumber numberWithInt:1];
    bananas.quantity = [NSNumber numberWithInt:4];
    oranges.listed = [NSNumber numberWithBool:YES];
    bananas.listed = [NSNumber numberWithBool:YES];
    
    oranges.locationAtHome = locationAtHome;
    oranges.locationAtShop = locationAtShop;
    
    oranges.unit = kg;
    bananas.unit = kg;
}


- (void)demo7
{
    [self showUnitAndItemCount];
    
    
    
    /*只有当正真保存上下文时，系统才会去实施Delete规则*/
    /*Failed to save _context: Error Domain=NSCocoaErrorDomain Code=1600 "The operation couldn’t be completed. ,如果想解决这个错误，
     就必须在删除Unit对象之前，确保该对象可以安全的移除（类NSManagedObject中的validateForDelete）*/
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    NSPredicate* filter = [NSPredicate predicateWithFormat:@"name == %@",@"Kg"];
    [request setPredicate:filter];
    
    NSArray* kgUnit = [self.coreDataHelper.context executeFetchRequest:request error:nil];
    for (Unit* unit in kgUnit) {
        [self.coreDataHelper.context deleteObject:unit];
    }
    
    [self showUnitAndItemCount];
}

- (void)showUnitAndItemCount
{
    NSFetchRequest* itemsRequest = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    NSError* itemsError = nil;
    NSArray* fetchedItems = [self.coreDataHelper.context executeFetchRequest:itemsRequest error:&itemsError];
    if (!fetchedItems) {
        DebugLog(@"%@",itemsError);
    }
    else{
        DebugLog(@"Found %lu items",fetchedItems.count);
    }
    
    NSFetchRequest* unitsRequest = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    NSError* unitsError = nil;
    NSArray* fetchedUnits = [self.coreDataHelper.context executeFetchRequest:unitsRequest error:&unitsError];
    
    if (!fetchedUnits) {
        DebugLog(@"%@",unitsError);
    }
    else{
        DebugLog(@"Found %lu units", [fetchedUnits count]);
    }
}

/*数据验证错误
        把数据保存到持久化存储区之前，它们必须通过验证。加入某个对象未能通过验证
        ，那么系统就会跑出domain为NSCocoaErrorDeomain的NSError。
 */


-(void)demo8
{
    NSArray* homeLocations = [NSArray arrayWithObjects:@"Fruit Bowl",@"Pantry",@"Nursery",@"Bathroom",@"Fridge", nil];
    NSArray* shopLocations = [NSArray arrayWithObjects:@"Produce",@"Aisle 1",@"Aisle 2",@"Aisle 3",@"Deli", nil];
    NSArray* unitNames = [NSArray arrayWithObjects:@"g",@"pkt",@"box",@"ml",@"kg", nil];
    NSArray* itemNames = [NSArray arrayWithObjects:@"Grapes",@"Biscuits",@"Nappies",@"Shampoo",@"Sausages", nil];
    
    for (int i = 0; i < itemNames.count; i++) {
        LocationAtHome* locationAtHone = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtHome" inManagedObjectContext:self.coreDataHelper.context];
        LocationAtShop* locationAtShop = [NSEntityDescription insertNewObjectForEntityForName:@"LocationAtShop" inManagedObjectContext:self.coreDataHelper.context];
        Unit* unit = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:self.coreDataHelper.context];
        Item* item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:self.coreDataHelper.context];
        locationAtHone.storedin = homeLocations[i];
        locationAtShop.aisle = shopLocations[i];
        unit.name = unitNames[i];
        item.name = itemNames[i];
        
        item.locationAtHome = locationAtHone;
        
        item.locationAtShop = locationAtShop;
        
        item.unit = unit;
        
        item.quantity = [NSNumber numberWithInt:arc4random() % 20];
    }
    
    [self.coreDataHelper saveContext];
}

@end
