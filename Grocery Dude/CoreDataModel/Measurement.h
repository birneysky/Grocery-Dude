//
//  Measurement.h
//  Grocery Dude
//
//  Created by zhangguang on 16/2/15.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


/*托管对象模型的迁移
    模型版本控制
        为了不使应用程序奔溃，我们需要在修改模型之前先创建新的模型版本
        添加新的模型后，就不应该删除旧版的模型了。就得模型有助于把原来的持久化存储区迁移到当前的模型版本。
        假设用户的设备上原来就没有持久化存储区，那么可以先不考虑模型版本控制的问题，等到程序上appstore之后再说。
    添加新的模型版本步骤
        1.选中 Model.xcdatamodel
        2.点击Editor->Add Model Version
        3.点击finish按钮,讲Model2作为版本名称
        现在Modelx2.xcdatamodel这个新模型的内容一开始便与Modelx.xcdatamodel完全形同，而开发者不经意间就会在错误的模型版本上修改
        所以，为了防止这一情况的发生，在编辑模型前，应再三检查你所选定的模型是不是自己要编辑的那个
        在Modelx2.xcdatamodel中添加Measurement实体，添加名“abc"的属性，类型设置为string
        添加新的模型版本之后，必须将其设置为当前版本，然后才能使用它。
        现在如果想正常运行应用程序，那么我们还必须配置好迁移选项，告诉CoreData应该如何迁移。
        要是现在就去运行应用程序的话，那么自然还是会发生Store in incompatible（存储区不兼容）的错误
    轻量级迁移方式
            把新模型设为当前版本之后，必须迁移现有的持久化存储区，只有这样，才能正常使用新模型。这是因为，持久化存储区协调器会试着用新版本的模型来打开原有的存储区
            ，但是由于原有的存储区是用旧版本模型创建的，所以操作会失败。在向NSPersistentStoreCoordinator添加存储区时，只需要将下列选项放在NSDictionary里，
            即可自动完成迁移工作：
        1.如果传给NSPersistentStoreCoordinator的NSMigratePersistentStoresAutomaticallyOption是YES，那么CoreData就会试着把低版本的（也就是与当前模型兼容的）
            持久化存储区迁移到最新版本的模型。
        2.如果传给NSPersistentStoreCoordinator的NSInferMappingModelAutomaticallyOption是YES，那么CoreData就会试着已最合理的方式自动推断出源模型实体中的
            某个属性到底对应于目标模型实体中的哪一个属性
        设置以上两个选项为YES 传给NSPersistentStoreCoordinator这种方式叫做轻量级迁移
        如果在开发CoreData程序是还是用了iCloud，那么只能采用这种迁移方式
 */

NS_ASSUME_NONNULL_BEGIN

@interface Measurement : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Measurement+CoreDataProperties.h"
