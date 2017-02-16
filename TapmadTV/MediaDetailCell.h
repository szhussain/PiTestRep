//
//  MediaDetailCell.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/28/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaDetailCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgLive;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewMedia;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDesciption;

+ (UINib*) nib;
@end
