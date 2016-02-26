//
//  CoreDataImporter.m
//  Grocery Dude
//
//  Created by zhangguang on 16/2/24.
//  Copyright © 2016年 com.v2tech. All rights reserved.
//

#import "CoreDataImporter.h"

@implementation CoreDataImporter

#pragma mark - *** Apis ***
+ (void)saveContext:(NSManagedObjectContext*)context
{
    [context performBlockAndWait:^{
        if ([context hasChanges]) {
            NSError* error = nil;
            if ([context save:&error]) {
                TRACE(@"CoreDataImporter Saved changes from context to persistent store");
            }
            else{
                DebugLog(@"CoreDataImporter Falied to save changes from context to persistent sotre : %@",error);
            }
        }
        else{
            TRACE(@"CoreDataImporter Skipped saving context as there are no changes");
        }
    }];
}

- (instancetype)initWithUniqueAttributes:(NSDictionary*)uniqueAttributes
{
    if (self = [super init]) {
        self.entitiesWithUniqueAttributes = uniqueAttributes;
        assert(uniqueAttributes);
    }
    return self;
}

- (NSString*)uniqueAttributeForEntity:(NSString*)entity
{
    return [self.entitiesWithUniqueAttributes valueForKey:entity];
}

- (NSManagedObject*)insertUniqueObjectInTargetEntity:(NSString*)entity
                                uniqueAttributeValue:(NSString*)uniqueAttributeValue
                                     attributeValues:(NSDictionary*)attributeVlaues
                                           inContext:(NSManagedObjectContext*)context
{
    NSString* uniqueAttribute = [self uniqueAttributeForEntity:entity];
    if (uniqueAttributeValue.length > 0) {
        NSManagedObject* existObject = [self existingObjectInContext:context forEntity:entity withUniqueAttributeValue:uniqueAttributeValue];
        if (existObject) {
            DebugLog(@"%@ object with %@ value '%@' already exists",entity,uniqueAttribute,uniqueAttributeValue);
            return existObject;
        }
        else{
            NSManagedObject* newObject = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
            [newObject setValuesForKeysWithDictionary:attributeVlaues];
            DebugLog(@"Created %@ object with %@ '%@'",entity,uniqueAttribute,uniqueAttributeValue);
            return newObject;
        }
    }
    else{
        DebugLog(@"Skipped %@ object creation:unique attribute value is a lenght",entity);
    }
    return nil;
}

- (NSManagedObject*)insertBasicObjectInTargetEntity:(NSString*)entity
                              targetEntityAttribute:(NSString*)targetEntityAttribute
                                 sourceXMLAttribute:(NSString*)sourceXMLAttribute
                                      attributeDict:(NSDictionary*)attributeDict
                                            context:(NSManagedObjectContext*)context
{
    NSArray* attributes = [NSArray arrayWithObject:targetEntityAttribute];
    NSArray* values = [NSArray arrayWithObject:[attributeDict valueForKey:sourceXMLAttribute]];
    
    NSDictionary* attributeValues =[NSDictionary dictionaryWithObjects:values forKeys:attributes]; //[NSDictionary dictionaryWithObject:values forKey:attributes];
    
    return [self insertUniqueObjectInTargetEntity:entity uniqueAttributeValue:[attributeDict valueForKey:sourceXMLAttribute] attributeValues:attributeValues inContext:context];
}

#pragma mark - *** Helper ***

- (NSManagedObject*)existingObjectInContext:(NSManagedObjectContext*)context
                                  forEntity:(NSString*)entity
                   withUniqueAttributeValue:(NSString*)uniqueAttributesValue
{
    NSString* uniqueAttribute = [self uniqueAttributeForEntity:entity];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K==%@",uniqueAttribute,uniqueAttributesValue];
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchLimit:1];
    NSError* error ;
    NSArray* fethedReqults =[context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        DebugLog(@"Error:%@",error.localizedDescription);
    }
    
    if (fethedReqults.count == 0) {
        return nil;
    }
    return fethedReqults.lastObject;
}

