//
//  RestKitManager.m
//  TapmadTV
//
//  Created by Zeeshan Hussain on 11/29/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import "RestKitManager.h"
#import "Constants.h"
#import "Category.h"
#import "Section.h"
#import "Video.h"
#import "Utilities.h"

static RestKitManager *rkInstance = nil;

@interface RestKitManager (Private)

+(RestKitManager*) sharedInstance;
-(void) initializeRestKit;
-(void) getAllHomeVideosAndDetails;
-(void) getAllChannelsAndChannelCategories;
-(void) getAllVODAndVODCategories;
-(void) getAllMoviesAndMovieCategories;
-(void) getMoreSectionVideos:(NSString*) url;
-(void) getRelatedVideos:(NSString*) url;

-(NSMutableArray*) getCategories:(NSString*) entityName predicate:(NSPredicate*) predicate;
-(NSMutableArray*) getVideos:(NSString*) entityName predicate:(NSPredicate*) predicate;

@end


@implementation RestKitManager

typedef enum responseDescriptorTypes
{
    CHANNEL_AND_CATEGORIES,
    VOD_AND_CATEGORIES,
    MOVIE_AND_CATEGORIES,
    HOME_DETAILS,
    MORE_SECTION_VIDEOS,
    RELATED_VIDEOS
    
} ResponseDescriptorTypes;

#pragma mark --Intialize Methods

+(RestKitManager*) sharedInstance {
    
    if (rkInstance == nil) {
        rkInstance = [[RestKitManager alloc] init];
        [rkInstance initializeRestKit];
    }
    return rkInstance;
}

+(void) getAllHomeVideosAndDetails{
    
    [[RestKitManager sharedInstance] getAllHomeVideosAndDetails];
}

+(void) getAllChannelsAndChannelCategories{
    
    [[RestKitManager sharedInstance] getAllChannelsAndChannelCategories];
}

+(void) getAllVODAndVODCategories{
    
    [[RestKitManager sharedInstance] getAllVODAndVODCategories];
}

+(void) getAllMoviesAndMovieCategories{
    
    [[RestKitManager sharedInstance] getAllMoviesAndMovieCategories];
}

+(void) getMoreSectionVideos:(NSString*) url{
    
    [[RestKitManager sharedInstance] getMoreSectionVideos:url];
}

+(void) getRelatedVideos:(NSString*) url{
    
    [[RestKitManager sharedInstance] getRelatedVideos:url];
}


+(NSMutableArray*) getCategories:(NSString*) entityName predicate:(NSPredicate*) predicate{
    return [[RestKitManager sharedInstance] getCategories:entityName predicate:predicate];
}

+(NSMutableArray*) getVideos:(NSString*) entityName predicate:(NSPredicate*) predicate{
    return [[RestKitManager sharedInstance] getVideos:entityName predicate:predicate];
}

-(id) init {
    
    if (self = [super init]) {
    }
    return self;
}

-(void) initializeRestKit {

    // Initialize RestKit
    objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:g_base_url]];
    
    // Initialize managed object model from bundle
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    // Initialize managed object store
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    objectManager.managedObjectStore = managedObjectStore;
    
    
    // Complete Core Data stack initialization
    [managedObjectStore createPersistentStoreCoordinator];
    NSString *storePath = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"TapmadTV.sqlite"];
    NSString *seedPath = [[NSBundle mainBundle] pathForResource:@"RKSeedDatabase" ofType:@"sqlite"];
    NSError *error;
    
    setAppDatabasePath(storePath);
    
    //  if the DB version is changed then delete all data
    NSInteger ver = getAppDatabaseVersion();
    if(ver)
    {
        if(ver != g_db_version)
        [self removeDatabase:storePath];
    }
    else{
        setAppDatabaseVersion(g_db_version);
        [self removeDatabase:storePath];
    }

    
