//
//  AVPlayerVC.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 1/11/17.
//  Copyright © 2017 pitv. All rights reserved.
//

#import <AVKit/AVKit.h>

@interface AVPlayerVC : AVPlayerViewController
{
    UIView *playbackControlsView;
    
}

@property(nonatomic) NSURL *urlLow;
@property(nonatomic) NSURL *urlHigh;

-(void) addPlaybackControls:(CGRect)frame;
@end
