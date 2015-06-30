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
#import <AudioToolbox/AudioServices.h>

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

}

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

@end

@implementation RecordViewController
@synthesize dataDict;
@synthesize jobTypeDict;

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
    
    statPriority = @"Normal";
    isStat = NO;
    
    _countTimer.text = @"00:00";
    _countDownTimer.text = @"00:00";

    if (IS_IPHONE4) {
        
        _topLayout.constant = 20;
    }
    
    rec_time = 1;
    
    [self fetchFTPDetails];
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
    NSLog(@"Day:%ld",(long)[components day]);
    NSLog(@"Month:%ld",(long)[components month]);
    NSLog(@"Year:%ld",(long)[components year]);
    NSLog(@"Hour:%ld",(long)[components hour]);
    NSLog(@"Min:%ld",(long)[components minute]);
    NSLog(@"Second:%ld",(long)[components second]);

    NSString *file = [NSString stringWithFormat:@"%@_%@_%ld%ld%ld_%ld%ld%ld",fname,lname,(long)[components day],(long)[components month],(long)[components year],(long)[components hour],(long)[components minute],(long)[components second]];
    
    return file;
}


#pragma mark - Action

- (IBAction)statPressed:(UIButton *)sender {
    
    if (isStat) {
        [sender setImage:[UIImage imageNamed:@"checkbox_off"] forState:UIControlStateNormal];
        
        statPriority = @"Normal";
        NSLog(@"Stat Normal");
        isStat = NO;
    }
    else {
        [sender setImage:[UIImage imageNamed:@"checkbox_on"] forState:UIControlStateNormal];

        statPriority = @"High";
        NSLog(@"Stat High");
        isStat = YES;
    }
    
}
- (IBAction)recordPressded:(id)sender {
    
    if (!recorder.recording) {

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
        
    }
    else{
        
        [_playButton setEnabled:NO];
        [_sendButton setEnabled:NO];
        [_deleteButton setEnabled:NO];

        [sender setImage:[UIImage imageNamed:@"recorder_image"]forState:UIControlStateNormal];
        
        [recorder pause];
        
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
        [_recordButton setEnabled:YES];


    }
    else if (player.isPlaying){
        
        [player stop];
        [player_timer invalidate];

        [_playButton setEnabled:YES];
        [_sendButton setEnabled:YES];
        [_deleteButton setEnabled:YES];
        
        _slider.value = 0.0;
        _countDownTimer.text = @"00:00";
        _countTimer.text = @"00:00";
    }
    
    
}
- (IBAction)pausePressed:(id)sender {
    
    if (!player.isPlaying) {
        
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
    [player setDelegate:self];
    
    [player play];
    
    _slider.minimumValue = 0.0;
    float total= player.duration;
    total = total/60;
    _slider.maximumValue = total;
    
    player_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
        
        [_sendButton setEnabled:NO];
        [_recordButton setEnabled:NO];
        [_deleteButton setEnabled:NO];
    
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
    NSLog(@"SliderValue:%f",f);
    _countTimer.text = [NSString stringWithFormat:@"%.2f",f];
    
    NSTimeInterval timeLeft = player.duration - player.currentTime;
    
    // update your UI with timeLeft
    _countDownTimer.text = [NSString stringWithFormat:@"%.2f", timeLeft];
    

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
    
    rec_time = rec_time + 1;
                              
}
- (IBAction)deleteRecord:(id)sender {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentdir stringByAppendingPathComponent:_fileName.text];
    
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    
    if (success) {
        
        [self addMessageLoader:@"deleted"];
    }
    else {
        
        [self addMessageLoader:error.localizedDescription];
    }

}

#pragma mark - AVAudioPlayer delegate methods

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    
    if (flag) {
        
        _slider.value = 0.0;
        
        [player_timer invalidate];
        
        _countTimer.text = @"00:00";
        
        _countDownTimer.text = @"00:00";
        
        [_sendButton setEnabled:YES];
        [_recordButton setEnabled:YES];
        [_deleteButton setEnabled:YES];

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
//    uploadFile.hostname = [_hostDict objectForKey:@"HOST"];
    uploadFile.hostname = @"192.168.1.7";
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
    
    SendQViewController *sendQObj = [self.storyboard instantiateViewControllerWithIdentifier:@"SendQView"];
    [self.navigationController showViewController:sendQObj sender:self];


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

    SendQViewController *sendQObj = [self.storyboard instantiateViewControllerWithIdentifier:@"SendQView"];
    [self.navigationController showViewController:sendQObj sender:self];

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