//    [self removeDatabase:storePath];
    
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:storePath fromSeedDatabaseAtPath:seedPath withConfiguration:nil options:nil error:&error];
    NSAssert(persistentStore, @"Failed to add persistent store with error: %@", error);
    
    // Create the managed object contexts
    [managedObjectStore createManagedObjectContexts];
    
    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
    
    //////////////////////////////////// ******* Mapping for Home Screen Data ******** ////////////////////////////////
    RKObjectMapping *categoryMapping = [RKObjectMapping mappingForClass:[Category class]];
    [categoryMapping addAttributeMappingsFromDictionary:@{@"TabId": @"categoryId", @"TabName": @"categoryName", @"TabPosterPath": @"categoryPosterPath"}];
    
    RKObjectMapping *sectionMapping = [RKObjectMapping mappingForClass:[Section class]];
    [sectionMapping addAttributeMappingsFromDictionary:@{@"SectionId": @"sectionId", @"SectionName": @"sectionName"}];

    RKObjectMapping *videoMapping = [RKObjectMapping mappingForClass:[Video class]];
    [videoMapping addAttributeMappingsFromDictionary:@{@"IsVideoChannel": @"isVideoChannel",
                                                         @"IsVideoFree": @"isVideoFree",
                                                         @"VideoAddedDate": @"videoAddedDate",
                                                         @"VideoCategoryId": @"videoCategoryId",
                                                         @"VideoCategoryName": @"videoCategoryName",
                                                         @"VideoDescription": @"videoDescription",
                                                         @"VideoDuration": @"videoDuration",
                                                         @"VideoEntityId": @"videoEntityId",
                                                         @"VideoImagePath": @"videoImagePath",
                                                         @"VideoImagePathLarge": @"videoImagePathLarge",
                                                         @"VideoName": @"videoName",
                                                         @"VideoPackageId": @"videoPackageId",
                                                         @"VideoTotalViews": @"videoTotalViews",
                                                         @"VideoRating": @"videoRating"}];
    
    
    [sectionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"Videos" toKeyPath:@"videos" withMapping:videoMapping]];
    
    [categoryMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"Sections" toKeyPath:@"sections" withMapping:sectionMapping]];
    
    
    homeCategoryResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:categoryMapping
                                                                                       method:RKRequestMethodGET
                                                                                  pathPattern:nil
                                                                                      keyPath:@"Tabs"
                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    //////////////////////////////////// ******* Mapping for More Section Videos ******** ////////////////////////////////
    
    RKObjectMapping *moreSectionVideosMapping = [RKObjectMapping mappingForClass:[Video class]];
    [moreSectionVideosMapping addAttributeMappingsFromDictionary:@{@"IsVideoChannel": @"isVideoChannel",
                                                       @"IsVideoFree": @"isVideoFree",
                                                       @"VideoAddedDate": @"videoAddedDate",
                                                       @"VideoCategoryId": @"videoCategoryId",
                                                       @"VideoCategoryName": @"videoCategoryName",
                                                       @"VideoDescription": @"videoDescription",
                                                       @"VideoDuration": @"videoDuration",
                                                       @"VideoEntityId": @"videoEntityId",
                                                       @"VideoImagePath": @"videoImagePath",
                                                       @"VideoImagePathLarge": @"videoImagePathLarge",
                                                       @"VideoName": @"videoName",
                                                       @"VideoPackageId": @"videoPackageId",
                                                       @"VideoTotalViews": @"videoTotalViews",
                                                       @"VideoRating": @"videoRating"}];
    
    moreSectionVideosResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:moreSectionVideosMapping
                                                                                  method:RKRequestMethodGET
                                                                             pathPattern:nil
                                                                                 keyPath:@"Videos"
                                                                             statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    
    //////////////////////////////////// ******* Mapping for Related Videos ******** ////////////////////////////////
    
    RKObjectMapping *relatedSectionMapping = [RKObjectMapping mappingForClass:[Section class]];
    [relatedSectionMapping addAttributeMappingsFromDictionary:@{@"SectionId": @"sectionId", @"SectionName": @"sectionName"}];

    
    RKObjectMapping *relatedVideosMapping = [RKObjectMapping mappingForClass:[Video class]];
    [relatedVideosMapping addAttributeMappingsFromDictionary:@{@"IsVideoChannel": @"isVideoChannel",
                                                                   @"IsVideoFree": @"isVideoFree",
                                                                   @"VideoAddedDate": @"videoAddedDate",
                                                                   @"VideoCategoryId": @"videoCategoryId",
                                                                   @"VideoCategoryName": @"videoCategoryName",
                                                                   @"VideoDescription": @"videoDescription",
                                                                   @"VideoDuration": @"videoDuration",
                                                                   @"VideoEntityId": @"videoEntityId",
                                                                   @"VideoImagePath": @"videoImagePath",
                                                                   @"VideoImagePathLarge": @"videoImagePathLarge",
                                                                   @"VideoName": @"videoName",
                                                                   @"VideoPackageId": @"videoPackageId",
                                                                   @"VideoTotalViews": @"videoTotalViews",
                                                                   @"VideoRating": @"videoRating"}];
    
    [relatedSectionMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"Videos" toKeyPath:@"videos" withMapping:relatedVideosMapping]];
    
    relatedVideosResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:relatedSectionMapping
                                                                                       method:RKRequestMethodGET
                                                                                  pathPattern:nil
                                                                                      keyPath:@"Sections"
                                                                                  statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    
    //////////////////////////////////// ******* Mapping for Channels AND ChannelCategories ******** ////////////////////////////////
    RKEntityMapping *channelCategoriesMapping = [RKEntityMapping mappingForEntityForName:@"ChannelCategories" inManagedObjectStore:managedObjectStore];
    [channelCategoriesMapping addAttributeMappingsFromDictionary:@{
                                                            @"VideoCategoryId":             @"videoCategoryId",
                                                            @"VideoCategoryName":   @"videoCategoryName",
                                                            @"VideoCategoryImagePath":    @"videoCategoryImagePath",
                                                            @"VideoCategoryDescription": @"videoCategoryDescription"}];
    // This will act as Primary Key and help to keep the record unique in table
    channelCategoriesMapping.identificationAttributes = @[ @"videoCategoryId" ];
    
    RKEntityMapping *channelMapping = [RKEntityMapping mappingForEntityForName:@"Channel" inManagedObjectStore:managedObjectStore];
    [channelMapping addAttributeMappingsFromDictionary:@{
                                                        @"VideoCategoryId":             @"videoCategoryId",
                                                        @"VideoEntityId":   @"videoEntityId",
                                                        @"VideoName":    @"videoName",
                                                        @"VideoDescription": @"videoDescription",
                                                        @"VideoImageThumbnail":    @"videoImageThumbnail",
                                                        @"VideoPosterPath":    @"videoPosterPath",
                                                        @"VideoImagePath":    @"videoImagePath",
                                                        @"VideoImagePathLarge":    @"videoImagePathLarge",
                                                        @"VideoStreamUrl":    @"videoStreamUrl",
                                                        @"VideoStreamUrlLow":    @"videoStreamUrlLow",
                                                        @"VideoTotalViews":    @"videoTotalViews",
                                                        @"VideoAddedDate":    @"videoAddedDate",
                                                        @"VideoPackageId":    @"videoPackageId",
                                                        @"VideoRating":    @"videoRating",
                                                        @"IsVideoChannel":    @"isVideoChannel"}];
    channelMapping.identificationAttributes = @[ @"videoEntityId" ]; // Primary Key
    
    channelCategoriesResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:channelCategoriesMapping
                                                                                                      method:RKRequestMethodGET
                                                                                                 pathPattern:nil
                                                                                                     keyPath:@"Categories"
                                                                                                 statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    channelResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:channelMapping
                                                                                                   method:RKRequestMethodGET
                                                                                              pathPattern:nil
                                                                                                  keyPath:@"Videos"
                                                                                              statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    
    
    
    
    //////////////////////////////////// ******* Mapping for VOD AND VODCategories ******** ////////////////////////////////
    RKEntityMapping *VODCategoriesMapping = [RKEntityMapping mappingForEntityForName:@"VODCategories" inManagedObjectStore:managedObjectStore];
    [VODCategoriesMapping addAttributeMappingsFromDictionary:@{
                                                                   @"VideoCategoryId":             @"videoCategoryId",
                                                                   @"VideoParentCategoryId":             @"videoParentCategoryId",
                                                                   @"VideoCategoryName":   @"videoCategoryName",
                                                                   @"VideoCategoryImagePath":    @"videoCategoryImagePath",
                                                                   @"VideoCategoryImagePathLarge":    @"videoCategoryImagePathLarge",
                                                                   @"VideoCategoryImageThumbnail": @"videoCategoryImageThumbnail",
                                                                   @"VideoCategoryDescription": @"videoCategoryDescription"}];
    VODCategoriesMapping.identificationAttributes = @[ @"videoCategoryId" ]; // Primary Key
    
    RKEntityMapping *VODMapping = [RKEntityMapping mappingForEntityForName:@"VOD" inManagedObjectStore:managedObjectStore];
    [VODMapping addAttributeMappingsFromDictionary:@{
                                                         @"VideoCategoryId":             @"videoCategoryId",
                                                         @"VideoEntityId":   @"videoEntityId",
                                                         @"VideoName":    @"videoName",
                                                         @"VideoDescription": @"videoDescription",
                                                         @"VideoImageThumbnail":    @"videoImageThumbnail",
                                                         @"VideoPosterPath":    @"videoPosterPath",
                                                         @"VideoImagePath":    @"videoImagePath",
                                                         @"VideoImagePathLarge":    @"videoImagePathLarge",
                                                         @"VideoStreamUrl":    @"videoStreamUrl",
                                                         @"VideoStreamUrlLow":    @"videoStreamUrlLow",
                                                         @"VideoTotalViews":    @"videoTotalViews",
                                                         @"VideoAddedDate":    @"videoAddedDate",
                                                         @"VideoPackageId":    @"videoPackageId",
                                                         @"VideoRating":    @"videoRating",
                                                         @"IsVideoChannel":    @"isVideoChannel"}];
    VODMapping.identificationAttributes = @[ @"videoEntityId" ]; // Primary Key
    
    VODCategoriesResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:VODCategoriesMapping
                                                                                                             method:RKRequestMethodGET
                                                                                                        pathPattern:nil
                                                                                                            keyPath:@"Categories"
                                                                                                        statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    VODResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:VODMapping
                                                                                                    method:RKRequestMethodGET
                                                                                               pathPattern:nil
                                                                                                   keyPath:@"Videos"
                                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    
    
    
    
    //////////////////////////////////// ******* Mapping for Movie AND MovieCategories ******** ////////////////////////////////
    RKEntityMapping *MovieCategoriesMapping = [RKEntityMapping mappingForEntityForName:@"MovieCategories" inManagedObjectStore:managedObjectStore];
    [MovieCategoriesMapping addAttributeMappingsFromDictionary:@{
                                                               @"VideoCategoryId":             @"videoCategoryId",
                                                               @"VideoParentCategoryId":             @"videoParentCategoryId",
                                                               @"VideoCategoryName":   @"videoCategoryName",
                                                               @"VideoCategoryImagePath":    @"videoCategoryImagePath",
                                                               @"VideoCategoryImagePathLarge":    @"videoCategoryImagePathLarge",
                                                               @"VideoCategoryImageThumbnail":    @"videoCategoryImageThumbnail",
                                                               @"VideoCategoryDescription": @"videoCategoryDescription"}];
    MovieCategoriesMapping.identificationAttributes = @[ @"videoCategoryId" ]; // Primary Key
    
    RKEntityMapping *MovieMapping = [RKEntityMapping mappingForEntityForName:@"Movie" inManagedObjectStore:managedObjectStore];
    [MovieMapping addAttributeMappingsFromDictionary:@{
                                                     @"VideoCategoryId":             @"videoCategoryId",
                                                     @"VideoEntityId":   @"videoEntityId",
                                                     @"VideoName":    @"videoName",
                                                     @"VideoDescription": @"videoDescription",
                                                     @"VideoImageThumbnail":    @"videoImageThumbnail",
                                                     @"VideoPosterPath":    @"videoPosterPath",
                                                     @"VideoImagePath":    @"videoImagePath",
                                                     @"VideoImagePathLarge":    @"videoImagePathLarge",
                                                     @"VideoStreamUrl":    @"videoStreamUrl",
                                                     @"VideoStreamUrlLow":    @"videoStreamUrlLow",
                                                     @"VideoTotalViews":    @"videoTotalViews",
                                                     @"VideoAddedDate":    @"videoAddedDate",
                                                     @"VideoPackageId":    @"videoPackageId",
                                                     @"VideoRating":    @"videoRating",
                                                     @"IsVideoChannel":    @"isVideoChannel"}];
    // This will act as Primary Key and help to keep the record unique in table
    MovieMapping.identificationAttributes = @[ @"videoEntityId" ];
    
    movieCategoriesResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:MovieCategoriesMapping
                                                                                                         method:RKRequestMethodGET
                                                                                                    pathPattern:nil
                                                                                                        keyPath:@"Categories"
                                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    movieResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:MovieMapping
                                                                                                method:RKRequestMethodGET
                                                                                           pathPattern:nil
                                                                                               keyPath:@"Videos"
                                                                                           statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

