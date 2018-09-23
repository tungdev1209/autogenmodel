//
//  MainViewModel.h
//  GenModelMacOS
//
//  Created by Tung Nguyen on 9/22/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainViewModel : NSObject

-(void)requestAPI;
-(NSString *)generateCodeFor:(NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
