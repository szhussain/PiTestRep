//
//  ChannelCategories+CoreDataProperties.m
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/16/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import "ChannelCategories+CoreDataProperties.h"

@implementation ChannelCategories (CoreDataProperties)

+ (NSFetchRequest<ChannelCategories *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ChannelCategories"];
}

@dynamic videoCategoryDescription;
@dynamic videoCategoryId;
@dynamic videoCategoryImagePath;
@dynamic videoCategoryName;

@end
