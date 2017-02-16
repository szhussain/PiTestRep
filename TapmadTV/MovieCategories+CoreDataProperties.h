//
//  MovieCategories+CoreDataProperties.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 1/9/17.
//  Copyright © 2017 pitv. All rights reserved.
//

#import "MovieCategories+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MovieCategories (CoreDataProperties)

+ (NSFetchRequest<MovieCategories *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *videoCategoryDescription;
@property (nullable, nonatomic, copy) NSNumber *videoCategoryId;
@property (nullable, nonatomic, copy) NSString *videoCategoryImagePath;
@property (nullable, nonatomic, copy) NSString *videoCategoryName;
@property (nullable, nonatomic, copy) NSNumber *videoParentCategoryId;
@property (nullable, nonatomic, copy) NSString *videoCategoryImagePathLarge;
@property (nullable, nonatomic, copy) NSString *videoCategoryImageThumbnail;

@end

NS_ASSUME_NONNULL_END
