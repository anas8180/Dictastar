//
//  RecordViewController.m
//  Dictastar
//
//  Created by mohamed on 17/06/15.
//  Copyright (c) 2015 mohamed. All rights reserved.
//

#import "RecordViewController.h"
#import "BTServicesClient.h"
#import "SendQViewController.h"
#import "BRRequestUpload.h"
#import "BRRequest+_UserData.h"
#import "Constant.h"
#import "UIViewController+ActivityLoader.h"
#import "ScheduleViewController.h"
#import <AudioToolbox/AudioServices.h>
#import "PCSEQVisualizer.h"

@interface RecordViewController ()<BRRequestDelegate> {
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    NSString *statPriority;
    BOOL isStat;
    NSString *fileNameString;
    NSData *uploadData;
    BRRequestUpload *uploadFile;
    NSTimer *record_timer,*player_timer;
    int rec_time;
    int max_dict;
    PCSEQVisualizer *eq;

}

@property (strong, nonatomic) IBOutlet UILabel *record_timer_lable;
@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet UILabel *patientName;
@property (strong, nonatomic) IBOutlet UILabel *conditionLable;
@property (strong, nonatomic) IBOutlet UILabel *fileName;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) NSDictionary *user_info;
@property (strong, nonatomic) NSDictionary *hostDict;
@property (strong, nonatomic) IBOutlet UILabel *countTimer;
@property (strong, nonatomic) IBOutlet UILabel *countDownTimer;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topLayout;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) NSArray *inputs;
@end

@implementation RecordViewController
@synthesize dataDict;
@synthesize jobTypeDict;
@synthesize alertDelete;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _user_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"];
    max_dict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"max_dict"] intValue];
    
    max_dict = max_dict * 60;

    _patientName.text = [NSString stringWithFormat:@"%@ %@",[dataDict objectForKey:@"Name"],[self cutStringDate:[dataDict objectForKey:@"Dateofstudy"]]];
    
    NSArray *nameArray = [[dataDict objectForKey:@"Name"] componentsSeparatedByString:@" "];

    fileNameString = [self getAudioFileName:nameArray];
    
    _fileName.text = [NSString stringWithFormat:@"%@.m4a",fileNameString];

    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               _fileName.text,
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),&audioRouteOverride);
    
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
    
    statPriority = @"Hight";
    isStat = YES;
    
    _countTimer.text = @"00:00";
    _countDownTimer.text = @"00:00";
    
  

    if (IS_IPHONE4) {
        
        _topLayout.constant = 20;
    }
    
    rec_time = 1;
    
    [self fetchFTPDetails];
    [self showVisualizer];
    [self showBarVisualizer];
    
    _playButton.enabled = NO;
    _deleteButton.enabled = NO;
    _sendButton.enabled = NO;
    _stopButton.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Service Call

-(void)fetchFTPDetails {
    
    [[BTServicesClient sharedClient] GET:@"GetFTPDetailsJSON" parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        NSArray *data  = [jsonData objectForKey:@"Table"];
        _hostDict = [data objectAtIndex:0];
        NSLog(@"Array:%@",data);
        NSLog(@"HostDict:%@",_hostDict);
        
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        NSLog(@"%@",error.localizedDescription);
        
        
    }];

}

-(void)showVisualizer
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if (error)
    {
        NSLog(@"Error setting up audio session category: %@", error.localizedDescription);
    }
    [session setActive:YES error:&error];
    if (error)
    {
        NSLog(@"Error setting up audio session active: %@", error.localizedDescription);
    }
    
    // Customizing the audio plot's look
    // Background color
    self.audioPlot.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    //
    
    // Waveform color
    self.audioPlot.color = [UIColor colorWithRed:0.984 green:0.471 blue:0.525 alpha:1.0];
    //
    
    // Plot type
    self.audioPlot.plotType = EZPlotTypeBuffer;
    //
    
    // Create the microphone
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
    //
    
    //
    // Set up the microphone input UIPickerView items to select
    // between different microphone inputs. Here what we're doing behind the hood
    // is enumerating the available inputs provided by the AVAudioSession.
    //
    self.inputs = [EZAudioDevice inputDevices];
    
    // Start the microphone
    [self.microphone startFetchingAudio];
    //
    [self.audioPlot setHidden:YES];
}

