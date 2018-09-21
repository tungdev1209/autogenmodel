//
//  ViewController.m
//  GenModelMacOS
//
//  Created by Tung Nguyen on 9/21/18.
//  Copyright © 2018 Tung Nguyen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) dispatch_queue_t requestQueue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

-(dispatch_queue_t)requestQueue {
    if (!_requestQueue) {
        _requestQueue = dispatch_queue_create("com.tung.testrequest", DISPATCH_QUEUE_SERIAL);
    }
    return _requestQueue;
}

- (IBAction)btnPressed:(id)sender {
    dispatch_async(self.requestQueue, ^{
        [self requestAPI];
    });
}

-(void)requestAPI {
    NSURL *url = [NSURL URLWithString:@"http://localhost:8080/"];
    NSURLRequest *urlReq = [[NSURLRequest alloc] initWithURL:url];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [[AppInteractorManager shared] generateModel:data];
        [session finishTasksAndInvalidate];
    }];
    [task resume];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
