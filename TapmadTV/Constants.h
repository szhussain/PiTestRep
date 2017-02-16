//
//  Constants.h
//  TapmadTV
//
//  Created by Apple MacBook Pro on 11/29/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define g_app_version                       @"Version 0.0.1"
#define g_app_name                          @"TapmadTV"

// changing this version will drop all tables
#define g_db_version                        1

#define g_CallUs    @"Call us at: +92(021)35302095"
// BASE URL for 'TEST' and 'LIVE'
#define g_base_url                          @"http://api.tapmad.com"

// User token (this token will be different for every user)
//#define k_UserToken @"userToken=a6f452ec3293d7fb72c5b677257b20ectmp"

// Other API URLs
#define g_getHomeVideosAndDetails           g_base_url"/api/getSectionAndDetail/V1/en/ios"
#define g_getAllChannelsWithCategories      g_base_url"/api/getAllChannelsWithCategories/V1/en/ios"
#define g_getAllVODWithCategories      g_base_url"/api/getAllVODsWithCategories/V1/en/ios"
#define g_getAllMoviesWithCategories      g_base_url"/api/getAllMoviesWithCategories/V1/en/ios"

///{Version}/{Language}/{Platform}/    {IsChannel}/{PackageId}/{ChannelOrVODId}/   {Gender}/{Age}/{AdType}
// 3 parameters at the end are hard coded for now
// Parameters: IsChannel, PackageId, ChannelOrVODId
#define g_getVODOrChannelURLWithAd            g_base_url"/api/getVODOrChannelURLWithAd/V1/en/ios/%@/%@/%@/All/15/1"


// Parameters: SectionId
//#define g_getMoreSectionVideos            g_base_url"/api/getSectionMoreInfo/V1/en/android/%@/0"
#define g_getMoreSectionVideos            g_base_url"/api/getSectionMoreInfo/V1/en/ios/%@/0"

//#define g_getRelatedChannelsOrVODs            g_base_url"/api/getRelatedChannelsOrVODs/V1/en/android/%@/%@"
#define g_getRelatedChannelsOrVODs            g_base_url"/api/getRelatedChannelsOrVODs/V1/en/ios/%@/%@"

#define g_checkAndRegisterTempUser            g_base_url"/api/checkAndRegisterTempUser/V1/en/ios/%@/%@"

///saveOrUpdateDeviceInfo/{Version}/{Language}/{Platform}/{DeviceID}/{DeviceMAC}/{DeviceToken}/{DeviceBrand}/{DeviceName}/{DeviceModel}/{DeviceManufacturer}/{DeviceProduct}
#define g_saveOrUpdateDeviceInfo            g_base_url"/api/saveOrUpdateDeviceInfo/V1/en/ios/%@/%@/%@/iOS/iOS/iOS/Apple/iOS"

// API response codes
#define k_response_ok                   1
#define k_response_fail                   0
#define k_territory_error   1001

// Notifications Name
#define AllHomeVideosAndDetailsAreDownloaded @"AllHomeVideosAndDetailsAreDownloaded"
#define AllChannelsAndChannelCategoriesAreDownloaded @"AllChannelsAndChannelCategoriesAreDownloaded"
#define AllVODAndVODCategoriesAreDownloaded @"AllVODAndVODCategoriesAreDownloaded"
#define AllMoviesAndMoviesCategoriesAreDownloaded @"AllMoviesAndMoviesCategoriesAreDownloaded"
#define MoreSectionVideosAreDownloaded @"MoreSectionVideosAreDownloaded"
#define RelatedVideosAreDownloaded @"RelatedVideosAreDownloaded"
#define MenuIsShowing @"MenuIsShowing"

#define ShowLoadingView @"ShowLoadingView"
#define HideLoadingView @"HideLoadingView"


// Alert View
#define kCustomAlert(title,msg) [[[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show]

// Data download status
#define k_NotDownloaded @"0"
#define k_Downloaded @"1"
#define k_LiveChannelDataDownloadStatus @"LiveChannelDataDownloadStatus"
#define k_VODDataDownloadStatus @"VODDataDownloadStatus"
#define k_MoviesDataDownloadStatus @"MoviesDataDownloadStatus"
#define k_HomeDataDownloadStatus @"HomeDataDownloadStatus"
#define k_HomeData @"HomeData"
#define k_DB_Version @"DBVersion"
#define k_DB_Path @"DBPath"

#define k_UserToken @"UserToken"

// ViewControllers

#define k_CurrentViewControllerName @"CurrentViewControllerName"
#define k_SelectedViewControllerName @"SelectedViewControllerName"

//#define k_MainCVC @"MainCollectionViewController"
#define k_HomeCVC @"HomeCollectionViewController"
#define k_MoviesCVC @"MoviesCollectionViewController"
#define k_ChannelsCVC @"LiveChannelsCollectionViewController"
#define k_VODsCVC @"VODCollectionViewController"
#define k_AboutTVC @"AboutTableViewController"

// Media Type
#define k_Channels @"Channels"
#define k_Movies @"Movies"
#define k_VOD @"VOD"
#define k_Home @"Home"
#define k_PlayCVC @"PlayCVC"

// Entity names
#define k_entity_channel @"Channel"
#define k_entity_channelcategories @"ChannelCategories"

#define k_entity_movie @"Movie"
#define k_entity_moviecategories @"MovieCategories"

#define k_entity_vod @"VOD"
#define k_entity_vodcategories @"VODCategories"

// Facebook Keys
#define k_userId @"userId"
#define k_userEmail @"userEmail"
#define k_userName @"userName"
#define k_userImageURL @"userImageURL"


// VOD Category ID
#define k_VideoParentCategoryId 0
// Font
#define k_Font_Regular [UIFont fontWithName:@"System" size:14];

// Errors
#define error_Internet @"Internet connection is not available."
#define error_msg @"An error occurred, please try again."
#define territory_error_msg @"Contents are not available for viewing in your region."

// Google Analytics Screen Name
#define ga_homeScreen @"Home Screen"
#define ga_aboutScreen @"About Screen"
#define ga_moviesScreen @"Movies Screen"
#define ga_vodScreen @"VOD Screen"
#define ga_channelsScreen @"Channels Screen"

#define ga_detailScreen            @"%@ Detail Screen"
#define ga_moreVideosScreen          @"More %@ Videos Screen"
#define ga_playScreen               @"%@ Play Screen"

#endif /* Constants_h */
