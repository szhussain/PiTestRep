//
//  Video.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/21/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Video : NSObject

@property (nonatomic, strong) NSNumber *videoEntityId;
@property (nonatomic, strong) NSNumber *isVideoChannel;
@property (nonatomic, strong) NSString *videoName;
@property (nonatomic, strong) NSString *videoDescription;
@property (nonatomic, strong) NSString *videoImagePath;
@property (nonatomic, strong) NSString *videoImagePathLarge;
@property (nonatomic, strong) NSNumber *videoCategoryId;
@property (nonatomic, strong) NSString *videoCategoryName;
@property (nonatomic, strong) NSNumber *videoPackageId;
@property (nonatomic, strong) NSNumber *videoTotalViews;
@property (nonatomic, strong) NSString *videoAddedDate;
@property (nonatomic, strong) NSNumber *videoRating;
@property (nonatomic, strong) NSString *VideoDuration;
@property (nonatomic, strong) NSNumber *isVideoFree;

@end