-(void) setResponseDescriptor:(ResponseDescriptorTypes) currDes{
    
    // Jugaar: First remove all descriptors
    [objectManager removeResponseDescriptor:VODResponseDescriptor];
    [objectManager removeResponseDescriptor:VODCategoriesResponseDescriptor];
    [objectManager removeResponseDescriptor:movieResponseDescriptor];
    [objectManager removeResponseDescriptor:movieCategoriesResponseDescriptor];
    [objectManager removeResponseDescriptor:channelCategoriesResponseDescriptor];
    [objectManager removeResponseDescriptor:channelResponseDescriptor];
    [objectManager removeResponseDescriptor:homeCategoryResponseDescriptor];
    [objectManager removeResponseDescriptor:moreSectionVideosResponseDescriptor];
    [objectManager removeResponseDescriptor:relatedVideosResponseDescriptor];
    
    // Add the desired ones
    switch (currDes) {
        case CHANNEL_AND_CATEGORIES:
            [objectManager addResponseDescriptor:channelCategoriesResponseDescriptor];
            [objectManager addResponseDescriptor:channelResponseDescriptor];
            break;
        case VOD_AND_CATEGORIES:
            [objectManager addResponseDescriptor:VODCategoriesResponseDescriptor];
            [objectManager addResponseDescriptor:VODResponseDescriptor];
            break;
        case MOVIE_AND_CATEGORIES:
            [objectManager addResponseDescriptor:movieCategoriesResponseDescriptor];
            [objectManager addResponseDescriptor:movieResponseDescriptor];
            break;
        case HOME_DETAILS:
            [objectManager addResponseDescriptor:homeCategoryResponseDescriptor];
            break;
        case MORE_SECTION_VIDEOS:
            [objectManager addResponseDescriptor:moreSectionVideosResponseDescriptor];
            break;
        case RELATED_VIDEOS:
            [objectManager addResponseDescriptor:relatedVideosResponseDescriptor];
            break;
        default:
            break;
    }
}

