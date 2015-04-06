//
//  CreateSlideShowVC.m
//  Fun Spot App
//
//  Created by Tran Thanh Bang on 10/16/14.
//
//
#import "CreateSlideShowVC.h"
#import "SlideShowVC.h"
#import "AsynImageButton.h"
#import "PhotoViewController.h"
#import "BaseNavigationController.h"
#import "ImageGalleryViewController.h"
#import "CreateSlideShowVC.h"
#import "Annotation.h"
#import "PhotoObj.h"
#import "ObjectSavePathSlide.h"
#import "PlayListView.h"
#import "FileHelper.h"
#import <FacebookSDK/FacebookSDK.h>
#import "TTTAttributedLabel.h"
#import "PreviewSlideshow.h"
#import "NewCellPhoto.h"

@interface CreateSlideShowVC ()<UINavigationControllerDelegate,UIGestureRecognizerDelegate,AVAudioPlayerDelegate,AVAudioRecorderDelegate,AVAudioSessionDelegate,MPMediaPickerControllerDelegate,PlayListViewDelegate>
{
    __weak IBOutlet UIView *viewNavigation;
    __weak IBOutlet UILabel *_lbNameAudio;
    __weak IBOutlet UILabel *_lbDurationSlide;
    __weak IBOutlet UIView *_viewMenuBar;
    __weak IBOutlet UIButton *btnBack;
    __weak IBOutlet UIScrollView *_scrollImages;
    UIScrollView *_scrollerView;
    NSMutableArray *_images;
    AppDelegate *delegate;
    UITapGestureRecognizer *recognizer;
    NSString *stringAudioCroped,*stringURLVideoSaved,*strURLVideoServer,*strLinkLocalDB;
    NSURL *urlAudio;
    MPMediaItemCollection	*_userMediaItemCollection;
    PlayListView *_playListView;
    float screenHeightDevice;
    float audioDurationSeconds;
    NSOperationQueue *queueGetData;
    CGRect rectNavigation;
    MFMailComposeViewController *mailCompose;
    NSMutableArray *arraySaveURLPathVideoCreated;
    BOOL saved,choseAudio;
    __weak IBOutlet UIView *sharingView;
    NSString *strImageLinkFist;
}

@end

@implementation CreateSlideShowVC
@synthesize arrayImages,musicPlayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getScreenHeight];
    [self initData];
    [self initUI];
    [self getImage];
    stringAudioCroped = [[NSBundle mainBundle]pathForResource:@"output11111" ofType:@"m4a"];
}
- (void)getScreenHeight
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenHeightDevice = screenRect.size.height;
    rectNavigation = viewNavigation.frame;
}
- (void)initData
{
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    arraySaveURLPathVideoCreated = [NSMutableArray array];
    queueGetData = [[NSOperationQueue alloc]init];
    queueGetData.name = @"queueGetImagesSQLite";
    _images = [NSMutableArray array];
    choseAudio = false;
}
- (void)initUI
{
    [mainCollectionView registerNib:[UINib nibWithNibName:@"NewCellPhoto" bundle:nil] forCellWithReuseIdentifier:@"NewCellPhoto"];
//    btnBack.imageEdgeInsets = UIEdgeInsetsMake(8, 7, 7, 6);
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgScrollSlideShow.png"]];
}

- (void) getImage{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Loading..." animated:YES];
    [queueGetData addOperationWithBlock:^{
        arrayImages = [NSMutableArray array];
        @autoreleasepool {
            NSMutableArray * arrayPhoto = [[NSMutableArray alloc] init];
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            IMSSqliteManager *sqlManager = [[IMSSqliteManager alloc] init];
            @synchronized(self){
                arrayPhoto = [sqlManager getPhotoItemsSync:[[userDefault objectForKey:@"userTripId"] intValue] andReceipt:0];
            }
            for (int i = 0; i < arrayPhoto.count; i++) {
                PhotoObj *obj = [arrayPhoto objectAtIndex:i];
                NSString *strImageName = [Common getFilePath:obj.urlPhoto];
                NSData *pngData = [NSData dataWithContentsOfFile:strImageName];
                UIImage *image = [UIImage imageWithData:pngData];
                CGSize size = CGSizeMake(208, 208);
                UIImage *img = [Common imageWithImage:image scaledToSize:size];
                
                obj.imageThumbnail = img;
                
                [arrayImages addObject:obj];
            }
        }
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [mainCollectionView reloadData];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }];
    }];
}

