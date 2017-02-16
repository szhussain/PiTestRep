//
//  SVHeaderView.m
//  CustomHeaderTest
//
//  Created by Apple MacBook Pro on 12/23/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import "SVHeader.h"

@implementation SVHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.svCategories.backgroundColor = [UIColor colorWithRed:128.0f/255.0f green:170.0f/255.0f blue:85.0f/255.0f alpha:1];
}

+ (UINib*) nib
{
    return [UINib nibWithNibName:@"SVHeader" bundle:nil];
}


@end
