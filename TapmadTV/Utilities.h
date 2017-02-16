//
//  Utilities.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/16/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef Utilities_h
#define Utilities_h

void setChannelDataStatus(NSString* status);
NSString* getChannelDataStatus();

void setVODDataStatus(NSString* status);
NSString* getVODDataStatus();

void setMoviesDataStatus(NSString* status);
NSString* getMoviesDataStatus();

void setHomeDataStatus(NSString* status);
NSString* getHomeDataStatus();

void setAppDatabaseVersion(NSInteger version);
NSInteger getAppDatabaseVersion();

void setAppDatabasePath(NSString* path);
NSString* getAppDatabasePath();


void setUserToken(NSString* token);
NSString* getUserToken();

void setViewControllerNameForKey(NSString* currVC, NSString* vcKey);
NSString* getViewControllerNameForKey(NSString* vcKey);

void saveHomeData(NSArray* arrData);
NSArray* getHomeData();

void setUserFacebookDetails(NSString* userId, NSString* userName, NSString* userEmail, NSString* userImageURL);
NSString* getUserFacebookDetailsForKey(NSString* userKey);


// This method will encode the URL with spaces or other characters
NSString * URLEncodedString_ch(NSString* str);

BOOL connected();

void showAlert (UIViewController *con, NSString* msg);

// send Google Analytics Screen Names
void sendGoogleAnalyticsScreenName(NSString* screenName);

void restrictRotation (BOOL restriction);

// Get device identifier
NSString * getDeviceIdentifier();

#endif /* Utilities_h */