- (void) createScrollImageView{
    for (UIView *subView in _scrollImages.subviews) {
        [subView removeFromSuperview];
    }
    float x = 0;
    float y = 5;
    _scrollImages.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height - 40 - 120);
    _scrollImages.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgScrollImages.png"]];
    for (int i = 0; i < arrayImages.count; i++) {
        PhotoObj *objPhoto = [[PhotoObj alloc] init];
        objPhoto = [arrayImages objectAtIndex:i];
        if (i % 3 == 0 ) {
            x = 5;
        }else
            x+= 105;
        y = 105*(i/3)+5;
        AsynImageButton *asynImgBtn = [[AsynImageButton alloc] initWithFrame:CGRectMake(x, y, 100, 100)];
        asynImgBtn.tag = TagImage+i;
        NSString *strImageName = [Common getFilePath:objPhoto.urlPhoto];
        NSData *pngData = [NSData dataWithContentsOfFile:strImageName];
        UIImage *image = [UIImage imageWithData:pngData];
        [asynImgBtn loadIMageFromImage:image];
        [asynImgBtn addTarget:self action:@selector(insertImage:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollImages addSubview:asynImgBtn];
        
        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(x, y+79, 100, 21)];
        lblName.backgroundColor = [UIColor blackColor];
        lblName.textColor = [UIColor whiteColor];
        lblName.text = objPhoto.caption;
        lblName.alpha = 0.6;
        lblName.font = [UIFont boldSystemFontOfSize:12];
        [_scrollImages addSubview:lblName];
        
        UIButton *btnSync = [[UIButton alloc] initWithFrame:CGRectMake(x+80, y+2, 20, 23)];
        [btnSync setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
        btnSync.tag = TagImageClickSync+i;
        [_scrollImages addSubview:btnSync];
        if (objPhoto.isChecked == 0) {
            btnSync.hidden=YES;
        }
        else
            btnSync.hidden=NO;
    }
    [_scrollImages setContentSize:CGSizeMake(300, y+105)];
    _scrollImages.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _viewMenuBar.frame = CGRectMake(0, _scrollImages.frame.origin.y + _scrollImages.frame.size.height, self.view.frame.size.width, 40);
}
- (void) clearSelectPhoto{
    for (UIView *subView in _scrollImages.subviews) {
        if (subView.tag >= TagImageClickSync) {
            subView.hidden = YES;
        }
    }
    for (UIView *subView in _scrollerView.subviews) {
        [subView removeFromSuperview];
    }
    
    for (int i = 0; i < arrayImages.count ; i++) {
        PhotoObj *photo = [arrayImages objectAtIndex:i];
        photo.isChecked = NO;
    }
    [mainCollectionView reloadData];
    PhotoObj *objPhoto = [_images objectAtIndex:0];
    strImageLinkFist = [self convertServerLinkImage:objPhoto.urlPhoto];
    [_images removeAllObjects];
}
- (void) insertImage:(id)sender{
    sharingView.hidden = YES;
    [self.view endEditing:YES];
    UIButton *btn = (UIButton *)sender;
    PhotoObj *photo = [arrayImages objectAtIndex:btn.tag-TagImage];
    if (photo.isChecked == 0) {
        lblInstruction.hidden = YES;
        photo.isChecked=1;
        for (UIView *subView in _scrollImages.subviews) {
            if (subView.tag == TagImageClickSync + (btn.tag-TagImage)) {
                subView.hidden=NO;
                [_images addObject:photo];
                
                break;
            }
        }
    }else
    {
        
        photo.isChecked=0;
        for (UIView *subView in _scrollImages.subviews) {
            if (subView.tag == TagImageClickSync + (btn.tag-TagImage)) {
                for (PhotoObj *ptObject in _images) {
                    if ([ptObject.urlPhoto isEqualToString:photo.urlPhoto]) {
                        [_images removeObject:ptObject];
                        break;
                    }
                }
                subView.hidden=YES;
                break;
            }
        }
        if (![lblInstruction.text isEqualToString:@"Your Slideshow has been created. Tap on download button to store it into your device or select photos and create again"]) {
            lblInstruction.hidden = YES;
        }else{
            if (_images.count == 0) {
                lblInstruction.hidden = NO;
                [self.view bringSubviewToFront:lblInstruction];
            }
        }
    }
    [self calculationDurationOfSlide];
    [self createScrollView];
}
- (void)calculationDurationOfSlide
{
    float timeOfSlide = _images.count *3.0f;
    if (timeOfSlide >60) {
        int minutes = timeOfSlide/60;
        float seconds = fmodf(timeOfSlide, 60.0f);
        NSLog(@"====== :%i ==== seconds :%f",minutes,seconds);
        if (minutes>0) {
            if (seconds <10) {
                _lbDurationSlide.text = [NSString stringWithFormat:@"0%i:0%.0f",minutes,seconds];
            }
            else
            {
                _lbDurationSlide.text = [NSString stringWithFormat:@"0%i:%.0f",minutes,seconds];
            }
        }
        else
        {
            if (seconds <10) {
                _lbDurationSlide.text = [NSString stringWithFormat:@"00:0%.0f",seconds];
            }
            else
            {
                _lbDurationSlide.text = [NSString stringWithFormat:@"00:%.0f",seconds];
            }
        }
    }
    else
    {
        if (timeOfSlide <10) {
            _lbDurationSlide.text = [NSString stringWithFormat:@"00:0%.0f",timeOfSlide];
        }
        else
        {
            _lbDurationSlide.text = [NSString stringWithFormat:@"00:%.0f",timeOfSlide];
        }
    }
}
- (void)createScrollView
{
    for (UIView *subView in _scrollerView.subviews) {
        [subView removeFromSuperview];
    }
    _scrollerView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, _viewMenuBar.frame.origin.y + _viewMenuBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - (_viewMenuBar.frame.origin.y + _viewMenuBar.frame.size.height ))];
    _scrollerView.backgroundColor = [UIColor clearColor];
    _scrollerView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    _scrollerView.showsHorizontalScrollIndicator = NO;
    _scrollerView.showsVerticalScrollIndicator = NO;
    _scrollerView.bounces = NO;
    
    NSLog(@"======= :%f",_scrollerView.frame.size.height);
    
    float x ;
    for(int i=0;i<_images.count;i++)
    {
        x = 10 + (_scrollerView.frame.size.height-15) *i;
        recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addMorePhotos:)];
        recognizer.numberOfTouchesRequired = 1;
        recognizer.numberOfTapsRequired = 1;
        recognizer.delegate = self;
        UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, 10, _scrollerView.frame.size.height - 20, _scrollerView.frame.size.height - 20)];
        [bgImageView setTag:i];
        [bgImageView setUserInteractionEnabled:YES];
        PhotoObj *photo = [_images objectAtIndex:i];
        NSString *strImageName = [Common getFilePath:photo.urlPhoto];
        NSData *pngData = [NSData dataWithContentsOfFile:strImageName];
        UIImage *image = [UIImage imageWithData:pngData];
        bgImageView.image=image;
        [bgImageView addGestureRecognizer:recognizer];
        
        UIImageView *ImageViewDelete = [[UIImageView alloc]initWithFrame:CGRectMake(bgImageView.frame.size.width-15, 0, 15, 15)];
        [ImageViewDelete setTag:i];
        [ImageViewDelete setUserInteractionEnabled:YES];
        [ImageViewDelete addGestureRecognizer:recognizer];
        ImageViewDelete.image = [UIImage imageNamed:@"ic_delete.png"];
        [bgImageView addSubview:ImageViewDelete];
        [_scrollerView addSubview:bgImageView];
    }
    _scrollerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgScrollSlideShow.png"]];
    _scrollerView.contentSize = CGSizeMake(x + (_scrollerView.frame.size.height-15), 80);
    [self.view addSubview:_scrollerView];
}
- (void)moveToLastObject
{
    CGPoint bottomOffset = CGPointMake(0, _images.count-1);
    [_scrollerView setContentOffset:bottomOffset animated:YES];
}
- (IBAction)addMorePhotos:(UITapGestureRecognizer *)sender
{
    NSLog(@"sender tag :%i",sender.view.tag);
    if (sender.view.tag == _images.count) {
        for (PhotoObj *photo in arrayImages) {
            photo.isChecked = 0;
        }
    }
    else
    {
        PhotoObj *photo = [_images objectAtIndex:sender.view.tag];
        [_images removeObjectAtIndex:sender.view.tag];
        for (PhotoObj *objPhoto in arrayImages) {
            if ([photo.urlPhoto isEqualToString:objPhoto.urlPhoto]) {
                objPhoto.isChecked = 0;
                break;
            }
        }
        [self createScrollView];
    }
    [self createScrollImageView];
    [self calculationDurationOfSlide];
    //import srcoll to bot in here.
}

