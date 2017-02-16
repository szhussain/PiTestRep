//
//  ImageHeader.m
//  CustomHeaderTest
//
//  Created by Apple MacBook Pro on 12/23/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import "ImageHeader.h"

@implementation ImageHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
+ (UINib*) nib
{
    return [UINib nibWithNibName:@"ImageHeader" bundle:nil];
}


@end
