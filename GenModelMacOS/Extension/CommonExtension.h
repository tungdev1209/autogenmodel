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

@interface NSString(App)

@property (nonatomic, copy, readonly) NSString *asCamelCase;
@property (nonatomic, copy, readonly) NSString *asUpperCamelCase;

@end

NS_ASSUME_NONNULL_END
