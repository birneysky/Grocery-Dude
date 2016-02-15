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
        为了完成这些需求，开发者需要创建模型映射，以便手工指明映射关系
 */


NS_ASSUME_NONNULL_BEGIN

@interface Amount : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Amount+CoreDataProperties.h"
