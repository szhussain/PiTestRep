//
//  MainCollectionViewController.m
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/1/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import "MainCollectionViewController.h"
#import "SWRevealViewController.h"
#import "UIImageView+WebCache.h"
#import "RestKitManager.h"
#import "Constants.h"
#import "Channel+CoreDataClass.h"
#import "PlayCollectionViewController.h"
#import "Utilities.h"
#import "Movie+CoreDataClass.h"
#import "MovieCategories+CoreDataClass.h"
#import "MoreMediaTableViewController.h"
#import "VODCategories+CoreDataClass.h"
#import "VOD+CoreDataClass.h"
#import "AMTumblrHud.h"
#import "Category.h"
#import "Section.h"
#import "Video.h"
#import "ImageHeader.h"
#import "SVHeader.h"
#import "MediaDetailCell.h"
#import <HTHorizontalSelectionList/HTHorizontalSelectionList.h>
#import <AFNetworkReachabilityManager.h>

@interface MainCollectionViewController ()<HTHorizontalSelectionListDataSource, HTHorizontalSelectionListDelegate>{
    
    NSMutableArray *arrChannelCategories;
    NSMutableArray* arrChannels;
    NSMutableArray* arrMovies;
    NSMutableArray* arrMovieCategories;
    NSMutableArray* arrVODsubCategories;
    NSMutableArray* arrVODsCategories;
    NSInteger prevCat;
    NSInteger currCat;
    NSInteger selectedIndex;
    AMTumblrHud *loadingView;
    BOOL isLoading;
    HTHorizontalSelectionList *selectionList;
    ImageHeader *imgHeaderView;
    SVHeader *svHeaderView;
    UIRefreshControl *refreshControl;
    BOOL isDataDownloaded;
    UIView *closeMenuView;
    BOOL isMenuShowing;
}

@end

@implementation MainCollectionViewController

static NSString * const kImageHeader = @"ImageHeader";
static NSString * const kSVHeader = @"SVHeader";
static NSString * const kMediaDetailCell = @"MediaDetailCell";

- (void) viewWillAppear:(BOOL)animated{
    
    // jugar for landscape orientation
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    // Register Notification to notify that data is done downloading
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allChannelsAndChannelCategoriesDownloaded:) name:AllChannelsAndChannelCategoriesAreDownloaded object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allMoviesAndMoviesCategoriesDownloaded:) name:AllMoviesAndMoviesCategoriesAreDownloaded object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allVODAndVODCategoriesDownloaded:) name:AllVODAndVODCategoriesAreDownloaded object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuIsShowing) name:MenuIsShowing object:nil];
}

- (void) viewWillDisappear:(BOOL)animated{
    
    // unRegister notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AllChannelsAndChannelCategoriesAreDownloaded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AllMoviesAndMoviesCategoriesAreDownloaded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AllVODAndVODCategoriesAreDownloaded object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MenuIsShowing object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    prevCat = 0;
    currCat = 0;
    isLoading = NO;
    isDataDownloaded = NO;
    
    selectionList = [[HTHorizontalSelectionList alloc] init];
    selectionList.backgroundColor = [UIColor clearColor];
    [selectionList setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [selectionList setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    selectionList.delegate = self;
    selectionList.dataSource = self;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:128.0f/255.0f green:170.0f/255.0f blue:85.0f/255.0f alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    loadingView = [[AMTumblrHud alloc] initWithFrame:[UIScreen mainScreen].bounds];
    loadingView.hudColor = [UIColor colorWithRed:128.0f/255.0f green:170.0f/255.0f blue:85.0f/255.0f alpha:1];
    loadingView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.5];
    
//    SWRevealViewController *revealViewController = self.revealViewController;
//    if ( revealViewController )
    if(self.revealViewController)
    {
        // increasing the -ve value reduce the width of the side Menu
        self.revealViewController.rearViewRevealWidth = -50;
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    [self loadData];
    
    self.collectionView.backgroundColor = [UIColor colorWithRed:228.0f/255.0f green:228.0f/255.0f blue:228.0f/255.0f alpha:1];
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionHeadersPinToVisibleBounds = YES;
    
    [self.collectionView registerNib:[ImageHeader nib] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kImageHeader];
    
    [self.collectionView registerNib:[SVHeader nib] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSVHeader];
    
    [self.collectionView registerNib:[MediaDetailCell nib] forCellWithReuseIdentifier:kMediaDetailCell];
    
    // add Pull to Refresh
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    self.collectionView.alwaysBounceVertical = YES;
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if(AFNetworkReachabilityStatusNotReachable != status){
            // available
            [self loadData];
        }
    }];
    
////    // keep in Portrait
//    restrictRotation(YES);
    
    closeMenuView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UITapGestureRecognizer *singleTapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(menuIsShowing)];
    [closeMenuView addGestureRecognizer:singleTapGesture];
}

