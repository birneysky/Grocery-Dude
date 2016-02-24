//
//  CoreDataImporter.h
//  Grocery Dude
//
//  Created by zhangguang on 16/2/24.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataImporter : NSObject

@property (nonatomic,strong) NSDictionary* entitiesWithUniqueAttributes;

+ (void)saveContext:(NSManagedObjectContext*)context;
/*uniqueAttributes 里的每一个键都是某一实体的名称，而对应的值就是属性，该属性用来判断是否有重复数据。*/
- (instancetype)initWithUniqueAttributes:(NSDictionary*)uniqueAttributes;

- (NSString*)uniqueAttributeForEntity:(NSString*)entity;

- (NSManagedObject*)insertUniqueObjectInTargetEntity:(NSString*)entity
                                uniqueAttributeValue:(NSString*)uniqueAttributeValue
                                      attributeValues:(NSDictionary*)attributeVlaues
                                           inContext:(NSManagedObjectContext*)context;

- (NSManagedObject*)insertBasicObjectInTargetEntity:(NSString*)entity
                              targetEntityAttribute:(NSString*)targetEntityAttribute
                                 sourceXMLAttribute:(NSString*)sourceXMLAttribute
                                      attributeDict:(NSDictionary*)attributeDict
                                            context:(NSManagedObjectContext*)context;

@end
