//
//  MainWindow.m
//  GenModelMacOS
//
//  Created by Tung Nguyen on 9/22/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import "MainWindow.h"
#import "MainViewController.h"

@interface MainWindow ()

@property (nonatomic, weak) IBOutlet NSButton *keyCodingCheckboxButton;

@end

@implementation MainWindow

- (void)awakeFromNib {
    [super awakeFromNib];
    [self checkLanguageState];
}

-(IBAction)genItemTapped:(id)sender {
    [(MainViewController *)self.contentViewController generateButtonPressed];
}

-(IBAction)useKeyCodingExtension:(NSButton *)sender {
    NSLog(@"sender: %ld", (long)sender.state);
    [[AppInteractorManager shared] setHasKeyCodingExt:sender.state == NSOnState];
}

-(IBAction)codeLanguageTapped:(NSButton *)sender {
    CodeLanguage currentLanguage = [AppInteractorManager shared].language;
    [[AppInteractorManager shared] setLanguage:(currentLanguage == CodeLanguageSwift ? CodeLanguageObjectiveC : CodeLanguageSwift)];
    [sender setTitle:[self titleForLanguage:[AppInteractorManager shared].language]];
    
    [self checkLanguageState];
    [self setKeyCodingIfNeeded];
}

-(void)setKeyCodingIfNeeded {
    if ([AppInteractorManager shared].language == CodeLanguageObjectiveC) {
        [[AppInteractorManager shared] setHasKeyCodingExt:NO];
    }
    else {
        [[AppInteractorManager shared] setHasKeyCodingExt:self.keyCodingCheckboxButton.state];
    }
}

-(void)checkLanguageState {
    if ([AppInteractorManager shared].language == CodeLanguageObjectiveC) {
        [self.toolbar removeItemAtIndex:3];
    }
    else {
        [self.toolbar insertItemWithItemIdentifier:@"KeyCodingExtension" atIndex:3];
    }
}

-(NSString *)titleForLanguage:(CodeLanguage)lang {
    if (lang == CodeLanguageObjectiveC) {
        return @"Objective-C";
    }
    else {
        return @"Swift";
    }
}

@end
