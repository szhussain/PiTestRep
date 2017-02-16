//
//  ChannelCategories+CoreDataProperties.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/16/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import "ChannelCategories+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ChannelCategories (CoreDataProperties)

+ (NSFetchRequest<ChannelCategories *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *videoCategoryDescription;
@property (nullable, nonatomic, copy) NSNumber *videoCategoryId;
@property (nullable, nonatomic, copy) NSString *videoCategoryImagePath;
@property (nullable, nonatomic, copy) NSString *videoCategoryName;

@end

NS_ASSUME_NONNULL_END
