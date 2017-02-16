//
//  PlayViewController.m
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/14/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import "PlayViewController.h"
#import "Constants.h"
#import "Utilities.h"
#import "AVPlayerVC.h"
#import "AppDelegate.h"

@import GoogleInteractiveMediaAds;

@interface PlayViewController ()<IMAAdsLoaderDelegate, IMAAdsManagerDelegate, AFNetworkingWrapperDelegate, AVPlayerViewControllerDelegate>{
    
    AFNetworkingWrapper *requestWrapper;
    NSString *videoURLLow;
    NSString *videoURLHigh;
    NSString *adURL;
    BOOL isVideoChannel;
    BOOL isConnectionAvailable;
    UIView *playbackControlsView;
//    BOOL isPlaybackShowing;
//    BOOL isVast;
}

/// Content video player.
//@property(nonatomic, strong) AVPlayerViewController *playerVC;
@property(nonatomic, strong) AVPlayerVC *playerVC;

@property(nonatomic, strong) AVPlayerViewController *adPlayerVC;

/// Play button.
@property(nonatomic, weak) IBOutlet UIButton *playButton;

// SDK
/// Entry point for the SDK. Used to make ad requests.
@property(nonatomic, strong) IMAAdsLoader *adsLoader;

/// Playhead used by the SDK to track content video progress and insert mid-rolls.
@property(nonatomic, strong) IMAAVPlayerContentPlayhead *contentPlayhead;

/// Main point of interaction with the SDK. Created by the SDK as the result of an ad request.
@property(nonatomic, strong) IMAAdsManager *adsManager;


@end

@implementation PlayViewController

static int const kTag = 1211;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // jugar for landscape orientation
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    isVideoChannel = NO;
    isConnectionAvailable = YES;
    
//    isPlaybackShowing = NO;
//    isVast = NO;
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(AFNetworkReachabilityStatusNotReachable == status){
            isConnectionAvailable = NO;
            // jugar: once the internet is disconnected showAlert will trigger after 20seconds
            [self performSelector:@selector(showInternetAlert) withObject:nil afterDelay:20.0];
        }
        else{
            // if internet gets connected showAlert call will be cancelled
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showInternetAlert) object:nil];
            // jugar: pause play will resume playing after internet disconnection
            [[self.playerVC player] pause];
            [[self.playerVC player] play];
            isConnectionAvailable = YES;
        }
    }];
}

- (BOOL)canAutoRotate
{
    return YES;
}


- (void)viewWillAppear:(BOOL)animated{
//    // jugar for landscape orientation
//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
//    // rotate to landscape
//    restrictRotation(NO);
    
//    NSString *requestUrl;
//    if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
//    {
//        sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_playScreen, self.channel.videoName]);
//        requestUrl = [NSString stringWithFormat:g_getVODOrChannelURLWithAd, [self.channel.isVideoChannel stringValue], self.channel.videoPackageId, self.channel.videoEntityId];
//        isVideoChannel = YES;
//    }
//    else if([self.mediaType isEqualToString:k_Movies])
//    {
//        sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_playScreen, self.movie.videoName]);
//        requestUrl = [NSString stringWithFormat:g_getVODOrChannelURLWithAd, [self.movie.isVideoChannel stringValue], self.movie.videoPackageId, self.movie.videoEntityId];
//        isVideoChannel = NO;
//    }
//    else if([self.mediaType isEqualToString:k_VOD])
//    {
//        sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_playScreen, self.vod.videoName]);
//        requestUrl = [NSString stringWithFormat:g_getVODOrChannelURLWithAd, [self.vod.isVideoChannel stringValue], self.vod.videoPackageId, self.vod.videoEntityId];
//        if([self.vod.isVideoChannel boolValue])
//            isVideoChannel = YES;
//        else
//            isVideoChannel = NO;
//    }
//    else if([self.mediaType isEqualToString:k_Home])
//    {
//        sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_playScreen, self.video.videoName]);
//        requestUrl = [NSString stringWithFormat:g_getVODOrChannelURLWithAd, [self.video.isVideoChannel stringValue], self.video.videoPackageId, self.video.videoEntityId];
//        if([self.video.isVideoChannel boolValue])
//            isVideoChannel = YES;
//        else
//            isVideoChannel = NO;
//    }
//    
//    requestWrapper = [[AFNetworkingWrapper alloc] initWithURL:requestUrl andPostParams:nil];
//    requestWrapper.delegate = self;
//    [requestWrapper startAsynchronousGet];
}