#pragma mark -- Server-Fetch Methods
-(void) getAllHomeVideosAndDetails{

    // Set Response Descriptors
    [self setResponseDescriptor:HOME_DETAILS];
    
    // Show Activity Indicator
    [AFRKNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // getObjectsAtPath determines which API we are calling and in which Entity to save the data
    [[RKObjectManager sharedManager]
     getObjectsAtPath:g_getHomeVideosAndDetails
     parameters:nil
     success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         
         //JSON have been saved in core data by now
         NSArray *arr = [mappingResult array];
         // Send Notification and Hide Activity Indicator
         [[NSNotificationCenter defaultCenter] postNotificationName:AllHomeVideosAndDetailsAreDownloaded object:[NSNumber numberWithBool:1] userInfo:[NSDictionary dictionaryWithObject:arr forKey:@"data"]];
         
         [AFRKNetworkActivityIndicatorManager sharedManager].enabled = NO;
     }
     failure: ^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Load failed with error: %@", error);
         
         // Send Notification and Hide Activity Indicator
         [[NSNotificationCenter defaultCenter] postNotificationName:AllHomeVideosAndDetailsAreDownloaded object:[NSNumber numberWithBool:0] userInfo:[NSDictionary dictionaryWithObject:error.localizedDescription forKey:@"error"]];

         [AFRKNetworkActivityIndicatorManager sharedManager].enabled = NO;
     }
     ];
}