#pragma mark - choose audio to create slide show
- (void)viewDidUnload
{
    [super viewDidUnload];
    [self removeMusicPlayerObserver];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark Music Player

- (void)initializeMusicPlayer {
    self.musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    [self.musicPlayer setShuffleMode:MPMusicShuffleModeOff];
    [self.musicPlayer setRepeatMode:MPMusicRepeatModeNone];
}


#pragma Add observer to Music Player state Notifications

- (void)addMusicPlayerObserver {
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNowPlayingSongStateChanged:)
                                                 name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                               object:self.musicPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePlaybackStateChanged:)
                                                 name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                               object:self.musicPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleVolumeChangedFromOutSideApp:)
                                                 name:MPMusicPlayerControllerVolumeDidChangeNotification
                                               object:self.musicPlayer];
    [self.musicPlayer beginGeneratingPlaybackNotifications];
}


#pragma Remove obsever for Music Player Notifications

- (void)removeMusicPlayerObserver {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                                  object:self.musicPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                                  object:self.musicPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMusicPlayerControllerVolumeDidChangeNotification
                                                  object:self.musicPlayer];
    
    [self.musicPlayer endGeneratingPlaybackNotifications];
}

#pragma Music player Notification selectors

- (void)handleNowPlayingSongStateChanged:(id)notification {
    NSLog(@"handleNowPlayingSongStateChanged");
}


- (void)handlePlaybackStateChanged:(id)notification {
    
    NSLog(@"handlePlaybackStateChanged");
    
    MPMusicPlaybackState playbackState = self.musicPlayer.playbackState;
    
    if (playbackState == MPMusicPlaybackStatePaused || playbackState == MPMusicPlaybackStateStopped) {
        
    }else if (playbackState == MPMusicPlaybackStatePlaying) {
        
    }
}

- (void)handleVolumeChangedFromOutSideApp:(id)notification {
    
    NSLog(@"handleVolumeChangedFromOutSideApp");
}

#pragma Music Player Controls Methods


- (IBAction)playPauseMusic:(id)sender {
    
    MPMusicPlaybackState playbackState = self.musicPlayer.playbackState;
    
	if (playbackState == MPMusicPlaybackStateStopped || playbackState == MPMusicPlaybackStatePaused) {
		[self.musicPlayer play];
	} else if (playbackState == MPMusicPlaybackStatePlaying) {
        [self.musicPlayer pause];
    }
    
    
}
- (IBAction)createSlideShow:(id)sender {
    saved= NO;
//    else if (urlAudio == nil && choseAudio){
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Travel buddy" message:@"Please choose mp3 file of audio" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//        [alert show];
//    }
//    for (PhotoObj *objPhoto in arrayImages) {
//        if (objPhoto.isChecked == 1) {
//            [_images addObject:objPhoto];
//        }
//    }
    if (_images.count==0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Travel buddy" message:@"Please choose your images" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }else if (_images.count <2){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Travel buddy" message:@"Please choose at least 2 images" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }else{
        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Creating..." animated:YES];
        if (urlAudio !=nil) {
            
            if (audioDurationSeconds/3<_images.count) {
                [self mergerAudio];
            }else{
                [self trimAudio:_images.count*3.0f];
            }
        }
        else
        {
            stringAudioCroped = [[NSBundle mainBundle]pathForResource:@"output11111" ofType:@"m4a"];
            urlAudio = [NSURL fileURLWithPath:stringAudioCroped];
            [self trimAudio:1.0f];
        }
    }
}

- (IBAction)selectSong:(id)sender {
    
    if (_images.count==0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Travel Buddy" message:@"Please choose images to create slide show" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
//        if ([[USER_DEFAULT objectForKey:@"showAlertGuide"] isEqualToString:@"0"]) {
//            [delegate showAlert:@"We only support to use downloaded audio file in your library"];
//            [USER_DEFAULT setObject:@"1" forKey:@"showAlertGuide"];
//            [USER_DEFAULT synchronize];
//        }
        
        MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
        mediaPicker.delegate = self;
        mediaPicker.showsCloudItems = NO;
        [self presentModalViewController:mediaPicker animated:YES];
    }
}
#pragma mark MPMediaPickerController delegate methods

- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    MPMediaItem *item = [[mediaItemCollection items] objectAtIndex:0];
    _lbNameAudio.text = [item valueForProperty:MPMediaItemPropertyTitle];
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    urlAudio = url;
    choseAudio = YES;
    AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    CMTime audioDuration = audioAsset.duration;
    audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    [self dismissModalViewControllerAnimated:YES];
    [self updateTheMediaColledtionsItems:mediaItemCollection];
}
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissModalViewControllerAnimated:YES];
}
- (void)updateTheMediaColledtionsItems:(MPMediaItemCollection *)mediaItemCollection {
    
    MPMediaItem * item = (MPMediaItem *)[mediaItemCollection.items objectAtIndex:0];
    NSURL * pathURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
    urlAudio = pathURL;
    NSLog(@"PathURLAAAAAA :%@",urlAudio);
    if (_userMediaItemCollection == nil) {
        _userMediaItemCollection = mediaItemCollection;
        [self.musicPlayer setQueueWithItemCollection: _userMediaItemCollection];
        [self.musicPlayer play];
    } else  {
        BOOL wasPlaying = NO;
        if (self.musicPlayer.playbackState ==
            MPMusicPlaybackStatePlaying) {
            wasPlaying = YES;
        }
        
        MPMediaItem *nowPlayingItem	= self.musicPlayer.nowPlayingItem;
        NSTimeInterval currentPlaybackTime	= self.musicPlayer.currentPlaybackTime;
        NSMutableArray *currentSongsList= [[_userMediaItemCollection items] mutableCopy];
        NSArray *nowSelectedSongsList = [mediaItemCollection items];
        
        [currentSongsList addObjectsFromArray:nowSelectedSongsList];
        
        _userMediaItemCollection = [MPMediaItemCollection collectionWithItems:(NSArray *) currentSongsList];
        
        [self.musicPlayer setQueueWithItemCollection: _userMediaItemCollection];
        
        self.musicPlayer.nowPlayingItem	= nowPlayingItem;
        self.musicPlayer.currentPlaybackTime = currentPlaybackTime;
        [self.musicPlayer pause];
    }
}

