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

@end

@implementation MainWindow

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(IBAction)genItemTapped:(id)sender {
    [(MainViewController *)self.contentViewController generateButtonPressed];
}

@end
