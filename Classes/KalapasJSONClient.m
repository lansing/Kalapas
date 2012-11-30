//
//  KalapasJSONClient.m
//  Ollie
//
//  Created by Max Lansing on 11/11/12.
//  Copyright (c) 2012 Empire Mining. All rights reserved.
//

#import "KalapasJSONClient.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

@implementation KalapasJSONClient

@synthesize timeoutInterval, cachePolicy, baseURL, resourcePath;

+(KalapasJSONClient *)clientWithBaseURL:(NSURL *)baseURL resourcePath:(NSString *)resourcePath {
  KalapasJSONClient * client = [[[self class] alloc] init];
  client.baseURL = baseURL;
  client.resourcePath = resourcePath;
  return client;
}

-(id)init {
  self = [super init];
  if (self) {
    self.timeoutInterval = 30;
    self.cachePolicy = NSURLRequestUseProtocolCachePolicy;
  }
  return self;
}

#pragma mark -
#pragma mark URL parameter encoding

+(NSString*)urlEscapeString:(NSString *)unencodedString
{
  CFStringRef originalStringRef = (__bridge_retained CFStringRef)unencodedString;
  NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, NULL,kCFStringEncodingUTF8);
  CFRelease(originalStringRef);
  return s;
}


+(NSURL*)addQueryStringToUrl:(NSURL *)url withDictionary:(NSDictionary *)dictionary
{
  NSMutableString * urlWithQueryString = [[NSMutableString alloc] initWithString:[url absoluteString]];
  
  for (id key in dictionary) {
    NSString *keyString = [key description];
    NSString *valueString = [[dictionary objectForKey:key] description];
    
    if ([urlWithQueryString rangeOfString:@"?"].location == NSNotFound) {
      [urlWithQueryString appendFormat:@"?%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
    } else {
      [urlWithQueryString appendFormat:@"&%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
    }
  }
  return [NSURL URLWithString:urlWithQueryString];
}

#pragma mark -
#pragma mark Resource locations

-(NSString *)showPath:(NSString *)resourceID {
  return [NSString stringWithFormat:@"/%@/%@", self.resourcePath, resourceID];
}

-(NSURL *)showURL:(NSString *)resourceID {
  return [NSURL URLWithString:[self showPath:resourceID] relativeToURL:self.baseURL];
}

-(NSString *)updatePath:(NSString *)resourceID {
  return [NSString stringWithFormat:@"/%@/%@", self.resourcePath, resourceID];
}

-(NSURL *)updateURL:(NSString *)resourceID {
  return [NSURL URLWithString:[self updatePath:resourceID] relativeToURL:self.baseURL];
}

-(NSURL *)createURL {
  return [NSURL URLWithString:[self createPath] relativeToURL:self.baseURL];
}

-(NSString *)createPath {
  return [NSString stringWithFormat:@"/%@", self.resourcePath];
}

-(NSURL *)deleteURL:(NSString *)resourceID {
  return [NSURL URLWithString:[self deletePath:resourceID] relativeToURL:self.baseURL];
}

-(NSString *)deletePath:(NSString *)resourceID {
  return [NSString stringWithFormat:@"/%@/%@", self.resourcePath, resourceID];
}

-(NSURL *)indexURL {
  return [NSURL URLWithString:[self indexPath] relativeToURL:self.baseURL];
}

-(NSString *)indexPath {
  return [NSString stringWithFormat:@"/%@", self.resourcePath];
}

#pragma mark -
#pragma mark REST methods

-(void)indexWithParameters:(NSDictionary *)parameters success:(void (^)(NSArray * indexArray))success failure:(void (^)(NSError *error))failure{
  NSURL * indexURL = self.indexURL;
  if (parameters != nil) {
    indexURL = [[self class] addQueryStringToUrl:indexURL withDictionary:parameters];
  }
  [self get:indexURL success:^(AFHTTPRequestOperation *operation, id responseObject) {
    success(responseObject);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    failure(error);
  }];
}

-(void)indexWithSuccess:(void (^)(NSArray * indexArray))success failure:(void (^)(NSError *error))failure{
  [self indexWithParameters:nil success:success failure:failure];
}

-(void)create:(NSDictionary *)createDict success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
  NSError * error = [NSError alloc];
  NSData * createBodyData = [NSJSONSerialization dataWithJSONObject:createDict options:0 error:&error];
  [self post:self.createURL body:createBodyData success:^(AFHTTPRequestOperation *operation, id responseObject) {
    success(responseObject);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    failure(error);
  }];
}

-(void)showResourceID:(NSString *)resourceID success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
  [self get:[self showURL:resourceID] success:^(AFHTTPRequestOperation *operation, id responseObject) {
    success(responseObject);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    failure(error);
  }];
}