-(void) getAllChannelsAndChannelCategories{
    
    // Set Response Descriptors
    [self setResponseDescriptor:CHANNEL_AND_CATEGORIES];
    
    // Show Activity Indicator
    [AFRKNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // getObjectsAtPath determines which API we are calling and in which Entity to save the data
    [[RKObjectManager sharedManager]
     getObjectsAtPath:g_getAllChannelsWithCategories
     parameters:nil
     success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         
         //JSON have been saved in core data by now
//         NSArray *arr = [mappingResult array];
         
         // Send Notification and Hide Activity Indicator
         [[NSNotificationCenter defaultCenter] postNotificationName:AllChannelsAndChannelCategoriesAreDownloaded object:[NSNumber numberWithInteger:k_response_ok]];
         [AFRKNetworkActivityIndicatorManager sharedManager].enabled = NO;
     }
     failure: ^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Load failed with error: %@", error);
         
         if(error.code == k_territory_error)
         {
             // Send Notification and Hide Activity Indicator
             [[NSNotificationCenter defaultCenter] postNotificationName:AllChannelsAndChannelCategoriesAreDownloaded object:[NSNumber numberWithInteger:k_territory_error] userInfo:[NSDictionary dictionaryWithObject:error.localizedDescription forKey:@"error"]];
         }
         else
         {
             // Send Notification and Hide Activity Indicator
             [[NSNotificationCenter defaultCenter] postNotificationName:AllChannelsAndChannelCategoriesAreDownloaded object:[NSNumber numberWithInteger:k_response_fail] userInfo:[NSDictionary dictionaryWithObject:error.localizedDescription forKey:@"error"]];
         }
         
         [AFRKNetworkActivityIndicatorManager sharedManager].enabled = NO;
     }
     ];

}

