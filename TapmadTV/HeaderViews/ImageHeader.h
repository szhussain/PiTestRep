//
//  ImageHeader.h
//  CustomHeaderTest
//
//  Created by Apple MacBook Pro on 12/23/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageHeader : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

+ (UINib*) nib;

@end
