//
//  MoreMediaTableViewController.m
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/15/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import "MoreMediaTableViewController.h"
#import "RestKitManager.h"
#import "Constants.h"
#import "UIImageView+WebCache.h"
#import "PlayCollectionViewController.h"
#import "AMTumblrHud.h"
#import "MoreMediaCell.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

@interface MoreMediaTableViewController (){
    NSMutableArray *arrChannels;
    NSMutableArray *arrMovies;
    NSMutableArray *arrVODs;
    NSMutableArray *arrMoreVideos;
    BOOL isLoading;
    AMTumblrHud *loadingView;
    
    NSInteger selectedSection;
}

@end

@implementation MoreMediaTableViewController

static NSString * const kMoreMediaCell = @"MoreMediaCell";

- (void) viewWillAppear:(BOOL)animated{
    
    // jugar for landscape orientation
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
    // Register Notification to notify that data is done downloading
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moreSectionVideosDownloaded:) name:MoreSectionVideosAreDownloaded object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relatedVideosDownloaded:) name:RelatedVideosAreDownloaded object:nil];
}

- (void) viewWillDisappear:(BOOL)animated{
    
    // unRegister notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MoreSectionVideosAreDownloaded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RelatedVideosAreDownloaded object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isLoading = NO;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:228.0f/255.0f green:228.0f/255.0f blue:228.0f/255.0f alpha:1];
    
    [self loadData];
    
    [self.tableView registerNib:[MoreMediaCell nib] forCellReuseIdentifier:kMoreMediaCell];
    
    arrMoreVideos = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.tableView.separatorColor = [UIColor clearColor];
    
//    // keep in Portrait
//    restrictRotation(YES);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
        return [arrChannels count];
    else if([self.mediaType isEqualToString:k_Movies])
        return [arrMovies count];
    else if([self.mediaType isEqualToString:k_VOD])
        return [arrVODs count];
    else
        return [arrMoreVideos count]; // k_Home
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 140.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MoreMediaCell *cell = [tableView dequeueReusableCellWithIdentifier:kMoreMediaCell forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithRed:228.0f/255.0f green:228.0f/255.0f blue:228.0f/255.0f alpha:1];
    
    if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
    {
        Channel *video = (Channel*)[arrChannels objectAtIndex:indexPath.section];
        [cell.imgViewMedia sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(video.videoImagePath)]
                             placeholderImage:nil];
        cell.lblTitle.text = video.videoName;
        cell.lblDesciption.text = video.videoDescription;
        
        UIImageView *liveImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"liveIcon.png"]];
        liveImgView.frame = CGRectMake(cell.vuThumbnail.frame.size.width-40, 0, 40, 20);
        [cell.vuThumbnail addSubview:liveImgView];
    }
    else if([self.mediaType isEqualToString:k_Movies])
    {
        Movie *video = (Movie*)[arrMovies objectAtIndex:indexPath.section];
        [cell.imgViewMedia sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(video.videoImagePath)]
                             placeholderImage:nil];
        cell.lblTitle.text = video.videoName;
        cell.lblDesciption.text = video.videoDescription;
    }
    else if([self.mediaType isEqualToString:k_VOD])
    {
        VOD *video = (VOD*)[arrVODs objectAtIndex:indexPath.section];
        [cell.imgViewMedia sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(video.videoImagePath)]
                             placeholderImage:nil];
        cell.lblTitle.text = video.videoName;
        cell.lblDesciption.text = video.videoDescription;
    }
    else if([self.mediaType isEqualToString:k_Home])
    {
        Video *video = (Video*)[arrMoreVideos objectAtIndex:indexPath.section];
        [cell.imgViewMedia sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(video.videoImagePath)]
                             placeholderImage:nil];
        cell.lblTitle.text = video.videoName;
        cell.lblDesciption.text = video.videoDescription;
    }
    
    CGSize maxSize = CGSizeMake(cell.lblDesciption.frame.size.width, MAXFLOAT);
    CGRect labelRect = [cell.lblDesciption.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:cell.lblDesciption.font} context:nil];
    
    cell.lblDesciption.frame = labelRect;
    
    
    UIImageView *playImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playIcon.png"]];
    playImgView.frame = CGRectMake(15, cell.vuThumbnail.frame.size.height-50, 40, 40);
    [cell.vuThumbnail addSubview:playImgView];
    
    cell.lblTitle.textColor = [UIColor colorWithRed:128.0f/255.0f green:170.0f/255.0f blue:85.0f/255.0f alpha:1];
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.vuThumbnail.layer.cornerRadius = 10;
    cell.vuThumbnail.clipsToBounds = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedSection = indexPath.section;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"ShowPlayCVCFromMoreMedia" sender:nil];
}
#pragma mark --Segue Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowPlayCVCFromMoreMedia"]) {
        
        PlayCollectionViewController *vc = (PlayCollectionViewController*) segue.destinationViewController;
        if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
        {
            vc.channelCategory = self.channelCategory;
            vc.channel = (Channel*)[arrChannels objectAtIndex:selectedSection];
            vc.mediaType = k_Channels;
            self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:self.channelCategory.videoCategoryName style:UIBarButtonItemStylePlain target:nil action:nil];
        }
        else if([self.mediaType isEqualToString:k_Movies])
        {
            vc.movieCategory = self.movieCategory;
            vc.movie = (Movie*)[arrMovies objectAtIndex:selectedSection];
            vc.mediaType = k_Movies;
            self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:self.movieCategory.videoCategoryName style:UIBarButtonItemStylePlain target:nil action:nil];
        }
        else if([self.mediaType isEqualToString:k_VOD])
        {
            vc.vodCategory = self.vodCategory;
            vc.vod = (VOD*)[arrVODs objectAtIndex:selectedSection];
            vc.mediaType = k_VOD;
            self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:self.vodCategory.videoCategoryName style:UIBarButtonItemStylePlain target:nil action:nil];
        }
        else // k_Home
        {
            vc.video = (Video*)[arrMoreVideos objectAtIndex:selectedSection];
            vc.mediaType = k_Home;
            self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:vc.video.videoCategoryName style:UIBarButtonItemStylePlain target:nil action:nil];
        }
    }
}