#pragma mark - Merge audio
- (BOOL) mergerAudio
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    AVMutableComposition *composition = [[AVMutableComposition alloc] init];
    
    AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionAudioTrack setPreferredVolume:0.8];
    NSString *soundOne  =[[NSBundle mainBundle]pathForResource:@"30secs" ofType:@"mp3"];
    NSLog(@"====== :%@",soundOne);
    NSURL *url = urlAudio;
    AVAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetTrack *clipAudioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, avAsset.duration) ofTrack:clipAudioTrack atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *compositionAudioTrack1 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionAudioTrack setPreferredVolume:0.3];
    NSString *soundOne1  =[[NSBundle mainBundle]pathForResource:@"30secs" ofType:@"mp3"];
    NSURL *url1 = urlAudio;
    AVAsset *avAsset1 = [AVURLAsset URLAssetWithURL:url1 options:nil];
    AVAssetTrack *clipAudioTrack1 = [[avAsset1 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [compositionAudioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, avAsset.duration) ofTrack:clipAudioTrack1 atTime:kCMTimeZero error:nil];
    
    
    AVMutableCompositionTrack *compositionAudioTrack2 = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [compositionAudioTrack2 setPreferredVolume:1.0];
    NSString *soundOne2  =[[NSBundle mainBundle]pathForResource:@"30secs" ofType:@"mp3"];
    NSURL *url2 = urlAudio;
    AVAsset *avAsset2 = [AVURLAsset URLAssetWithURL:url2 options:nil];
    AVAssetTrack *clipAudioTrack2 = [[avAsset2 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [compositionAudioTrack1 insertTimeRange:CMTimeRangeMake(kCMTimeZero, avAsset2.duration) ofTrack:clipAudioTrack2 atTime:kCMTimeZero error:nil];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:composition
                                           presetName:AVAssetExportPresetAppleM4A];
    if (nil == exportSession) return NO;
    
    NSString *soundOneNew = [documentsDirectory stringByAppendingPathComponent:@"combined10.m4a"];
    stringAudioCroped = soundOneNew;
    NSURL *urlSoundNew = [NSURL fileURLWithPath:soundOneNew];
    [[NSFileManager defaultManager] removeItemAtURL:urlSoundNew error:NULL];
    exportSession.outputURL = [NSURL fileURLWithPath:soundOneNew]; // output path
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    NSLog(@"OUT :%@",soundOneNew);
    // perform the export
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusCompleted");
            float timeEnd = _images.count *3.0f;
            [self trimAudio:timeEnd];
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            NSLog(@"AVAssetExportSessionStatusFailed");
        } else {
            NSLog(@"Export Session Status: %d", exportSession.status);
        }
    }];
    return YES;
}

