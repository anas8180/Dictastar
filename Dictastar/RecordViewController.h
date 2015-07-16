//
//  RecordViewController.h
//  Dictastar
//
//  Created by mohamed on 17/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EZAudio.h"
#import "PCSEQVisualizer.h"

@interface RecordViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate,EZMicrophoneDelegate>
{
    
    __weak IBOutlet UIView *barVisualizer;
}
@property (nonatomic, strong) NSDictionary *dataDict;
@property (nonatomic, strong) NSDictionary *jobTypeDict;
@property (nonatomic, strong) UIAlertView *alertDelete;
@property (weak, nonatomic) IBOutlet EZAudioPlot *audioPlot;
@property (nonatomic, strong) EZMicrophone *microphone;

@end
