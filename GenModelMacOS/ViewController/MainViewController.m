//
//  ViewController.m
//  GenModelMacOS
//
//  Created by Tung Nguyen on 9/21/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"

@interface MainViewController ()

@property (nonatomic, weak) MainView *mainView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    self.mainView = (MainView *)self.view;
    self.mainView.controller = self;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

-(void)generateButtonPressed {
    [self.mainView btnGenereatePressed];
}

-(void)chooseLanguage:(CodeLanguage)language {
    
}


@end