#pragma mark - trim audio
- (void)trimAudio:(float)timeEnd
{
    
    NSURL *audioFileInput = urlAudio;
    // Path of your destination save audio file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *libraryCachesDirectory = [paths objectAtIndex:0];
    
    NSString *strOutputFilePath = [libraryCachesDirectory stringByAppendingPathComponent:@"output.mov"];
    NSString *requiredOutputPath = [libraryCachesDirectory stringByAppendingPathComponent:@"output.m4a"];
    stringAudioCroped = requiredOutputPath;
    
    NSURL *audioFileOutput = [NSURL fileURLWithPath:requiredOutputPath];
    [[NSFileManager defaultManager] removeItemAtURL:audioFileOutput error:NULL];
    
    AVAsset *asset = [AVAsset assetWithURL:audioFileInput];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset
                                                                            presetName:AVAssetExportPresetAppleM4A];
    timeEnd = _images.count * 3.0f;
    
    float startTrimTime = 0.0f;
    float endTrimTime = timeEnd;
    
    CMTime startTime = CMTimeMake((int)(floor(startTrimTime * 100)), 100);
    CMTime stopTime = CMTimeMake((int)(ceil(endTrimTime * 100)), 100);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    exportSession.outputURL = audioFileOutput;
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.timeRange = exportTimeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         if (AVAssetExportSessionStatusCompleted == exportSession.status)
         {
             NSLog(@"Success!");
             NSLog(@" OUtput path is \n %@", requiredOutputPath);
             stringAudioCroped = requiredOutputPath;
             NSFileManager * fm = [[NSFileManager alloc] init];
             [fm moveItemAtPath:strOutputFilePath toPath:requiredOutputPath error:nil];
//             [self createVideo];
             [self uploadVideoToServer:stringAudioCroped];
         }
         
         else if (AVAssetExportSessionStatusFailed == exportSession.status)
         {
             
             NSLog(@"failed %@", exportSession.error.localizedDescription);
         }
     }];
}
-(UIImage*)imageWithImage: (UIImage*) sourceImage scaledToWidth: (float) i_width
{
    float oldWidth = sourceImage.size.width;
    float oldHeight = sourceImage.size.height;
    float scaleFactor = i_width / oldWidth;
    float tyle = sourceImage.size.width/sourceImage.size.height;
    NSLog(@"====Ty le :%f",sourceImage.size.width/sourceImage.size.height);
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)createVideo {

    stringURLVideoSaved = @"";
    NSError *error = nil;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    NSString *videoOutputPath = [documentsDirectory stringByAppendingPathComponent:@"test_output.mp4"];
    
    if ([fileMgr removeItemAtPath:videoOutputPath error:&error] != YES)
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    
    CGSize imageSize = CGSizeMake(480, 400);
    NSUInteger fps = 30;
    
    NSMutableArray *imageArray;
    NSArray* imagePaths = [[NSBundle mainBundle] pathsForResourcesOfType:@"jpg" inDirectory:nil];
    imageArray = [[NSMutableArray alloc] initWithCapacity:imagePaths.count];
    
    for (PhotoObj *slide in _images) {
        
        NSString *strImageName = [Common getFilePath:slide.urlPhoto];
        NSData *pngData = [NSData dataWithContentsOfFile:strImageName];
        UIImage *image = [UIImage imageWithData:pngData];

        CGRect rect = CGRectMake(0,0,480,400);
        UIGraphicsBeginImageContext( rect.size );
        [image drawInRect:rect];
        UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *imageData = UIImagePNGRepresentation(picture1);
        UIImage *img=[UIImage imageWithData:imageData];
        [imageArray addObject:img];
    }
    
    //////////////     end setup    ///////////////////////////////////
    
    NSLog(@"Start building video from defined frames.");
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:videoOutputPath] fileType:AVFileTypeQuickTimeMovie
                                                              error:&error];
    NSParameterAssert(videoWriter);
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:imageSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:imageSize.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [videoWriter addInput:videoWriterInput];
    
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    
    //convert uiimage to CGImage.
    int frameCount = 0;
    double numberOfSecondsPerFrame = 3;
    double frameDuration = fps * numberOfSecondsPerFrame;
    
    //for(VideoFrame * frm in imageArray)
    NSLog(@"**************************************************");
    for(UIImage * img in imageArray)
    {
        //UIImage * img = frm._imageFrame;
        buffer = [self pixelBufferFromCGImage:[img CGImage]];
        
        BOOL append_ok = NO;
        int j = 0;
        while (!append_ok && j < 30) {
            if (adaptor.assetWriterInput.readyForMoreMediaData)  {
                //print out status:
                NSLog(@"Processing video frame (%d,%d)",frameCount,[imageArray count]);
                
                CMTime frameTime = CMTimeMake(frameCount*frameDuration,(int32_t) fps);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                if(!append_ok){
                    NSError *error = videoWriter.error;
                    if(error!=nil) {
                        NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
                    }
                }
            }
            else {
                printf("adaptor not ready %d, %d\n", frameCount, j);
                [NSThread sleepForTimeInterval:0.1];
            }
            j++;
        }
        if (!append_ok) {
            printf("error appending image %d times %d\n, with error.", frameCount, j);
        }
        frameCount++;
    }
    NSLog(@"**************************************************");
    
    //Finish the session:
    [videoWriterInput markAsFinished];
    [videoWriter finishWriting];
    NSLog(@"Write Ended");
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    if (stringAudioCroped.length <10) {
        stringAudioCroped  =[[NSBundle mainBundle]pathForResource:@"output11111" ofType:@"m4a"];
        NSLog(@"STRING AUDIO :%@",stringAudioCroped);
    }
    printf("mixComposition ending %d times \n, ", 1);
    
    NSURL    *audio_inputFileUrl = [NSURL fileURLWithPath:stringAudioCroped];
    NSURL    *video_inputFileUrl = [NSURL fileURLWithPath:videoOutputPath];
    
    NSString *tripId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userTripId"];
    NSString *timeStamp = [self timeStamp];
    NSString *fileNameVideoSave=[NSString stringWithFormat:@"video_%@_%@.mp4",tripId,timeStamp];
    NSString *outputFilePath = [FileHelper videoPathForName:fileNameVideoSave];
    
    NSURL    *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    
    stringURLVideoSaved = outputFilePath;
    
    CMTime nextClipStartTime = kCMTimeZero;
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:nextClipStartTime error:nil];
    
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    //_assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputFileType = @"public.mpeg-4";
    //NSLog(@"support file types= %@", [_assetExport supportedFileTypes]);
    _assetExport.outputURL = outputFileUrl;
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         
         if (saved == YES) {
             
         }else{
             ObjectSavePathSlide *saveObj = [[ObjectSavePathSlide alloc]init];
             [saveObj getData:outputFilePath saved:0];
             [arraySaveURLPathVideoCreated addObject:saveObj];
         }
//         [self exportDidFinish:_assetExport];
         saved = NO;
     }
     ];
    stringURLVideoSaved = outputFilePath;
    NSLog(@"DONE.....outputFilePath--->%@", outputFilePath);
    [self uploadVideoToServer:stringAudioCroped];
}

