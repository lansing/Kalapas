//
//  KalapasModel.h
//  Ollie
//
//  Created by Max Lansing on 5/30/12.
//  Copyright (c) 2012 Empire Mining. All rights reserved.
//

#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import "KalapasJSONClient.h"
#import "KalapasModel.h"
#import "NSString+Casing.h"
#import "NSObject+EMSelectorGoodies.h"
#import <objc/runtime.h>
#import "ISO8601DateFormatter.h"

@implementation KalapasModel

#pragma mark -
#pragma mark Remote Host and URL

+(NSURL *)remoteBaseURL {
  assert(false); //implement in sublass.
}

#pragma mark -
#pragma mark REST paths

+(NSString *)modelPathUnderscoreSingular {
  return [[[self class] description] dashedStringFromCamelCased];
}

+(NSString *)modelPathUnderscorePlural {
  return [[[self class] modelPathUnderscoreSingular] stringByAppendingString:@"s"];
}


#pragma mark -
#pragma mark Introspection

+(NSDictionary *)associationTypeDict {
  return nil;
}

+(Class)typeForRelatedModel:(NSString *)propertyKey {
  Class theClass = [[[self class] associationTypeDict] objectForKey:propertyKey];
  if (theClass == nil) {
    theClass = [[self class] classForPropertyKey:propertyKey];
  }
  return theClass;
}

-(KalapasModel *)relatedModelForProperty:(NSString*)propertyKey fromObj:(id)obj {
  Class relatedClass = [[self class] typeForRelatedModel:propertyKey];
  KalapasModel * model = [[relatedClass alloc] init];
  if ([obj isKindOfClass:[NSString class]]) {
    assert(false); //derp
  } else if ([obj isKindOfClass:[NSDictionary class]]) {
    [model assignPropertiesFromDict:obj];
  }
  return model;
}

#pragma mark -
#pragma mark Serialization

-(NSDictionary *)serializationDict {
  NSMutableDictionary * d = [[NSMutableDictionary alloc] init];
  
  [[self serializeProperties] enumerateObjectsUsingBlock:^(id propKey, NSUInteger idx, BOOL *stop) {  
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id val = [self performSelector:NSSelectorFromString((NSString *)propKey)];
#pragma clang diagnostic pop
    if ([val isKindOfClass:[NSDate class]]) {
      ISO8601DateFormatter * format = [[ISO8601DateFormatter alloc] init];
      format.includeTime = YES;
      val = [format stringFromDate:val];
    }
    if (val == nil) {
      val = [NSNull null];
    }
    [d setObject:val forKey:propKey];
  }];
  
  return [NSDictionary dictionaryWithDictionary:d];
}

-(NSArray *)serializeProperties {
  assert(false); //should be implemented in subclass.
  return nil;
}


#pragma mark -
#pragma mark Deserialization

-(void)assignPropertiesFromDict:(NSDictionary *)propertyDict {
  [propertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    if (obj == [NSNull null]) {
      obj = nil;
    }

    Class relatedClass = [[self class] typeForRelatedModel:key];
    if ([relatedClass isSubclassOfClass:[KalapasModel class]]) {
      if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray * tempArray = [[NSMutableArray alloc] init];
        for (id memberObj in obj) {
          KalapasModel * member = [self relatedModelForProperty:key fromObj:memberObj];
          [tempArray addObject:member];
        }
        obj = tempArray;
      } else {
        obj = [self relatedModelForProperty:key fromObj:obj];
      }
    }

    SEL setSet = [[self class] setSelectorFromString:key];
    if ([self respondsToSelector:setSet]) {
      Class propClass = [[self class] classForPropertyKey:key];
      if (propClass == [NSDate class]) {
        obj = [[[ISO8601DateFormatter alloc] init] dateFromString:obj];
      }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      [self performSelector:setSet withObject:obj];
#pragma clang diagnostic pop
    }
    
  }];
}

#pragma mark -
#pragma mark REST client defaults

+(KalapasJSONClient *)restClient {
  return [KalapasJSONClient clientWithBaseURL:[[self class] remoteBaseURL] resourcePath:[[self class]modelPathUnderscorePlural]];
}

-(NSString *)resourceID {
  assert(false); //must be implemented in subclass
}

#pragma mark -
#pragma mark REST methods

-(void)showWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure {
  KalapasJSONClient * client = [[self class] restClient];
  [client showResourceID:self.resourceID success:^(NSDictionary *resource) {
    [self assignPropertiesFromDict:resource];
    success(self);
  } failure:^(NSError *error) {
    failure(error);
  }];
}

-(void)createWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure {
  KalapasJSONClient * client = [[self class] restClient];
  [client create:self.serializationDict success:^(NSDictionary *resource) {
    [self assignPropertiesFromDict:resource];
    success(self);
  } failure:^(NSError *error) {
    failure(error);
  }];
}

+(void)indexWithParameters:(NSDictionary *)parameters success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
  KalapasJSONClient * client = [[self class] restClient];
  [client indexWithParameters:parameters
                      success:^(NSArray *resources) {
                        NSMutableArray * tempArray = [NSMutableArray arrayWithCapacity:[resources count]];
                        for (NSDictionary * itemDict in resources) {
                          KalapasModel * item = [[[self class] alloc] init];
                          [item assignPropertiesFromDict:itemDict];
                          [tempArray addObject:item];
                        }
                        success([NSArray arrayWithArray:tempArray]);
                      }
                      failure:failure];
}


+(void)indexWithSuccess:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
  [[self class] indexWithParameters:nil success:success failure:failure];
}

-(void)updateWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure {
  KalapasJSONClient * client = [[self class] restClient];
  [client updateResourceID:self.resourceID parameters:self.serializationDict success:^(NSDictionary *resource) {
    success(self);
  } failure:^(NSError *error) {
    failure(error);
  }];
}

-(void)deleteWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure {
  KalapasJSONClient * client = [[self class] restClient];
  [client deleteResourceID:self.resourceID withSuccess:^(NSDictionary *resource) {
    success(self);
  } failure:^(NSError *error) {
    failure(error);
  }];
}



@end
