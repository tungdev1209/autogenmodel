//
//  ViewController.h
//  GenModelMacOS
//
//  Created by Tung Nguyen on 9/21/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainViewController : NSViewController

-(void)generateButtonPressed;
-(void)chooseLanguage:(CodeLanguage)language;

@end

