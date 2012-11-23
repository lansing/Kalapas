//
//  KalapasJSONClient.h
//  Ollie
//
//  Created by Max Lansing on 11/11/12.
//  Copyright (c) 2012 Empire Mining. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperation;
@protocol AFMultipartFormData;

@interface KalapasJSONClient : NSObject

+(KalapasJSONClient *)clientWithBaseURL:(NSURL *)baseURL resourcePath:(NSString *)resourcePath;

-(NSString *)indexPath;
-(NSString *)createPath;
-(NSString *)updatePath:(NSString *)resourceID;
-(NSString *)deletePath:(NSString *)resourceID;
-(NSString *)showPath:(NSString *)resourceID;
 
-(NSURL *)indexURL;
-(NSURL *)createURL;
-(NSURL *)updateURL:(NSString *)resourceID;
-(NSURL *)deleteURL:(NSString *)resourceID;
-(NSURL *)showURL:(NSString *)resourceID;
 


-(void)indexWithSuccess:(void (^)(NSArray * resources))success failure:(void (^)(NSError *error))failure;
-(void)create:(NSDictionary *)createDict success:(void (^) (NSDictionary * resource))success failure:(void (^)(NSError *error))failure;
-(void)showResourceID:(NSString *)resourceID success:(void (^)(NSDictionary * resource))success failure:(void (^)(NSError *error))failure;
-(void)updateResourceID:(NSString *)resourceID parameters:(NSDictionary *)updateDict success:(void (^)(NSDictionary * resource))success failure:(void (^) (NSError * error))failure;
-(void)deleteResourceID:(NSString *)resourceID withSuccess:(void (^)(NSDictionary * resource))success failure:(void (^) (NSError * error))failure;


-(NSMutableURLRequest *)request:(NSURL *)url;
-(NSMutableURLRequest *)request:(NSURL *)url body:(NSData *)body;
-(NSMutableURLRequest *)postRequest:(NSURL *)url body:(NSData *)body;
-(NSMutableURLRequest *)putRequest:(NSURL *)url body:(NSData *)body;
-(NSMutableURLRequest *)deleteRequest:(NSURL *)url;
-(NSMutableURLRequest *)multipartFormRequest:(NSURL *)url constructingBodyWithBlock:(void(^)(id<AFMultipartFormData> formData))block;

-(void)performRequest:(NSURLRequest *)request success:(void (^)(AFHTTPRequestOperation * operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failure;

-(void)post:(NSURL *)url body:(NSData *)body success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
-(void)put:(NSURL *)url body:(NSData *)body success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
-(void)get:(NSURL *)url success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
-(void)deleteRemote:(NSURL *)url success:(void (^)(AFHTTPRequestOperation * operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failure;
-(void)upload:(NSURL *)url files:(NSArray *)filePaths withNames:(NSArray *)fileNames withFormDatas:(NSArray *)formDatas withFormNames:(NSArray *)formNames withSuccess:(void (^)(AFHTTPRequestOperation * operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failure uploadProgress:(void (^)(NSUInteger, long long, long long))uploadProgress;


@property NSTimeInterval timeoutInterval;
@property NSURLRequestCachePolicy cachePolicy;
@property NSURL * baseURL;
@property NSString * resourcePath;

@end
