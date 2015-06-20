//
//  BTActionService.m
//  Dictastar
//
//  Created by mohamed on 20/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "BTActionService.h"
#import "UIKit+AFNetworking.h"

static NSString * const DictastarAPIBaseURLString = @"http://182.72.151.117/HL7WS/HLIntegration.asmx?op=";

@implementation BTActionService

+ (instancetype)sharedClient
{
    static BTActionService *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[BTActionService alloc] initWithBaseURL:[NSURL URLWithString:DictastarAPIBaseURLString]];
        _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone ];
        _sharedClient.securityPolicy.allowInvalidCertificates = YES;
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        
    });
    
    return _sharedClient;
}

#pragma mark - custom initialization

-(id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self)
    {
        self.requestSerializer = [AFHTTPRequestSerializer new];
        //        self.responseSerializer = [AFJSONResponseSerializer new];
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

@end
