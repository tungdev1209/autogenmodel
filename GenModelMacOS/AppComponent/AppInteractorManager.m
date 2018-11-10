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
@property (nonatomic, strong) NSMutableArray *decoders;
@property (nonatomic, strong) NSMutableArray *codingKeys;

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
        self.decoders = [[NSMutableArray alloc] init];
        self.codingKeys = [[NSMutableArray alloc] init];
        self.language = CodeLanguageObjectiveC;
        
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

-(NSArray *)generateModel:(NSData *)data {
    NSError *error = nil;
    id jsonContent = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        return @[];
    }
    
    NSLog(@"===================== BEGIN =====================");
    [self analyzeContent:jsonContent key:@"datasource" currentComponents:@[[@"" mutableCopy]]];
    NSLog(@"===================== END =====================");
    
    [self appendEndSymbol];
    
    NSArray *result = [self.interfaces copy];
    [self.interfaces removeAllObjects];
    [self.codingKeys removeAllObjects];
    [self.decoders removeAllObjects];
    return result;
}

-(void)appendEndSymbol {
    int interfacesCount = (int)self.interfaces.count;
    for (int i = 0; i < interfacesCount; i++) {
        NSMutableString *interface = self.interfaces[i];
        switch (self.language) {
            case CodeLanguageObjectiveC:
                [interface appendString:@"\n@end\n"];
                break;
                
            case CodeLanguageSwift: {
                NSMutableString *codingKey = self.codingKeys[i];
                NSMutableString *decoder = self.decoders[i];
                [codingKey appendString:@"\t}\n"];
                [decoder appendString:@"\t}\n"];
                [interface appendString:codingKey];
                [interface appendString:decoder];
                [interface appendString:@"}\n"];
            }
                break;
                
            default:
                break;
        }
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

-(NSArray *)createInterfaceWithKey:(NSString *)key name:(NSString **)interfaceName {
    *interfaceName = [self createInterfaceNameFrom:key];
    NSMutableString *interface;
    NSMutableArray *components = [[NSMutableArray alloc] init];
    switch (self.language) {
        case CodeLanguageObjectiveC: {
            interface = [[NSMutableString alloc] initWithFormat:@"//\n#import <Foundation/Foundation.h>\n\n@interface %@: NSObject\n\n", *interfaceName];
            [components addObject:interface];
        }
            break;
            
        case CodeLanguageSwift: {
            interface = [[NSMutableString alloc] initWithFormat:@"//\nimport UIKit\n\nstruct %@: Codable {\n", *interfaceName];
            
            NSMutableString *codingKey = [[NSMutableString alloc] initWithFormat:@"\n\tprivate enum CodingKeys: String, CodingKey {\n"];
            [self.codingKeys addObject:codingKey];
            
            NSMutableString *decoder = [[NSMutableString alloc] initWithFormat:@"\n\tinit(from decoder: Decoder) throws {\n"];
            [decoder appendString:@"\t\tlet container = try decoder.container(keyedBy: CodingKeys.self)\n"];
            [self.decoders addObject:decoder];
            
            [components addObject:interface];
            [components addObject:codingKey];
            [components addObject:decoder];
        }
            break;
            
        default:
            break;
    }
    [self.interfaces addObject:interface];
    return components;
}

-(void)analyzeContent:(id)jsonContent key:(NSString *)aKey currentComponents:(NSArray *)aComponents {
    NSMutableString *anInterface = (NSMutableString *)aComponents.firstObject;
    if ([jsonContent isKindOfClass:[NSDictionary class]]) {
        // create new interface with aKey
        NSString *interfaceName;
        NSArray *components = [self createInterfaceWithKey:aKey name:&interfaceName];
        
        if (![anInterface isEqualToString:@""]) {
            [anInterface appendString:[self generateObjectProperty:interfaceName keyName:aKey]];
            [self generateCodingKeyAndDecoder:aComponents keyName:aKey keyType:interfaceName isObject:YES];
        }
        
        NSDictionary *content = (NSDictionary *)jsonContent;
        for (NSString *key in content.allKeys) {
            id value = content[key];
            [self analyzeContent:value key:key currentComponents:components];
        }
    }
    else if ([jsonContent isKindOfClass:[NSArray class]]) {
        [anInterface appendString:[self gennerateArrayProperty:aKey]];
        [self generateCodingKeyAndDecoder:aComponents keyName:aKey keyType:@"[Any]"];
    }
    else {
        NSString *contentType = NSStringFromClass([jsonContent class]);
        NSString *keyType = @"";
        [anInterface appendString:[self generateCommonPropertyForType:contentType keyName:aKey keyType:&keyType]];
        [self generateCodingKeyAndDecoder:aComponents keyName:aKey keyType:keyType];
        NSLog(@"key: %@ - value: %@ - %@", aKey, jsonContent, NSStringFromClass([jsonContent class]));
    }
}

-(void)generateCodingKeyAndDecoder:(NSArray *)components keyName:(NSString *)key keyType:(NSString *)keyType {
    [self generateCodingKeyAndDecoder:components keyName:key keyType:keyType isObject:NO];
}

-(void)generateCodingKeyAndDecoder:(NSArray *)components keyName:(NSString *)key keyType:(NSString *)keyType isObject:(BOOL)isObject {
    if (self.language == CodeLanguageObjectiveC) return;
    NSMutableString *codingKey = (NSMutableString *)components[1];
    NSMutableString *decoder = (NSMutableString *)components[2];
    [codingKey appendFormat:@"\t\tcase %@\n", key];
    if (isObject) {
        [decoder appendFormat:@"\t\t%@ = container.decode(.%@, defaultType: %@.self)\n", key, key, keyType];
    }
    else {
        [decoder appendFormat:@"\t\t%@ = container.decode(.%@, defaultValue: %@)\n", key, key, [self getDefaultValueFor:keyType]];
    }
}

-(NSString *)getDefaultValueFor:(NSString *)type {
    if ([type isEqualToString:@"String"]) {
        return @"\"\"";
    }
    else if ([type isEqualToString:@"Int"]) {
        return @"0";
    }
    else if ([type isEqualToString:@"Bool"]) {
        return @"false";
    }
    else if ([type isEqualToString:@"Double"] || [type isEqualToString:@"Float"]) {
        return @"0.0";
    }
    return type;
}
    
-(NSString *)generateObjectProperty:(NSString *)object keyName:(NSString *)keyName {
    NSString *property = @"";
    switch (self.language) {
        case CodeLanguageObjectiveC: {
            property = [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@;\n", object, keyName];
        }
            break;
            
        case CodeLanguageSwift: {
            property = [NSString stringWithFormat:@"\tlet %@: %@\n", keyName, object];
        }
            break;
            
        default:
            break;
    }
    return property;
}

-(NSString *)gennerateArrayProperty:(NSString *)keyName {
    NSString *property = @"";
    switch (self.language) {
        case CodeLanguageObjectiveC: {
            property = [NSString stringWithFormat:@"@property (nonatomic, strong) NSArray *%@;\n", keyName];
        }
            break;
            
        case CodeLanguageSwift: {
            property = [NSString stringWithFormat:@"\tlet %@: [Any]\n", keyName];
        }
            break;
            
        default:
            break;
    }
    return property;
}

-(NSString *)generateCommonPropertyForType:(NSString *)type keyName:(NSString *)keyName keyType:(NSString **)keyType {
    NSString *property = @"";
    switch (self.language) {
        case CodeLanguageSwift: {
            if ([type containsString:@"String"]) {
                property = [NSString stringWithFormat:@"\tlet %@: String\n", keyName];
                *keyType = @"String";
            }
            else if ([type containsString:@"Bool"]) {
                property = [NSString stringWithFormat:@"\tlet %@: Bool\n", keyName];
                *keyType = @"Bool";
            }
            else if ([type containsString:@"Number"]) {
                property = [NSString stringWithFormat:@"\tlet %@: Int\n", keyName];
                *keyType = @"Int";
            }
            else {
                property = [NSString stringWithFormat:@"\tlet %@: Any\n", keyName];
                *keyType = @"Any";
            }
        }
            break;
            
        case CodeLanguageObjectiveC: {
            if ([type containsString:@"String"]) {
                property = [NSString stringWithFormat:@"@property (nonatomic, copy) NSString *%@;\n", keyName];
            }
            else if ([type containsString:@"Bool"]) {
                property = [NSString stringWithFormat:@"@property (nonatomic, assign) BOOL %@;\n", keyName];
            }
            else if ([type containsString:@"Number"]) {
                property = [NSString stringWithFormat:@"@property (nonatomic, strong) NSNumber *%@;\n", keyName];
            }
            else {
                property = [NSString stringWithFormat:@"@property (nonatomic, strong) UnknownKey *%@;\n", keyName];
            }
        }
            break;
            
        default:
            break;
    }
    return property;
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