-(void) getAllVODAndVODCategories{
    

    // Set Response Descriptors
    [self setResponseDescriptor:VOD_AND_CATEGORIES];
    
    // Show Activity Indicator
    [AFRKNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // getObjectsAtPath determines which API we are calling and in which Entity to save the data
    [[RKObjectManager sharedManager]
     getObjectsAtPath:g_getAllVODWithCategories
     parameters:nil
     success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         
         //JSON have been saved in core data by now
//        NSArray *arr = [mappingResult array];
         
         // Send Notification and Hide Activity Indicator
         [[NSNotificationCenter defaultCenter] postNotificationName:AllVODAndVODCategoriesAreDownloaded object:[NSNumber numberWithInteger:k_response_ok]];
         [AFRKNetworkActivityIndicatorManager sharedManager].enabled = NO;
     }
     failure: ^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Load failed with error: %@", error);
         
         if(error.code == k_territory_error)
         {
             // Send Notification and Hide Activity Indicator
             [[NSNotificationCenter defaultCenter] postNotificationName:AllVODAndVODCategoriesAreDownloaded object:[NSNumber numberWithInteger:k_territory_error] userInfo:[NSDictionary dictionaryWithObject:error.localizedDescription forKey:@"error"]];
         }
         else
         {
             // Send Notification and Hide Activity Indicator
             [[NSNotificationCenter defaultCenter] postNotificationName:AllVODAndVODCategoriesAreDownloaded object:[NSNumber numberWithBool:k_response_fail] userInfo:[NSDictionary dictionaryWithObject:error.localizedDescription forKey:@"error"]];
         }
         
         
         [AFRKNetworkActivityIndicatorManager sharedManager].enabled = NO;
     }
     ];
    
}

