//
//  MediaDetailsHeader.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/28/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaDetailsHeader : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblFree;
@property (weak, nonatomic) IBOutlet UILabel *lblLive;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UILabel *lblRating;
@property (weak, nonatomic) IBOutlet UILabel *lblViews;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;

+ (UINib*) nib;

@end
