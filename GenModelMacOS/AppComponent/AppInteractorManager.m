//
//  AppInteractorManager.m
//  AutoGenVIPERMac
//
//  Created by Tung Nguyen on 8/21/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import "AppInteractorManager.h"

#define AppPath @"GenerateModel"
#define SourceCodeFiles @[@"Interactor_m", @"Interactor_h", @"Presenter_m", @"Presenter_h", @"Wireframe_m", @"Wireframe_h", @"Protocols_h", @"Interactor_swift", @"Presenter_swift", @"Wireframe_swift", @"Protocols_swift"]
#define kInteractor @"Interactor"
#define kPresenter @"Presenter"
#define kWireframe @"Wireframe"
#define kProtocols @"Protocols"
#define SourceCodeFilesTree @{kInteractor: @[@"Interactor_m", @"Interactor_h"],   \
                              kPresenter : @[@"Presenter_m", @"Presenter_h"],     \
                              kWireframe : @[@"Wireframe_m", @"Wireframe_h"],     \
                              kProtocols : @[@"Protocols_h"]}
#define SourceCodeSwiftFilesTree  @{kInteractor: @[@"Interactor_swift"],   \
                                    kPresenter : @[@"Presenter_swift"],    \
                                    kWireframe : @[@"Wireframe_swift"],    \
                                    kProtocols : @[@"Protocols_swift"]}

@interface AppInteractorManager()

@property (nonatomic, strong) dispatch_queue_t fileManagerQueue;
@property (nonatomic, strong) dispatch_queue_t menuTappingQueue;

@property (nonatomic, strong) NSMutableArray *interfaces;

@end

@implementation AppInteractorManager

+(instancetype)shared {
    static AppInteractorManager *m = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        m = [[AppInteractorManager alloc] init];
    });
    return m;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fileManagerQueue = dispatch_queue_create("autogenviper.appdatamanager.filemanager", DISPATCH_QUEUE_SERIAL);
        self.menuTappingQueue = dispatch_queue_create("autogenviper.appdatamanager.menutapping", DISPATCH_QUEUE_SERIAL);
        
        self.interfaces = [[NSMutableArray alloc] init];
        
        __weak typeof(self) weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:NSMenuWillSendActionNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dispatch_async(self.menuTappingQueue, ^{
                strongSelf.menuItemTapped = (NSMenuItem *)note.userInfo[@"MenuItem"];
                NSString *menuTitle = strongSelf.menuItemTapped.title;
                if ([NSStringFromSelector(strongSelf.menuItemTapped.action) isEqualToString:@"saveDocument:"]) {
                    strongSelf.menuSelectorTapped = MenuKeySelectorSaveDocument;
                }
                else {
                    
                }
            });
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:NSMenuDidSendActionNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            
        }];
    }
    return self;
}

-(void)loadFilesToDocumentDir {
    if ([self checkAndCreateAppDocumentsDirectory]) {
        [self loadOriginalFilesToAppDocumentsDirectoryWithReplace:NO];
    }
}

-(void)loadOriginalFilesToAppDocumentsDirectoryWithReplace:(BOOL)replace {
    for (NSString *fileName in SourceCodeFiles) {
        [self loadOriginalFileToAppDocumentsDirectory:fileName replace:replace];
    }
}

-(NSString *)applicationDocumentsPath {
    if (!_applicationDocumentsPath) {
        _applicationDocumentsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:AppPath];
        NSLog(@"%@", _applicationDocumentsPath);
    }
    return _applicationDocumentsPath;
}

-(NSString *)applicationDocumentPathForFile:(NSString *)fileName {
    return [[self applicationDocumentsPath] stringByAppendingPathComponent:fileName];
}

-(BOOL)checkAndCreateAppDocumentsDirectory {
    __block BOOL result = NO;
    dispatch_sync(self.fileManagerQueue, ^{
        NSString *appPath = [self applicationDocumentsPath];
        NSLog(@"App path: %@", appPath);
        NSError *error = nil;
        [self createDirAtPathIfNeeded:appPath error:&error];
        if (error) {
            NSLog(@"Could not create app dir - error: %@", error);
        }
        result = !error;
    });
    return result;
}

-(NSString *)contentOfOriginalFile:(NSString *)fileName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    return [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
}

-(void)loadOriginalFileToAppDocumentsDirectory:(NSString *)fileName replace:(BOOL)isReplace {
    dispatch_sync(self.fileManagerQueue, ^{
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
        NSString *appFilePath = [[self applicationDocumentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", fileName]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:appFilePath]) {
            if (isReplace) {
                NSError *error = nil;
                BOOL removeResult = [fileManager removeItemAtPath:appFilePath error:&error];
                if (removeResult) {
                    NSLog(@"Remove file success at %@", appFilePath);
                }
                else {
                    NSLog(@"Could not remove file at %@ - error: %@", filePath, error);
                }
            }
            else {
                return;
            }
        }
        NSError *error = nil;
        BOOL copyResult = [fileManager copyItemAtPath:filePath toPath:appFilePath error:&error];
        if (copyResult) {
            NSLog(@"Copy file success to %@", appFilePath);
        }
        else {
            NSLog(@"Could not copy file to %@ - error: %@", appFilePath, error);
        }
    });
}

-(void)createDirAtPathIfNeeded:(NSString *)path error:(NSError **)error {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir] && !isDir) {
        [fileManager createDirectoryAtPath:path
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:error];
    }
}