#pragma mark --Funcs

-(void) loadData{
    
    if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
    {
        sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_moreVideosScreen, self.channelCategory.videoCategoryName]);
//        self.navigationController.navigationBar.topItem.title = self.channelCategory.videoCategoryName;
        [self fetchChannelDataFromDB];
    }
    else if([self.mediaType isEqualToString:k_Movies])
    {
        sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_moreVideosScreen, self.movieCategory.videoCategoryName]);
//        self.navigationController.navigationBar.topItem.title = self.movieCategory.videoCategoryName;
        [self fetchMovieDataFromDB];
    }
    else if([self.mediaType isEqualToString:k_VOD])
    {
        sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_moreVideosScreen, self.vodCategory.videoCategoryName]);
//        self.navigationController.navigationBar.topItem.title = self.vodCategory.videoCategoryName;
        [self fetchVODDataFromDB];
    }
    else if([self.mediaType isEqualToString:k_Home])
    {
//        self.navigationController.navigationBar.topItem.title = self.screenTitle;
        if(self.isFromPlayCVC)
            [self fetchRelatedChannelsOrVODsFromServer];
        else
            [self fetchMoreSectionVideosFromServer];
    }
}

-(void) fetchChannelDataFromDB{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoCategoryId = %@",self.channelCategory.videoCategoryId];;
    
    [arrChannels removeAllObjects];
    arrChannels = [RestKitManager getVideos:k_entity_channel predicate:predicate];
    [self.tableView reloadData];
}

-(void) fetchMovieDataFromDB{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoCategoryId = %@",self.movieCategory.videoCategoryId];;
    
    [arrMovies removeAllObjects];
    arrMovies = [RestKitManager getVideos:k_entity_movie predicate:predicate];
    [self.tableView reloadData];
}

-(void) fetchVODDataFromDB{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoCategoryId = %@",self.vodCategory.videoCategoryId];;
    [arrVODs removeAllObjects];
    arrVODs = [RestKitManager getVideos:k_entity_vod predicate:predicate];
    [self.tableView reloadData];
}

-(void) fetchRelatedChannelsOrVODsFromServer{
    
    if(!isLoading)
        [self showLoadingView];
    
    sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_moreVideosScreen, self.video.videoName]);
    
    NSString *url = [NSString stringWithFormat:g_getRelatedChannelsOrVODs, self.video.videoEntityId, self.video.isVideoChannel];
    [RestKitManager getRelatedVideos:url];
}

-(void) fetchMoreSectionVideosFromServer{

    if(!isLoading)
        [self showLoadingView];
    
    sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_moreVideosScreen, self.screenTitle]);
    
    NSString *url = [NSString stringWithFormat:g_getMoreSectionVideos, self.sectionId];
    
    [RestKitManager getMoreSectionVideos:url];
}

-(void) relatedVideosDownloaded:(NSNotification *)notification{
    
    if(isLoading)
        [self hideLoadingView];
    
    if((BOOL)[[notification object] integerValue])
    {
        NSArray *arrSections = [[notification userInfo] valueForKey:@"data"];
        Section *section = (Section*)[arrSections objectAtIndex:0];
        [arrMoreVideos addObjectsFromArray:section.videos];
    }
    else
    {
//        [self showAlert:[[notification userInfo] valueForKey:@"error"]];
        showAlert(self, error_msg);
    }
    
    [self.tableView reloadData];
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

#pragma mark --Data CallBack

-(void) moreSectionVideosDownloaded:(NSNotification *)notification{
    [arrMoreVideos removeAllObjects];
    if(isLoading)
        [self hideLoadingView];
    
    if((BOOL)[[notification object] integerValue])
    {
        [arrMoreVideos addObjectsFromArray:[[notification userInfo] valueForKey:@"data"]];
    }
    else
    {
//        [self showAlert:[[notification userInfo] valueForKey:@"error"]];
        showAlert(self, error_msg);
    }
    
    [self.tableView reloadData];
    
}


@end
