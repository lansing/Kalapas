//
//  NSString+Casing.m
//  Ollie
//
//  Created by Max Lansing on 11/12/12.
//  Copyright (c) 2012 Trigger Consulting. All rights reserved.
//

#import "NSString+Casing.h"

@implementation NSString (Casing)

- (NSString *)dashedStringFromCamelCased {
  NSScanner *scanner = [NSScanner scannerWithString:self];
  scanner.caseSensitive = YES;
  NSString *builder = [NSString string];
  NSString *buffer = nil;
  
  while (![scanner isAtEnd]) {
    if ([scanner scanCharactersFromSet:[NSCharacterSet lowercaseLetterCharacterSet]
                            intoString:&buffer]) {
      builder = [builder stringByAppendingString:buffer];
    } else if ([scanner scanCharactersFromSet:[NSCharacterSet uppercaseLetterCharacterSet]
                                   intoString:&buffer]) {
      if (scanner.scanLocation != 1) {
        builder = [builder stringByAppendingString:@"_"];
      }
      builder = [builder stringByAppendingString:[buffer lowercaseString]];
    }
  }
  return builder;
}

@end
