//
//  AppUtils.m
//  AutoGenVIPERMac
//
//  Created by Tung Nguyen on 2/13/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import "AppUtils.h"

@implementation AppUtils

+(NSString *)currentDate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yy"];
    return [formatter stringFromDate:[NSDate date]];
}

+(NSString *)currentYear {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    return [formatter stringFromDate:[NSDate date]];
}

+(NSString *)stringFromState:(NSControlStateValue)value {
    return value == NSControlStateValueOn ? @"1" : @"0";
}

+(BOOL)boolFromState:(NSControlStateValue)value {
    return value == NSControlStateValueOn;
}

+(void)rotate360Animation:(NSView *)view counterClockWise:(BOOL)counterClockWise {
    [view setWantsLayer:YES];
    [view.layer setAnchorPoint:CGPointMake(0.5f, 0.5f)];
    CGFloat centerX = view.frame.size.width / 2.0f + view.frame.origin.x;
    CGFloat centerY = view.frame.size.height / 2.0f + view.frame.origin.y;
    view.layer.position = CGPointMake(centerX, centerY);
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    anim.fromValue = @(0.0f);
    if (counterClockWise) {
        anim.toValue = @(-2.0f * M_PI);
    }
    else {
        anim.toValue = @(2.0f * M_PI);
    }
    anim.duration = 0.35f;
    [view.layer addAnimation:anim forKey:nil];
}

+(void)flashAnimation:(NSView *)view {
    [view setWantsLayer:YES];
    [view.layer setAnchorPoint:CGPointMake(0.5f, 0.5f)];
    CGFloat centerX = view.frame.size.width / 2.0f + view.frame.origin.x;
    CGFloat centerY = view.frame.size.height / 2.0f + view.frame.origin.y;
    view.layer.position = CGPointMake(centerX, centerY);
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim.fromValue = @(1.0f);
    anim.toValue = @(0.0);
    anim.duration = 0.2f;
    [view.layer addAnimation:anim forKey:nil];
    
    anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anim.fromValue = @(0.0f);
    anim.toValue = @(1.0);
    anim.duration = 0.2f;
    [view.layer addAnimation:anim forKey:nil];
}

@end
