//
//  AppMainMenu.m
//  AutoGenVIPERMac
//
//  Created by Tung Nguyen on 2/23/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import "AppMainMenu.h"

@interface AppMainMenu ()

@property (nonatomic, strong) NSMenu *mainMenu;

@end

@implementation AppMainMenu

+(instancetype)shared {
    static AppMainMenu *m = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m = [[AppMainMenu alloc] init];
    });
    return m;
}

-(NSMenu *)mainMenu {
    if (!_mainMenu) {
        _mainMenu = [[NSApplication sharedApplication] mainMenu];
    }
    return _mainMenu;
}

-(NSMenuItem *)fileItem {
    if (!_fileItem) {
        _fileItem = [self.mainMenu itemWithTitle:@"File"];
    }
    return _fileItem;
}

-(NSMenuItem *)fileSaveItem {
    if (!_fileSaveItem) {
        _fileSaveItem = [self.fileItem.submenu itemAtIndex:4];
    }
    return _fileSaveItem;
}

-(NSMenuItem *)fileResetItem {
    if (!_fileResetItem) {
        _fileResetItem = [self.fileItem.submenu itemAtIndex:6];
    }
    return _fileResetItem;
}

-(void)startup {
    [self.mainMenu setAutoenablesItems:NO];
    [self.fileSaveItem setEnabled:NO];
}

-(void)reset {
    [self.fileSaveItem setEnabled:NO];
}

@end