-(void)showBarVisualizer
{
    eq = [[PCSEQVisualizer alloc]initWithNumberOfBars:5];
    [barVisualizer addSubview:eq];
    [eq setHidden:YES];
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

- (NSString *) getAudioFileName:(NSArray *)name {
    
    NSString *fname,*lname;
    
    if (name.count>1) {
        fname = [name objectAtIndex:0];
        lname = [name objectAtIndex:1];
    }
    
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:currentDate];
//    NSLog(@"Day:%ld",(long)[components day]);
//    NSLog(@"Month:%ld",(long)[components month]);
//    NSLog(@"Year:%ld",(long)[components year]);
//    NSLog(@"Hour:%ld",(long)[components hour]);
//    NSLog(@"Min:%ld",(long)[components minute]);
//    NSLog(@"Second:%ld",(long)[components second]);

    NSString *file = [NSString stringWithFormat:@"%@_%@_%ld%ld%ld_%ld%ld%ld",fname,lname,(long)[components month],(long)[components day],(long)[components year],(long)[components hour],(long)[components minute],(long)[components second]];
    NSLog(@"DateFormat:%@",file);
    return file;
}


#pragma mark - Action

- (IBAction)statPressed:(UIButton *)sender {
    
    if (isStat) {
        [sender setImage:[UIImage imageNamed:@"record_stat_button"] forState:UIControlStateNormal];
        
        statPriority = @"Normal";
        NSLog(@"Stat Normal");
        isStat = NO;
    }
    else {
        [sender setImage:[UIImage imageNamed:@"record_stat_button_ticked"] forState:UIControlStateNormal];

        statPriority = @"High";
        NSLog(@"Stat High");
        isStat = YES;
    }
    
}
- (IBAction)recordPressded:(id)sender {
    
    if (!recorder.recording) {

        [self.audioPlot setHidden:NO];
        NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [documentdir stringByAppendingPathComponent:_fileName.text];
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];

        if (!fileExists) {
            
            NSArray *nameArray = [[dataDict objectForKey:@"Name"] componentsSeparatedByString:@" "];
            
            fileNameString = [self getAudioFileName:nameArray];
            
            _fileName.text = [NSString stringWithFormat:@"%@.m4a",fileNameString];
            
            // Set the audio file
            NSArray *pathComponents = [NSArray arrayWithObjects:
                                       [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                       _fileName.text,
                                       nil];
            NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
 
            // Setup audio session
                        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                                     sizeof (audioRouteOverride),&audioRouteOverride);
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
            
        }

        [sender setImage:[UIImage imageNamed:@"recorder_pause"]forState:UIControlStateNormal];
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        record_timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(recordingTime)
                                               userInfo:nil
                                                repeats:YES];
        [self addMessageLoader:@"Record Start"];

        [recorder record];
        
        [_playButton setEnabled:NO];
        [_sendButton setEnabled:NO];
        [_deleteButton setEnabled:NO];
        _stopButton.enabled = YES;
        
    }
    else{
        
        [_playButton setEnabled:NO];
        [_sendButton setEnabled:NO];
        [_deleteButton setEnabled:NO];

        [sender setImage:[UIImage imageNamed:@"recorder_image"]forState:UIControlStateNormal];
        
        [recorder pause];
        [self.audioPlot setHidden:YES];
        
        [record_timer invalidate];
        
    }
}
- (IBAction)stopPressed:(UIButton *)sender {
    
    if (recorder.recording) {
        
        [_recordButton setImage:[UIImage imageNamed:@"recorder_image"]forState:UIControlStateNormal];
        
        [recorder stop];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        [record_timer invalidate];
        [self addMessageLoader:@"Record Stop"];
        NSLog(@"Stop Record");
        
        [_playButton setEnabled:YES];
        [_sendButton setEnabled:YES];
        [_deleteButton setEnabled:YES];
        [_recordButton setEnabled:NO];
        [self.audioPlot setHidden:YES];
        [eq setHidden:YES];
        
    }
    else if (player.isPlaying){
        
        [player stop];
        [player_timer invalidate];
        
        [_playButton setImage:[UIImage imageNamed:@"play_button"]forState:UIControlStateNormal];
        NSLog(@"Player Stop");
        
        [_playButton setEnabled:YES];
        [_sendButton setEnabled:YES];
        [_deleteButton setEnabled:YES];
        [_recordButton setEnabled:NO];
        [self.audioPlot setHidden:YES];
        [eq setHidden:YES];
        
        _slider.value = 0.0;
        
        player = nil;
    }
    
    
}
- (IBAction)pausePressed:(id)sender {
    
    if (!player.isPlaying) {
        
        if (player != nil) {
            
            [player play];
            [sender setImage:[UIImage imageNamed:@"record_pause_button"] forState:UIControlStateNormal];
            [eq setHidden:NO];
            [eq start];
            
            _slider.minimumValue = 0.0;
            float total= player.duration;
            total = total/60;
            _slider.maximumValue = total;
            
            player_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
            
            [_sendButton setEnabled:NO];
            [_recordButton setEnabled:NO];
            [_deleteButton setEnabled:NO];
            
            NSString *dur = [NSString stringWithFormat:@"%02d:%02d", (int)((int)(player.duration)) / 60, (int)((int)(player.duration)) % 60];
            
            _countTimer.text = dur;

        }
        
        else {
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
            [player setDelegate:self];
            
            [player play];
            [eq setHidden:NO];
            [eq start];
            [self.audioPlot setHidden:YES];
            _slider.minimumValue = 0.0;
            float total= player.duration;
            total = total/60;
            _slider.maximumValue = total;
            
            player_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
            
            [_sendButton setEnabled:NO];
            [_recordButton setEnabled:NO];
            [_deleteButton setEnabled:NO];
            
            NSString *dur = [NSString stringWithFormat:@"%02d:%02d", (int)((int)(player.duration)) / 60, (int)((int)(player.duration)) % 60];
            
            _countTimer.text = dur;
            
            [sender setImage:[UIImage imageNamed:@"record_pause_button"] forState:UIControlStateNormal];
            
            _record_timer_lable.text = @"00:00";
            
        }
        
    }
    
    else {
        
        [player pause];
        NSLog(@"Play Pause");
        [self.audioPlot setHidden:YES];
        [eq setHidden:YES];
        [eq stop];
        [sender setImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateNormal];
//        record_pause_button
//         player = nil;
    }
   
}
- (IBAction)sendPressed:(id)sender {
    
    [self addLoader];
    
    NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *tileDirectory = [documentdir stringByAppendingPathComponent:_fileName.text];

    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:tileDirectory error:nil] fileSize];
    
    NSString *fileSizeString = [NSString stringWithFormat:@"%llu",fileSize];

    NSDictionary *params = @{@"facilityID":[_user_info objectForKey:@"FacilityId"],@"username":[_user_info objectForKey:@"username"],@"filename":_fileName.text,@"fileType":@".wav",@"fileSize":fileSizeString,@"priority":statPriority,@"attendingPhysicianId":[_user_info objectForKey:@"DictatorId"],@"typeofDictation":[jobTypeDict objectForKey:@"Type"],@"notes":@""};
    
    [[BTServicesClient sharedClient] GET:@"AddDictateDetailsinJson" parameters:params success:^(NSURLSessionDataTask * __unused task, id JSON) {
        
        NSError* error;
        NSDictionary* jsonData = [NSJSONSerialization JSONObjectWithData:JSON options:kNilOptions error:&error];
        NSArray *data  = [jsonData objectForKey:@"Table"];

        [self uploadFile];
        
        
        
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        //Failure of service call....
        
        NSLog(@"%@",error.localizedDescription);
        
        [self hideHud];
    }];

    
}
- (IBAction)sliderChanged:(UISlider *)sender {
    
    NSInteger position = (NSInteger)self.slider.value * 60; // Assume the slider scale is in minutes- so convert to sec
    if (player.isPlaying)
    {
        [player pause];
//        [player setCurrentTime:position];
    }
    [player setCurrentTime:position];
    
//    if (player.isPlaying) {
//        [player play];
//    }
}

