//
//  MainWindowController.m
//  GenModelMacOS
//
//  Created by Tung Nguyen on 9/22/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import "MainWindowController.h"
#import "MainWindow.h"

@interface MainWindowController ()

@end

@implementation MainWindowController

-(void)awakeFromNib {
    [super awakeFromNib];
    [(MainWindow *)self.window setController:self];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
