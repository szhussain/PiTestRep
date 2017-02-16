//
//  SectionHeaderReusableView.m
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/29/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import "SectionHeaderReusableView.h"

@implementation SectionHeaderReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.btnMore.backgroundColor = [UIColor colorWithRed:128.0f/255.0f green:170.0f/255.0f blue:85.0f/255.0f alpha:1];
}

+ (UINib*) nib
{
    return [UINib nibWithNibName:@"SectionHeaderReusableView" bundle:nil];
}
@end