-(NSString *)createInterfaceNameFrom:(NSString *)inputString {
    /* create a locale where diacritic marks are not considered important, e.g. US English */
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en-US"];
    
    /* get first char */
    NSString *firstChar = [inputString substringToIndex:1];
    
    /* remove any diacritic mark */
    NSString *folded = [firstChar stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:locale];
    
    /* create the new string */
    NSString *result = [[folded uppercaseString] stringByAppendingString:[inputString substringFromIndex:1]];
    return result;
}

-(NSMutableString *)createInterfaceWithKey:(NSString *)key name:(NSString **)interfaceName {
    *interfaceName = [self createInterfaceNameFrom:key];
    NSMutableString *interface = [[NSMutableString alloc] initWithFormat:@"//\n#import <Foundation/Foundation.h>\n\n@interface %@: NSObject\n\n", *interfaceName];
    [self.interfaces addObject:interface];
    return interface;
}

-(NSArray *)generateModel:(NSData *)data {
    NSError *error = nil;
    id jsonContent = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        return @[];
    }
    
    [self createDirAtPathIfNeeded:[self applicationDocumentsPath] error:nil];
    
    NSLog(@"===================== BEGIN =====================");
    [self analyzeContent:jsonContent key:@"datasource" currentInterface:@""];
    NSLog(@"===================== END =====================");
    
    for (NSMutableString *string in self.interfaces) {
        [string appendString:@"\n@end\n"];
    }
    
    NSArray *result = [self.interfaces copy];
    [self.interfaces removeAllObjects];
    return result;
}

-(void)analyzeContent:(id)jsonContent key:(NSString *)aKey currentInterface:(NSMutableString *)anInterface {
    if ([jsonContent isKindOfClass:[NSDictionary class]]) {
        // create new interface with aKey
        NSString *interfaceName;
        NSMutableString *interface = [self createInterfaceWithKey:aKey name:&interfaceName];
        if (![anInterface isEqualToString:@""]) {
            [anInterface appendFormat:@"@property (nonatomic, strong) %@ *%@;\n", interfaceName, aKey];
        }
        
        NSDictionary *content = (NSDictionary *)jsonContent;
        NSArray *keys = content.allKeys;
        for (NSString *key in keys) {
            id value = content[key];
            [self analyzeContent:value key:key currentInterface:interface];
        }
    }
    else if ([jsonContent isKindOfClass:[NSArray class]]) {
        [anInterface appendFormat:@"@property (nonatomic, strong) NSArray *%@;\n", aKey];
    }
    else {
        NSString *contentType = NSStringFromClass([jsonContent class]);
        if ([contentType containsString:@"String"]) {
            [anInterface appendFormat:@"@property (nonatomic, copy) NSString *%@;\n", aKey];
        }
        else if ([contentType containsString:@"Bool"]) {
            [anInterface appendFormat:@"@property (nonatomic, assign) BOOL %@;\n", aKey];
        }
        else if ([contentType containsString:@"Number"]) {
            [anInterface appendFormat:@"@property (nonatomic, strong) NSNumber *%@;\n", aKey];
        }
        else {
            [anInterface appendFormat:@"@property (nonatomic, strong) UnknownKey *%@;\n", aKey];
        }
        NSLog(@"key: %@ - value: %@ - %@", aKey, jsonContent, NSStringFromClass([jsonContent class]));
    }
}

