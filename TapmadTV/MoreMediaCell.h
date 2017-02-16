//
//  MoreMediaCell.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 1/5/17.
//  Copyright © 2017 pitv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreMediaCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *vuThumbnail;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewMedia;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDesciption;

+ (UINib*) nib;

@end
