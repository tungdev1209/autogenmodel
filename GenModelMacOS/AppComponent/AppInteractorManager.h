//
//  AppInteractorManager.h
//  AutoGenVIPERMac
//
//  Created by Tung Nguyen on 8/21/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "ScriptDescription.h"
#import "ObservableObject.h"

#define kASResultReplace @"Replace"
#define kASResultYES @"YES"
#define kASResultGemPath @"gempath"

typedef enum : NSUInteger {
    MenuKeySelectorSaveDocument,
} MenuKeySelector;

@interface AppInteractorManager : ObservableObject

@property (nonatomic, strong) NSMenuItem *menuItemTapped;
@property (nonatomic, copy) NSString *applicationDocumentsPath;
@property (nonatomic, assign) MenuKeySelector menuSelectorTapped;

@property (nonatomic, assign) CodeLanguage language;

+(instancetype)shared;
-(void)loadFilesToDocumentDir;
-(void)loadOriginalFileToAppDocumentsDirectory:(NSString *)fileName replace:(BOOL)isReplace;
-(NSString *)contentOfOriginalFile:(NSString *)fileName;
-(NSString *)generateVIPERfiles:(ScriptDescription *)scriptDes;
-(NSString *)runScript:(ScriptDescription *)scriptDescription;
-(NSString *)applicationDocumentsPath;
-(NSString *)applicationDocumentPathForFile:(NSString *)fileName;
-(BOOL)saveFile:(NSString *)fileContent withPath:(NSString *)filePath;

-(NSArray *)generateModel:(NSData *)data;

@end
