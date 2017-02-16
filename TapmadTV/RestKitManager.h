//
//  RestKitManager.h
//  TapmadTV
//
//  Created by Zeeshan Hussain on 11/29/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChannelCategories+CoreDataClass.h"
#import <RestKit/CoreData.h>
#import <RestKit/RestKit.h>


//@protocol RestKitManagerObserver
//
//-(void) dataLoadedOk;
//-(void) dataLoadFailed:(NSError*)error;
//
//@end


@interface RestKitManager : NSObject{
    RKObjectManager *objectManager;
    RKResponseDescriptor *channelCategoriesResponseDescriptor;
    RKResponseDescriptor *channelResponseDescriptor;
    RKResponseDescriptor *VODCategoriesResponseDescriptor;
    RKResponseDescriptor *VODResponseDescriptor;
    RKResponseDescriptor *movieCategoriesResponseDescriptor;
    RKResponseDescriptor *movieResponseDescriptor;
    
    RKResponseDescriptor *homeCategoryResponseDescriptor;
//    RKResponseDescriptor *homeSectionResponseDescriptor;
//    RKResponseDescriptor *homeVideoResponseDescriptor;
    
    RKResponseDescriptor *moreSectionVideosResponseDescriptor;
    RKResponseDescriptor *relatedVideosResponseDescriptor;
}
/* This method will fetch all the Channel Categories and Videos from Server
 */
+(void) getAllChannelsAndChannelCategories;

/* This method will fetch all the Channel Categories and Videos from Server
 */
+(void) getAllVODAndVODCategories;

/* This method will fetch all the Channel Categories and Videos from Server
 */
+(void) getAllMoviesAndMovieCategories;

/* This method will fetch all the Home Screen Details and Videos from Server
 */
+(void) getAllHomeVideosAndDetails;

/* This method will fetch HomeScreen-More info from server
 */
+(void) getMoreSectionVideos:(NSString*) url;

/* This method will fetch HomeScreen-More info from server
 */
+(void) getRelatedVideos:(NSString*) url;


/* This method will get Categories from Local DB
    entityName: Name of the Table in Local DB
    predicate: search string
 */
+(NSMutableArray*) getCategories:(NSString*) entityName predicate:(NSPredicate*) predicate;

/* This method will get Videos from Local DB
    entityName: Name of the Table in Local DB
    predicate: search string
 */
+(NSMutableArray*) getVideos:(NSString*) entityName predicate:(NSPredicate*) predicate;

@end
