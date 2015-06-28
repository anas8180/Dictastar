//
//  UIViewController+ActivityLoader.h
//  PinkyApp
//
//  Created by mohamed on 21/04/15.
//  Copyright (c) 2015 Arsalan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ActivityLoader)

-(void)addLoader;
-(void)addMessageLoader:(NSString *)message;
-(void)hideHud;

@end
