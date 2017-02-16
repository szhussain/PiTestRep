//
//  SectionHeaderReusableView.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/29/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SectionHeaderReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnMore;

+ (UINib*) nib;


@end
