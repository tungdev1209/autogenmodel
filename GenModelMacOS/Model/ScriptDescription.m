//
//  ScriptDescription.m
//  AutoGenVIPERMac
//
//  Created by Tung Nguyen on 2/13/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import "ScriptDescription.h"

#define path(name, extension) [[NSBundle mainBundle] pathForResource:name ofType:extension]

@interface ScriptDescription ()

@property (nonatomic, copy) NSString *chooseInteractorString;
@property (nonatomic, copy) NSString *choosePresenterString;
@property (nonatomic, copy) NSString *chooseWireframeString;
@property (nonatomic, copy) NSString *chooseLanguageString;

@end

@implementation ScriptDescription

-(NSAppleEventDescriptor *)list {
    NSAppleEventDescriptor *list = [NSAppleEventDescriptor listDescriptor];
//    if ([self.scriptName isEqualToString:Script_AutoGen_Python]) {
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.scriptLink] atIndex:1];
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.authorName] atIndex:2];
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.projectName] atIndex:3];
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.projectPath] atIndex:4];
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.moduleName] atIndex:5];
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.modulePath] atIndex:6];
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.documentFilePath] atIndex:7];
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.date] atIndex:8];
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.year] atIndex:9];
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.chooseInteractorString] atIndex:10];
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.choosePresenterString] atIndex:11];
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.chooseWireframeString] atIndex:12];
//    }
    if ([self.scriptName isEqualToString:Script_AutoGen_Ruby]) {
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.scriptLink] atIndex:1];
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.projectPath] atIndex:2];
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.projectName] atIndex:3];
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.modulePath] atIndex:4];
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.moduleName] atIndex:5];
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.chooseInteractorString] atIndex:6];
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.choosePresenterString] atIndex:7];
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.chooseWireframeString] atIndex:8];
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.chooseLanguageString] atIndex:9];
    }
    else if ([self.scriptName isEqualToString:Script_Undo_Ruby]) {
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.scriptLink] atIndex:1];
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.projectPath] atIndex:2];
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.projectName] atIndex:3];
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.modulePath] atIndex:4];
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.moduleName] atIndex:5];
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.chooseLanguageString] atIndex:6];
    }
    else if ([self.scriptName isEqualToString:Script_Undo_Shell]) {
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[NSString stringWithFormat:@"%@/%@", self.modulePath, self.moduleName]] atIndex:1];
    }
//    else if ([self.scriptName isEqualToString:Script_Shell]) {
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.scriptLink] atIndex:1];
//    }
//    else if ([self.scriptName isEqualToString:Script_Test_Ruby]) {
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.scriptLink] atIndex:1];
//    }
//    else if ([self.scriptName isEqualToString:Script_Test_Python]) {
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.scriptLink] atIndex:1];
//    }
//    else if ([self.scriptName isEqualToString:Script_Test_Python]) {
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.scriptLink] atIndex:1];
//    }
    else if ([self.scriptName isEqualToString:Script_Check_Dependencies]) {
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.scriptLink] atIndex:1];
    }
    else if ([self.scriptName isEqualToString:Script_Check_ExistingDir]) {
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.scriptLink] atIndex:1];
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[NSString stringWithFormat:@"%@/%@", self.modulePath, self.moduleName]] atIndex:2];
    }
    else if ([self.scriptName isEqualToString:Script_Confirm_ReplaceDir]) {
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.moduleName] atIndex:1];
        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[NSString stringWithFormat:@"%@/%@", self.modulePath, self.moduleName]] atIndex:2];
    }
//    else if ([self.scriptName isEqualToString:Script_Install_Dependencies]) {
//        [list insertDescriptor:[NSAppleEventDescriptor descriptorWithString:self.dependenciesLink] atIndex:1];
//    }
    return list;
}

-(NSString *)scriptLink {
//    if ([self.scriptName isEqualToString:Script_AutoGen_Python]) {
//        return path(Script_AutoGen_Python, @"py");
//    }
    if ([self.scriptName isEqualToString:Script_AutoGen_Ruby]) {
        return path(Script_AutoGen_Ruby, @"rb");
    }
    else if ([self.scriptName isEqualToString:Script_Undo_Ruby]) {
        return path(Script_Undo_Ruby, @"rb");
    }
//    else if ([self.scriptName isEqualToString:Script_Test_Ruby]) {
//        return path(Script_Test_Ruby, @"rb");
//    }
//    else if ([self.scriptName isEqualToString:Script_Test_Python]) {
//        return path(Script_Test_Python, @"py");
//    }
    else if ([self.scriptName isEqualToString:Script_Check_Dependencies]) {
        return path(Script_Check_Dependencies, @"sh");
    }
//    else if ([self.scriptName isEqualToString:Script_Shell]) {
//        return path(Script_Shell, @"sh");
//    }
    else if ([self.scriptName isEqualToString:Script_Check_ExistingDir]) {
        return path(Script_Check_ExistingDir, @"sh");
    }
    return @"";
}

-(NSString *)appleEventDescriptor {
//    if ([self.scriptName isEqualToString:Script_AutoGen_Python]) {
//        return @"run_python";
//    }
    if ([self.scriptName isEqualToString:Script_AutoGen_Ruby]) {
        return @"run_ruby";
    }
    else if ([self.scriptName isEqualToString:Script_Undo_Ruby]) {
        return @"run_undo_ruby";
    }
    else if ([self.scriptName isEqualToString:Script_Undo_Shell]) {
        return @"run_shell_undo";
    }
//    else if ([self.scriptName isEqualToString:Script_Shell]) {
//        return @"run_shell";
//    }
//    else if ([self.scriptName isEqualToString:Script_Test_Ruby]) {
//        return @"run_test_ruby";
//    }
//    else if ([self.scriptName isEqualToString:Script_Test_Python]) {
//        return @"run_test_python";
//    }
    else if ([self.scriptName isEqualToString:Script_Check_Dependencies]) {
        return @"run_shell_check_dependencies";
    }
//    else if ([self.scriptName isEqualToString:Script_Install_Dependencies]) {
//        return @"install_dependencies";
//    }
    else if ([self.scriptName isEqualToString:Script_Check_ExistingDir]) {
        return @"run_shell_check_exist";
    }
    else if ([self.scriptName isEqualToString:Script_Confirm_ReplaceDir]) {
        return @"confirm_replace_dir";
    }
    return @"";
}
         
-(NSString *)chooseInteractorString {
    return self.chooseInteractor ? @"1" : @"0";
}

-(NSString *)choosePresenterString {
    return self.choosePresenter ? @"1" : @"0";
}

-(NSString *)chooseWireframeString {
    return self.chooseWireframe ? @"1" : @"0";
}

-(NSString *)chooseLanguageString {
    NSString *str = @"";
    switch (self.language) {
        case CodeLanguageObjectiveC:
            str = @"0";
            break;
            
        case CodeLanguageSwift:
            str = @"1";
            break;
            
        default:
            break;
    }
    return str;
}

@end