- (void)uploadVideoToServer:(NSString*)strURLAudioSaved
{
    [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Uploading" animated:YES];
//    NSString *result =@"";
    NSOperationQueue *queueUpLoad = [[NSOperationQueue alloc]init];
    queueUpLoad.name = @"queueUpLoad";
    [queueUpLoad addOperationWithBlock:^{
        
        int userID = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
        int userTripID = [[NSUserDefaults standardUserDefaults]integerForKey:@"userTripId"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        [request setHTTPShouldHandleCookies:NO];
        [request setTimeoutInterval:30];
        [request setHTTPMethod:@"POST"];
        //flag(=1), client_ver, ownerid, photourl, isreceipt(=0,=1), caption, clientid
        NSMutableDictionary* _params = [[NSMutableDictionary alloc] init];
        [_params setObject:[NSNumber numberWithInt:userID] forKey:@"user_id"];
        [_params setObject:[NSNumber numberWithInt:userTripID] forKey:@"trip_id"];
        
        NSString *strPhotoId = @"";
        for (int i = 0; i < _images.count; i++) {
            PhotoObj *photo = [_images objectAtIndex:i];
            strPhotoId = [NSString stringWithFormat:@"%@%d,",strPhotoId,photo.serverId];
        }
        [_params setObject:strPhotoId forKey:@"image_ids"];
        //- Commit ảnh và update data, có input: flag(=1), client_ver, ownerid, photourl, isreceipt(=0,=1), caption, clientid
        NSString *BoundaryConstant = @"V2ymHFg03ehbqgZCaKO6jy";
        
        // string constant for the post parameter 'file'
        NSString *FileParamConstant = @"audio";
        //Setup request URL
        NSURL *requestURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/create_slideshow.php",SERVER_LINK]];
        
        // set Content-Type in HTTP header
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BoundaryConstant];
        [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        // post body
        NSMutableData *body = [NSMutableData data];
        
        // add params (all params are strings)
        for (NSString *param in _params) {
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        // add image data
        NSData *audioData = [NSData dataWithContentsOfFile:strURLAudioSaved];
        if (audioData) {
            printf("appending image data\n");
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\'%@\'; filename=\".mp3\"\r\n", FileParamConstant] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:audioData];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        
        // setting the body of the post to the reqeust
        [request setHTTPBody:body];
        
        // set the content-length
        NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        // set URL
        [request setURL:requestURL];
        
        NSURLResponse *response = nil;
        NSError *error=nil;
        NSData *data=[[NSData alloc] initWithData:[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error]];
        
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            NSLog(@"Upload Video : %@",dict);
            NSString* message = [dict objectForKey:@"result"];
            NSLog(@"=== message : %@",message);
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            if ([message isEqualToString:@"success"]) {
                NSString *pathVideo = [dict objectForKey:@"path"];
                strURLVideoServer = [NSString stringWithFormat:@"%@%@",SERVER_LINK,pathVideo];
//                NSURL *url = [NSURL URLWithString:strURLVideoServer];
//                moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
//                [moviePlayer play];
//
//                lblInstruction.text = @"Your Slideshow has been created. Tap on download button to store it into your device or select photos and create again";
                lblInstruction.hidden = NO;
                [self.view bringSubviewToFront:lblInstruction];
                [self clearSelectPhoto];
                _lbDurationSlide.text = @"00:00";
                _lbNameAudio.text = @"No audio";
                stringAudioCroped = [[NSBundle mainBundle]pathForResource:@"output11111" ofType:@"m4a"];
                [self PlaySlideshowVideo];
//                [self saveVideoToLocal];
                
//                NSURL *url = [NSURL URLWithString:strURLVideoServer];
//                [self playVedio:url];
                
            }else {
                [delegate showAlert:@"Upload failed"];
            }
        }];
    }];
}

-(void) saveVideoToLocal{
    NSURL *url = [NSURL URLWithString:strURLVideoServer];
    NSUInteger location = [strURLVideoServer rangeOfString:@"slideshow_"].location;
    NSString *strLocalLink = [strURLVideoServer substringFromIndex:location];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
//    NSString *tripId = [[NSUserDefaults standardUserDefaults]objectForKey:@"userTripId"];
//    NSString *timeStamp = [self timeStamp];
    NSString *fileNameVideoSave=[NSString stringWithFormat:@"%@",strLocalLink];
    NSString *outputFilePath = [FileHelper videoPathForName:fileNameVideoSave];
    strLinkLocalDB = outputFilePath;
    
    [request setDownloadDestinationPath:outputFilePath];
    [request setDelegate:self];
    [request startAsynchronous];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
-(void)requestFinished:(ASIHTTPRequest *)request

{
    
    [[[UIAlertView alloc] initWithTitle:nil
                                 message:@"Download slideshow successful"
                                delegate:self
                       cancelButtonTitle:@"OK"
                       otherButtonTitles:nil] show];
    
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    
    NSLog(@"%@",request.error);
    
}
- (NSString *) timeStamp {
    return [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
}

#pragma mark - Save video to library
- (void)exportDidFinish:(AVAssetExportSession*)session
{
    if(session.status == AVAssetExportSessionStatusCompleted){
        NSURL *outputURL = session.outputURL;
        NSLog(@"URL :%@",outputURL);
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL
                                        completionBlock:^(NSURL *assetURL, NSError *error){
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if (error) {
                                                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
                                                    [alert show];
                                                    
                                                }else{
                                                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                                    [self playVedio:outputURL];
                                                }
                                            });
                                        }];
        }
    }
}

- (void)writeDataToFile:(NSMutableString *)stringInPut
{
    NSMutableString *printString = [NSMutableString stringWithString:@""];
    
    //CREATE FILE
    
    NSError *error;
    
    // Create file manager
    //NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSString *documentsDirectory = [NSHomeDirectory()
                                    stringByAppendingPathComponent:@"Documents"];
    
    NSString *filePath = [documentsDirectory
                          stringByAppendingPathComponent:@"fileArray.txt"];
    
    NSLog(@"string to write:%@",printString);
    // Write to the file
    [printString writeToFile:filePath atomically:YES
                    encoding:NSUTF8StringEncoding error:&error];
}

- (void)PlaySlideshowVideo{
    PreviewSlideshow *createVC = [[PreviewSlideshow alloc]initWithNibName:@"PreviewSlideshow" bundle:nil];
    createVC.strVideoLink = strURLVideoServer;
    createVC.strImageLink = strImageLinkFist;
    [self.navigationController pushViewController:createVC animated:YES];
}

-(void)playVedio:(NSURL*)moviePath{
    mp = [[MPMoviePlayerViewController alloc] initWithContentURL:moviePath];
    
    [[mp moviePlayer] prepareToPlay];
    [[mp moviePlayer] setUseApplicationAudioSession:NO];
    [[mp moviePlayer] setShouldAutoplay:YES];
    [[mp moviePlayer] setControlStyle:2];
    [[mp moviePlayer] setRepeatMode:MPMovieRepeatModeOne];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [self presentMoviePlayerViewControllerAnimated:mp];
    
}

-(void)videoPlayBackDidFinish:(NSNotification*)notification  {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [mp.moviePlayer stop];
    mp = nil;
    
        for (ObjectSavePathSlide *obj in arraySaveURLPathVideoCreated) {
            NSURL *url = [NSURL fileURLWithPath:obj.pathVideo];
            [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
        }
    
    [self dismissMoviePlayerViewControllerAnimated];
    viewNavigation.frame = rectNavigation;
}

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image size:(CGSize)size {
    
    //CGSize size = CGSizeMake(320,480);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          size.width,
                                          size.height,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status != kCVReturnSuccess){
        NSLog(@"Failed to create pixel buffer");
    }
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 kCGImageAlphaPremultipliedFirst);
    //kCGImageAlphaNoneSkipFirst);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

////////////////////////
- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image {
    CGSize size = CGSizeMake(480,400);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          size.width,
                                          size.height,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status != kCVReturnSuccess){
        NSLog(@"Failed to create pixel buffer");
    }
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 kCGImageAlphaPremultipliedFirst);
    //kCGImageAlphaNoneSkipFirst);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)backToSlideShowVC:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveThisSlideShow:(id)sender {
    saved  = YES;
//    if (_images.count==0) {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Travel buddy" message:@"Please choose your images" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//        [alert show];
//    }
//    else{
        Reachability *reach = [Reachability reachabilityForInternetConnection];
        NetworkStatus netStatus = [reach currentReachabilityStatus];
        
        if (netStatus == NotReachable) {
            [delegate showAlert:@"Cannot connect to server. Please check your internet connection"];
        }else{
            [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"Downloading..." animated:YES];
            [self saveVideoToLocal];
        }
        
