//
//  EmptyMediaCell.m
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/28/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import "EmptyMediaCell.h"

@implementation EmptyMediaCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (UINib*) nib
{
    return [UINib nibWithNibName:@"EmptyMediaCell" bundle:nil];
}

@end
