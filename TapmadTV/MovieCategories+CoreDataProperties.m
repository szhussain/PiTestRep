//
//  MovieCategories+CoreDataProperties.m
//  TapmadTV
//
//  Created by Apple MacBook Pro on 1/9/17.
//  Copyright © 2017 pitv. All rights reserved.
//

#import "MovieCategories+CoreDataProperties.h"

@implementation MovieCategories (CoreDataProperties)

+ (NSFetchRequest<MovieCategories *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"MovieCategories"];
}

@dynamic videoCategoryDescription;
@dynamic videoCategoryId;
@dynamic videoCategoryImagePath;
@dynamic videoCategoryName;
@dynamic videoParentCategoryId;
@dynamic videoCategoryImagePathLarge;
@dynamic videoCategoryImageThumbnail;

@end
