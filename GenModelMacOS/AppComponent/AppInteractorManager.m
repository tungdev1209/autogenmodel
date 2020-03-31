//
//  AppInteractorManager.m
//  AutoGenVIPERMac
//
//  Created by Tung Nguyen on 8/21/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import "AppInteractorManager.h"
#import "CommonExtension.h"

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
    
    NSLog(@"//===================== BEGIN =====================");
    [self analyzeContent:jsonContent key:@"datasource" currentComponents:@[[@"" mutableCopy]]];
    NSLog(@"//===================== END =====================");
    
    [self appendEndSymbol];
    
    NSMutableArray *result = [self.interfaces mutableCopy];
    
    [self.interfaces removeAllObjects];
    [self.codingKeys removeAllObjects];
    [self.decoders removeAllObjects];
    
    if (self.hasKeyCodingExt) {
        NSMutableString *kdExtenstion = [[NSMutableString alloc] init];
        [kdExtenstion appendWithTabLevel:0 string:@"//===================== EXTENSION ====================="];
        [kdExtenstion appendWithTabLevel:0 string:@"extension KeyedDecodingContainer {"];
        [kdExtenstion appendWithTabLevel:1 string:@"func decode<T>(_ key: KeyedDecodingContainer<K>.Key, defaultValue: T) -> T {"];
        [kdExtenstion appendWithTabLevel:2 string:@"do {"];
        [kdExtenstion appendWithTabLevel:3 string:@"switch defaultValue.self {"];
        [kdExtenstion appendWithTabLevel:3 string:@"case is Bool:"];
        [kdExtenstion appendWithTabLevel:4 string:@"return try decode(Bool.self, forKey: key) as! T"];
        [kdExtenstion appendWithTabLevel:4 string:@""];
        [kdExtenstion appendWithTabLevel:3 string:@"case is Int:"];
        [kdExtenstion appendWithTabLevel:4 string:@"return try decode(Int.self, forKey: key) as! T"];
        [kdExtenstion appendWithTabLevel:4 string:@""];
        [kdExtenstion appendWithTabLevel:3 string:@"case is String:"];
        [kdExtenstion appendWithTabLevel:4 string:@"return try decode(String.self, forKey: key) as! T"];
        [kdExtenstion appendWithTabLevel:4 string:@""];
        [kdExtenstion appendWithTabLevel:3 string:@"case is Double:"];
        [kdExtenstion appendWithTabLevel:4 string:@"return try decode(Double.self, forKey: key) as! T"];
        [kdExtenstion appendWithTabLevel:4 string:@""];
        [kdExtenstion appendWithTabLevel:3 string:@"case is Float:"];
        [kdExtenstion appendWithTabLevel:4 string:@"return try decode(Float.self, forKey: key) as! T"];
        [kdExtenstion appendWithTabLevel:4 string:@""];
        [kdExtenstion appendWithTabLevel:3 string:@"case is CGFloat:"];
        [kdExtenstion appendWithTabLevel:4 string:@"return try decode(CGFloat.self, forKey: key) as! T"];
        [kdExtenstion appendWithTabLevel:4 string:@""];
        [kdExtenstion appendWithTabLevel:3 string:@"default:"];
        [kdExtenstion appendWithTabLevel:4 string:@"return defaultValue"];
        [kdExtenstion appendWithTabLevel:3 string:@"}"];
        [kdExtenstion appendWithTabLevel:2 string:@"} catch {"];
        [kdExtenstion appendWithTabLevel:3 string:@"return defaultValue"];
        [kdExtenstion appendWithTabLevel:2 string:@"}"];
        [kdExtenstion appendWithTabLevel:1 string:@"}"];
        
        [kdExtenstion appendWithTabLevel:1 string:@""];
        
        [kdExtenstion appendWithTabLevel:1 string:@"func decode<T: Codable>(_ key: KeyedDecodingContainer<K>.Key, defaultType: T.Type) -> T? {"];
        [kdExtenstion appendWithTabLevel:2 string:@"do {"];
        [kdExtenstion appendWithTabLevel:3 string:@"return try decode(defaultType.self, forKey: key)"];
        [kdExtenstion appendWithTabLevel:2 string:@"} catch {"];
        [kdExtenstion appendWithTabLevel:3 string:@"return nil"];
        [kdExtenstion appendWithTabLevel:2 string:@"}"];
        [kdExtenstion appendWithTabLevel:1 string:@"}"];
        [kdExtenstion appendWithTabLevel:0 string:@"}"];
        
        [result insertObject:kdExtenstion atIndex:0];
    }
    
    return result;
}