- (BOOL)canAutoRotate
{
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshData{
    
    if(connected())
       [self reloadData];
    else
    {
        showAlert(self, error_Internet);
        [refreshControl endRefreshing];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"PushPlayCVC"])
    {
        NSIndexPath *path = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        
        PlayCollectionViewController *vc = (PlayCollectionViewController*) segue.destinationViewController;
        if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
        {
            vc.channel = (Channel*) [arrChannels objectAtIndex:path.item];
            vc.mediaType = k_Channels;
            for(int i=0; i<[arrChannelCategories count]; i++)
            {
                ChannelCategories *cat = (ChannelCategories*) [arrChannelCategories objectAtIndex:i];
                if([[cat.videoCategoryId stringValue] isEqualToString:[vc.channel.videoCategoryId stringValue]])
                    vc.channelCategory = cat;
            }
            self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:vc.channelCategory.videoCategoryName style:UIBarButtonItemStylePlain target:nil action:nil];
        }
        
        if([self.mediaType isEqualToString:k_Movies])
        {
            vc.movie = (Movie*) [arrMovies objectAtIndex:path.item];
            vc.mediaType = k_Movies;
            for(int i=0; i<[arrMovieCategories count]; i++)
            {
                MovieCategories *cat = (MovieCategories*) [arrMovieCategories objectAtIndex:i];
                if([[cat.videoCategoryId stringValue] isEqualToString:[vc.movie.videoCategoryId stringValue]])
                    vc.movieCategory = cat;
            }
            self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:vc.movieCategory.videoCategoryName style:UIBarButtonItemStylePlain target:nil action:nil];
        }
    }
    else if ([segue.identifier isEqualToString:@"ShowMediaTVC"])
    {
        NSIndexPath *path = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
        
        MoreMediaTableViewController *vc = (MoreMediaTableViewController*) segue.destinationViewController;
        VODCategories *ch = (VODCategories*) [arrVODsubCategories objectAtIndex:path.item];
        vc.vodCategory = ch;
        vc.mediaType = k_VOD;
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:vc.vodCategory.videoCategoryName style:UIBarButtonItemStylePlain target:nil action:nil];
    }
}

