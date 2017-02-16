//
//  AppDelegate.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 11/23/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property () BOOL restrictRotation;

- (void)saveContext;


@end

