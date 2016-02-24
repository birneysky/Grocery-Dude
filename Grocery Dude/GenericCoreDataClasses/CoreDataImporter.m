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
    
    NSDictionary* attributeValues = [NSDictionary dictionaryWithObject:values forKey:attributes];
    
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

@end