- (void)updateTime:(NSTimer *)timer {
    
    float f =  (player.currentTime) ;
    self.slider.value = f/60.0;
    
    NSString *dur = [NSString stringWithFormat:@"%02d:%02d", (int)((int)(player.currentTime)) / 60, (int)((int)(player.currentTime)) % 60];

    _countDownTimer.text = dur;

    
}

-(void)recordingTime {
    
    if (rec_time == max_dict) {
        
        [recorder stop];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        [record_timer invalidate];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Time Exceeded" message:@"Recording Stopped" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
    
    NSString *dur = [NSString stringWithFormat:@"%02d:%02d", rec_time / 60, rec_time % 60];
    
    _record_timer_lable.text = dur;
    
    rec_time = rec_time + 1;
    
}
- (IBAction)deleteRecord:(id)sender {
    
    alertDelete = [[UIAlertView alloc]init];
    [alertDelete setDelegate:self];
    [alertDelete setTitle:@"Alert!"];
    [alertDelete setMessage:@"Do you want to Delete Record?"];
    [alertDelete addButtonWithTitle:@"Yes"];
    [alertDelete addButtonWithTitle:@"No"];
    
    alertDelete.alertViewStyle =UIAlertViewStyleDefault;
    alertDelete.tag = 1;
    [alertDelete show];
    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//    NSString *filePath = [documentdir stringByAppendingPathComponent:_fileName.text];
//    
//    NSError *error;
//    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
//    
//    if (success) {
//        
//        UIAlertView* add = [[UIAlertView alloc] init];
//        [add setDelegate:self];
//        [add setTitle:@"Alert!"];
//        [add setMessage:@"Do you want to Delete Record?"];
//        [add addButtonWithTitle:@"Yes"];
//        [add addButtonWithTitle:@"No"];
//        
//        add.alertViewStyle =UIAlertViewStyleDefault;
//        add.tag = 1;
//        [add show];
//
//    }
//    else {
//        
//        [self addMessageLoader:error.localizedDescription];
//    }

}

#pragma mark - AVAudioPlayer delegate methods

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    if (flag) {
        
        [_playButton setImage:[UIImage imageNamed:@"play_button"]forState:UIControlStateNormal];
        
        _slider.value = 0.0;
   
        [player_timer invalidate];
        _countTimer.text = @"00:00";
        
        _countDownTimer.text = @"00:00";
        
        [_sendButton setEnabled:YES];
        [_recordButton setEnabled:NO];
        [_deleteButton setEnabled:YES];
        [self.audioPlot setHidden:YES];
        [eq setHidden:YES];
        [eq stop];
    }
}

