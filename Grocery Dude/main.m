//
//  main.m
//  Grocery Dude
//
//  Created by zhangguang on 15/8/5.
//  Copyright (c) 2015年 com.v2tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

/*应用程序功能
    1.分类显示家里各个位置的东西，以便提示你该购买哪些生活用品了
    2.在超市购物时，可以告诉你某件货品摆在哪条过道旁的货架上
    3.可以将待买物品按照过道编组，这样每条过道只需走一遍，即可拿完所需采购的货品。
    4.可以通过icloud在各个设备之间同步数据。
 */

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
