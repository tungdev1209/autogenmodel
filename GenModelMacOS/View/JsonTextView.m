//
//  JsonTextView.m
//  GenModelMacOS
//
//  Created by Tung Nguyen on 12/24/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import "JsonTextView.h"
#import "CommonExtension.h"

@interface JsonTextView ()

@property (nonatomic, strong) NSAttributedString *placeHolderString;

@end

@implementation JsonTextView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSColor *txtColor = [NSColor grayColor];
    NSFont *font = NSFont.defaultItalicValue;
    NSDictionary *txtDict = @{NSForegroundColorAttributeName: txtColor,
                              NSFontAttributeName: font};
    self.placeHolderString = [[NSAttributedString alloc] initWithString:@"Paste your json here..." attributes:txtDict];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
    if ([self.string isEqualToString:@""]) {
        if (self != [self.window firstResponder]) {
            [self.placeHolderString drawAtPoint:NSMakePoint(3, 0)];
        }
        else {
            self.string = @"";
        }
    }
}

@end