#pragma mark - Uplaod FTP on Server

- (void)uploadFile
{
    //----- get the file to upload as an NSData object
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               _fileName.text,
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    uploadData = [NSData dataWithContentsOfURL:outputFileURL];
    
    uploadFile = [[BRRequestUpload alloc] initWithDelegate:self];
    
    uploadFile.path = [NSString stringWithFormat:@"/%@/%@",[_user_info objectForKey:@"FacilityId"],_fileName.text];
    NSLog(@"UploadFilePath:%@",uploadFile.path);
    uploadFile.hostname = [_hostDict objectForKey:@"HOST"];
//    uploadFile.hostname = @"192.168.1.7";
    NSLog(@"HostUrl:%@",uploadFile.hostname);
    uploadFile.username = [_hostDict objectForKey:@"UN"];
    uploadFile.password = [_hostDict objectForKey:@"PWD"];
    
    [uploadFile start];
}

-(BOOL) shouldOverwriteFileWithRequest: (BRRequest *) request
{
    //----- set this as appropriate if you want the file to be overwritten
    if (request == uploadFile)
    {
        //----- if uploading a file, we set it to YES
        return YES;
    }
    
    //----- anything else (directories, etc) we set to NO
    return NO;
}

-(void) requestCompleted: (BRRequest *) request
{
    [self hideHud];
    
    NSLog(@"Request %@ completed!", request);
    uploadFile = nil;
    
 /*   SendQViewController *sendQObj = [self.storyboard instantiateViewControllerWithIdentifier:@"SendQView"];
    [self.navigationController showViewController:sendQObj sender:self]; */


    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        //Do not forget to import AnOldViewController.h
        if ([controller isKindOfClass:[ScheduleViewController class]]) {
            
            [self.navigationController popToViewController:controller
                                                  animated:YES];
            break;
        }
    }

}

- (NSData *) requestDataToSend: (BRRequestUpload *) request
{
    //----- returns data object or nil when complete
    //----- basically, first time we return the pointer to the NSData.
    //----- and BR will upload the data.
    //----- Second time we return nil which means no more data to send
    NSData *temp = uploadData;                                                  // this is a shallow copy of the pointer, not a deep copy
    
    uploadData = nil;                                                           // next time around, return nil...
    
    return temp;
}

