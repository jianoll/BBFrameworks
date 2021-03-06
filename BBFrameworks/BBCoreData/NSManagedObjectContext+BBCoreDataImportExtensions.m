//
//  NSManagedObjectContext+BBImportExtensions.m
//  BBFrameworks
//
//  Created by William Towe on 4/18/15.
//  Copyright (c) 2015 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "NSManagedObjectContext+BBCoreDataImportExtensions.h"
#import "NSManagedObjectContext+BBCoreDataExtensions.h"
#import "BBFoundationDebugging.h"
#import "BBFoundationFunctions.h"
#import "BBSnakeCaseToLlamaCaseValueTransformer.h"
#import "BBDefaultManagedObjectEntityMapping.h"
#import "BBDefaultManagedObjectPropertyMapping.h"

#import <objc/runtime.h>

@interface NSManagedObjectContext (BBCoreDataImportExtensionsPrivate)
+ (NSMutableDictionary *)_BB_propertyMappingDictionary;
@end

@implementation NSManagedObjectContext (BBImportExtensions)

static void *kBB_defaultIdentityKey = &kBB_defaultIdentityKey;
+ (NSString *)BB_defaultIdentityKey; {
    return objc_getAssociatedObject(self, kBB_defaultIdentityKey);
}
+ (void)BB_setDefaultIdentityKey:(NSString *)key; {
    objc_setAssociatedObject(self, kBB_defaultIdentityKey, key, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

static void *kBB_defaultDateFormatterKey = &kBB_defaultDateFormatterKey;
+ (NSDateFormatter *)BB_defaultDateFormatter; {
    NSDateFormatter *retval = objc_getAssociatedObject(self, kBB_defaultDateFormatterKey);
    
    if (!retval) {
        static NSDateFormatter *kRetval;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            kRetval = [[NSDateFormatter alloc] init];
            
            [kRetval setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
        });
        
        retval = kRetval;
    }
    
    return retval;
}
+ (void)BB_setDefaultDateFormatter:(NSDateFormatter *)dateFormatter; {
    objc_setAssociatedObject(self, kBB_defaultDateFormatterKey, dateFormatter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSDictionary *)BB_propertyMappingForEntityNamed:(NSString *)entityName; {
    return [self _BB_propertyMappingDictionary][entityName] ?: [[BBDefaultManagedObjectPropertyMapping alloc] init];
}
+ (void)BB_registerPropertyMapping:(NSDictionary *)propertyMapping forEntityNamed:(NSString *)entityName; {
    [[self _BB_propertyMappingDictionary] setObject:propertyMapping forKey:entityName];
}

- (NSManagedObject *)BB_managedObjectWithDictionary:(NSDictionary *)dictionary entityName:(NSString *)entityName propertyMapping:(id<BBManagedObjectPropertyMapping>)propertyMapping error:(NSError *__autoreleasing *)error; {
    NSParameterAssert(dictionary);
    NSParameterAssert(entityName);
    NSParameterAssert(propertyMapping);
    
    NSString *const kIdentityKey = [self.class BB_defaultIdentityKey];
    id identity = dictionary[[propertyMapping JSONKeyForEntityPropertyKey:kIdentityKey entityName:entityName]];
    
    NSParameterAssert(identity);
    
    NSError *outError;
    NSManagedObject *retval = [self BB_fetchEntityNamed:entityName predicate:[NSPredicate predicateWithFormat:@"%K == %@",kIdentityKey,identity] sortDescriptors:nil limit:1 error:&outError].firstObject;
    
    if (!retval) {
        if (outError) {
            *error = outError;
            
            return nil;
        }
        
        retval = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self];
        
        [retval setValue:identity forKey:kIdentityKey];
        
        BBLog(@"created entity %@ with identity %@",entityName,identity);
    }
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *JSONKey, id JSONValue, BOOL *stop) {
        NSString *const kPropertyKey = [propertyMapping entityPropertyKeyForJSONKey:JSONKey entityName:entityName];
        id const kPropertyValue = [propertyMapping entityPropertyValueForEntityPropertyKey:kPropertyKey value:JSONValue entityName:entityName context:self];
        
        [retval setValue:kPropertyValue forKey:kPropertyKey];
    }];
    
    return retval;
}

- (void)BB_importJSON:(id<NSFastEnumeration,NSObject>)JSON entityOrder:(NSArray *)entityOrder entityMapping:(id<BBManagedObjectEntityMapping>)entityMapping completion:(void(^)(BOOL success, NSError *error))completion; {
    NSParameterAssert([JSON isKindOfClass:[NSDictionary class]] || (JSON && entityOrder.count > 0));
    
    if (!entityMapping) {
        entityMapping = [[BBDefaultManagedObjectEntityMapping alloc] init];
    }
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [context setUndoManager:nil];
    [context setParentContext:self];
    [context performBlock:^{
        NSMutableArray *entityNames = [[NSMutableArray alloc] init];
        
        if ([JSON isKindOfClass:[NSDictionary class]]) {
            if (entityOrder.count > 0) {
                [entityNames addObjectsFromArray:entityOrder];
            }
            else {
                [entityNames addObjectsFromArray:[(NSDictionary *)JSON allKeys]];
            }
            
            for (NSString *JSONEntityName in entityNames) {
                NSString *const kEntityName = [entityMapping entityNameForJSONEntityName:JSONEntityName];
                id<BBManagedObjectPropertyMapping> const kPropertyMapping = [self.class BB_propertyMappingForEntityNamed:kEntityName];
                NSArray *const kEntityDicts = [(NSDictionary *)JSON objectForKey:JSONEntityName];
                
                for (NSDictionary *entityDict in kEntityDicts) {
                    NSError *outError;
                    if (![context BB_managedObjectWithDictionary:entityDict entityName:kEntityName propertyMapping:kPropertyMapping error:&outError]) {
                        BBLogObject(outError);
                    }
                }
            }
        }
        else {
            [entityNames addObjectsFromArray:entityOrder];
            
            NSString *const kEntityName = [entityMapping entityNameForJSONEntityName:entityOrder.lastObject];
            id<BBManagedObjectPropertyMapping> const kPropertyMapping = [self.class BB_propertyMappingForEntityNamed:kEntityName];
            
            for (NSDictionary *entityDict in JSON) {
                NSError *outError;
                if (![context BB_managedObjectWithDictionary:entityDict entityName:kEntityName propertyMapping:kPropertyMapping error:&outError]) {
                    BBLogObject(outError);
                }
            }
        }
        
        NSError *outError;
        if ([context BB_saveRecursively:&outError]) {
            if (completion) {
                BBDispatchMainSyncSafe(^{
                    completion(YES,nil);
                });
            }
        }
        else {
            if (completion) {
                BBDispatchMainSyncSafe(^{
                    completion(NO,outError);
                });
            }
        }
    }];
}

@end

@implementation NSManagedObjectContext (BBImportExtensionsPrivate)

static void *kBB_registerPropertyMappingForEntityNamed = &kBB_registerPropertyMappingForEntityNamed;
+ (NSDictionary *)_BB_propertyMappingDictionary; {
    NSDictionary *retval = objc_getAssociatedObject(self, kBB_registerPropertyMappingForEntityNamed);
    
    if (!retval) {
        objc_setAssociatedObject(self, kBB_registerPropertyMappingForEntityNamed, [[NSMutableDictionary alloc] init], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return retval;
}

@end