//
//  AppDelegate.m
//  TapmadTV
//
//  Created by Apple MacBook Pro on 11/23/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AFNetworkReachabilityManager.h>
#import <Google/Analytics.h>
#import "Utilities.h"
#import "AFNetworkingWrapper.h"
#import "Constants.h"
#import <UserNotifications/UserNotifications.h>


@interface AppDelegate ()<AFNetworkingWrapperDelegate>{
    
//    AMTumblrHud *loadingView;
//    AFNetworkingWrapper *requestWrapper;
    NSString *token;
}
@end

@implementation AppDelegate

static int const kTagRegister = 1321;
static int const kTagPushNotification = 1421;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    if(![[UIApplication sharedApplication] isRegisteredForRemoteNotifications])
//    {
//        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeNone) categories:nil]];
//        
//        [[UIApplication sharedApplication] registerForRemoteNotifications];
//    }
    
    
    // initialize Facebook
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // Google Analytics
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    
    
    NSString *deviceVendorId = getDeviceIdentifier();
    
    NSString *requestUrl = [NSString stringWithFormat:g_checkAndRegisterTempUser, deviceVendorId, @"02:00:00:00:00:00"];
    AFNetworkingWrapper *requestWrapper = [[AFNetworkingWrapper alloc] initWithURL:requestUrl andPostParams:nil tag:kTagRegister];
    requestWrapper.delegate = self;
    requestWrapper.tag = kTagRegister;
    [requestWrapper startAsynchronousGet];
    
//    NSInteger ver = getAppDatabaseVersion();
//    if(ver)
//    {
//        if(ver != g_db_version)
//           [self removeDatabase];
//    }
//    else{
//        setAppDatabaseVersion(g_db_version);
//        [self removeDatabase];
//    }

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

//-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    if(self.restrictRotation)
//        return UIInterfaceOrientationMaskPortrait;
//    else
//        return UIInterfaceOrientationMaskLandscapeLeft;
//}


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    UIViewController *currentViewController = [self topViewController];
    
    if ([currentViewController respondsToSelector:@selector(canAutoRotate)]) {
        NSMethodSignature *signature = [currentViewController methodSignatureForSelector:@selector(canAutoRotate)];
        
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        
        [invocation setSelector:@selector(canAutoRotate)];
        [invocation setTarget:currentViewController];
        
        [invocation invoke];
        
        BOOL canAutorotate = NO;
        [invocation getReturnValue:&canAutorotate];
        
        if (canAutorotate) {
            return UIInterfaceOrientationMaskLandscapeLeft;
        }
    }
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIViewController *)topViewController
{
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"TapmadTV"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
//                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}


#pragma mark AFNetworkingWrapperDelegate Methods

- (void)requestFinished:(id)response tag:(int)callTag
{
    if(callTag == kTagRegister)
    {
        if([[[response objectForKey:@"Response"] objectForKey:@"status"] isEqualToString:@"Success"]){
            NSString *userToken = [NSString stringWithFormat:@"userToken=%@",
                                   [[response objectForKey:@"TempUser"] objectForKey:@"TempUserToken"]];
            setUserToken(userToken);
            
//            if(![[UIApplication sharedApplication] isRegisteredForRemoteNotifications])
            {
                [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge) categories:nil]];
                
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }
    }
    else if(callTag == kTagPushNotification)
    {
        
    }
    
}

- (void)requestFailed:(NSError*)error
{
//    showAlert(self, error_msg);
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
//    token = [deviceToken.description copy];
    
    token = [[[[deviceToken description]
                                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                                    stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"The generated device token string is : %@",token);
    
    NSString *userToken = [getUserToken() stringByReplacingOccurrencesOfString:@"userToken=" withString:@""];
    
    NSString *requestUrl = [NSString stringWithFormat:g_saveOrUpdateDeviceInfo, userToken, @"02:00:00:00:00:00", token];
    AFNetworkingWrapper *pushRequestWrapper = [[AFNetworkingWrapper alloc] initWithURL:requestUrl andPostParams:nil tag:kTagPushNotification];
    pushRequestWrapper.delegate = self;
    pushRequestWrapper.tag = kTagPushNotification;
    [pushRequestWrapper startAsynchronousGet];
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error{
    
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo{
    
    NSLog(@"Push notification received.");
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    //Called when a notification is delivered to a foreground app.
    
    NSLog(@"Userinfo %@",notification.request.content.userInfo);
    
    completionHandler(UNNotificationPresentationOptionAlert);
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    //Called to let your app know which action was selected by the user for a given notification.
    
    NSLog(@"Userinfo %@",response.notification.request.content.userInfo);
    
}

//-(void) removeDatabase{
//    
//    NSString *storePath = getAppDatabasePath();
//    NSError *error;
//    if ([[NSFileManager defaultManager] fileExistsAtPath:storePath]){
//        BOOL res = [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:storePath] error:&error];
//        if(res)
//        NSLog(@"deleted");
//        else
//        NSLog(@"not deleted");
//    }
//    
//    NSString *shmPath = [NSString stringWithFormat:@"%@-shm",storePath];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:shmPath]){
//        BOOL res = [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:shmPath] error:&error];
//        if(res)
//        NSLog(@"deleted");
//        else
//        NSLog(@"not deleted");
//    }
//    
//    NSString *walPath = [NSString stringWithFormat:@"%@-wal",storePath];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:walPath]){
//        BOOL res = [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:walPath] error:&error];
//        if(res)
//        NSLog(@"deleted");
//        else
//        NSLog(@"not deleted");
//    }
//    
//    setChannelDataStatus(k_NotDownloaded);
//    setMoviesDataStatus(k_NotDownloaded);
//    setVODDataStatus(k_NotDownloaded);
//    
//    setAppDatabaseVersion(g_db_version);
//    
//}


@end
