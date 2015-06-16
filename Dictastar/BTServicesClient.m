//
//  BTServicesClient.m
//
//  Created by Madhavi


#import "BTServicesClient.h"
#import "UIKit+AFNetworking.h"

@implementation BTServicesClient

static NSString * const PinkyTalksAPIBaseURLString = @"http://182.72.151.117:8080/ios/service.asmx?op=";


+ (instancetype)sharedClient
{
    static BTServicesClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[BTServicesClient alloc] initWithBaseURL:[NSURL URLWithString:PinkyTalksAPIBaseURLString]];
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