#pragma mark --UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
    {
        if([arrChannels count]>0)
            return 2;
        else
            return 0;
    }
    else if([self.mediaType isEqualToString:k_Movies])
    {
        if([arrMovies count]>0)
            return 2;
        else
            return 0;
    }
    else if([self.mediaType isEqualToString:k_VOD])
    {
        if([arrVODsCategories count]>0)
            return 2;
        else
            return 0;
    }
    else
        return 0;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if(section == 0)
        return 0;
    else
    {
        if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
            return [arrChannels count];
        else if([self.mediaType isEqualToString:k_Movies])
            return [arrMovies count];
        else if([self.mediaType isEqualToString:k_VOD])
            return [arrVODsubCategories count];
        else
            return 0;
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return CGSizeMake(320, 200);
    else
        return CGSizeMake(320, 45);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((self.collectionView.frame.size.width-30)/2, (self.collectionView.frame.size.width-30)/2);
//    return CGSizeMake((self.collectionView.frame.size.width-30)/2, 180);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if(section == 0)
        return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
    else
        return UIEdgeInsetsMake(10, 10, 10, 10);
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if (kind == UICollectionElementKindSectionHeader)
        {
            NSString *encodedURL;
            if(!imgHeaderView)
                imgHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kImageHeader forIndexPath:indexPath];
            
            if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
            {
                if([arrChannelCategories count]>0)
                {
                    ChannelCategories *cat = (ChannelCategories*)[arrChannelCategories objectAtIndex:currCat];
                    if(cat.videoCategoryImagePath != NULL)
                        encodedURL = URLEncodedString_ch(cat.videoCategoryImagePath);
                }
            }
            else if([self.mediaType isEqualToString:k_Movies])
            {
                if([arrMovieCategories count]>0)
                {
                    MovieCategories *cat = (MovieCategories*)[arrMovieCategories objectAtIndex:currCat];
                    if(cat.videoCategoryImageThumbnail != NULL)
                        encodedURL = URLEncodedString_ch(cat.videoCategoryImageThumbnail);
                }
            }
            else  // k_VOD
            {
                if([arrVODsCategories count]>0)
                {
                    VODCategories *cat = (VODCategories*)[arrVODsCategories objectAtIndex:currCat];
                    if(cat.videoCategoryImageThumbnail != NULL)
                        encodedURL = URLEncodedString_ch(cat.videoCategoryImageThumbnail);
                }
            }
            
            [imgHeaderView.imgView sd_setImageWithURL:[NSURL URLWithString:encodedURL]
                                     placeholderImage:nil];
        }
        return imgHeaderView;
    }
    else
    {
        if (kind == UICollectionElementKindSectionHeader)
        {
            if(!svHeaderView)
                svHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSVHeader forIndexPath:indexPath];
            
            selectionList.frame = svHeaderView.bounds;
            [svHeaderView.svCategories addSubview:selectionList];
        }
        return svHeaderView;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    MediaDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMediaDetailCell forIndexPath:indexPath];
    
    if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
    {
        Channel *video = (Channel*)[arrChannels objectAtIndex:indexPath.item];
        // Here we use the new provided sd_setImageWithURL: method to load the web image
        [cell.imgViewMedia sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(video.videoImagePath)]
                             placeholderImage:nil];
        cell.lblTitle.text = video.videoName;
        cell.lblDesciption.text = video.videoDescription;
        
        UIImageView *liveImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"liveIcon.png"]];
        liveImgView.frame = CGRectMake(cell.frame.size.width-40, 0, 40, 20);
        [cell.contentView addSubview:liveImgView];
        
        cell.imgLive.hidden = NO;
    }
    
    if([self.mediaType isEqualToString:k_Movies])
    {
        Movie *video = (Movie*)[arrMovies objectAtIndex:indexPath.item];
        [cell.imgViewMedia sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(video.videoImagePath)]
                             placeholderImage:nil];
        cell.lblTitle.text = video.videoName;
        cell.lblDesciption.text = video.videoDescription;
        
        cell.imgLive.hidden = YES;
    }
    
    if([self.mediaType isEqualToString:k_VOD])
    {
        VODCategories *videoSubCategory = (VODCategories*)[arrVODsubCategories objectAtIndex:indexPath.item];
        [cell.imgViewMedia sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(videoSubCategory.videoCategoryImagePath)]
                             placeholderImage:nil];
        
        cell.lblTitle.text = videoSubCategory.videoCategoryName;
        cell.lblDesciption.text = videoSubCategory.videoCategoryDescription;
        
        cell.imgLive.hidden = YES;
    }
    
    UIImageView *playImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playIcon.png"]];
    playImgView.frame = CGRectMake(5, cell.frame.size.height/2-15, 25, 25);
    [cell.contentView addSubview:playImgView];
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius = 10;
    cell.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:cell.layer.cornerRadius] CGPath];
    
    return cell;
}


