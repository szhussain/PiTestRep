//
//  Section.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/21/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Video.h"

@interface Section : NSObject

@property (nonatomic, strong) NSNumber *sectionId;
@property (nonatomic, strong) NSString *sectionName;
@property (nonatomic, strong) NSArray *videos;


@end
