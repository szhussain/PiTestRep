//
//  SVHeaderView.h
//  CustomHeaderTest
//
//  Created by Apple MacBook Pro on 12/23/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVHeader : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIScrollView *svCategories;

+ (UINib*) nib;
@end
