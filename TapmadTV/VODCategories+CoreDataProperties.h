//
//  VODCategories+CoreDataProperties.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 1/6/17.
//  Copyright © 2017 pitv. All rights reserved.
//

#import "VODCategories+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface VODCategories (CoreDataProperties)

+ (NSFetchRequest<VODCategories *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *videoCategoryDescription;
@property (nullable, nonatomic, copy) NSNumber *videoCategoryId;
@property (nullable, nonatomic, copy) NSString *videoCategoryImagePath;
@property (nullable, nonatomic, copy) NSString *videoCategoryName;
@property (nullable, nonatomic, copy) NSNumber *videoParentCategoryId;
@property (nullable, nonatomic, copy) NSString *videoCategoryImageThumbnail;
@property (nullable, nonatomic, copy) NSString *videoCategoryImagePathLarge;

@end

NS_ASSUME_NONNULL_END
