//
//  BTActionService.h
//  Dictastar
//
//  Created by mohamed on 20/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface BTActionService : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end
