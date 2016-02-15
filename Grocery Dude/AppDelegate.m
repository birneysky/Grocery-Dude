//
//  AppDelegate.m
//  Grocery Dude
//
//  Created by zhangguang on 15/8/5.
//  Copyright (c) 2015年 com.v2tech. All rights reserved.
//

#import "AppDelegate.h"
#import "Item.h"


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
    [self demo];
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
        Item* newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                                      inManagedObjectContext:self.coreDataHelper.context];
        newItem.name = each;
        DebugLog(@"Inserted New Managed object for '%@'",newItem.name);
    }
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSPredicate* filter = [NSPredicate predicateWithFormat:@"name != %@",@"Coffee"];
    [request setPredicate:filter];
    
    NSArray* fetchObjects = [self.coreDataHelper.context executeFetchRequest:request error:nil];
    for (Item* item in fetchObjects) {
        [self.coreDataHelper.context deleteObject:item];
         DebugLog(@" Fetch Object = %@",item.name);
    }

}

@end
