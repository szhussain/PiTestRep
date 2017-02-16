//
//  Movie+CoreDataProperties.m
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/16/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import "Movie+CoreDataProperties.h"

@implementation Movie (CoreDataProperties)

+ (NSFetchRequest<Movie *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Movie"];
}

@dynamic isVideoChannel;
@dynamic videoAddedDate;
@dynamic videoCategoryId;
@dynamic videoDescription;
@dynamic videoEntityId;
@dynamic videoImagePath;
@dynamic videoImagePathLarge;
@dynamic videoImageThumbnail;
@dynamic videoName;
@dynamic videoPackageId;
@dynamic videoPosterPath;
@dynamic videoRating;
@dynamic videoStreamUrl;
@dynamic videoStreamUrlLow;
@dynamic videoTotalViews;

@end
