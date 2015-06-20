//
//  RecordViewController.h
//  Dictastar
//
//  Created by mohamed on 17/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RecordViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) NSDictionary *dataDict;

@end
