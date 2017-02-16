//
//  Utilities.m
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/16/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import <AFNetworkReachabilityManager.h>
#import <UIKit/UIKit.h>
#import <Google/Analytics.h>
#import "AppDelegate.h"


void setChannelDataStatus(NSString* status) {
    [[NSUserDefaults standardUserDefaults] setObject:status forKey:k_LiveChannelDataDownloadStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString* getChannelDataStatus(){
    return [[NSUserDefaults standardUserDefaults] stringForKey:k_LiveChannelDataDownloadStatus];
}

void setVODDataStatus(NSString* status) {
    [[NSUserDefaults standardUserDefaults] setObject:status forKey:k_VODDataDownloadStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString* getVODDataStatus(){
    return [[NSUserDefaults standardUserDefaults] stringForKey:k_VODDataDownloadStatus];
}

void setMoviesDataStatus(NSString* status) {
    [[NSUserDefaults standardUserDefaults] setObject:status forKey:k_MoviesDataDownloadStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString* getMoviesDataStatus(){
    return [[NSUserDefaults standardUserDefaults] stringForKey:k_MoviesDataDownloadStatus];
}

void setViewControllerNameForKey(NSString* currVC, NSString* vcKey){

    [[NSUserDefaults standardUserDefaults] setObject:currVC forKey:vcKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
NSString* getViewControllerNameForKey(NSString* vcKey){

    return [[NSUserDefaults standardUserDefaults] stringForKey:vcKey];
}

void setHomeDataStatus(NSString* status) {
    [[NSUserDefaults standardUserDefaults] setObject:status forKey:k_HomeDataDownloadStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString* getHomeDataStatus(){
    return [[NSUserDefaults standardUserDefaults] stringForKey:k_HomeDataDownloadStatus];
}

void setAppDatabaseVersion(NSInteger version){
    [[NSUserDefaults standardUserDefaults] setInteger:version forKey:k_DB_Version];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSInteger getAppDatabaseVersion(){
    return [[NSUserDefaults standardUserDefaults] integerForKey:k_DB_Version];
}

void setAppDatabasePath(NSString* path){
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:k_DB_Path];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString* getAppDatabasePath(){
    return [[NSUserDefaults standardUserDefaults] stringForKey:k_DB_Path];
}

void setUserToken(NSString* token){
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:k_UserToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSString* getUserToken(){
    return [[NSUserDefaults standardUserDefaults] stringForKey:k_UserToken];
}

void setUserFacebookDetails(NSString* userId, NSString* userName, NSString* userEmail, NSString* userImageURL){

    [[NSUserDefaults standardUserDefaults] setObject:userId forKey:k_userId];
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:k_userName];
    [[NSUserDefaults standardUserDefaults] setObject:userEmail forKey:k_userEmail];
    [[NSUserDefaults standardUserDefaults] setObject:userImageURL forKey:k_userImageURL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
NSString* getUserFacebookDetailsForKey(NSString* userKey){

    return [[NSUserDefaults standardUserDefaults] stringForKey:userKey];
}


void saveHomeData(NSArray* arrData){
    NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:arrData];
    [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:k_HomeData];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSArray* getHomeData(){
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:k_HomeData];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}


NSString * URLEncodedString_ch(NSString* str) {
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[str UTF8String];
    int sourceLen = (int)strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"%20"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' || thisChar == ':' || thisChar == '/' || thisChar == '?' || thisChar == '%' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

BOOL connected() {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

void showAlert (UIViewController *con, NSString* msg) {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [con presentViewController:alert animated:YES completion:nil];
}

void sendGoogleAnalyticsScreenName(NSString* screenName){
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:screenName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];

}

void restrictRotation (BOOL restriction)
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

NSString * getDeviceIdentifier()
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return @"";
}

