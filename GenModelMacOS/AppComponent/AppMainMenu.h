//
//  AppMainMenu.h
//  AutoGenVIPERMac
//
//  Created by Tung Nguyen on 2/23/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppMainMenu : NSObject

@property (nonatomic, assign) BOOL fileSave;
@property (nonatomic, weak) NSMenuItem *fileItem;
@property (nonatomic, weak) NSMenuItem *fileSaveItem;
@property (nonatomic, weak) NSMenuItem *fileResetItem;

+(instancetype)shared;
-(void)startup;
-(void)reset;

@end
