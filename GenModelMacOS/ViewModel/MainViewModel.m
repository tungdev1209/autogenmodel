//
//  MainViewModel.m
//  GenModelMacOS
//
//  Created by Tung Nguyen on 9/22/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import "MainViewModel.h"

@interface MainViewModel ()

@property (nonatomic, strong) dispatch_queue_t requestQueue;

@end

@implementation MainViewModel

-(dispatch_queue_t)requestQueue {
    if (!_requestQueue) {
        _requestQueue = dispatch_queue_create("com.tung.genmodel", DISPATCH_QUEUE_SERIAL);
    }
    return _requestQueue;
}

-(NSString *)generateCodeFor:(NSString *)jsonString {
    NSError *error = nil;
    if (!error) {
        NSArray *codes = [[AppInteractorManager shared] generateModel:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
        return [codes componentsJoinedByString:@"\n=====================================================\n"];
    }
    return @"";
}

-(void)requestAPI {
    dispatch_async(self.requestQueue, ^{
        NSURL *url = [NSURL URLWithString:@"http://localhost:8080/"];
        NSURLRequest *urlReq = [[NSURLRequest alloc] initWithURL:url];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [[AppInteractorManager shared] generateModel:data];
            [session finishTasksAndInvalidate];
        }];
        [task resume];
    });
}

@end
