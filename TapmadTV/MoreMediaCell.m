//
//  MoreMediaCell.m
//  TapmadTV
//
//  Created by Apple MacBook Pro on 1/5/17.
//  Copyright © 2017 pitv. All rights reserved.
//

#import "MoreMediaCell.h"

@implementation MoreMediaCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.lblDesciption sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (UINib*) nib
{
    return [UINib nibWithNibName:@"MoreMediaCell" bundle:nil];
}

@end
