//
//  MainView.m
//  GenModelMacOS
//
//  Created by Tung Nguyen on 9/22/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import "MainView.h"
#import "MainViewModel.h"
#import "DivisionView.h"
#import "CommonExtension.h"

@interface MainView ()

@property (nonatomic, strong) MainViewModel *viewModel;

@property (weak) IBOutlet NSTextView *jsonTextView;
@property (weak) IBOutlet NSTextView *codeTextView;
@property (weak) IBOutlet NSLayoutConstraint *jsonWidthConstraint;
@property (weak) IBOutlet NSLayoutConstraint *codeWidthConstraint;
@property (weak) IBOutlet DivisionView *divView;

@property (nonatomic, weak) NSTrackingArea *trackingArea;

@property (nonatomic, assign) NSPoint lastLocation;

@end

@implementation MainView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [self.jsonTextView setFont:NSFont.defaultValue];
    [self.codeTextView setFont:NSFont.defaultValue];
    
    self.viewModel = [[MainViewModel alloc] init];
    
    NSPanGestureRecognizer *pan = [[NSPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHandler:)];
    [self.divView addGestureRecognizer:pan];
    
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways) owner:self userInfo:nil];
    self.trackingArea = trackingArea;
    [self addTrackingArea:self.trackingArea];
}

-(void)gestureHandler:(NSGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[NSPanGestureRecognizer class]]) {
        NSPanGestureRecognizer *pan = (NSPanGestureRecognizer *)gesture;
        switch (pan.state) {
            case NSGestureRecognizerStateBegan: {
                self.lastLocation = [pan locationInView:self];
            }
                break;
                
            case NSGestureRecognizerStateChanged: {
                NSPoint location = [pan locationInView:self];
                CGFloat trans = location.x - self.lastLocation.x;
                self.lastLocation = location;
                self.jsonWidthConstraint.constant += trans;
            }
                break;
                
            case NSGestureRecognizerStateEnded:
            case NSGestureRecognizerStateFailed:
            case NSGestureRecognizerStateCancelled: {
                
            }
                break;
                
            default:
                break;
        }
    }
}

-(void)btnGenereatePressed {
    self.codeTextView.string = [self.viewModel generateCodeFor:self.jsonTextView.string];
}

-(void)updateTrackingAreas {
//    NSLog(@"%@", NSStringFromSelector(_cmd));
    [super updateTrackingAreas];
}

-(void)mouseExited:(NSEvent *)event {
    [self resetCursorRects];
}

-(void)mouseEntered:(NSEvent *)event {
    [self addCursorRect:self.bounds cursor:[NSCursor resizeLeftRightCursor]];
}

@end
