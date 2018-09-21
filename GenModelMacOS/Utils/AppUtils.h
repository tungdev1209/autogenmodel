//
//  AppUtils.h
//  AutoGenVIPERMac
//
//  Created by Tung Nguyen on 2/13/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

typedef enum : NSUInteger {
    CodeLanguageObjectiveC,
    CodeLanguageSwift,
} CodeLanguage;

@class ScriptDescription;

@interface AppUtils : NSObject

+(NSString *)currentDate;
+(NSString *)currentYear;
+(NSString *)stringFromState:(NSControlStateValue)value;
+(BOOL)boolFromState:(NSControlStateValue)value;
+(void)rotate360Animation:(NSView *)view counterClockWise:(BOOL)counterClockWise;
+(void)flashAnimation:(NSView *)view;

@end
