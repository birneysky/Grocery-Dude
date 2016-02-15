//
//  Item.m
//  Grocery Dude
//
//  Created by zhangguang on 15/8/5.
//  Copyright (c) 2015年 com.v2tech. All rights reserved.
//

#import "Item.h"

/*在应用程序的进化中，其托管对象模型也可能需要改变。对于一些比较简单的修改，
 诸如设定属性的默认值，设定验证规则，使用获取请求模板等，是直接可以实施的。
 而对于一些结构化的修改，则需要先把持久化存储区迁移到新的模型版本才行。加入没有提供迁移数据所需的映射和设定，那么应用程序就会奔溃。
 如按照下列步骤修改，即可引发模型不兼容错误：
 1.运行 Grocery Dude ，确保程序用现有模型创建持久化存储区。
 2.在Model.xcdatamodel文件中新建实体“Measurement”
 3.在MeasureMent实体中，添加名“abc"的属性，类型设置为string
 4.重新运行应用程序，
 对于开发初期的应用程序来说，这种奔溃不算什么，我们只需把程序删除，并重新运行就ok
 删除之后，程序将按照新修改的模型来创建持久化存储区，这样存储区和模型就兼容了，程序不会奔溃了，
 但是这样做也会失去存储区里面原有的数据。
 */

@implementation Item

@dynamic name;
@dynamic quantity;
@dynamic photoData;
@dynamic listed;
@dynamic collected;

@end