-(void)updateResourceID:(NSString *)resourceID parameters:(NSDictionary *)updateDict success:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
  NSError * error = [NSError alloc];
  NSData * updateBodyData = [NSJSONSerialization dataWithJSONObject:updateDict options:0 error:&error];
  [self put:[self updateURL:resourceID] body:updateBodyData success:^(AFHTTPRequestOperation *operation, id responseObject) {
    success(responseObject);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    failure(error);
  }];
}

-(void)deleteResourceID:(NSString *)resourceID withSuccess:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
  [self deleteRemote:[self deleteURL:resourceID] success:^(AFHTTPRequestOperation * operation, id responseObject) {
    success(responseObject);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    failure(error);
  } ];
}



#pragma mark -
#pragma mark URL Requests

-(NSMutableURLRequest *)request:(NSURL *)url {
  NSMutableURLRequest * request = [[NSMutableURLRequest alloc]
                                   initWithURL:url
                                   cachePolicy:self.cachePolicy
                                   timeoutInterval:self.timeoutInterval];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  return request;
}

-(NSMutableURLRequest *)request:(NSURL *)url body:(NSData *)body {
  NSMutableURLRequest * request = [self request:url];
  [request setHTTPBody:body];
  return request;
}

-(NSMutableURLRequest *)postRequest:(NSURL *)url body:(NSData *)body {
  NSMutableURLRequest * request = [self request:url body:body];
  [request setHTTPMethod:@"POST"];
  return request;
}

-(NSMutableURLRequest *)putRequest:(NSURL *)url body:(NSData *)body {
  NSMutableURLRequest * request = [self request:url body:body];
  [request setHTTPMethod:@"PUT"];
  return request;
}

-(NSMutableURLRequest *)deleteRequest:(NSURL *)url {
  NSMutableURLRequest * request = [self request:url];
  [request setHTTPMethod:@"DELETE"];
  return request;
}

-(NSMutableURLRequest *)multipartFormRequest:(NSURL *)url constructingBodyWithBlock:(void(^)(id<AFMultipartFormData> formData))block {
  AFHTTPClient * httpClient = [[AFHTTPClient alloc] initWithBaseURL:url.baseURL];
  NSMutableURLRequest *request =  [httpClient multipartFormRequestWithMethod:@"POST" path:url.path parameters:nil constructingBodyWithBlock:block];
  return request;
}

#pragma mark -
#pragma mark HTTP Actions

-(void)performRequest:(NSURLRequest *)request success:(void (^)(AFHTTPRequestOperation * operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failure {
  
  AFJSONRequestOperation * operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
  [operation setCompletionBlockWithSuccess:success
                                   failure:failure];
  [operation start];
}

-(void)get:(NSURL *)url success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
  [self performRequest:[self request:url] success:success failure:failure];
}

-(void)post:(NSURL *)url body:(NSData *)body success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
  [self performRequest:[self postRequest:url body:body] success:success failure:failure];
}

-(void)put:(NSURL *)url body:(NSData *)body success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
  [self performRequest:[self putRequest:url body:body] success:success failure:failure];
}

-(void)deleteRemote:(NSURL *)url success:(void (^)(AFHTTPRequestOperation *, id))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
  [self performRequest:[self deleteRequest:url] success:success failure:failure];
}

-(void)upload:(NSURL *)url files:(NSArray *)filePaths withNames:(NSArray *)fileNames withFormDatas:(NSArray *)formDatas withFormNames:(NSArray *)formNames withSuccess:(void (^)(AFHTTPRequestOperation * operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation * operation, NSError * error))failure uploadProgress:(void (^)(NSUInteger, long long, long long))uploadProgress {
  
  NSMutableURLRequest *request = [self multipartFormRequest:url constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    NSError * error;
    for (NSString * formName in formNames) {
      NSData * formDataElement = [formDatas objectAtIndex:[formNames indexOfObject:formName]];
      [formData appendPartWithFormData:formDataElement name:formName];
    }
    for (NSString * filePath in filePaths) {
      NSString * fileName = [fileNames objectAtIndex:[filePaths indexOfObject:filePath]];
      [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:fileName error:&error];
    }
  }];
    
  AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  
  [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    success(operation, responseObject);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    failure(operation, error);
  }];
  
  [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
    uploadProgress(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
  }];
  
  [operation start];
}



@end