#pragma mark --UICollectionViewDelegate

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if([self.mediaType isEqualToString:k_Channels] || [self.mediaType isEqualToString:k_Movies] || self.mediaType == NULL)
        [self performSegueWithIdentifier:@"PushPlayCVC" sender:nil];
    else if([self.mediaType isEqualToString:k_VOD])
        [self performSegueWithIdentifier:@"ShowMediaTVC" sender:nil];
    
}

#pragma mark - HTHorizontalSelectionListDataSource Protocol Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    
    if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
    {
        return [arrChannelCategories count];
    }
    else if([self.mediaType isEqualToString:k_Movies])
    {
        return [arrMovieCategories count];
    }
    else // k_VOD
    {
        return [arrVODsCategories count];
    }
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    
    if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
    {
        ChannelCategories *catObj = (ChannelCategories*) [arrChannelCategories objectAtIndex:index];
        return catObj.videoCategoryName;
    }
    else if([self.mediaType isEqualToString:k_Movies])
    {
        MovieCategories *catObj = (MovieCategories*) [arrMovieCategories objectAtIndex:index];
        return catObj.videoCategoryName;
    }
    else // k_VOD
    {
        VODCategories *catObj = (VODCategories*) [arrVODsCategories objectAtIndex:index];
        return catObj.videoCategoryName;
    }
}

#pragma mark - HTHorizontalSelectionListDelegate Protocol Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    
    if(index != currCat)
    {
        prevCat = currCat;
        currCat = index;
        
        if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
            [self fetchChannelDataFromDB:currCat];
        else if([self.mediaType isEqualToString:k_Movies])
            [self fetchMoviesDataFromDB:currCat];
        else // k_VOD
            [self fetchVODsDataFromDB:currCat];
        
    }
}

#pragma mark --Funcs

-(void) loadData{
    
    if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
    {
        if([getChannelDataStatus() isEqualToString:k_Downloaded])
            [self fetchChannelDataFromDB:0];
        else
            [self fetchChannelDataFromServer];
    }
    else if([self.mediaType isEqualToString:k_Movies])
    {
        if([getMoviesDataStatus() isEqualToString:k_Downloaded])
            [self fetchMoviesDataFromDB:0];
        else
            [self fetchMoviesDataFromServer];
    }
    else if([self.mediaType isEqualToString:k_VOD])
    {
        if([getVODDataStatus() isEqualToString:k_Downloaded])
            [self fetchVODsDataFromDB:0];
        else
            [self fetchVODDataFromServer];
    }
}

-(void) fetchChannelDataFromDB:(NSInteger)categoryIndex{
    arrChannelCategories = [RestKitManager getCategories:k_entity_channelcategories predicate:nil];
    NSPredicate *predicate = nil;
    
    ChannelCategories *objCat = [arrChannelCategories objectAtIndex:categoryIndex];
    if(categoryIndex != 0) // because 0 is for ALL
        predicate = [NSPredicate predicateWithFormat:@"videoCategoryId = %@",objCat.videoCategoryId];
    
    [arrChannels removeAllObjects];
    arrChannels = [RestKitManager getVideos:k_entity_channel predicate:predicate];
    if([arrChannels count]>0)
        isDataDownloaded = YES;
    [selectionList reloadData];
    [self.collectionView reloadData];
    
    [refreshControl endRefreshing];
}

-(void) fetchMoviesDataFromDB:(NSInteger)categoryIndex{
    arrMovieCategories = [RestKitManager getCategories:k_entity_moviecategories predicate:nil];
    NSPredicate *predicate = nil;
    
    MovieCategories *objCat = [arrMovieCategories objectAtIndex:categoryIndex];
    predicate = [NSPredicate predicateWithFormat:@"videoCategoryId = %@",objCat.videoCategoryId];
        
    [arrMovies removeAllObjects];
    arrMovies = [RestKitManager getVideos:k_entity_movie predicate:predicate];
    if([arrMovies count]>0)
        isDataDownloaded = YES;
    [selectionList reloadData];
    [self.collectionView reloadData];
    
    [refreshControl endRefreshing];
}

