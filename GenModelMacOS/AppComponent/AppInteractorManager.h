//
//  AppInteractorManager.h
//  AutoGenVIPERMac
//
//  Created by Tung Nguyen on 8/21/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "ObservableObject.h"
#import "AppUtils.h"

@interface AppInteractorManager: ObservableObject

@property (nonatomic, assign) CodeLanguage language;
@property (nonatomic, assign) BOOL hasKeyCodingExt;

+(instancetype)shared;

-(NSArray *)generateModel:(NSData *)data;

@end