-(void) getAllMoviesAndMovieCategories{
   

    // Set Response Descriptors
    [self setResponseDescriptor:MOVIE_AND_CATEGORIES];
    
    // Show Activity Indicator
    [AFRKNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // getObjectsAtPath determines which API we are calling and in which Entity to save the data
    [[RKObjectManager sharedManager]
     getObjectsAtPath:g_getAllMoviesWithCategories
     parameters:nil
     success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         
         //JSON have been saved in core data by now
//        NSArray *arr = [mappingResult array];
         
         // Send Notification and Hide Activity Indicator
         [[NSNotificationCenter defaultCenter] postNotificationName:AllMoviesAndMoviesCategoriesAreDownloaded object:[NSNumber numberWithBool:k_response_ok]];
         [AFRKNetworkActivityIndicatorManager sharedManager].enabled = NO;
     }
     failure: ^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Load failed with error: %@", error);
         
         if(error.code == k_territory_error)
         {
             // Send Notification and Hide Activity Indicator
             [[NSNotificationCenter defaultCenter] postNotificationName:AllMoviesAndMoviesCategoriesAreDownloaded object:[NSNumber numberWithInteger:k_territory_error] userInfo:[NSDictionary dictionaryWithObject:error.localizedDescription forKey:@"error"]];
         }
         else
         {
             // Send Notification and Hide Activity Indicator
             [[NSNotificationCenter defaultCenter] postNotificationName:AllMoviesAndMoviesCategoriesAreDownloaded object:[NSNumber numberWithBool:k_response_fail] userInfo:[NSDictionary dictionaryWithObject:error.localizedDescription forKey:@"error"]];
         }
         
         [AFRKNetworkActivityIndicatorManager sharedManager].enabled = NO;
     }
     ];
}

-(void) getMoreSectionVideos:(NSString*) url{
    

    // Set Response Descriptors
    [self setResponseDescriptor:MORE_SECTION_VIDEOS];
    
    // Show Activity Indicator
    [AFRKNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // getObjectsAtPath determines which API we are calling and in which Entity to save the data
    [[RKObjectManager sharedManager]
     getObjectsAtPath:url
     parameters:nil
     success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         
         //JSON have been saved in core data by now
         NSArray *arr = [mappingResult array];
         // Send Notification and Hide Activity Indicator
         [[NSNotificationCenter defaultCenter] postNotificationName:MoreSectionVideosAreDownloaded object:[NSNumber numberWithBool:1] userInfo:[NSDictionary dictionaryWithObject:arr forKey:@"data"]];
         
         [AFRKNetworkActivityIndicatorManager sharedManager].enabled = NO;
     }
     failure: ^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Load failed with error: %@", error);
         
         // Send Notification and Hide Activity Indicator
         [[NSNotificationCenter defaultCenter] postNotificationName:MoreSectionVideosAreDownloaded object:[NSNumber numberWithBool:0] userInfo:[NSDictionary dictionaryWithObject:error.localizedDescription forKey:@"error"]];
         
         [AFRKNetworkActivityIndicatorManager sharedManager].enabled = NO;
     }
     ];
}

