//
//  MainView.h
//  GenModelMacOS
//
//  Created by Tung Nguyen on 9/22/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainView : NSView

@property (nonatomic, weak) MainViewController *controller;

- (void)btnGenereatePressed;

@end

NS_ASSUME_NONNULL_END
