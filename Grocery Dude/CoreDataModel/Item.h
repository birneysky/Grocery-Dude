//
//  Item.h
//  Grocery Dude
//
//  Created by zhangguang on 15/8/5.
//  Copyright (c) 2015年 com.v2tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/*
 1.添加托管对象模型文件
    1.1 new group 取名为 CoreDataModel
    1.2 在Data Model组下 新建Data Model类型的文件，取名为Model.xcdatamodeld
 2.托管对象模型可以拥有一个或多个实体。实体的设计与传统数据库中数据表的设计是相似的。
    2.1 实体属性数据类型
        2.1.1  Interger16   -32768 -- 32767 NSNumber
               Interger32   -2147483648 -- 2147483647  INT32_MAX NSNumber
               Interger64   -9223372036854775808 -- 9223372036854775807 NSNumber
               通常可以选用Interger32
               CoreData 只使用带符号的整数，这样做的优点是既可以表示正值，又可以表示复制，缺点：最大值要比无符号数整数小
        2.1.2 单精度浮点数（float） 和双精度浮点数（double） NSNumber
               在涉及到“元” "分“ 等货币单位的财务运算中，则不应该他们，因为”舍入误差“会导致钱数出错。
        2.1.3 小数 decimal    NSDecimalNumner，如想保留精度，则只能使用NSDecimalNumber内置的方法。
               涉及货币或者其他十进制运算的场合中，建议使用“小数”数据类型，对于cpu来说，十进制并不是原生的数制，这就意味着以小数运算时，处理器会有比较大的开销
        2.1.4 字符串 NSString
        2.1.5 Boolean  yes/no
        2.1.6 日期类型  NSDate
               用来保存日期和时间
        2.1.7 二进制数据类型 NSData
               如果要保存照片，音频或者由 ‘0’，‘1’二进制位组成的连续块数据（BLOB）。
               存储照片时，可以通过 UIImagePNGRepresentation 或者  UIImageJPEGRepresentation 来把UIImage 转换成 NSData，或者是可以通过UIImage的imageWithData 转换回来
               二进制数据这种数据类型对于大文件来说比较合适，在该类型的设置选项中，我们可以开启 “Allows External Storage” 将其存储在数据库之外。启用这个选项，CoreData就会自行判断是吧文件存放在数据库内的效率高，
               还是存放到数据库外的效率高
        2.1.8 可变类型 id
               可变（Transfromable）数据类型很适合用来把objective-c对象存放在属性里。这种属性类型比较灵活，他可以存放任意类型的实例。比方说UIcolor类的实例就可以保存在这种类型的属性里
               若想把id对象放入存储区或者取出，则需要借助NSValueTransformer
 */

/*
 属性的各种设置选项说明
    1. Transient 如果勾选，该特性不会写入持久化存储区，不写入似乎很怪，但有时候，只需要把特性留在托管对象上下文里就行了。
    2. Optional  如果勾选，表示并不一定要有值，所有特性在刚创建时都是Optional的，如果是非Optional的，在放回存储区时，必须有值才行。
    3. Indexed   系统会优化Indexed特性以提升搜索效率，但代价是要在底层的持久化存储区中占用额外的空间。这些空间的大小取决于索引的数量
    4. Validation 阻止不合理的数据进入持久化存储区。如日期属性，可以限制日期的范围。
    5. Reg.Ex. 正则表达式，不仅能够限定字符串的最小长度以及最大长度，还能实现很多验证功能，一般来说，用来判断字符串值是不是与某个特性模式相匹配，匹配才能写入持久化存储区，表达式规范请参考：
    6. Default 除了可变数据类型和二进制数据之外，其余数据类型都可以具备默认值，如果开发者不指定具体的值，那他们的初始值就是默认值。
    7. Allows External Storage 启用会把数据量1MB的数据保存在持久化存储区之外。如果是xml存储区，该选项不起作用
    8. Indexed in Spotlight  mac专用，不影响ios，把基于Core Data 的mac应用程序同 Spotlight集成起来
    9. Name  如果某个属性为可变类型，那么名称这一栏中写的名称将会用NSValueTransfromer子类的名称，而这个子类会知道如何在任意的类与NSData 之间相互转化
 */

@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * quantity; //数量
@property (nonatomic, retain) NSData * photoData;
@property (nonatomic, retain) NSNumber * listed; //是否已出现在购物清单中
@property (nonatomic, retain) NSNumber * collected; //是否已经拿到了所要购买的物品

@end