-(void) getRelatedVideos:(NSString*) url{
    
    // Set Response Descriptors
    [self setResponseDescriptor:RELATED_VIDEOS];
    
    // Show Activity Indicator
    [AFRKNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // getObjectsAtPath determines which API we are calling and in which Entity to save the data
    [[RKObjectManager sharedManager]
     getObjectsAtPath:url
     parameters:nil
     success: ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         
         //JSON have been saved in core data by now
         NSArray *arr = [mappingResult array];
         // Send Notification and Hide Activity Indicator
         [[NSNotificationCenter defaultCenter] postNotificationName:RelatedVideosAreDownloaded object:[NSNumber numberWithBool:1] userInfo:[NSDictionary dictionaryWithObject:arr forKey:@"data"]];
         
         [AFRKNetworkActivityIndicatorManager sharedManager].enabled = NO;
     }
     failure: ^(RKObjectRequestOperation *operation, NSError *error) {
         RKLogError(@"Load failed with error: %@", error);
         
         // Send Notification and Hide Activity Indicator
         [[NSNotificationCenter defaultCenter] postNotificationName:RelatedVideosAreDownloaded object:[NSNumber numberWithBool:0] userInfo:[NSDictionary dictionaryWithObject:error.localizedDescription forKey:@"error"]];
         
         [AFRKNetworkActivityIndicatorManager sharedManager].enabled = NO;
     }
     ];
}

#pragma mark -- DB-Fetch Methods
-(NSMutableArray*) getCategories:(NSString*) entityName predicate:(NSPredicate*) predicate{
    NSMutableArray *arrCategories;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoCategoryId"
                                                                   ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    if(predicate)
        fetchRequest.predicate = predicate;
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    arrCategories = [[NSMutableArray alloc] initWithArray:[context executeFetchRequest:fetchRequest error:&error]];
    return arrCategories;
}

-(NSMutableArray*) getVideos:(NSString*) entityName predicate:(NSPredicate*) predicate{
    
    NSSortDescriptor *sortDescriptor;
    
    if([entityName isEqualToString:k_entity_movie]){
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoAddedDate"
                                                                       ascending:YES];
    }
    else{
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"videoTotalViews"
                                                                       ascending:NO];
    }
    NSArray *sortDescriptors = @[sortDescriptor];
    
    NSMutableArray *arrVideos;
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    if(predicate)
        fetchRequest.predicate = predicate;
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error = nil;
    arrVideos = [[NSMutableArray alloc] initWithArray:[context executeFetchRequest:fetchRequest error:&error]];
    return arrVideos;
}

-(void) removeDatabase:(NSString *)storePath{
    
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:storePath]){
        BOOL res = [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:storePath] error:&error];
        if(res)
        NSLog(@"deleted");
        else
        NSLog(@"not deleted");
    }
    
    NSString *shmPath = [NSString stringWithFormat:@"%@-shm",storePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:shmPath]){
        BOOL res = [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:shmPath] error:&error];
        if(res)
        NSLog(@"deleted");
        else
        NSLog(@"not deleted");
    }
    
    NSString *walPath = [NSString stringWithFormat:@"%@-wal",storePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:walPath]){
        BOOL res = [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:walPath] error:&error];
        if(res)
        NSLog(@"deleted");
        else
        NSLog(@"not deleted");
    }
    
    setChannelDataStatus(k_NotDownloaded);
    setMoviesDataStatus(k_NotDownloaded);
    setVODDataStatus(k_NotDownloaded);
    
    setAppDatabaseVersion(g_db_version);
}


@end
