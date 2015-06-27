//
//  RecordViewController.m
//  Dictastar
//
//  Created by mohamed on 17/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "RecordViewController.h"

@interface RecordViewController () {
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;

}
@property (strong, nonatomic) IBOutlet UILabel *patientName;
@property (strong, nonatomic) IBOutlet UILabel *conditionLable;
@property (strong, nonatomic) IBOutlet UILabel *fileName;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UIButton *playStopButton;

@end

@implementation RecordViewController
@synthesize dataDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"%@",dataDict);
    
    _patientName.text = [NSString stringWithFormat:@"%@ %@",[dataDict objectForKey:@"Name"],[self cutStringDate:[dataDict objectForKey:@"Dateofstudy"]]];
    
    NSString *fileNameString = [self getAudioFileName:[dataDict objectForKey:@"Name"]];
    _fileName.text = [NSString stringWithFormat:@"%@.m4a",fileNameString];

    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    
    _slider.value = 0.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

-(NSString *)cutStringDate:(NSString *)dateString
{
    // cut the String
    NSRange range = [dateString rangeOfString:@"T"];
    NSString *newString = [dateString substringWithRange:NSMakeRange(0, range.location)];
    
    // chanage the Date Format
    NSDateFormatter *oldFormatter = [[NSDateFormatter alloc] init];
    [oldFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *theDate= [oldFormatter dateFromString:newString];
    NSDateFormatter *newFormatter = [[NSDateFormatter alloc]init];
    [newFormatter setDateFormat:@"MM/dd/yyyy"];
    
    NSString *cutDate = [NSString stringWithFormat:@"%@",[newFormatter stringFromDate:theDate]];
    
    cutDate = [cutDate stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    
    return cutDate;
    
}

- (NSString *) getAudioFileName:(NSString *)name {
    
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:currentDate];
    NSLog(@"%ld",(long)[components day]);
    NSLog(@"%ld",(long)[components month]);
    NSLog(@"%ld",(long)[components year]);
    NSLog(@"%ld",(long)[components hour]);
    NSLog(@"%ld",(long)[components minute]);
    NSLog(@"%ld",(long)[components second]);

    NSString *file = [NSString stringWithFormat:@"%@_%ld%ld%ld_%ld%ld%ld",name,[components day],[components month],[components year],[components hour],[components minute],[components second]];
    
    return file;
}


#pragma mark - Action

- (IBAction)statPressed:(UIButton *)sender {
}
- (IBAction)recordPressded:(id)sender {
    
    if (!recorder.recording) {
        [_playStopButton setImage:[UIImage imageNamed:@"recorder_stop"] forState:UIControlStateNormal];

        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        
    }
}
- (IBAction)stopPressed:(UIButton *)sender {
    
    if (recorder.recording) {
        
        [recorder stop];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        

    }
    else if (player.isPlaying){
        
        [player stop];
    }
    
}
- (IBAction)pausePressed:(id)sender {
    
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
    [player setDelegate:self];
    
    [player play];
    
    _slider.minimumValue = 0.0;
    float total= player.duration;
    total = total/60;
    _slider.maximumValue = total;
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    
}
- (IBAction)sendPressed:(id)sender {
    
}
- (IBAction)sliderChanged:(UISlider *)sender {
    
    NSInteger position = (NSInteger)self.slider.value * 60; // Assume the slider scale is in minutes- so convert to sec
    if (player.isPlaying)
    {
        [player pause];
    }
    [player setCurrentTime:position];
    
    if (player.isPlaying) {
        [player
         play];
    }
}

- (void)updateTime:(NSTimer *)timer {
    
    float f =  (player.currentTime) ;
    self.slider.value = f/60.0;
    
}

#pragma mark - AVAudioPlayer delegate methods

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    if (flag) {
        
        [_playStopButton setImage:[UIImage imageNamed:@"recorder_play"] forState:UIControlStateNormal];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
