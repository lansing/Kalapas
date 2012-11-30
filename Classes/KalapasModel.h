//
//  OllieRESTModel.h
//  Ollie
//
//  Created by Max Lansing on 5/30/12.
//  Copyright (c) 2012 Empire Mining. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AFHTTPRequestOperation;
@class KalapasJSONClient;

@interface KalapasModel : NSObject

@property (readonly) NSDictionary * serializationDict;
@property (readonly) NSArray * serializeProperties;
@property (readonly) NSString * resourceID;

+(NSString *)modelPathUnderscoreSingular;
+(NSString *)modelPathUnderscorePlural;
+(NSDictionary *)associationTypeDict;
-(void)assignPropertiesFromDict:(NSDictionary *)propertyDict;

+(void)indexWithParameters:(NSDictionary *)parameters success:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure;
+(void)indexWithSuccess:(void (^)(NSArray * indexArray))success failure:(void (^)(NSError *error))failure;
-(void)showWithSuccess:(void (^)(id shownObject))success failure:(void (^)(NSError * error))failure;
-(void)createWithSuccess:(void (^) (id createdObject))success failure:(void (^)(NSError *error))failure;
-(void)updateWithSuccess:(void (^)(id updatedObject))success failure:(void (^) (NSError * error))failure;
-(void)deleteWithSuccess:(void (^)(id deletedObject))success failure:(void (^) (NSError * error))failure;



+(NSURL *)remoteBaseURL;
+(KalapasJSONClient *)restClient;

@end
