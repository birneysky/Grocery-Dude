//
//  Amount.h
//  Grocery Dude
//
//  Created by zhangguang on 16/2/15.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/*默认的迁移方式
        有时候我们需要比轻量级迁移更为精细的控制手段。比方说，
        我们要把Measurement实体替换成另外一个名叫Amount的实体，并且还想把Measurement实体中abc属性迁移到Amount实体的xyz上
        abc中已有的数据也要迁移到xyz属性。
        为了完成这些需求，开发者需要创建模型映射，以便手工指明映射关系.
        在添加持久化存取区时，即便NSInferMappingModelAutomaticallyOption设置为YES，coredata也还是会先检测有没有文件，如果有的话
        ，那么在执行自动推断前，它会先试着使用这个文件来迁移，在测试映射模型钱，建议先关闭该选项，这样才可以确定映射模型是不是已经付诸使用并且能正常工作了
    操作步骤：
        1.NSInferMappingModelAutomaticallyOption 设置为NO
        2.根据Model2版本来创建新版本模型 命名为Model3
        3.删除Measurement，新建Amount 实体，添加xyz属性，类型为String
        4.Model3 设置为当前版本
        5.创建Amount子类
        6.运行程序，程序奔溃
    为了解决错误，我们需要创建映射模型，已指明字段之间的映射关系。具体到本例来说，就是要把旧模型中Measurement中的abc属性迁移为Amount中xyz
    操作步骤如下:
    1. 确保CoreDataModel为选中状态
    2. File->new->file
    3. 选择IOS->CoreData->Mapping Model,next
    4. 把Model2.xcdatamodel选为Source Data Model ,next
    5. 把Model3.xcdatamodel选为Target Data Model，next
    6. 将mapping model的名称设置为Model2toModel3，create
    8. 打开Model2toModel3.xcmappingmodel文件
    9. 在ENTITY MAPPINGS中选定Amount
    10. 点击View->Utilities->Show Maping Model Inspector （option + command + 3）
    11. 在Entity Maping 区域中，把Amount实体Source设置成Measurement
    12. 如果要实现更复杂的迁移方式，那么可以在Cuntom Policy文本框中输入类名,这个类应该是NSEntityMigrationPolicy的子类
        在该子类中复写CreateDestinationInstancesForSourceInstance方法而操作待迁移的数据。
            比方说，可以拦截abc这个属性的值，将其中每个单词的首字母改为大写，然后把修改过的值迁移到xyz属性
        Maping Model Inspector  底部的Source Fetch选项可通过谓词（在Filter Predicate文本框中输入）限定迁移过来的数据量。
        假如只想把旧数据中的一部分迁移过来，那么这个选项就很有用了，此处的谓词格式与通常代码中编写的谓词相似，只不过要用$source变量来表示源数据。
        比方说，如果想把abc属性为nil的源数据排除掉，那么可将谓词写成$source.abc != nil.

        打开Model2toModel3.xcmappingmodel中的ItemToItem实体，观察属性映射中的内容，会看到目标实体中每个属性都设置有对应的Value Expression
        现在再来查看MeasurementToAmount实体的映射，会发现xyz这个Destinatin属性并没有设置Value Expression。这就意味着xyz目前没有对应的Source属性，
        需要按照ItemToItem实体映射中的那种格式，给他设置一条Value Expression
    13. 给名为xyz的Destination属性设置适当的Value Expression：
        13.1 在MeasurementToAmount实体映射界面中，把xyz这个Destination属性的Value Expression 设置为$source.abc.
             现在迁移模型已经配置好了，但demo方法仍然会从Measurement实体获取数据，而在新模型中，是没有这个实体的，所以demo方法应该使用Amout实例
 
 */


NS_ASSUME_NONNULL_BEGIN

@interface Amount : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Amount+CoreDataProperties.h"
