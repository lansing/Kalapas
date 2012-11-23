//
//  NSObject+EMSelectorGoodies.h
//  Ollie
//
//  Created by Max Lansing on 11/12/12.
//  Copyright (c) 2012 Empire Mining. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (EMSelectorGoodies)

+(SEL)setSelectorFromString:(NSString*)key;
+(NSString *)propertyTypeForKey:(NSString *)key;
+(Class)classForPropertyKey:(NSString *)key;

@end
