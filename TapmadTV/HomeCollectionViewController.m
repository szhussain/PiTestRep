//
//  HomeCollectionViewController.m
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/22/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import "HomeCollectionViewController.h"
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
#import "SectionHeader.h"
#import <HTHorizontalSelectionList/HTHorizontalSelectionList.h>
#import "MediaDetailCell.h"
#import "EmptyMediaCell.h"
#import <AFNetworkReachabilityManager.h>
#import "AppDelegate.h"

@interface HomeCollectionViewController ()<HTHorizontalSelectionListDataSource, HTHorizontalSelectionListDelegate>{
    ImageHeader *imgHeaderView;
    SVHeader *svHeaderView;
    NSMutableArray* arrCategoriesData;
    NSMutableArray *arrItems;
    NSInteger prevCat;
    NSInteger currCat;
    NSInteger selectedIndex;
    AMTumblrHud *loadingView;
    BOOL isLoading;
    HTHorizontalSelectionList *selectionList;
    UIView *closeMenuView;
    BOOL isMenuShowing;
    UIRefreshControl *refreshControl;
    BOOL isDataDownloaded;
}

@end

@implementation HomeCollectionViewController

static NSString * const kImageHeader = @"ImageHeader";
static NSString * const kSVHeader = @"SVHeader";
static NSString * const kSectionHeader = @"SectionHeader";
static NSString * const kMediaDetailCell = @"MediaDetailCell";
static NSString * const kEmptyMediaCell = @"EmptyMediaCell";

- (void) viewWillAppear:(BOOL)animated{
    
    // jugar for landscape orientation
//    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
//    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    // Register Notification to notify that data is done downloading
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(allHomeVideosAndDetailsDownloaded:) name:AllHomeVideosAndDetailsAreDownloaded object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuIsShowing) name:MenuIsShowing object:nil];
    
//    // set ViewController Name
//    setViewControllerNameForKey(k_HomeCVC, k_CurrentViewControllerName);
//    
//    // set google analytics screen name
//    sendGoogleAnalyticsScreenName(ga_homeScreen);
}

- (void) viewWillDisappear:(BOOL)animated{
    // unRegister notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AllHomeVideosAndDetailsAreDownloaded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MenuIsShowing object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    prevCat = 0;
    currCat = 0;
    isLoading = NO;
    isMenuShowing = NO;
    isDataDownloaded = NO;
    
    selectionList = [[HTHorizontalSelectionList alloc] init];
    selectionList.backgroundColor = [UIColor clearColor];
    [selectionList setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [selectionList setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    selectionList.delegate = self;
    selectionList.dataSource = self;
    
    arrCategoriesData = [[NSMutableArray alloc] initWithCapacity:0];
    arrItems = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:128.0f/255.0f green:170.0f/255.0f blue:85.0f/255.0f alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    loadingView = [[AMTumblrHud alloc] initWithFrame:[UIScreen mainScreen].bounds];
    loadingView.hudColor = [UIColor colorWithRed:128.0f/255.0f green:170.0f/255.0f blue:85.0f/255.0f alpha:1];
    loadingView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:0.5];
    
//    SWRevealViewController *revealViewController = self.revealViewController;
    if ( self.revealViewController )
    {
        // increasing the -ve value reduce the width of the side Menu
        self.revealViewController.rearViewRevealWidth = -50;
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    self.collectionView.backgroundColor = [UIColor colorWithRed:228.0f/255.0f green:228.0f/255.0f blue:228.0f/255.0f alpha:1];
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionHeadersPinToVisibleBounds = YES;
    
    [self.collectionView registerNib:[ImageHeader nib] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kImageHeader];
    
    [self.collectionView registerNib:[SVHeader nib] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSVHeader];
    
    [self.collectionView registerNib:[SectionHeader nib] forCellWithReuseIdentifier:kSectionHeader];
    
    [self.collectionView registerNib:[MediaDetailCell nib] forCellWithReuseIdentifier:kMediaDetailCell];
    
    [self.collectionView registerNib:[EmptyMediaCell nib] forCellWithReuseIdentifier:kEmptyMediaCell];
    
    [self loadData];
    
    closeMenuView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UITapGestureRecognizer *singleTapGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(menuIsShowing)];
    [closeMenuView addGestureRecognizer:singleTapGesture];
    
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
    
}

//-(void)viewDidAppear:(BOOL)animated{
//    // keep in Portrait
//    restrictRotation(YES);
//}

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

#pragma mark ----> Prepare Segue

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"PushPlayCVC2"])
    {
        PlayCollectionViewController *vc = (PlayCollectionViewController*) segue.destinationViewController;
        Video *video = (Video*) [arrItems objectAtIndex:selectedIndex];
        vc.video = video;
        vc.mediaType = k_Home;
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:video.videoCategoryName style:UIBarButtonItemStylePlain target:nil action:nil];

    }
    else if ([segue.identifier isEqualToString:@"ShowMediaTVC2"])
    {
        MoreMediaTableViewController *vc = (MoreMediaTableViewController*) segue.destinationViewController;
//        vc.section = (Section*)[arrItems objectAtIndex:selectedIndex];
        Section *sec = (Section*)[arrItems objectAtIndex:selectedIndex];
        vc.sectionId = sec.sectionId;
        vc.screenTitle = sec.sectionName;
        vc.mediaType = k_Home;
        vc.isFromPlayCVC = NO;
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:sec.sectionName style:UIBarButtonItemStylePlain target:nil action:nil];

    }
}