-(void)appendEndSymbol {
    int interfacesCount = (int)self.interfaces.count;
    for (int i = 0; i < interfacesCount; i++) {
        NSMutableString *interface = self.interfaces[i];
        switch (self.language) {
        case CodeLanguageObjectiveC: {
            [interface appendString:@"\n-(instancetype)initWithDatasource:(NSDictionary *)datasource;\n"];
            [interface appendString:@"\n@end\n"];
            NSMutableString *decoder = self.decoders[i];
            [decoder appendWithTabLevel:1 string:@"return self;"];
            [decoder appendWithTabLevel:0 string:@"}"];
            [decoder appendWithTabLevel:0 string:@"\n@end\n"];
            [interface appendString:decoder];
            break;
        }
            
        case CodeLanguageSwift: {
            NSMutableString *codingKey = self.codingKeys[i];
            NSMutableString *decoder = self.decoders[i];
            [codingKey appendWithTabLevel:1 string:@"}"];
            [decoder appendWithTabLevel:1 string:@"}"];
            [interface appendString:codingKey];
            [interface appendString:decoder];
            [interface appendWithTabLevel:0 string:@"}"];
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
    *interfaceName = key.asUpperCamelCase;
    NSMutableString *interface;
    NSMutableArray *components = [[NSMutableArray alloc] init];
    switch (self.language) {
    case CodeLanguageObjectiveC: {
        interface = [[NSMutableString alloc] initWithFormat:@"//\n#import <Foundation/Foundation.h>\n\n@interface %@: NSObject\n\n", *interfaceName];
        [components addObject:interface];
        
        NSMutableString *decoder = [[NSMutableString alloc] init];
        [decoder appendWithTabLevel:0 format:@"\n@implementation %@", *interfaceName];
        [decoder appendWithTabLevel:0 string:@""];
        [decoder appendWithTabLevel:0 string:@"-(instancetype)initWithDatasource:(NSDictionary *)datasource {"];
        [decoder appendWithTabLevel:1 string:@"self = [super init];"];
        [self.decoders addObject:decoder];
        
        [components addObject:decoder];
    }
        break;
        
    case CodeLanguageSwift: {
        interface = [[NSMutableString alloc] initWithFormat:@"//\nimport UIKit\n\nstruct %@: Codable {\n", *interfaceName];
        
        NSMutableString *codingKey = [[NSMutableString alloc] initWithFormat:@"\n\tprivate enum CodingKeys: String, CodingKey {\n"];
        [self.codingKeys addObject:codingKey];
        
        NSMutableString *decoder = [[NSMutableString alloc] init];
        [decoder appendWithTabLevel:0 string:@""];
        [decoder appendWithTabLevel:1 string:@"init(from decoder: Decoder) throws {"];
        [decoder appendWithTabLevel:2 string:@"let container = try decoder.container(keyedBy: CodingKeys.self)"];
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
        [self generateCodingKeyAndDecoder:aComponents keyName:aKey keyType:@"[Any]" isObject:YES];
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

-(void)generateCodingKeyAndDecoder:(NSArray *)components keyName:(NSString *)originKey keyType:(NSString *)keyType isObject:(BOOL)isObject {
    switch (self.language) {
    case CodeLanguageSwift: {
        if (components.count <= 2) return;
        NSMutableString *codingKey = (NSMutableString *)components[1];
        NSMutableString *decoder = (NSMutableString *)components[2];
        NSString *key = originKey.asCamelCase;
        if ([key isEqualToString:originKey]) {
            [codingKey appendWithTabLevel:2 format:@"case %@", key];
        } else {
            [codingKey appendWithTabLevel:2 format:@"case %@ = \"%@\"", key, originKey];
        }
        if (self.hasKeyCodingExt) {
            if (isObject) {
                if ([keyType containsString:@"]"]) { // is array
                    [decoder appendWithTabLevel:2 format:@"%@ = container.decode(.%@, defaultType: %@.self) ?? []", key, key, keyType];
                } else {
                    [decoder appendWithTabLevel:2 format:@"%@ = container.decode(.%@, defaultType: %@.self)", key, key, keyType];
                }
            }
            else {
                [decoder appendWithTabLevel:2 format:@"%@ = container.decode(.%@, defaultValue: %@)", key, key, [self getDefaultValueFor:keyType]];
            }
        }
        else {
            [decoder appendWithTabLevel:2 format:@"%@ = try container.decode(%@.self, forKey: .%@)", key, keyType, key];
        }
        break;
    }
        
    case CodeLanguageObjectiveC: {
        if (components.count <= 1) return;
        NSMutableString *decoder = (NSMutableString *)components[1];
        NSString *key = originKey.asCamelCase;
        if (isObject) {
            if ([keyType containsString:@"]"]) { // is array
                [decoder appendWithTabLevel:1 format:@"self.%@ = @[];", key];
            } else {
                [decoder appendWithTabLevel:1 format:@"self.%@ = [[%@ alloc] initWithDatasource:datasource[@\"%@\"]];", key, keyType, originKey];
            }
        } else {
            [decoder appendWithTabLevel:1 format:@"self.%@ = datasource[@\"%@\"];", key, originKey];
            [decoder appendWithTabLevel:1 format:@"if (!self.%@) {", key];
            [decoder appendWithTabLevel:2 format:@"self.%@ = %@;", key, [self getDefaultValueFor:keyType]];
            [decoder appendWithTabLevel:1 format:@"}"];
        }
        break;
    }
    }
}

-(NSString *)getDefaultValueFor:(NSString *)type {
    if ([type isEqualToString:@"String"]) {
        return self.language == CodeLanguageSwift ? @"\"\"" : @"@\"\"";
    }
    else if ([type isEqualToString:@"Int"]) {
        return self.language == CodeLanguageSwift ? @"0" : @"@0";
    }
    else if ([type isEqualToString:@"Bool"]) {
        return @"false";
    }
    else if ([type isEqualToString:@"Double"] ||
             [type isEqualToString:@"Float"] ||
             [type isEqualToString:@"CGFloat"])
    {
        return self.language == CodeLanguageSwift ? @"0.0" : @"@0";
    }
    return type;
}

-(NSString *)generateObjectProperty:(NSString *)object keyName:(NSString *)originKeyName {
    NSString *property = @"";
    NSString *keyName = originKeyName.asCamelCase;
    switch (self.language) {
    case CodeLanguageObjectiveC: {
        property = [NSString stringWithFormat:@"@property (nonatomic, strong) %@ *%@;\n", object, keyName];
    }
        break;
        
    case CodeLanguageSwift: {
        property = [NSString stringWithFormat:@"\tlet %@: %@?\n", keyName, object];
    }
        break;
        
    default:
        break;
    }
    return property;
}

-(NSString *)gennerateArrayProperty:(NSString *)originKeyName {
    NSString *property = @"";
    NSString *keyName = originKeyName.asCamelCase;
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

-(NSString *)generateCommonPropertyForType:(NSString *)type keyName:(NSString *)originKeyName keyType:(NSString **)keyType {
    NSString *property = @"";
    NSString *keyName = originKeyName.asCamelCase;
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
            *keyType = @"String";
        }
        else if ([type containsString:@"Bool"]) {
            property = [NSString stringWithFormat:@"@property (nonatomic, assign) BOOL %@;\n", keyName];
            *keyType = @"Bool";
        }
        else if ([type containsString:@"Number"]) {
            property = [NSString stringWithFormat:@"@property (nonatomic, strong) NSNumber *%@;\n", keyName];
            *keyType = @"Int";
        }
        else {
            property = [NSString stringWithFormat:@"@property (nonatomic, strong) id *%@;\n", keyName];
            *keyType = @"Any";
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
