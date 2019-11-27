//
//  CommonExtension.m
//  GenModelMacOS
//
//  Created by Tung Nguyen on 12/24/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import "CommonExtension.h"

@implementation NSMutableString(App)

-(void)appendWithTabLevel:(int)tabLevel string:(NSString *)aString {
    for (int i = 0; i < tabLevel; i++) {
        [self appendString:@"\t"];
    }
    [self appendString:aString];
    [self appendString:@"\n"];
}

-(void)appendWithTabLevel:(int)tabLevel format:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    NSString *aString = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:ap];
    va_end(ap);
    [self appendWithTabLevel:tabLevel string:aString];
}

@end

@implementation NSFont(App)

+(NSFont *)defaultValue {
    return [NSFont systemFontOfSize:15.0];
}

+(NSFont *)defaultItalicValue {
    return [[NSFontManager sharedFontManager] fontWithFamily:@"Helvetica" traits:NSItalicFontMask weight:0 size:15.0];
}

@end

@implementation NSString(App)

-(NSString *)convertToSnakeFormat {
    NSArray *components = [self componentsSeparatedByString:@"_"];
    if (components.count == 0) {return self;}
    NSMutableString *result;
    for (NSString *str in components) {
        if ([str isEqualToString:@""]) {continue;}
        NSString *firstChar = [str substringToIndex:1];
        
        if (!result) { // this str is the first string in list
            if ([[firstChar uppercaseString] isEqualToString:firstChar]) {
                firstChar = firstChar.lowercaseString;
            }
        } else {
            if ([[firstChar lowercaseString] isEqualToString:firstChar]) {
                firstChar = firstChar.uppercaseString;
            }
        }
        
        NSString *finalStr = [NSString stringWithFormat:@"%@%@", firstChar, [str substringFromIndex:1]];
        if (!result) {
            result = [[NSMutableString alloc] initWithString:finalStr];
        } else {
            [result appendString:finalStr];
        }
    }
    return result;
}

@end
