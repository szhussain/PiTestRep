//
//  Category.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/21/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Section.h"

@interface Category : NSObject

@property (nonatomic, strong) NSNumber *categoryId;
@property (nonatomic, strong) NSString *categoryName;
@property (nonatomic, strong) NSString *categoryPosterPath;
@property (nonatomic, strong) NSArray *sections;

@end
