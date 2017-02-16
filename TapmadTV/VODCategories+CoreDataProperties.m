//
//  VODCategories+CoreDataProperties.m
//  TapmadTV
//
//  Created by Apple MacBook Pro on 1/6/17.
//  Copyright © 2017 pitv. All rights reserved.
//

#import "VODCategories+CoreDataProperties.h"

@implementation VODCategories (CoreDataProperties)

+ (NSFetchRequest<VODCategories *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"VODCategories"];
}

@dynamic videoCategoryDescription;
@dynamic videoCategoryId;
@dynamic videoCategoryImagePath;
@dynamic videoCategoryName;
@dynamic videoParentCategoryId;
@dynamic videoCategoryImageThumbnail;
@dynamic videoCategoryImagePathLarge;

@end
