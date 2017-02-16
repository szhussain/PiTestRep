//
//  PlayViewController.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/14/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel+CoreDataClass.h"
#import "AFNetworkingWrapper.h"
#import "Movie+CoreDataClass.h"
#import "VOD+CoreDataClass.h"
#import "Video.h"

@interface PlayViewController : UIViewController

@property(nonatomic) Channel *channel;
@property(nonatomic) Movie *movie;
@property(nonatomic) VOD *vod;
@property(nonatomic) Video *video;
@property(nonatomic) NSString *mediaType;
@end
