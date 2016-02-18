//
//  ItemViewController.h
//  Grocery Dude
//
//  Created by zhangguang on 16/2/17.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

/*ScrollView 与 Autolayout
 
    当涉及到 ScrollView 时，以前没问题的约束在这就出现了错误，看到 Storyboard 错误提示：ScrollView has ambiguous scrollable content height
    UIScrollView 有一个 contentSize 属性，其定义了 ScrollView 可滚动内容的大小，用纯代码写的时候，我们会直接对这个属性赋值，定义其大小。
    在 Autolayout 下，UIScrollView 的 contentSize 是由其内容的约束来定义的。 ScrollView中subview设置的约束，不仅起到布局自身的作用，
    同时也起到了定义 ScrollView 可滚动范围的作用(contentSize)
    当你用subview 的 leading/trailing/top/bottom 来互相决定其大小的时候，就会出现“ScrollView has ambiguous scrollable content height”
    聪明的做法是在 UIScrollView 和它原来的 subviews 之间增加一个 content view：这样的好处是：
    1.通过设置Content View的Size来调整ScrollView的contentsize；（通常可以设置Content View的Size与ScrollView的size 相等）
 
 */

@interface ItemViewController : UIViewController

@property (nonatomic,strong) NSManagedObjectID* selectedItemID;

@end
