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

/*为了支持深拷贝，我们必须增强CoreDataImporterl类的功能，使其可以完成“拷贝托管对象”这种比较复杂的流程。
 还必须支持三种类型的关系，也就是一对一关系，一对多关系，以及有序的一对多关系。
 鉴于整个流程比较复杂，所以将其分解成几个部分。
 */

@end