- (void)viewDidAppear:(BOOL)animated{
    
    NSString *requestUrl;
    if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
    {
        sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_playScreen, self.channel.videoName]);
        requestUrl = [NSString stringWithFormat:g_getVODOrChannelURLWithAd, [self.channel.isVideoChannel stringValue], self.channel.videoPackageId, self.channel.videoEntityId];
        isVideoChannel = YES;
    }
    else if([self.mediaType isEqualToString:k_Movies])
    {
        sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_playScreen, self.movie.videoName]);
        requestUrl = [NSString stringWithFormat:g_getVODOrChannelURLWithAd, [self.movie.isVideoChannel stringValue], self.movie.videoPackageId, self.movie.videoEntityId];
        isVideoChannel = NO;
    }
    else if([self.mediaType isEqualToString:k_VOD])
    {
        sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_playScreen, self.vod.videoName]);
        requestUrl = [NSString stringWithFormat:g_getVODOrChannelURLWithAd, [self.vod.isVideoChannel stringValue], self.vod.videoPackageId, self.vod.videoEntityId];
        if([self.vod.isVideoChannel boolValue])
            isVideoChannel = YES;
        else
            isVideoChannel = NO;
    }
    else if([self.mediaType isEqualToString:k_Home])
    {
        sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_playScreen, self.video.videoName]);
        requestUrl = [NSString stringWithFormat:g_getVODOrChannelURLWithAd, [self.video.isVideoChannel stringValue], self.video.videoPackageId, self.video.videoEntityId];
        if([self.video.isVideoChannel boolValue])
            isVideoChannel = YES;
        else
            isVideoChannel = NO;
    }
    
    requestWrapper = [[AFNetworkingWrapper alloc] initWithURL:requestUrl andPostParams:nil tag:kTag];
    requestWrapper.delegate = self;
    [requestWrapper startAsynchronousGet];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [self.playerVC.player pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Content Player Setup

- (void)setUpContentPlayer {
    
    NSURL *highStreamURL;
    NSURL *lowStreamURL;
    if(isVideoChannel) // if its not a video channel then don't append the User-Token at the end
    {
        highStreamURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",videoURLHigh, getUserToken()]];
        lowStreamURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",videoURLLow, getUserToken()]];
    }
    else
    {
        highStreamURL = [NSURL URLWithString:videoURLHigh];
        lowStreamURL = [NSURL URLWithString:videoURLLow];
    }
    
    self.playerVC = [[AVPlayerVC alloc] init];
    self.playerVC.urlHigh = highStreamURL;
    self.playerVC.urlLow = lowStreamURL;
    self.playerVC.player = [AVPlayer playerWithURL:lowStreamURL];
    
    // this will fill the whole screen with video
//    self.playerVC.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self addChildViewController:self.playerVC];
    [self.view addSubview:self.playerVC.view];
    self.playerVC.view.frame = self.view.frame;
    [self.playerVC.player play];
    [self.playerVC addPlaybackControls:self.view.frame];
    
    // Set up our content playhead and contentComplete callback.
    self.contentPlayhead = [[IMAAVPlayerContentPlayhead alloc] initWithAVPlayer:[self.playerVC player]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.playerVC player].currentItem];
}


#pragma mark SDK Setup

- (void)setupAdsLoader {
    self.adsLoader = [[IMAAdsLoader alloc] initWithSettings:nil];
    self.adsLoader.delegate = self;
}

- (void)requestAds {
    
    // Create an ad display container for ad rendering.
    IMAAdDisplayContainer *adDisplayContainer =
    [[IMAAdDisplayContainer alloc] initWithAdContainer:self.playerVC.view companionSlots:nil];
    
    // Create an ad request with our ad tag, display container, and optional user context.
    IMAAdsRequest *request = [[IMAAdsRequest alloc] initWithAdTagUrl:adURL
                                                  adDisplayContainer:adDisplayContainer
                                                     contentPlayhead:self.contentPlayhead
                                                         userContext:nil];
    [self.adsLoader requestAdsWithRequest:request];
}

- (void)contentDidFinishPlaying:(NSNotification *)notification {
    // Make sure we don't call contentComplete as a result of an ad completing.
    if (notification.object == [self.playerVC player].currentItem) {
        [self.adsLoader contentComplete];
    }
}

#pragma mark AdsLoader Delegates

- (void)adsLoader:(IMAAdsLoader *)loader adsLoadedWithData:(IMAAdsLoadedData *)adsLoadedData {
    // Grab the instance of the IMAAdsManager and set ourselves as the delegate.
    self.adsManager = adsLoadedData.adsManager;
    self.adsManager.delegate = self;
    // Create ads rendering settings to tell the SDK to use the in-app browser.
    IMAAdsRenderingSettings *adsRenderingSettings = [[IMAAdsRenderingSettings alloc] init];
    adsRenderingSettings.webOpenerPresentingController = self;
    // Initialize the ads manager.
    [self.adsManager initializeWithAdsRenderingSettings:adsRenderingSettings];
}

- (void)adsLoader:(IMAAdsLoader *)loader failedWithErrorData:(IMAAdLoadingErrorData *)adErrorData {
    // Something went wrong loading ads. Log the error and play the content.
    NSLog(@"IMAAdsLoader Error loading ads: %@", adErrorData.adError.message);
    [[self.playerVC player] play];
}

