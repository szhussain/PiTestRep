//
//  AVPlayerVC.m
//  TapmadTV
//
//  Created by Apple MacBook Pro on 1/11/17.
//  Copyright © 2017 pitv. All rights reserved.
//

#import "AVPlayerVC.h"
#import <AVFoundation/AVFoundation.h>

@interface AVPlayerVC (){

    BOOL isHighLowShowing;
    BOOL isPlayingLow;
    UIButton *btnHigh;
    UIButton *btnLow;
}

@end

@implementation AVPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isHighLowShowing = YES;
    isPlayingLow = YES;
    [self performSelector:@selector(showHideHighLow) withObject:nil afterDelay:5.0];
}

-(void) addPlaybackControls:(CGRect)frame{

    playbackControlsView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height-100)/2, self.view.frame.size.width, 40)];
    playbackControlsView.center = self.view.center;
    
    btnHigh = [UIButton buttonWithType:UIButtonTypeCustom];
    btnHigh.frame = CGRectMake((playbackControlsView.frame.size.width/2)-30, 0, 30, 30);
    [btnHigh setImage:[UIImage imageNamed:@"hdIcon.png"] forState:UIControlStateNormal];
    [btnHigh addTarget:self action:@selector(highClicked) forControlEvents:UIControlEventTouchUpInside];
    [playbackControlsView addSubview:btnHigh];
    
    btnLow = [UIButton buttonWithType:UIButtonTypeCustom];
    btnLow.frame = CGRectMake((playbackControlsView.frame.size.width/2)+30, 0, 30, 30);
    [btnLow setImage:[UIImage imageNamed:@"sdGreenIcon.png"] forState:UIControlStateNormal];
    [btnLow addTarget:self action:@selector(lowClicked) forControlEvents:UIControlEventTouchUpInside];
    [playbackControlsView addSubview:btnLow];
    
    
    if([self.urlLow absoluteString] != nil && [self.urlHigh absoluteString] != nil)
        [self.view addSubview:playbackControlsView];
    
    if([self.urlLow absoluteString] == nil)
    {
        [self.player pause];
        self.player = [AVPlayer playerWithURL:self.urlHigh];
        [self.player play];
        [btnHigh setImage:[UIImage imageNamed:@"hdGreenIcon.png"] forState:UIControlStateNormal];
        [btnLow setImage:[UIImage imageNamed:@"sdIcon.png"] forState:UIControlStateNormal];
        isPlayingLow = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)highClicked{

    [self showHideHighLow];
    if(isPlayingLow)
    {
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:self.urlHigh];
        [item seekToTime:self.player.currentTime];
        [self.player replaceCurrentItemWithPlayerItem:item];
        [btnHigh addTarget:self action:@selector(highClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [btnHigh setImage:[UIImage imageNamed:@"hdGreenIcon.png"] forState:UIControlStateNormal];
        [btnLow setImage:[UIImage imageNamed:@"sdIcon.png"] forState:UIControlStateNormal];
        isPlayingLow = NO;
    }
    
}

-(void)lowClicked{
    
    [self showHideHighLow];
    if(!isPlayingLow)
    {
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:self.urlLow];
        [item seekToTime:self.player.currentTime];
        [self.player replaceCurrentItemWithPlayerItem:item];
        
        [btnHigh setImage:[UIImage imageNamed:@"hdIcon.png"] forState:UIControlStateNormal];
        [btnLow setImage:[UIImage imageNamed:@"sdGreenIcon.png"] forState:UIControlStateNormal];
        isPlayingLow = YES;
    }
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

    [self showHideHighLow];
}

-(void)showHideHighLow{
    
    if(isHighLowShowing)
    {
        playbackControlsView.hidden = YES;
        isHighLowShowing = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showHideHighLow) object:nil];
    }
    else
    {
        playbackControlsView.hidden = NO;
        isHighLowShowing = YES;
        [self performSelector:@selector(showHideHighLow) withObject:nil afterDelay:5.0];
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


//-(void)showHidePlaybackControls{
//    
//    if(!isPlaybackShowing)
//    {
//        
//        CGRect viewFrame = playbackControlsView.frame;
//        viewFrame.origin.y = self.view.frame.size.height-100;;
//        [UIView animateWithDuration:0.5
//                              delay:0.5
//                            options: UIViewAnimationOptionCurveEaseOut
//                         animations:^{
//                             playbackControlsView.frame = viewFrame;
//                             playbackControlsView.userInteractionEnabled = YES;
//                         }
//                         completion:^(BOOL finished){
//                         }];
//        isPlaybackShowing = YES;
//    }
//    else
//    {
//        CGRect viewFrame = playbackControlsView.frame;
//        viewFrame.origin.y = self.view.frame.size.height;
//        [UIView animateWithDuration:0.5
//                              delay:0.5
//                            options: UIViewAnimationOptionCurveEaseOut
//                         animations:^{
//                             playbackControlsView.frame = viewFrame;
//                             playbackControlsView.userInteractionEnabled = NO;
//                         }
//                         completion:^(BOOL finished){
//                         }];
//        isPlaybackShowing = NO;
//    }
//    
//}

@end
