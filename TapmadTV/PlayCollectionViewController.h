//
//  PlayCollectionViewController.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/6/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Channel+CoreDataClass.h"
#import "ChannelCategories+CoreDataClass.h"
#import "MovieCategories+CoreDataClass.h"
#import "Movie+CoreDataClass.h"
#import "VOD+CoreDataClass.h"
#import "VODCategories+CoreDataClass.h"
#import "Category.h"
#import "Section.h"
#import "Video.h"

@interface PlayCollectionViewController : UICollectionViewController

@property(nonatomic) Channel *channel;
@property(nonatomic) ChannelCategories *channelCategory;

@property(nonatomic) Movie *movie;
@property(nonatomic) MovieCategories *movieCategory;

@property(nonatomic) VOD *vod;
@property(nonatomic) VODCategories *vodCategory;

@property(nonatomic) Category *category;
@property(nonatomic) Section *section;
@property(nonatomic) Video *video;

@property(nonatomic) NSString *mediaType;


@end