-(NSString *)generateVIPERfiles:(ScriptDescription *)scriptDes {
    __block NSMutableString *result = [[NSMutableString alloc] initWithString:@"Creating VIPER files tree\n"];
    dispatch_sync(self.fileManagerQueue, ^{
//        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *modulePath = [scriptDes.modulePath stringByAppendingPathComponent:scriptDes.moduleName];
        NSError *error = nil;
        [self createDirAtPathIfNeeded:modulePath error:&error];
        if (error) {
            [result appendString:@"=== Creating files - ERROR ===\n"];
            [result appendString:error.description];
            return;
        }
        NSArray *treeKeys = SourceCodeFilesTree.allKeys;
        for (NSString *treeKey in treeKeys) {
            if ((!scriptDes.chooseInteractor && [treeKey isEqualToString:kInteractor]) ||
                (!scriptDes.choosePresenter && [treeKey isEqualToString:kPresenter]) ||
                (!scriptDes.chooseWireframe && [treeKey isEqualToString:kWireframe])) {
                continue;
            }
            
            // create dir for each component (for Objective-C)
            NSString *componentPath = modulePath;
            if (scriptDes.language == CodeLanguageObjectiveC && ![treeKey isEqualToString:kProtocols]) {
                componentPath = [modulePath stringByAppendingPathComponent:treeKey];
                [self createDirAtPathIfNeeded:componentPath error:&error];
                if (error) {
                    [result appendString:[NSString stringWithFormat:@"Could not create module component path %@ - error: %@\n", componentPath, error]];
                    NSLog(@"%@", result);
                    return;
                }
            }
            
            // create component files
            NSArray *componentFiles;
            if (scriptDes.language == CodeLanguageObjectiveC) {
                componentFiles = SourceCodeFilesTree[treeKey];
            }
            else { // Swift
                componentFiles = SourceCodeSwiftFilesTree[treeKey];
            }
            
            NSString *aFileName;
            for (NSString *fileName in componentFiles) {
                if (scriptDes.language == CodeLanguageObjectiveC) {
                    aFileName = [fileName stringByReplacingOccurrencesOfString:@"_h" withString:@".h"];
                    aFileName = [aFileName stringByReplacingOccurrencesOfString:@"_m" withString:@".m"];
                }
                else { // Swift
                    aFileName = [fileName stringByReplacingOccurrencesOfString:@"_swift" withString:@".swift"];
                }
                aFileName = [NSString stringWithFormat:@"%@%@", scriptDes.moduleName, aFileName];
                
                NSString *filePath = [componentPath stringByAppendingPathComponent:aFileName];
                
                NSString *docFilePath = [[self applicationDocumentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", fileName]];
                NSError *readingError = nil;
                NSString *contentFile = [NSString stringWithContentsOfFile:docFilePath encoding:NSUTF8StringEncoding error:&readingError];
                if (readingError) {
                    [result appendString:[NSString stringWithFormat:@"Could not read template of file %@ - error: %@\n", aFileName, readingError]];
                    return;
                }
                contentFile = [contentFile stringByReplacingOccurrencesOfString:@"%(author)s" withString:scriptDes.authorName];
                contentFile = [contentFile stringByReplacingOccurrencesOfString:@"%(module)s" withString:scriptDes.moduleName];
                contentFile = [contentFile stringByReplacingOccurrencesOfString:@"%(time)s" withString:scriptDes.date];
                contentFile = [contentFile stringByReplacingOccurrencesOfString:@"%(year)s" withString:scriptDes.year];
                contentFile = [contentFile stringByReplacingOccurrencesOfString:@"%(project)s" withString:scriptDes.projectName];
                
                NSError *writingError = nil;
                [contentFile writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&writingError];
                if (writingError) {
                    [result appendString:[NSString stringWithFormat:@"Could not create file %@ - error: %@\n", aFileName, writingError]];
                    NSLog(@"%@", writingError);
                    return;
                }
            }
        }
        [result appendString:@"=== VIPER files created ==="];
    });
    return result;
}

-(NSString *)runScript:(ScriptDescription *)scriptDescription {
    if (![NSThread isMainThread]) {
        __block NSString *result = @"";
        dispatch_sync(dispatch_get_main_queue(), ^{
            result = [self runScript:scriptDescription];
        });
        return result;
    }
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"autogen" ofType:@"scpt"]];
    NSAppleScript *script = [[NSAppleScript alloc] initWithContentsOfURL:url error:nil];
    
    NSAppleEventDescriptor *h = [NSAppleEventDescriptor descriptorWithString:[scriptDescription.appleEventDescriptor lowercaseString]];
    NSAppleEventDescriptor *ae = [NSAppleEventDescriptor appleEventWithEventClass:'ascr'
                                                                          eventID:'psbr'
                                                                 targetDescriptor:[NSAppleEventDescriptor nullDescriptor]
                                                                         returnID:kAutoGenerateReturnID
                                                                    transactionID:kAnyTransactionID];
    [ae setParamDescriptor:h forKeyword:'snam'];
    NSAppleEventDescriptor *list = scriptDescription.list;
    if (list) {
        [ae setParamDescriptor:list forKeyword:keyDirectObject];
    }
    
    NSDictionary *error = nil;
    NSAppleEventDescriptor *result = [script executeAppleEvent:ae error:&error];
    
    NSLog(@"error = %@", error);
    NSLog(@"result = %@", result);
    NSString *resultString = @"";
    if (result.stringValue) {
        resultString = result.stringValue;
    }
    else if (error) {
        resultString = [error[@"NSAppleScriptErrorMessage"] copy];
    }
    
    return resultString;
}

-(BOOL)saveFile:(NSString *)fileContent withPath:(NSString *)filePath {
    __block BOOL result = NO;
    dispatch_sync(self.fileManagerQueue, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            [fileManager removeItemAtPath:filePath error:nil];
        }
        result = [fileManager createFileAtPath:filePath contents:[fileContent dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    });
    return result;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
