//
//  AppInteractorManager.m
//  AutoGenVIPERMac
//
//  Created by Tung Nguyen on 8/21/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import "AppInteractorManager.h"

#define AppPath @"GenerateModel"

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
    }
    return self;
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
    if (self.hasKeyCodingExt) {
        [decoder appendFormat:@"\t\t%@ = try container.decode(%@.self, forKey: .%@)\n", key, keyType, key];
    }
    else {
        if (isObject) {
            [decoder appendFormat:@"\t\t%@ = container.decode(.%@, defaultType: %@.self)\n", key, key, keyType];
        }
        else {
            [decoder appendFormat:@"\t\t%@ = container.decode(.%@, defaultValue: %@)\n", key, key, [self getDefaultValueFor:keyType]];
        }
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