-(void) fetchVODsDataFromDB:(NSInteger)categoryIndex{
    arrVODsCategories = [RestKitManager getCategories:k_entity_vodcategories predicate:[NSPredicate predicateWithFormat:@"videoParentCategoryId = %li",k_VideoParentCategoryId]];
    NSPredicate *predicate = nil;
    
    VODCategories *objCat = [arrVODsCategories objectAtIndex:categoryIndex];
    predicate = [NSPredicate predicateWithFormat:@"videoParentCategoryId = %@",objCat.videoCategoryId];
    
    [arrVODsubCategories removeAllObjects];
    arrVODsubCategories = [RestKitManager getCategories:k_entity_vodcategories predicate:predicate];
    if([arrVODsubCategories count]>0)
        isDataDownloaded = YES;
    [selectionList reloadData];
    [self.collectionView reloadData];
    
    [refreshControl endRefreshing];
}


#pragma mark Fetch-Data
-(void) fetchChannelDataFromServer{
    
    if(!isLoading)
        [self showLoadingView];

    [RestKitManager getAllChannelsAndChannelCategories];
}

-(void) fetchMoviesDataFromServer{
    
    if(!isLoading)
        [self showLoadingView];
    
    [RestKitManager getAllMoviesAndMovieCategories];
}

-(void) fetchVODDataFromServer{
    
    if(!isLoading)
        [self showLoadingView];
    
    [RestKitManager getAllVODAndVODCategories];
}

#pragma mark Data-CallBack
-(void) allChannelsAndChannelCategoriesDownloaded:(NSNotification *)notification{
    
    if(isLoading)
        [self hideLoadingView];
    
    if([[notification object] integerValue] == k_response_ok)
    {
        [self fetchChannelDataFromDB:0];
        setChannelDataStatus(k_Downloaded);
    }
    else
    {
        showAlert(self, error_msg);
    }
}


-(void) allVODAndVODCategoriesDownloaded:(NSNotification *)notification{
    
    if(isLoading)
        [self hideLoadingView];
    
    if([[notification object] integerValue] == k_response_ok)
    {
        [self fetchVODsDataFromDB:0];
        setVODDataStatus(k_Downloaded);
    }
    else if([[notification object] integerValue] == k_response_fail)
    {
        showAlert(self, error_msg);
    }
    else
    {
        showAlert(self, territory_error_msg);
//        UIImageView *vu = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tapmadIconGreen.png"]];
//        [self.collectionView addSubview:vu];
    }
}


-(void) allMoviesAndMoviesCategoriesDownloaded:(NSNotification *)notification{
    
    if(isLoading)
        [self hideLoadingView];
    
    if([[notification object] integerValue] == k_response_ok)
    {
        [self fetchMoviesDataFromDB:0];
        setMoviesDataStatus(k_Downloaded);
    }
    else if([[notification object] integerValue] == k_response_fail)
    {
        showAlert(self, error_msg);
    }
    else
    {
        showAlert(self, territory_error_msg);
    }
}

-(void) showLoadingView{
    
    isLoading = YES;
    [self.navigationController.view addSubview:loadingView];
    [self.navigationController.view setUserInteractionEnabled:NO];
    [loadingView showAnimated:YES];
}

-(void) hideLoadingView{
    
    isLoading = NO;
    [self.navigationController.view setUserInteractionEnabled:YES];
    [loadingView hide];
}

-(void) reloadData{
    
    if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
    {
            [self fetchChannelDataFromServer];
    }
    else if([self.mediaType isEqualToString:k_Movies])
    {
            [self fetchMoviesDataFromServer];
    }
    else if([self.mediaType isEqualToString:k_VOD])
    {
            [self fetchVODDataFromServer];
    }
    
}

-(void) menuIsShowing{
    
    if(!isMenuShowing)
    {
        isMenuShowing = YES;
        [self.navigationController.view addSubview:closeMenuView];
    }
    else
    {
        isMenuShowing = NO;
        [closeMenuView removeFromSuperview];
        [self.revealViewController revealToggleAnimated:YES];
    }
}


@end