//        [MBProgressHUD showHUDAddedTo:self.view WithTitle:@"creating..." animated:YES];
//        
//        
//        if (urlAudio !=nil) {
//            if (audioDurationSeconds/3<_images.count) {
//                [self mergerAudio];
//            }else{
//                [self trimAudio:_images.count*3.0f];
//            }
//        }
//        else
//        {
//            stringAudioCroped = [[NSBundle mainBundle]pathForResource:@"output11111" ofType:@"m4a"];
//            urlAudio = [NSURL fileURLWithPath:stringAudioCroped];
//            [self trimAudio:_images.count*3.0f];
//            
//        }
//    }
   
}
- (void)createLinkUrlVideo
{
    for (ObjectSavePathSlide *saveObj in arraySaveURLPathVideoCreated) {
        if (![saveObj.pathVideo isEqualToString:stringURLVideoSaved]) {
            NSURL *url = [NSURL fileURLWithPath:saveObj.pathVideo];
            [[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
        }
    }
    arraySaveURLPathVideoCreated = [NSMutableArray array];
    
}
- (IBAction)sendMailThisSlideShow:(id)sender {
    if ([strURLVideoServer isEqualToString:@""] || strURLVideoServer == nil) {
        return;
    }
    sharingView.hidden = NO;
}

- (void)sendEmail {
    NSString *emailTitle = @"slideshow";
    NSString *tripName = [USER_DEFAULT objectForKey:@"userTripName"];
    
//    TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
//    label.font = [UIFont systemFontOfSize:14];
//    label.textColor = [UIColor darkGrayColor];
//    label.lineBreakMode = UILineBreakModeWordWrap;
//    label.text = strURLVideoServer;
    NSMutableString *body = [NSMutableString string];
    NSString *messageBody = [NSString stringWithFormat:@"I created a video for my %@ trip. Watch it here %@",tripName,strURLVideoServer];
//    NSString *messageBody = [NSString stringWithFormat:@"I created an video from %@'s photo. Watch and download it at ",tripName];
    [body appendString:messageBody];
//    [body appendString:[NSString stringWithFormat:@"<a href=\"%@\">%@</a>\n",strURLVideoServer,strURLVideoServer]];
    
//    NSString *bodyText =@"<html>";
//    bodyText = [bodyText stringByAppendingString:@"<head>"];
//    bodyText = [bodyText stringByAppendingString:@"</head>"];
//    bodyText = [bodyText stringByAppendingString:@"<body>"];
//    bodyText = [bodyText stringByAppendingString:messageBody];
//    bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"<a href=\"%@\">%@</a>\n",strURLVideoServer,strURLVideoServer]];
//    bodyText = [bodyText stringByAppendingString:@"</a>"];
//    bodyText = [bodyText stringByAppendingString:@"</body>"];
//    bodyText = [bodyText stringByAppendingString:@"</html>"];
    
//    label.enabledTextCheckingTypes = NSTextCheckingTypeLink; // Automatically detect links when the label text is subsequently changed
//    label.delegate = self; // Delegate methods are called when the user taps on a link (see `TTTAttributedLabelDelegate` protocol)
//    
//    label.text = @"Fork me on GitHub! (http://github.com/mattt/TTTAttributedLabel/)"; // Repository URL will be automatically detected and linked
//    
//    NSRange range = [label.text rangeOfString:@"me"];
//    [label addLinkToURL:[NSURL URLWithString:@"http://github.com/mattt/"] withRange:range];
    
    NSArray *toRecipents = [NSArray arrayWithObject:@" "];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:body isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Determine the file name and extension
    //NSArray *filepart = [file componentsSeparatedByString:@"."];
    NSString *filename = [[stringURLVideoSaved componentsSeparatedByString:@"/"]lastObject];
    NSString *extension = @"mp4";
    
    // Get the resource path and read the file using NSData
    NSData *fileData = [NSData dataWithContentsOfFile:stringURLVideoSaved];
    
    // Determine the MIME type
    NSString *mimeType;
    if ([extension isEqualToString:@"jpg"]) {
        mimeType = @"image/jpeg";
    } else if ([extension isEqualToString:@"png"]) {
        mimeType = @"image/png";
    } else if ([extension isEqualToString:@"doc"]) {
        mimeType = @"application/msword";
    } else if ([extension isEqualToString:@"ppt"]) {
        mimeType = @"application/vnd.ms-powerpoint";
    } else if ([extension isEqualToString:@"html"]) {
        mimeType = @"text/html";
    } else if ([extension isEqualToString:@"pdf"]) {
        mimeType = @"application/pdf";
    }else if ([extension isEqualToString:@"mp4"]) {
        mimeType = @"application/movie";
    }
    
    // Add attachment
//    [mc addAttachmentData:fileData mimeType:mimeType fileName:filename];
    
    // Present mail view controller on screen
//    [self presentViewController:mc animated:YES completion:nil];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self presentViewController:mc animated:YES completion:^{}];
    }];
}
#pragma mark mail delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            [delegate showAlert:@"Canceled"];
            NSLog(@"Result: canceled");
            [self dismissModalViewControllerAnimated:YES];
            break;
        case MFMailComposeResultSaved:
            [delegate showAlert:@"Saved"];
            NSLog(@"Result: saved");
            [self dismissModalViewControllerAnimated:YES];
            break;
        case MFMailComposeResultSent:
            [delegate showAlert:@"Sent"];
            NSLog(@"Result: sent");
            [self dismissModalViewControllerAnimated:YES];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case MFMailComposeResultFailed:
            [delegate showAlert:@"Failed"];
            NSLog(@"Result: failed");
            [self dismissModalViewControllerAnimated:YES];
            [delegate showAlert:@"Canceled"];
            break;
        default:
            NSLog(@"Result: not sent");
            [delegate showAlert:@"Not sent"];
            [self dismissModalViewControllerAnimated:YES];
            break;
    }
}

