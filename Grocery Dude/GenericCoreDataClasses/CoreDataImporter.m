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

- (void)establishOneToOneRelationship:(NSString*)relationshipName
                           fromObject:(NSManagedObject*)object
                             toObject:(NSManagedObject*)relatedObject
{
    if (!relationshipName || !object || !relatedObject) {
        DebugLog(@"SKipped establishing  One-To-One relationship '%@' between '%@' and '%@'" ,relationshipName,[self objectInfo:object],[self objectInfo:relatedObject]);
        NSLog(@"Dude to missing Info!");
        return;
    }
    
    NSManagedObject* existingRelatedObject = [object valueForKey:relationshipName];
    if (existingRelatedObject) {
        return;
    }
    
    NSDictionary* relationships = [object.entity relationshipsByName];
    NSRelationshipDescription* relationship = [relationships objectForKey:relationshipName];
    if (![relatedObject.entity isEqual:relationship.destinationEntity]) {
        DebugLog(@"%@ is the of wrong entity type to relate to %@",[self objectInfo:object],[self objectInfo:relatedObject]);
        return;
    }
    
    //建立关系
    
    [object setValue:relatedObject forKey:relationshipName];
    DebugLog(@"ESTABLISHED %@ relationship from %@ to %@",relationshipName,[self objectInfo:object],[self objectInfo:relatedObject]);
    [CoreDataImporter saveContext:relatedObject.managedObjectContext];
    [CoreDataImporter saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
    [relatedObject.managedObjectContext refreshObject:relatedObject mergeChanges:NO];
}

/*该方法负责创建对象的一对多关系。
 传给该方法的对象应该位于深拷贝操作的目标上下文中。
 传给该方法的NSMutableSet里面应该包含源上下文中的对象。
 在建立新关系的过程中，此方法会根据需要，在目标上下文里面创建缺失的对象
 
 创建一对多的关系的办法是：把sourceSet中对象添加到另一个对象的NSMutableSet里面，
 而那个NSMutableSet正是用来表示这一关系的。我们通过对象的键值来访问NSMutableSet。
 关系名称是键，NSMutableSet是值。由于NSMutableSet只能包含互不相同的对象，
 所以不必担心无意间为某个对象创建了重复的关系。
 */

- (void)establishToManyRelationship:(NSString*)relationshipName
                           fromObject:(NSManagedObject*)object
                        withSourceSet:(NSMutableSet*)sourceSet
{
    if (!object || !sourceSet || !relationshipName) {
        DebugLog(@"SKipped establishing a To-Many relationship from %@",[self objectInfo:object]);
        TRACE(@"Due to missing info!");
        return;
    }
    
    NSMutableSet* copiedSet = [object mutableSetValueForKeyPath:relationshipName];
    
    for (NSManagedObject* relatedObject in sourceSet) {
        NSManagedObject* copiedRelatedObject = [self copyUniqueObject:relatedObject toContext:object.managedObjectContext];
        if (copiedRelatedObject) {
            [copiedSet addObject:copiedRelatedObject];
            DebugLog(@"A Copy of %@ is now related via To-Many '%@' relationship to %@",[self objectInfo:object],relationshipName,[self objectInfo:copiedRelatedObject]);
        }
    }
    
    [CoreDataImporter saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
    
}

/*
 建立有序的一对多关系
 传给该方法的NSMutableOrderedSet应该包含在应该包含源上下文里的对象。
 在建立新关系的过程中，该方法会根据需要，在目标上下文中创建缺失的对象。
 有序的一对多关系的建立方式为：把sourceSet里的对象添加到另一个对象的NSMutableOrderedSet里面，
 而那个NSMutableOrderedSet正是用来表示这一关系的。通过键值对来访问NSMutableOrderedSet。键是“关系”的名称
 值是NSMutableOrderedSet。目标上下文中的那个NSMutableOrderedSet其对象的顺序要和上下文中对应的NSMutableOrderedSet相符。
 根据在sourceSet中所找到的对象来创建等价对象，并依次将其添加到目标对象的NSMutableOrderedSet里，以保证他们的顺序与sourceSet相符。
 */

- (void)establishOrderedToManyRelationship:(NSString*)relationshipName
                                fromObject:(NSManagedObject*)object
                             withSourceSet:(NSMutableOrderedSet*)sourceSet {
    if (!object || !sourceSet || !relationshipName) {
        DebugLog(@"SKipped establishment of an Ordered To-Many relationship from %@",[self objectInfo:object]);
        TRACE(@"Due to missing Info");
        return;
    }
    
    NSMutableOrderedSet* copiedSet = [object mutableOrderedSetValueForKey:relationshipName];
    
    for (NSManagedObject* relatedObject in sourceSet) {
        NSManagedObject* copiedRelatedObject = [self copyUniqueObject:relatedObject toContext:object.managedObjectContext];
        if (copiedRelatedObject) {
            [copiedSet addObject:copiedRelatedObject];
            DebugLog(@"A Copy of %@ is related via Order To Many '%@' relationship to %@",[self objectInfo:object],relationshipName,[self objectInfo:copiedRelatedObject]);
        }
    }
    
    [CoreDataImporter saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
}

/*
 该方法负责把源上下文里某个对象的全部关系都拷贝到目标上下文里的等价对象中。上面的方法都是为了编写这个方法而实现的
 在确认了开发者所传入的sourceObject以及targetContext参数都不是nil之后
 该方法首先判断目标上下文中有没有与sourceObject相等价的对象。这个等价的对象称为copiedObject，我们用早前实现好的copyUniqueObject方法来创建它。
 假如在尝试了copyUniqueObject方法之后copiedObject依然为nil，那么该方法返回。
 在拷贝关系的时候，该方法首先用[sourceObject.entity relationshipsByName]查出源对象所具备的各种关系，
 然后在获取到的NSDictionary里面遍历，找出源对象有效的关系。
 假如源对象确实具备某条关系，那我们就在copiedObject上面重新创建与之等价的关系。
 在拷贝某条关系之前，还得确定其类型。假如是一对多关系或者有序有序的一对多关系，那么就把适当的sourceSet传给establishToManyRelationship或者establishOrderedToManyRelationship方法，以拷贝此关系。假如是一对一关系，那就先把相关联的对象拷贝到目标上下文里，然后再调用相应的方法来建立关系。
 */
- (void)copyRelationshipsFromObject:(NSManagedObject*)sourceObject
                          toContext:(NSManagedObjectContext*)targetContext
{
    if (!sourceObject || !targetContext) {
        DebugLog(@"Failed to copyRelationships from '%@' to context '%@'",[self objectInfo:sourceObject],targetContext);
        return;
    }
    
    NSManagedObject* copiedObject = [self copyUniqueObject:sourceObject toContext:targetContext];
    if (!copiedObject) {
        return;
    }
    
    NSDictionary* relationships = [sourceObject.entity relationshipsByName];
    for (NSString* relationshipName in relationships) {
        NSRelationshipDescription* relationship = [relationships objectForKey:relationshipName];
        if ([sourceObject valueForKey:relationshipName]) {
            if (relationship.isToMany && relationship.isOrdered) {
                NSMutableOrderedSet* sourceSet = [sourceObject mutableOrderedSetValueForKey:relationshipName];
                [self establishOrderedToManyRelationship:relationshipName fromObject:copiedObject withSourceSet:sourceSet];
            }
            else if (relationship.isToMany && !relationship.ordered){
                NSMutableSet* sourceSet = [sourceObject mutableSetValueForKey:relationshipName];
                [self establishToManyRelationship:relationshipName fromObject:copiedObject withSourceSet:sourceSet];
            }
            else{
                NSManagedObject* relatedSourceObject = [sourceObject valueForKey:relationshipName];
                NSManagedObject* relatedCopiedObject = [self copyUniqueObject:relatedSourceObject toContext:targetContext];
                [self establishOneToOneRelationship:relationshipName fromObject:copiedObject toObject:relatedCopiedObject];
            }
        }
    }
}

/*对实体进行深拷贝。
 deepCopyEntities方法，根据给定的实体，把全部对象从一个上下文拷贝到另一个上下文之中。
 实现该方法的具体办法有很多种，而用户对这些办法体验也各有不同。在网上搜索core data programming guide:efficently importing data,
 应该会找到一篇由apple所写的编程指南，其中讨论了导入数据所用的技术。那边文章里面说，应该尽量先把所有的对象都一次性拷贝过去，然后再修正他们之间的“关系”。
 有些应用程序能够使用这个办法，另外一些程序也不行。导入数据会比较耗时，假如导入时没有建立关系，哪怕只有几秒钟的时间，用户也可能会认为程序出了bug。
 为了应对这一问题，我们有下面几种解决办法（用户可以根据应用程序的性质来决定具体方案）：
    1 禁止用户使用应用程序的部分功能或者全部功能。
        在导入数据时，可以通过MBProgressHUD 等方式来显示导入进度。如果导入时间过长，用户可能会着急。
        所以，对于某些应用程序来说，在导入数据时也许并不能把全部功能都禁用，而是只能禁用其中一部分功能，
        等数据导入好之后，在将其重新启用
    2 先导入所有对象，然后在建立关系。
        如果采用这个办法，那么用户可能会看到尚未完全导入的数据，这些数据之间的“关系”可能刚刚建立，也可能还没有建立起来。
        该办法是否可行，要根据数据模型来定。
    3 把对象和关系一并导入。
        虽说这个办法的效率不如另外两种高，但是整个深拷贝的过程可以放在后台运行，这样的话，对用户造成的影响就非常小了，
        甚至根本不会影响用户。这种办法所消耗的设备电量会多一些，但却能使用户在导入数据的过程中继续操作应用程序。
 
 CoreDataImporter采用的办法是把对象和关系一并导入。每个对象的深拷贝操作都包裹在autorelease池中执行，
 这样的话，系统在数据导入过程中需要定期释放内存
 */

- (void)deepCopyEntities:(NSArray*)entities
             fromContext:(NSManagedObjectContext*)sourceContext
               toContext:(NSManagedObjectContext*)targetContext
{
    for (NSString* entity in entities) {
        DebugLog(@"Copying %@ objects to target context...",entities);
        NSArray* sourceObjects = [self arrayForEntity:entity inContext:sourceContext withPredicate:nil];
        for (NSManagedObject* sourceObject in sourceObjects) {
            @autoreleasepool {
                [self copyUniqueObject:sourceObject toContext:targetContext];
                [self copyRelationshipsFromObject:sourceObject toContext:targetContext];
            }
        }
    }
}

@end
