//
//  HomeCollectionViewController.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/22/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCollectionViewController : UICollectionViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;

@property(nonatomic) NSString *mediaType;


@end
