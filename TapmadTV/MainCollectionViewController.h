//
//  MainCollectionViewController.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/1/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AMTumblrHud;

@interface MainCollectionViewController : UICollectionViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;

@property(nonatomic) NSString *mediaType;


@end
