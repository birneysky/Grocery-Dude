//
//  CoreDataHelper.h
//  Grocery Dude
//
//  Created by zhangguang on 15/8/5.
//  Copyright (c) 2015年 com.v2tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/*CoreDat是个框架，开发者可以把数据当做对象来操作，而不必在乎数据在磁盘中的存储方式。
 持久化存储区：指的是像SQLite数据库，xml文件（ios不支持xml文件作为持久化存储区）或者Binary store（atomic store）这种数据文件。*/


/*为了把数据从托管对象映射到持久化存储区中，CoreData需要使用托管对象模型*/

/*后端sql可见性设置
    把系统自动生成的sql 语句打印出来
    1. Product-> Scheme -> Edit Scheme
    2. Run Grocery Dude 切换至Arguments分页
    3. 点击Arguments Passed On Launch 区域中的'+'按钮
    4. 输入新参数“-com.apple.CoreData.SQLDebug 3” ok
 */

@interface CoreDataHelper : NSObject

/*托管对象上下文，磁盘与RAM之间传输数据时会有开销。磁盘读写速度比RAM要慢的多，所以不应该频繁访问它。
 而有个托管上下文之后，对于原来需要读写磁盘才能获取到的数据，现在只需要访问这个上下文，就可以非常迅速的获取到了。
 但它的缺点在于，开发者必须在托管上下文中定期的调用save方法，以便将变更后的数据写回磁盘。
 托管对象上下文的另一个功能是记录开发者对托管对象所做的修改，已提供完整的撤销和重做的支持。*/

/*托管对象上下文中，包含有多个托管对象。托管上下文对象负责管理其中托管对象的生命周期。
托管上下文对象也可以不止有一个，有时候我们需要在后台处理任务(比方说把数据保存到磁盘或者导入数据)，这种情况可以采用多个上下文
如果在前台上下文上面调用save：，那么界面就会有卡顿现象，尤其像数据变化较大时更是如此*/
@property (nonatomic,readonly) NSManagedObjectContext*       context;


/*托管对象模型--数据对象，托管对象持有一份对持久化存储区里相关数据的拷贝。所有的托管对象都必须位于托管上下文里面*/
@property (nonatomic,readonly) NSManagedObjectModel*         model;

/*持久化存储协调器，里面包含了一份持久化存储区，而存储区里面又含有数据表里的若干行数据。
 同一个持久化协调器可以有多个持久化存储区。*/
@property (nonatomic,readonly) NSPersistentStoreCoordinator* coordinator;
@property (nonatomic,readonly) NSPersistentStore*            store;

/*判断数据是否需要迁移*/
- (BOOL)isMigrationNecessaryForStore:(NSURL*)storeUrl;

- (BOOL) migrateStore:(NSURL*)sourceStore;

- (void)setupCoreData;

- (void)saveContext;

@end
