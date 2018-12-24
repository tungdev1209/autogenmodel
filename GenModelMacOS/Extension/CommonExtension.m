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
