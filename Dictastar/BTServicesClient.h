//
//  BTServicesClient.h
//
//  Created by Madhavi
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface BTServicesClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
