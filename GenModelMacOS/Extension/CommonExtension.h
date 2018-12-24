//
//  CommonExtension.h
//  GenModelMacOS
//
//  Created by Tung Nguyen on 12/24/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableString(App)

-(void)appendWithTabLevel:(int)tabLevel string:(NSString *)aString;
-(void)appendWithTabLevel:(int)tabLevel format:(NSString *)format, ...;

@end

@interface NSFont(App)

+(NSFont *)defaultValue;
+(NSFont *)defaultItalicValue;

@end

NS_ASSUME_NONNULL_END
