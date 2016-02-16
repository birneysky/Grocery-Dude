//
//  Unit.h
//  Grocery Dude
//
//  Created by zhangguang on 16/2/16.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/*
 托管对象模型的扩展
    1. 关系
            关系是用来连接实体的，在托管对象模型中使用关系，可以大幅降低数据库对容量的需求。
            如果不使用关系，那么同样的数据就可能会在多个实体中重复出现。
            消除重复确实是关系的一项优势，但其真正强大的地方在于：他可以在复杂的数据类型之间建立连接。
            
            以模型中的Item实体和Unit实体为例， Item表示购物清单中的货品，比如 Chocolate（巧克力） Potatoes(土豆) Milk(牛奶)
            Unit 实体则用来表示 g, Kg, ml 等计量单位，这些计量单位及其数值可以添加到Item里面，
            比方说：250g Chocolate
                   4Kg Potatoes
                   500ml Milk
            当然可以在Item实体里面添加名为Unit的属性，并把它设置为字符串类型。然后针对每个Item对象都生成一个字符串，其中写上某种计量单位，g kg ml等
            但这种做法的问题在于，它会浪费数据库的存储空间，因为这些Item的unit属性里，保存着大量的重复数据。除了浪费空间这个缺点之外，加入要更新所有Item的unit属性，
            那也是件麻烦事。比如说，现在要将计量单位从Kg 改为 kilogram ，那就得遍历所有的Item，并且逐个修改其中的字符串。这样做效率很低。
            解决办法是：用指向Unit实体的“关系”来取代这种字符串，该“关系”其实就是指向kg对象的指针，而数据库里只需要保存一份这样的Kg对象就好了
            这不仅降低了数据所占用的存储空间，而且还有个好处，就是若要改动计量单位的名称，则只需修改一个对象即可
            
            实现步骤：
            1.创建新的模型版本 Model5，将其设置为当前模型
            2.选定Model5 将其Editor Style切换为Graph
            3，按住Ctrl键，从Item向Unit拖一条线
 
            当处于Graph风格时，在两实体间创建的关系是双向关系，也就是说，两个实体之间的这种双向关系其实是由两条方向相反的关系组成的。
            在本例中，一条关系是从Item指向Unit，另一条是从Unit指向Item
            如果在Table风格时，创建出的关系是单向关系，此时如果需要建立双向关系，必须手动添加反向的那一条关系才行
 
            设置好双向关系之后，执行下列操作
            1. 将Item托管对象关联到Unit托管对象
            2. 将Unit托管对象关联到Item托管对象
            将两个实体关系起来之后，我们就可以通过关系来访问相关实体的属性了（比方说 Item.newRelationship.name）
            
            接下来需要考虑的问题是：每个方向上的关系是一对多的还是一对一的？
            现在考虑从Item到Unit方向的关系：
                假设从Item实体到Unit实体的关系是一对多的，那就意味着，每个Item都可以无数种计量单位，这不太合适，因为购物清单上的货品只需要一种计量单位就可以了
                注意：也可以限定一对多关系所能关联的对象个数上限
                
                如果从Item实体到Unit实体的关系是一对一的，每个Item就只有一种计量单位，这比较合适。由此从Item到Unit方向的关系的名称叫做unit比较合适，
                把名称从newRelationship改为unit之后，就可以通过item.unit.name来访问计量单位的名称了
 
            现在考虑从Unit到Item的“关系”：
                假设从Unit到Item的关系是一对一的，那就意味着，每一种计量单位只能由一件货品来使用，这显然不合适，
                相反考虑，一种计量单位可以供无数货品使用，这是合理的，由此Unit到Item的关系应该叫做items，unit.items 返回的NSSet中有很多指针，每个指针都指向使用该计量单位的获评
 
            修改步骤：
                1. 从Item指向Unit实体的newRelationship改名为unit
                2. 从Unit指向Item实体的newRelationship改名为items
                3. 把items这条关系的Type改成To-Many
 
        现在已经明白：关系的名称要和它所提供的某种访问能力相符。但是在使用，item.unit 以及 unit.items来访问关系目标对象之前，
        必须先为这些实体创建相应的NSManagedObject子类。另外如果在配置“一对多关系“时，勾选了Ordered选项时，那么在NSManagedObject子类里面对应的特性类型就会成为NSOrderedSet
    2. Delete规则
        在配置关系时，一定要注意Delete Rule。当我们删除某个对象时，该规则决定了与之相关的那些对象应该如何处理。
        可选择的“Delete 规则” 有以下几种
        2.1 Nullify  大多数情况都可以采用这种默认的Delete规则。如果删除了某个对象，而该对象与其他对象的关系又受制于“Nullify规则”，那么这些对象就会把指向该对象的“关系”清空。
                     比方说，有个名叫Kg的unit对象，它关联着一些Item对象。假如items关系的Delete规则是NUllify，那么当把这个名为Kg的unit对象删掉之后，与它相关的那些Item对象
                     就会将其unit特性设为nil
        2.2 Cascade 这种Delete规则会沿着关系来传播删除操作。比如说，有个名叫Kg的unit对象，它关联着一些Item对象，如果items关系的Delete规则是Cascade,
                    那么当把这个名为Kg的unit对象删掉之后，与它相关的所有item对象也会被删除。
        2.3 Deny 如果已经有其他对象与某对象相关联，那么这种规则会组织开发者删除该对象，比如，有个名叫Kg的unit对象，它关联着一下item对象，如果items关系为Deny，当开发者把这个kg对象
                 删除并试图将改动保存到上下文时，系统就会发现目前仍有item对象与之相关联，从而引发 validation error（验证错误）。
                 假如把某条关系的delete规则设置为deny，那么在删除对象之前，开发者需要确保程序里面已经没有与该对象通过该关系相关联的对象。
        2.4 No Action 这是一种奇怪的Delete规则，他会导致对象图处于不一致状态（inconsistent state） 
                      如果用了这条规则，那么删除某个对象之后，开发者必须手动设定反向的关系，已确保他们都指向有效的对象。只有再极个别的情况下才需要使用这种Delete规则。
        为了测试删除对象之后的效果，在Appdelegate.m添加一个新方法（showUnitAndItemCount），用来显示持久化存储区里的unit对象以及item对象的个数
 */

NS_ASSUME_NONNULL_BEGIN

@interface Unit : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Unit+CoreDataProperties.h"
