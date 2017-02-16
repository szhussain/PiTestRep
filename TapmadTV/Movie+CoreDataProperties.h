//
//  Movie+CoreDataProperties.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/16/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import "Movie+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Movie (CoreDataProperties)

+ (NSFetchRequest<Movie *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *isVideoChannel;
@property (nullable, nonatomic, copy) NSString *videoAddedDate;
@property (nullable, nonatomic, copy) NSNumber *videoCategoryId;
@property (nullable, nonatomic, copy) NSString *videoDescription;
@property (nullable, nonatomic, copy) NSNumber *videoEntityId;
@property (nullable, nonatomic, copy) NSString *videoImagePath;
@property (nullable, nonatomic, copy) NSString *videoImagePathLarge;
@property (nullable, nonatomic, copy) NSString *videoImageThumbnail;
@property (nullable, nonatomic, copy) NSString *videoName;
@property (nullable, nonatomic, copy) NSNumber *videoPackageId;
@property (nullable, nonatomic, copy) NSString *videoPosterPath;
@property (nullable, nonatomic, copy) NSNumber *videoRating;
@property (nullable, nonatomic, copy) NSString *videoStreamUrl;
@property (nullable, nonatomic, copy) NSString *videoStreamUrlLow;
@property (nullable, nonatomic, copy) NSNumber *videoTotalViews;

@end

NS_ASSUME_NONNULL_END