- (IBAction)btnSendEmailClick:(id)sender {
    if (strURLVideoServer.length<5) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Travel Buddy" message:@"Please create slide show before you send it" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    else{
        sharingView.hidden = YES;
        [self sendEmail];
    }
}
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}
- (IBAction)btnShareLinkFacebookClick:(id)sender {
    sharingView.hidden = YES;
    // Check if the Facebook app is installed and we can present the share dialog
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
    
    
    
    NSString *tripName = [USER_DEFAULT objectForKey:@"userTripName"];
    //Adding the Text to the facebook post value from iOS
    NSString *strTitle = [NSString stringWithFormat:@"Slide Show - %@",tripName];
    
    NSString *strDes = [NSString stringWithFormat:@"I created a slideshow of my %@ Trip. Watch it now!",tripName];
//    PhotoObj *objPhoto = [_images objectAtIndex:0];
//    NSString *strServerLinkImage = [self convertServerLinkImage:objPhoto.urlPhoto];
    // Put together the dialog parameters
    NSMutableDictionary *parameter = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   strTitle, @"name",
                                   @"Created with the Travel Buddy app", @"caption",
                                   strDes, @"description",
                                   strURLVideoServer, @"link",
                                   strImageLinkFist, @"picture",
                                   nil];
    
    // Show the feed dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:parameter
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  if (error) {
                                                      // An error occurred, we need to handle the error
                                                      // See: https://developers.facebook.com/docs/ios/errors
                                                      NSLog(@"Error publishing story: %@", error.description);
                                                  } else {
                                                      if (result == FBWebDialogResultDialogNotCompleted) {
                                                          // User canceled.
                                                          NSLog(@"User cancelled.");
                                                      } else {
                                                          // Handle the publish feed callback
                                                          NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                          
                                                          if (![urlParams valueForKey:@"post_id"]) {
                                                              // User canceled.
                                                              NSLog(@"User cancelled.");
                                                              
                                                          } else {
                                                              // User clicked the Share button
                                                              NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                              NSLog(@"result %@", result);
                                                          }
                                                      }
                                                  }
                                              }];
    
    // If the Facebook app is installed and we can present the share dialog
//    if ([FBDialogs canPresentShareDialogWithParams:params]) {
//
//        // Present share dialog
//        [FBDialogs presentShareDialogWithLink:params.link
//                                      handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//                                          if(error) {
//                                              // An error occurred, we need to handle the error
//                                              // See: https://developers.facebook.com/docs/ios/errors
//                                              NSLog(@"Error publishing story: %@", error.description);
//                                          } else {
//                                              // Success
//                                              NSLog(@"result %@", results);
//                                          }
//                                      }];
//        
//        // If the Facebook app is NOT installed and we can't present the share dialog
//    } else {
//        NSString *tripName = [USER_DEFAULT objectForKey:@"userTripName"];
//        //Adding the Text to the facebook post value from iOS
//        NSString *strTitle = [NSString stringWithFormat:@"Slide Show - %@",tripName];
//        
//        NSString *strDes = [NSString stringWithFormat:@"I created an video from photo which i have in %@. Watch it now!",tripName];
//        PhotoObj *objPhoto = [_images objectAtIndex:0];
//        NSString *strServerLinkImage = [self convertServerLinkImage:objPhoto.urlPhoto];
//        // Put together the dialog parameters
//        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                       strTitle, @"name",
//                                       @"Travel Buddy", @"caption",
//                                       strDes, @"description",
//                                       strURLVideoServer, @"link",
//                                       strServerLinkImage, @"picture",
//                                       nil];
//        
//        // Show the feed dialog
//        [FBWebDialogs presentFeedDialogModallyWithSession:nil
//                                               parameters:params
//                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
//                                                      if (error) {
//                                                          // An error occurred, we need to handle the error
//                                                          // See: https://developers.facebook.com/docs/ios/errors
//                                                          NSLog(@"Error publishing story: %@", error.description);
//                                                      } else {
//                                                          if (result == FBWebDialogResultDialogNotCompleted) {
//                                                              // User canceled.
//                                                              NSLog(@"User cancelled.");
//                                                          } else {
//                                                              // Handle the publish feed callback
//                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
//                                                              
//                                                              if (![urlParams valueForKey:@"post_id"]) {
//                                                                  // User canceled.
//                                                                  NSLog(@"User cancelled.");
//                                                                  
//                                                              } else {
//                                                                  // User clicked the Share button
//                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
//                                                                  NSLog(@"result %@", result);
//                                                              }
//                                                          }
//                                                      }
//                                                  }];
//    }
}
#pragma mark UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrayImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"NewCellPhoto";
    NewCellPhoto *cell = (NewCellPhoto *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle]loadNibNamed:@"NewCellPhoto" owner:self options:nil];
        cell = [array objectAtIndex:0];
    }
    cell.backgroundColor = [UIColor clearColor];
    
    PhotoObj *objPhoto = [[PhotoObj alloc] init];
    objPhoto = [arrayImages objectAtIndex:indexPath.row];
    
    cell.myImage.image = objPhoto.imageThumbnail;
    cell.myLblCaption.text = objPhoto.caption;
    cell.myBtnUpLoad.hidden = YES;
    cell.myActivity.hidden = YES;
    [cell.myBtnUpLoad setBackgroundImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
    if (objPhoto.isChecked == 1) {
        cell.myBtnUpLoad.hidden = NO;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(104, 104);
    return size;
}

- (NSString*)convertServerLinkImage:(NSString*)LocalLinkImage{
    NSString *strServerLink = @"";
    NSString *strTripId =[NSString stringWithFormat:@"%d",[[USER_DEFAULT objectForKey:@"userTripId"] intValue]];
    strServerLink = [LocalLinkImage substringFromIndex:7+strTripId.length];
    strServerLink = [NSString stringWithFormat:@"%@/images/%@/%@",SERVER_LINK,strTripId,strServerLink];
    return strServerLink;
}
- (IBAction)btnCancelViewSharingClick:(id)sender {
    sharingView.hidden = YES;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NewCellPhoto *cell = (NewCellPhoto *)[mainCollectionView cellForItemAtIndexPath:indexPath];
    
    PhotoObj *photo = [arrayImages objectAtIndex:indexPath.row];
    if (photo.isChecked == 0) {
        lblInstruction.hidden = YES;
        photo.isChecked=1;
        cell.myBtnUpLoad.hidden = NO;
        [_images addObject:photo];
    }else
    {
        photo.isChecked=0;
        [_images removeObject:photo];
        cell.myBtnUpLoad.hidden = YES;
        
        if (_images.count == 0) {
            lblInstruction.hidden = NO;
            [self.view bringSubviewToFront:lblInstruction];
        }
//        if (![lblInstruction.text isEqualToString:@"Your Slideshow has been created. Tap on download button to store it into your device or select photos and create again"]) {
//            lblInstruction.hidden = YES;
//        }else{
//            if (_images.count == 0) {
//                lblInstruction.hidden = NO;
//                [self.view bringSubviewToFront:lblInstruction];
//            }
//        }
    }
    [self calculationDurationOfSlide];
    [self createScrollView];
    [mainCollectionView reloadData];
}


@end