#pragma mark ----> UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if([arrItems count]>0)
        return 2;
    else
        return 0;
//    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if(section == 0)
        return 0;
    else
        return [arrItems count];
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
    id object = [arrItems objectAtIndex:indexPath.item];
    
    if ([object isKindOfClass:[Section class]])
        return CGSizeMake(self.collectionView.frame.size.width-30, 50);
    else
        return CGSizeMake((self.collectionView.frame.size.width-30)/2, (self.collectionView.frame.size.width-30)/2);
//        return CGSizeMake((self.collectionView.frame.size.width-30)/2, 180);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if(section == 0)
        return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
    else
        return UIEdgeInsetsMake(0, 10, 10, 10);
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if (kind == UICollectionElementKindSectionHeader)
        {
            if(!imgHeaderView)
                imgHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kImageHeader forIndexPath:indexPath];
            
            if([arrCategoriesData count]>0)
            {
                Category *cat = (Category*)[arrCategoriesData objectAtIndex:currCat];
                if(cat.categoryPosterPath != NULL)
                    [imgHeaderView.imgView sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(cat.categoryPosterPath)]
                                             placeholderImage:nil];
            }
        }
        return imgHeaderView;
    }
    else
    {
        if (kind == UICollectionElementKindSectionHeader)
        {
            if(!svHeaderView)
                svHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSVHeader forIndexPath:indexPath];
            
            if([arrCategoriesData count]>0)
            {
                selectionList.frame = svHeaderView.bounds;
                [svHeaderView.svCategories addSubview:selectionList];
            }
        }
        return svHeaderView;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    SectionHeader *sectionHeaderCell;
    MediaDetailCell *mediaDetailCell;
    EmptyMediaCell *emptyCell;
    
    id object = [arrItems objectAtIndex:indexPath.item];
    
    if ([object isKindOfClass:[Section class]])
    {
        Section *sec = (Section*) object;
        sectionHeaderCell = [collectionView dequeueReusableCellWithReuseIdentifier:kSectionHeader forIndexPath:indexPath];
        sectionHeaderCell.lblTitle.text = sec.sectionName;
        sectionHeaderCell.btnMore.tag = indexPath.item;
        [sectionHeaderCell.btnMore addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];
        return sectionHeaderCell;
    }
    else if ([object isKindOfClass:[Video class]])
    {
        Video *video = (Video*) object;
        mediaDetailCell = [collectionView dequeueReusableCellWithReuseIdentifier:kMediaDetailCell forIndexPath:indexPath];
        [mediaDetailCell.imgViewMedia sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(video.videoImagePath)]
                             placeholderImage:nil];
        mediaDetailCell.lblTitle.text = video.videoName;
        mediaDetailCell.lblDesciption.text = video.videoDescription;
        
        if([video.isVideoChannel boolValue])
            mediaDetailCell.imgLive.hidden = NO;
        else
            mediaDetailCell.imgLive.hidden = YES;
        
        UIImageView *playImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playIcon.png"]];
        playImgView.frame = CGRectMake(5, mediaDetailCell.frame.size.height/2-15, 25, 25);
        [mediaDetailCell.contentView addSubview:playImgView];
        
        mediaDetailCell.backgroundColor = [UIColor whiteColor];
        mediaDetailCell.layer.cornerRadius = 10;
        mediaDetailCell.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:mediaDetailCell.bounds cornerRadius:mediaDetailCell.layer.cornerRadius] CGPath];
        return mediaDetailCell;
    }
    else
    {
        emptyCell=[collectionView dequeueReusableCellWithReuseIdentifier:kEmptyMediaCell forIndexPath:indexPath];
        return emptyCell;
    }
}

