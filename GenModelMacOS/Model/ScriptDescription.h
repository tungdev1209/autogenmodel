//
//  ScriptDescription.h
//  AutoGenVIPERMac
//
//  Created by Tung Nguyen on 2/13/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppUtils.h"

//#define Script_AutoGen_Python @"AutoGenVIPER_Python"
#define Script_AutoGen_Ruby @"autogen"
#define Script_Undo_Ruby @"undo"
#define Script_Undo_Shell @"undo_sh"
#define Script_Check_Dependencies @"checkDependencies"
#define Script_Check_ExistingDir @"checkExist"
#define Script_Confirm_ReplaceDir @"ConfirmReplacing"

//#define Script_Shell @"Shell"
//#define Script_Install_Dependencies @"InstallDependencies"
//#define Script_Test_Ruby @"TestRuby"
//#define Script_Test_Python @"TestPython"

@interface ScriptDescription : NSObject

@property (nonatomic, copy) NSString *scriptName;
@property (nonatomic, copy) NSString *projectName;
@property (nonatomic, copy) NSString *projectPath;
@property (nonatomic, copy) NSString *moduleName;
@property (nonatomic, copy) NSString *modulePath;
@property (nonatomic, copy) NSString *documentFilePath;
@property (nonatomic, copy) NSString *authorName;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *year;
@property (nonatomic, assign) CodeLanguage language;
@property (nonatomic, assign) BOOL chooseInteractor;
@property (nonatomic, assign) BOOL choosePresenter;
@property (nonatomic, assign) BOOL chooseWireframe;
@property (nonatomic, copy) NSString *dependenciesLink;
@property (nonatomic, copy, readonly) NSString *scriptLink;
@property (nonatomic, strong, readonly) NSAppleEventDescriptor *list;
@property (nonatomic, copy, readonly) NSString *appleEventDescriptor;

@end