-(void) requestFailed:(BRRequest *) request
{
    [self hideHud];

    NSLog(@"Request:%@", request.error.message);
    
    uploadFile = nil;

  /*  SendQViewController *sendQObj = [self.storyboard instantiateViewControllerWithIdentifier:@"SendQView"];
    [self.navigationController showViewController:sendQObj sender:self]; */
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        
        //Do not forget to import AnOldViewController.h
        if ([controller isKindOfClass:[ScheduleViewController class]]) {
            
            [self.navigationController popToViewController:controller
                                                  animated:YES];
            break;
        }
    }

}

#pragma Alert Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked OK
    if (buttonIndex == 0) {
        // do something here...
        NSLog(@"Delete Yes");
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [documentdir stringByAppendingPathComponent:_fileName.text];
        
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
        
        if (success) {
            for (UIViewController *controller in self.navigationController.viewControllers) {
                
                //Do not forget to import AnOldViewController.h
                if ([controller isKindOfClass:[ScheduleViewController class]]) {
                    [self.navigationController popToViewController:controller animated:YES];
                    break;
                }
            }
        }
        else
        {
            [self addMessageLoader:@"Delete No"];
        }
    }
    else if(buttonIndex == 1)
    {
        NSLog(@"Delete No");
    }
}

#pragma mark - EZMicrophoneDelegate
#warning Thread Safety
// Note that any callback that provides streamed audio data (like streaming
// microphone input) happens on a separate audio thread that should not be
// blocked. When we feed audio data into any of the UI components we need to
// explicity create a GCD block on the main thread to properly get the UI
// to work.
- (void)microphone:(EZMicrophone *)microphone
  hasAudioReceived:(float **)buffer
    withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
{
    // Getting audio data as an array of float buffer arrays. What does that mean?
    // Because the audio is coming in as a stereo signal the data is split into
    // a left and right channel. So buffer[0] corresponds to the float* data
    // for the left channel while buffer[1] corresponds to the float* data
    // for the right channel.
    
    // See the Thread Safety warning above, but in a nutshell these callbacks
    // happen on a separate audio thread. We wrap any UI updating in a GCD block
    // on the main thread to avoid blocking that audio flow.
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        // All the audio plot needs is the buffer data (float*) and the size.
        // Internally the audio plot will handle all the drawing related code,
        // history management, and freeing its own resources.
        // Hence, one badass line of code gets you a pretty plot :)
        [weakSelf.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}

//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone hasAudioStreamBasicDescription:(AudioStreamBasicDescription)audioStreamBasicDescription
{
    // The AudioStreamBasicDescription of the microphone stream. This is useful
    // when configuring the EZRecorder or telling another component what
    // audio format type to expect.
    [EZAudioUtilities printASBD:audioStreamBasicDescription];
}

//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone
     hasBufferList:(AudioBufferList *)bufferList
    withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels
{
    // Getting audio data as a buffer list that can be directly fed into the
    // EZRecorder or EZOutput. Say whattt...
}

//------------------------------------------------------------------------------

- (void)microphone:(EZMicrophone *)microphone changedDevice:(EZAudioDevice *)device
{
    NSLog(@"Microphone changed device: %@", device.name);
    
    // Called anytime the microphone's device changes
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *name = device.name;
        NSString *tapText = @" (Tap To Change)";
        NSString *microphoneInputToggleButtonText = [NSString stringWithFormat:@"%@%@", device.name, tapText];
        NSRange rangeOfName = [microphoneInputToggleButtonText rangeOfString:name];
        NSMutableAttributedString *microphoneInputToggleButtonAttributedText = [[NSMutableAttributedString alloc] initWithString:microphoneInputToggleButtonText];
        [microphoneInputToggleButtonAttributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13.0f] range:rangeOfName];
//        [weakSelf.microphoneInputToggleButton setAttributedTitle:microphoneInputToggleButtonAttributedText forState:UIControlStateNormal];
        
        // reset the device list (a device may have been plugged in/out)
        weakSelf.inputs = [EZAudioDevice inputDevices];
//        [weakSelf.microphoneInputPickerView reloadAllComponents];
//        [weakSelf setMicrophonePickerViewHidden:YES];
    });
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
