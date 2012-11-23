//
//  NSObject+EMSelectorGoodies.m
//  Ollie
//
//  Created by Max Lansing on 11/12/12.
//  Copyright (c) 2012 Empire Mining. All rights reserved.
//

#import "NSObject+EMSelectorGoodies.h"
#import <objc/runtime.h>

const char * property_getTypeString( objc_property_t property )
{
	const char * attrs = property_getAttributes( property );
	if ( attrs == NULL )
		return ( NULL );
  
	static char buffer[256];
	const char * e = strchr( attrs, ',' );
	if ( e == NULL )
		return ( NULL );
  
	int len = (int)(e - attrs);
	memcpy( buffer, attrs, len );
	buffer[len] = '\0';
  
	return ( buffer );
}

@implementation NSObject (EMSelectorGoodies)

+(SEL)setSelectorFromString:(NSString*)key {
  NSString * selStr = [NSString stringWithFormat:@"set%@:", [NSString stringWithFormat:@"%@%@",[[key substringToIndex:1] uppercaseString],[key substringFromIndex:1]]];
  return NSSelectorFromString(selStr);
}

+(NSString *)propertyTypeForKey:(NSString *)key {
  objc_property_t theProperty = class_getProperty([self class], [key UTF8String]);
  if (!theProperty)
    return nil;
  const char * propertyType = property_getTypeString(theProperty);
  NSString * propertyTypeString = [NSString stringWithUTF8String:propertyType];
  return propertyTypeString;
}

+(Class)classForPropertyKey:(NSString *)key {
  NSString * propertyTypeString = [[self class] propertyTypeForKey:key];
  if (propertyTypeString == nil)
    return nil;
  NSString * className = [propertyTypeString substringWithRange:NSMakeRange(3, propertyTypeString.length-4)];
  return NSClassFromString(className);
}


@end