#pragma mark - *** Deep Copy  ***
- (NSString*)objectInfo:(NSManagedObject*)object
{
    if (!object) {
        return nil;
    }
    NSString* entity = object.entity.name;
    NSString* uniqueAttribute = [self uniqueAttributeForEntity:entity];
    NSString* uniqueAttributeValue = [object valueForKey:uniqueAttribute];
    
    return [NSString stringWithFormat:@"%@ '%@'",entity,uniqueAttributeValue];
}

- (NSArray*)arrayForEntity:(NSString*)entity
                 inContext:(NSManagedObjectContext*)context
             withPredicate:(NSPredicate*)predicate
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:entity];
    [request setFetchBatchSize:50];
    [request setPredicate:predicate];
    NSError* error;
    NSArray* array = [context executeFetchRequest:request error:&error];
    if (error) {
        DebugLog(@"Error fetching objects: %@",error.localizedDescription);
    }
    return array;
}

/*该方法负责把对象拷贝到给定的上下文中，并且确保每个对象只拷贝一次。假如object 或者 targetContext参数是nil，那么该方法返回nil
 从技术角度上看，copyUniqueObject方法其实并诶有真的拷贝托管对象，
 它只是在目标上下文中新建一个对象，并把源对象的各种属性值拷贝到这个新对象而已。
 根据前面的知识，我们要用insertUniqueObjectInTargetEntity方法来确保每一个对象只插入一次。
 假如待插入的对象已经在targetContext里面了，那么该方法就直接将这个对象返回了。
 注意，对象间的关系并不在该方法里拷贝，因为要采用另一种方式来拷贝他们。
 */

- (NSManagedObject*)copyUniqueObject:(NSManagedObject*)object
                           toContext:(NSManagedObjectContext*)targetContext
{
    if (!object || !targetContext) {
        DebugLog(@"Failed to copy %@ to context %@",[self objectInfo:object],targetContext);
        return nil;
    }
    
    NSString* entity = object.entity.name;
    NSString* uniqueAttribute = [self uniqueAttributeForEntity:entity];
    NSString* uniqueAttributeValue = [object valueForKey:uniqueAttribute];
    
    if (uniqueAttributeValue.length > 0) {
        NSMutableDictionary* attributeValuesToCopy = [[NSMutableDictionary alloc] init];
        for (NSString* attribute in object.entity.attributesByName) {
            [attributeValuesToCopy setValue:[object valueForKey:attribute] forKey:attribute];
        }
        
        //copy object
        NSManagedObject* copiedObject = [self insertUniqueObjectInTargetEntity:entity
                                                          uniqueAttributeValue:uniqueAttributeValue
                                                               attributeValues:attributeValuesToCopy
                                                                     inContext:targetContext];
        return copiedObject;
    }
    
    return nil;
}

/*
 该方法会根据关系个名称来创建由一个对象指向另一对象的一对一关系。方法中的大部分代码都用于验证待创建的关系是否合法。
 假如配到下列三种情况之一，那么该方法就不创建关系：
    1.给定的源对象，目标关系名称为nil
    2.待创建的关系已经存在
    3.该关系所要关联的那个对象其实体类型与关系所要求的不符
 创建一对一关系只需要一行代码。这行代码用于设定对象上表示关系的那个键值对的值。
 其中，键是关系的名称，而值则是关系所关联的对象。
 该方法最后一部分要执行相当重要的清理工作，也就是要从每个上下文里面把指定对象的引用移除。
 保存好上下文之后，我们在每个对象的managedObjectContext上面调用refreshObject方法，把他们转成‘fault”。
 这样做可以把对象从内存中移走，于是也就能打破由强引用所构成的循环。假如不那么做，那么系统就会保留这些无用的对象，
 从而造成资源浪费。若是缺了这一步，那么所有的源数据都要载入内存，于是，“从持久化存储区中导入数据”的优势就体现不出来了，
 它也就和“从xml”中导入数据“没有什么区别了。虽说频繁调用save的开销是比较大的，但是确能使内存占用量变得小一些。
 此外，由于整个过程在后台执行，所以不会影响用户界面。
 */

@end
