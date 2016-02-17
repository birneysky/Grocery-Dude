//
//  ItemViewController.h
//  Grocery Dude
//
//  Created by zhangguang on 16/2/17.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ItemViewController : UIViewController

@property (nonatomic,strong) NSManagedObjectID* selectedItemID;

@end
