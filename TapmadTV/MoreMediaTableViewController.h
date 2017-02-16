//
//  MoreMediaTableViewController.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/15/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChannelCategories+CoreDataClass.h"
#import "Channel+CoreDataClass.h"
#import "VOD+CoreDataClass.h"
#import "VODCategories+CoreDataClass.h"
#import "Movie+CoreDataClass.h"
#import "MovieCategories+CoreDataClass.h"
#import "Video.h"
#import "Section.h"
#import "Category.h"

@interface MoreMediaTableViewController : UITableViewController

@property(nonatomic) Channel *channel;
@property(nonatomic) ChannelCategories *channelCategory;

@property(nonatomic) Movie *movie;
@property(nonatomic) MovieCategories *movieCategory;

@property(nonatomic) VOD *vod;
@property(nonatomic) VODCategories *vodCategory;

@property(nonatomic) Video *video;
@property(nonatomic) Section *section;
@property(nonatomic) NSNumber *sectionId;
@property(nonatomic) NSString *screenTitle;
//@property(nonatomic) Category *category;

@property(nonatomic) NSString *mediaType;

@property(nonatomic) BOOL isFromPlayCVC;

@end