#pragma mark ----> UICollectionViewDelegate

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    id object = [arrItems objectAtIndex:indexPath.item];
    selectedIndex = indexPath.item;
    
    if ([object isKindOfClass:[Section class]])
    {
        [self performSegueWithIdentifier:@"ShowMediaTVC2" sender:nil];
    }
    else if ([object isKindOfClass:[Video class]])
        [self performSegueWithIdentifier:@"PushPlayCVC2" sender:nil];
}

#pragma mark ----> HTHorizontalSelectionListDataSource Protocol Methods

- (NSInteger)numberOfItemsInSelectionList:(HTHorizontalSelectionList *)selectionList {
    return [arrCategoriesData count];
}

- (NSString *)selectionList:(HTHorizontalSelectionList *)selectionList titleForItemWithIndex:(NSInteger)index {
    Category *catObj = (Category*) [arrCategoriesData objectAtIndex:index];
    return catObj.categoryName;
}

#pragma mark ----> HTHorizontalSelectionListDelegate Protocol Methods

- (void)selectionList:(HTHorizontalSelectionList *)selectionList didSelectButtonWithIndex:(NSInteger)index {
    
    if(index != currCat)
    {
        prevCat = currCat;
        currCat = index;
        [self prepareItemsArray];
    }
}

#pragma mark ----> Data-CallBack

-(void) allHomeVideosAndDetailsDownloaded:(NSNotification *)notification{
    [arrCategoriesData removeAllObjects];
    
    if(isLoading)
        [self hideLoadingView];
    
    if((BOOL)[[notification object] integerValue])
    {
//        saveHomeData([[notification userInfo] valueForKey:@"data"]);
//        setHomeDataStatus(k_Downloaded);
        [arrCategoriesData addObjectsFromArray:[[notification userInfo] valueForKey:@"data"]];
        if([arrCategoriesData count]>0)
            isDataDownloaded = YES;
        [self prepareItemsArray];
    }
    else
    {
//        showAlert(self, [[notification userInfo] valueForKey:@"error"]);
        showAlert(self, error_msg);
    }
    [refreshControl endRefreshing];
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

-(void) reloadData{
    
    [self fetchHomeDataFromServer];

}
#pragma mark ----> My Funcs

-(void) loadData{
    
    //    if([getHomeDataStatus() isEqualToString:k_Downloaded])
    //        [self getHomeDataFromLocal];
    //    else
    [self fetchHomeDataFromServer];
}

-(void) fetchHomeDataFromServer{
    
    if(!isLoading)
        [self showLoadingView];
    
    [RestKitManager getAllHomeVideosAndDetails];
}

-(void) getHomeDataFromLocal{
    [arrCategoriesData removeAllObjects];
    [arrCategoriesData addObjectsFromArray:getHomeData()];
    [self prepareItemsArray];
}

- (void)showMore:(id)sender {
    
    UIButton *btn = (UIButton*) sender;
    selectedIndex = btn.tag;
    [self performSegueWithIdentifier:@"ShowMediaTVC2" sender:nil];
}

// This method prepares the Items for a particular Category
-(void) prepareItemsArray{
    
    [arrItems removeAllObjects];
    Category *cat = (Category*)[arrCategoriesData objectAtIndex:currCat];
    
    for(int i=0; i<[cat.sections count]; i++)
    {
        Section *sec = (Section*) [cat.sections objectAtIndex:i];
        [arrItems addObject:sec];
        for(int k=0; k<[sec.videos count]; k++)
        {
            Video *video = (Video*) [sec.videos objectAtIndex:k];
            [arrItems addObject:video];
        }
        // This is a 'jugaar' to enter an empty cell so the cell before an section doesn't appear in middle
        // if video count is ODD then insert an dummy Object (in case a string)
        if ([sec.videos count] % 2)
        {
            NSString *empty = @"empty";
            [arrItems addObject:empty];
        }
    }
    [self.collectionView reloadData];
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

@end
