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
@property (nonatomic,readonly) NSManagedObjectContext*       importContext;


/*托管对象模型--数据对象，托管对象持有一份对持久化存储区里相关数据的拷贝。所有的托管对象都必须位于托管上下文里面*/
@property (nonatomic,readonly) NSManagedObjectModel*         model;

/*持久化存储协调器，里面包含了一份持久化存储区，而存储区里面又含有数据表里的若干行数据。
 同一个持久化协调器可以有多个持久化存储区。*/
@property (nonatomic,readonly) NSPersistentStoreCoordinator* coordinator;
@property (nonatomic,readonly) NSPersistentStore*            store;


/*************************/

@property (nonatomic,readonly) NSManagedObjectContext* sourceContext;

@property (nonatomic,readonly) NSPersistentStoreCoordinator* sourceCoordinator;

@property (nonatomic,readonly) NSPersistentStore* sourceStore;

/*************************/

/*判断数据是否需要迁移*/
- (BOOL)isMigrationNecessaryForStore:(NSURL*)storeUrl;

- (BOOL)migrateStore:(NSURL*)sourceStore;

- (void)setupCoreData;

- (void)saveContext;

- (void)showValidationError:(NSError*)anError;

@end

/*
 Core Data
     Core Data是OS X 10.4 Tiger之后引入的一个持久化技术，通过与数据库进行交互，将模型的状态持久化到磁盘。
   使用了对象-关系映射（ORM）技术，很好的将数据中的表和字段转化为对象和属性，同时将表之间的关系转化成了对象之间的包含关系。
 
 Core Data中的几个重要的概念
    1. Entity 实体
        我们可以在.xcdatamodel 文件中创建一些实体，并为其添加相应的属性和关系。这些实体和属性很类似于关系型数据库中表和字段的概念。
        实体和属性与数据库中的表和字段相互映射
    2. NSEntityDescription 实体对象描述
        描述了一个实体的基本属性，包括实体名，类名，属性，关系等等，可以通过实体描述来实例化托管对象。
        insertNewObjectForEntityForName: inManagedObjectContext:
    3.NSManagedObjectModel 托管对象模型（MOM）
        是实体对象描述（NSEntityDescription）集合。通过.mom 或者 .momd文件来实例化。.mom 或者 .momd是.xcdatamodel编译后得到的。
        mergedModelFromBundles
    4.NSManagedObject 托管对象 （MO）
        Entity 是一个模型，实体对象描述（NSEntityDescription）记录了这个模型的内容，对这个模型进行描述。然而MO才是正真要操作的东西。
        每一个MO都对应着一个实体并且有唯一的ID。因此它能够对应数据库中的某一条记录。
    5.NSManagedObjectContext 托管对象上下文 （ MOC)
        对MO的操作如何被数据库知道，并进行同步呢？这就需要MOC了，为什么我们操作的对象是托管的呢，这是因为使用了MOC监听MO。MOC作为监听者，
        当MO放生变化时，MOC知道它监听的MO对象发生了变化，然后就可以将这些改变提交给PSC，PSC将同数据库打交道来实现数据同步
    6.NSPersistentStoreCoordinator 持久化存储协调器 (PSC)
        PSC 使用NSPersistentStore对象与数据库交互，NSPersistentStore对象会将MOC提交的改变同步到数据库中。PSC是通过MOM进行实例化的（initWithManagedObjectModel:）
        一方面是因为它需要与数据库和上下文交互，所以需要知道所有实体描述才能正确的传达信息；二是因为在PSC初始化时，它会检测指定路径下是否有相应的数据库，如果没有则进行创建，
        所以它需要知道所有的实体描述来创建数据库。同时如果指定路径中存在数据库，那么它会将最新的MOM与当前数据库进行比对，看是否存在最新的MOM中的实体与属性等与沙盒中数据库的表和字段等不一致的情况，（如果不一致，会创建新的数据库取代老数据库，老数据库中的数据将会丢失，这也是为什么我们需要做数据迁移的操作了）。
 
   总结成一句话其实就是：创建MO使用MOC去监听，然后在操作完MO后，使用MOC 进行保存，将改变提交给PSC，然后PSC与数据库交互同步数据
 
 */



/*
深拷贝的执行过程可以宏观的描述成下面几个步骤
    1. 创建CoreDataImporter实例，创建时要提供NSDictionary，其中存有从实体名称到unique属性的映射，每个实体都要有这样一条映射。
    2. 给CoreDataImporter实例传入NSArray，这个数组中包含了待复制的各实体名称，而CoreDataImporter实例会依次遍历这些名称，
       并根据需要，把每个实体所对应的对象都拷贝到目标上下文中。
    3. 假如目标上下文中没有与源上下文相等价的对象，那就新建托管对象，并将其插入目标上下文。新对象的各个属性值根据源对象来设置。
    4. 如果源对象有'关系'，那就沿着关系找到相关的对象。然后根据需要，把那些相关对象拷贝到目标上下文里。
    5. 如果某条关系涉及的全部对象都已拷贝到目标上下文之中，那就在副本对象和与之相关的其他副本对象之间重建关系
 */


/*
 CoreData栈(Core Data stack) 这个术语是对持久化存储区，持久化存储协调器，托管对象模型以及托管对象上下文的合称。
 为了对源存储区实施深拷贝，我们需要再使用一套与目标存储区不同的Coredata栈。这样做的效果就相当于把深拷贝操作所涉及的源上下文和目标上下文区隔开了。
 两个栈之间的唯一的共性在于，他们都使用相同的托管对象模型。
 */