#pragma mark AdsManager Delegates

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdEvent:(IMAAdEvent *)event {
    // When the SDK notified us that ads have been loaded, play them.
    if (event.type == kIMAAdEvent_LOADED) {
        [adsManager start];
    }
}

- (void)adsManager:(IMAAdsManager *)adsManager didReceiveAdError:(IMAAdError *)error {
    // Something went wrong with the ads manager after ads were loaded. Log the error and play the
    // content.
    NSLog(@" IMAAdsLoader AdsManager error: %@", error.message);
    [[self.playerVC player] play];
}

- (void)adsManagerDidRequestContentPause:(IMAAdsManager *)adsManager {
    // The SDK is going to play ads, so pause the content.
    [[self.playerVC player] pause];
}

- (void)adsManagerDidRequestContentResume:(IMAAdsManager *)adsManager {
    // The SDK is done playing ads (at least for now), so resume the content.
    [[self.playerVC player] play];
}

#pragma mark AFNetworkingWrapperDelegate Methods

//- (void)requestFinished:(id)response
- (void)requestFinished:(id)response tag:(int) callTag
{
    if([[[response objectForKey:@"Response"] objectForKey:@"responseCode"] integerValue] == k_response_ok){
        
        // encode both Low/High Stream URLs
        NSString *strLow = (NSString*)[[response objectForKey:@"Video"] objectForKey:@"VideoStreamUrlLow"];
        if(strLow != (NSString *)[NSNull null])
        {
            if([strLow length]>0)
            {
                if([strLow containsString:@"id="])
                {
                    NSArray *arrStr = [strLow componentsSeparatedByString:@"id="];
                    NSString *enStr = URLEncodedString_ch(arrStr[0]);
                    videoURLLow = [NSString stringWithFormat:@"%@id=%@",enStr,arrStr[1]];
                }
                else
                    videoURLLow = URLEncodedString_ch(strLow);
            }
                
        }
        
        NSString *strHigh = [[response objectForKey:@"Video"] objectForKey:@"VideoStreamUrl"];
        if(strHigh != (NSString *)[NSNull null])
        {
            if([strHigh length]>0)
                videoURLHigh = URLEncodedString_ch(strHigh);
        }
        
        if([response objectForKey:@"Ad"] != [NSNull null])
        {
            if([[[response objectForKey:@"Ad"] objectForKey:@"IsVast"] integerValue] == 0)
                adURL = [[response objectForKey:@"Ad"] objectForKey:@"AdvertisementUrl"];
            else
                adURL = [[response objectForKey:@"Ad"] objectForKey:@"AdvertisementVastURL"];
        }

        [self setupAdsLoader];
        [self setUpContentPlayer];
        [self requestAds];
    }
}

-(void) playNonVastAd{
    
    self.adPlayerVC = [[AVPlayerViewController alloc] init];
    
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:adURL]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:playerItem];
    
    self.adPlayerVC.player = [AVPlayer playerWithPlayerItem:playerItem];
    
    [self addChildViewController:self.adPlayerVC];
    [self.view addSubview:self.adPlayerVC.view];
    self.adPlayerVC.view.frame = self.view.frame;
    [self.adPlayerVC.player play];
    self.adPlayerVC.showsPlaybackControls = NO;
    
//    [self.adPlayerVC.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    
//    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:adURL]];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
//    
//    AVPlayer* player = [[[AVPlayer alloc] initWithPlayerItem:playerItem] autorelease];
    
//    // Begin playback
//    [player play]
    

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor greenColor];
    btn.frame = CGRectMake(self.adPlayerVC.view.frame.size.width-30, self.adPlayerVC.view.frame.size.height-30, 50, 50);
    [btn addTarget:self action:@selector(didSelectButton) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.text = @"Skip Ad";
    btn.center = self.adPlayerVC.view.center;
    [self.adPlayerVC.view addSubview:btn];

}

-(void)didSelectButton{
    
    [self.adPlayerVC.player pause];
    [self.adPlayerVC.view removeFromSuperview];
    [self setUpContentPlayer];
}


-(void)itemDidFinishPlaying:(NSNotification *) notification {
    // Will be called when AVPlayer finishes playing playerItem
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.adPlayerVC.player && [keyPath isEqualToString:@"status"]) {
        if (self.adPlayerVC.player.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"play");
        } else if (self.adPlayerVC.player.status == AVPlayerStatusFailed) {
            NSLog(@"failed");
        }else if (self.adPlayerVC.player.status == AVPlayerStatusUnknown) {
            NSLog(@"unknow");
        }
    }
}

- (void)requestFailed:(NSError*)error
{
//    showAlert(self, error.localizedDescription);
    showAlert(self, error_msg);
}

-(void) showInternetAlert{
    
    showAlert(self, error_Internet);
}
@end
