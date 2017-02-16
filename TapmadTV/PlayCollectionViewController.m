//
//  PlayCollectionViewController.m
//  TapmadTV
//
//  Created by Apple MacBook Pro on 12/6/16.
//  Copyright © 2016 pitv. All rights reserved.
//

#import "PlayCollectionViewController.h"
#import "UIImageView+WebCache.h"
#import "RestKitManager.h"
#import "Constants.h"
#import "PlayViewController.h"
#import "MoreMediaTableViewController.h"
#import "AMTumblrHud.h"
#import "ImageHeader.h"
#import "MediaDetailsHeader.h"
#import "SectionHeaderReusableView.h"
#import "MediaDetailCell.h"
#import "Utilities.h"

@interface PlayCollectionViewController (){
    
    ImageHeader *imageHeader;
    MediaDetailsHeader *mediaDetailsHeader;
    SectionHeaderReusableView *sectionHeader;
    NSMutableArray *arrChannels;
    NSMutableArray *arrMovies;
    NSMutableArray *arrVODs;
    BOOL isLoading;
    AMTumblrHud *loadingView;
}

@end

@implementation PlayCollectionViewController

static NSString * const kMediaDetailCell = @"MediaDetailCell";
static NSString * const kImageHeader = @"ImageHeader";
static NSString * const kMediaDetailsHeader = @"MediaDetailsHeader";
static NSString * const kSectionHeaderReusableView = @"SectionHeaderReusableView";

- (void) viewWillAppear:(BOOL)animated{
    
//    // jugar for landscape orientation
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
////    // keep in Portrait
//    restrictRotation(YES);
    
    // Register Notification to notify that data is done downloading
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relatedVideosDownloaded:) name:RelatedVideosAreDownloaded object:nil];
}

- (void) viewWillDisappear:(BOOL)animated{
    
    // unRegister notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RelatedVideosAreDownloaded object:nil];
}

- (BOOL)canAutoRotate
{
    return NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor colorWithRed:228.0f/255.0f green:228.0f/255.0f blue:228.0f/255.0f alpha:1];
    
    [self loadData];
    
    [self.collectionView registerNib:[ImageHeader nib] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kImageHeader];
    
    [self.collectionView registerNib:[MediaDetailsHeader nib] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMediaDetailsHeader];
    
    [self.collectionView registerNib:[SectionHeaderReusableView nib] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSectionHeaderReusableView];
    
    [self.collectionView registerNib:[MediaDetailCell nib] forCellWithReuseIdentifier:kMediaDetailCell];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Prepare Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowMore"]) {
        
        MoreMediaTableViewController *vc = (MoreMediaTableViewController*) segue.destinationViewController;
        if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
        {
            vc.channelCategory = self.channelCategory;
            vc.mediaType = k_Channels;
            self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:self.channelCategory.videoCategoryName style:UIBarButtonItemStylePlain target:nil action:nil];
        }
        else if([self.mediaType isEqualToString:k_Movies])
        {
            vc.movieCategory = self.movieCategory;
            vc.mediaType = k_Movies;
            self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:self.movieCategory.videoCategoryName style:UIBarButtonItemStylePlain target:nil action:nil];
        }
        else if([self.mediaType isEqualToString:k_VOD])
        {
            vc.vodCategory = self.vodCategory;
            vc.mediaType = k_VOD;
            self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:self.vodCategory.videoCategoryName style:UIBarButtonItemStylePlain target:nil action:nil];
        }
        else if([self.mediaType isEqualToString:k_Home])
        {
//            vc.section = self.section;
//            vc.video = [self.section.videos objectAtIndex:path.item];
            vc.video = self.video;
            vc.sectionId = self.video.videoCategoryId;
            vc.screenTitle = self.video.videoCategoryName;
            vc.mediaType = k_Home;
            vc.isFromPlayCVC = YES;
            self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:self.video.videoCategoryName style:UIBarButtonItemStylePlain target:nil action:nil];
        }
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 3;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return CGSizeMake(320, 200);
    else if(section == 1)
        return CGSizeMake(320, 120);
    else
        return CGSizeMake(320, 50);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((self.collectionView.frame.size.width-30)/2, (self.collectionView.frame.size.width-30)/2);
//    return CGSizeMake((self.collectionView.frame.size.width-30)/2, 180);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if(section == 0 || section == 1)
        return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
    else
        return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if(section == 2)
    {
        if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
            return [arrChannels count];
        else if([self.mediaType isEqualToString:k_Movies])
            return [arrMovies count];
        else if([self.mediaType isEqualToString:k_VOD])
            return [arrVODs count];
        else
            return [self.section.videos count]; // k_Home
    }
    else
        return 0;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader)
    {
        // Initialize
        if(indexPath.section == 0)
        {
            if(!imageHeader)
                imageHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kImageHeader forIndexPath:indexPath];
            
            // Set Values
            if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
                [imageHeader.imgView sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(self.channel.videoImagePath)]
                                       placeholderImage:nil];
            else if([self.mediaType isEqualToString:k_Movies])
                [imageHeader.imgView sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(self.movie.videoImagePath)]
                                       placeholderImage:nil];
            else if([self.mediaType isEqualToString:k_VOD])
                [imageHeader.imgView sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(self.vod.videoImagePath)]
                                       placeholderImage:nil];
            else if([self.mediaType isEqualToString:k_Home])
                [imageHeader.imgView sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(self.video.videoImagePath)]
                                       placeholderImage:nil];
            
            UIImageView *playImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playIcon.png"]];
            playImgView.frame = CGRectMake(10, imageHeader.frame.size.height-75, 50, 50);
            [imageHeader addSubview:playImgView];
            
            UITapGestureRecognizer* playGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playClicked:)];
            [imageHeader setUserInteractionEnabled:YES];
            [imageHeader addGestureRecognizer:playGesture];

        }
        else if(indexPath.section == 1)
        {
            if(!mediaDetailsHeader)
                mediaDetailsHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMediaDetailsHeader forIndexPath:indexPath];
            
            // Set Values
            if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
            {
                mediaDetailsHeader.lblTitle.text = self.channel.videoName;
                mediaDetailsHeader.lblDate.text = self.channel.videoAddedDate;
                if(self.channel.videoRating != NULL)
                    mediaDetailsHeader.lblRating.text = [NSString stringWithFormat:@"%@",self.channel.videoRating];
                else
                    mediaDetailsHeader.lblRating.text = @"0";
                mediaDetailsHeader.lblViews.text = [NSString stringWithFormat:@"%@",self.channel.videoTotalViews];
                mediaDetailsHeader.lblDesc.text = self.channel.videoDescription;
            }
            else if([self.mediaType isEqualToString:k_Movies])
            {
                mediaDetailsHeader.lblTitle.text = self.movie.videoName;
                mediaDetailsHeader.lblDate.text = self.movie.videoAddedDate;
                if(self.movie.videoRating != NULL)
                    mediaDetailsHeader.lblRating.text = [NSString stringWithFormat:@"%@",self.movie.videoRating];
                else
                    mediaDetailsHeader.lblRating.text = @"0";
                mediaDetailsHeader.lblViews.text = [NSString stringWithFormat:@"%@",self.movie.videoTotalViews];
                mediaDetailsHeader.lblDesc.text = self.movie.videoDescription;
            }
            else if([self.mediaType isEqualToString:k_VOD])
            {
                mediaDetailsHeader.lblTitle.text = self.vod.videoName;
                mediaDetailsHeader.lblDate.text = self.vod.videoAddedDate;
                if(self.vod.videoRating != NULL)
                    mediaDetailsHeader.lblRating.text = [NSString stringWithFormat:@"%@",self.vod.videoRating];
                else
                    mediaDetailsHeader.lblRating.text = @"0";
                mediaDetailsHeader.lblViews.text = [NSString stringWithFormat:@"%@",self.vod.videoTotalViews];
                mediaDetailsHeader.lblDesc.text = self.vod.videoDescription;
                
            }
            else if([self.mediaType isEqualToString:k_Home])
            {
                mediaDetailsHeader.lblTitle.text = self.video.videoName;
                mediaDetailsHeader.lblDate.text = self.video.videoAddedDate;
                if(self.video.videoRating != NULL)
                    mediaDetailsHeader.lblRating.text = [NSString stringWithFormat:@"%@",self.video.videoRating];
                else
                    mediaDetailsHeader.lblRating.text = @"0";
                mediaDetailsHeader.lblViews.text = [NSString stringWithFormat:@"%@",self.video.videoTotalViews];
                mediaDetailsHeader.lblDesc.text = self.video.videoDescription;
            }
            mediaDetailsHeader.lblLive.textColor = [UIColor colorWithRed:128.0f/255.0f green:170.0f/255.0f blue:85.0f/255.0f alpha:1];;
            mediaDetailsHeader.lblFree.textColor = [UIColor colorWithRed:255.0f/255.0f green:0.0f/255.0f blue:25.0f/255.0f alpha:1];
            
        }
        else
        {
            if(!sectionHeader)
                sectionHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSectionHeaderReusableView forIndexPath:indexPath];
            
            // Set Values
            if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
            {
                sectionHeader.lblTitle.text = self.channelCategory.videoCategoryName;
                [sectionHeader.btnMore addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if([self.mediaType isEqualToString:k_Movies])
            {
                sectionHeader.lblTitle.text = self.movieCategory.videoCategoryName;
                [sectionHeader.btnMore addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if([self.mediaType isEqualToString:k_VOD])
            {
                sectionHeader.lblTitle.text = self.vodCategory.videoCategoryName;
                [sectionHeader.btnMore addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if([self.mediaType isEqualToString:k_Home])
            {
                sectionHeader.lblTitle.text = self.video.videoCategoryName;
                [sectionHeader.btnMore addTarget:self action:@selector(showMore:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
    // Return Section views
    if(indexPath.section == 0)
        return imageHeader;
    else if(indexPath.section == 1)
        return mediaDetailsHeader;
    else
        return sectionHeader;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    MediaDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMediaDetailCell forIndexPath:indexPath];
    
    if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
    {
        Channel *video = (Channel*)[arrChannels objectAtIndex:indexPath.item];
        [cell.imgViewMedia sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(video.videoImagePath)]
                             placeholderImage:nil];
        cell.lblTitle.text = video.videoName;
        cell.lblDesciption.text = video.videoDescription;
        
        UIImageView *liveImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"liveIcon.png"]];
        liveImgView.frame = CGRectMake(cell.frame.size.width-40, 0, 40, 20);
        [cell.contentView addSubview:liveImgView];
        
        cell.imgLive.hidden = NO;
    }
    else if([self.mediaType isEqualToString:k_Movies])
    {
        Movie *video = (Movie*)[arrMovies objectAtIndex:indexPath.item];
        [cell.imgViewMedia sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(video.videoImagePath)]
                             placeholderImage:nil];
        cell.lblTitle.text = video.videoName;
        cell.lblDesciption.text = video.videoDescription;
    
        cell.imgLive.hidden = YES;
    }
    else if([self.mediaType isEqualToString:k_VOD])
    {
        VOD *video = (VOD*)[arrVODs objectAtIndex:indexPath.item];
        [cell.imgViewMedia sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(video.videoImagePath)]
                             placeholderImage:nil];
        cell.lblTitle.text = video.videoName;
        cell.lblDesciption.text = video.videoDescription;
        
        if([video.isVideoChannel boolValue])
            cell.imgLive.hidden = NO;
        else
            cell.imgLive.hidden = YES;
    }
    else if([self.mediaType isEqualToString:k_Home])
    {
        Video *video = (Video*)[self.section.videos objectAtIndex:indexPath.item];
        [cell.imgViewMedia sd_setImageWithURL:[NSURL URLWithString:URLEncodedString_ch(video.videoImagePath)]
                             placeholderImage:nil];
        cell.lblTitle.text = video.videoName;
        cell.lblDesciption.text = video.videoDescription;
        
        if([video.isVideoChannel boolValue])
            cell.imgLive.hidden = NO;
        else
            cell.imgLive.hidden = YES;
    }
    
    
    cell.backgroundColor = [UIColor whiteColor];
    
    UIImageView *playImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playIcon.png"]];
    playImgView.frame = CGRectMake(5, cell.frame.size.height/2-15, 25, 25);
    [cell.contentView addSubview:playImgView];
    
    cell.layer.cornerRadius = 10;
    cell.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:cell.layer.cornerRadius] CGPath];
    
    return cell;
}

#pragma mark --UICollectionViewDelegate

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PlayCollectionViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"PlayCVC"];
    if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
    {
        vc.channel = [arrChannels objectAtIndex:indexPath.item];
        vc.channelCategory = self.channelCategory;
        vc.mediaType = k_Channels;
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:self.channelCategory.videoCategoryName style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    else if([self.mediaType isEqualToString:k_Movies])
    {
        vc.movie = [arrMovies objectAtIndex:indexPath.item];
        vc.movieCategory = self.movieCategory;
        vc.mediaType = k_Movies;
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:self.movieCategory.videoCategoryName style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    else if([self.mediaType isEqualToString:k_VOD])
    {
        vc.vod = [arrVODs objectAtIndex:indexPath.item];
        vc.vodCategory = self.vodCategory;
        vc.mediaType = k_VOD;
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:self.vodCategory.videoCategoryName style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    else if([self.mediaType isEqualToString:k_Home])
    {
        vc.video = [self.section.videos objectAtIndex:indexPath.item];
        vc.mediaType = k_Home;
        self.navigationItem.backBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:self.video.videoCategoryName style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark --Funcs

-(void) loadData{
    
    if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
    {
        sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_detailScreen, self.channel.videoName]);
//        self.navigationController.navigationBar.topItem.title = self.channelCategory.videoCategoryName;
        [self fetchChannelDataFromDB];
    }
    else if([self.mediaType isEqualToString:k_Movies])
    {
        sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_detailScreen, self.movie.videoName]);
//        self.navigationController.navigationBar.topItem.title = self.movieCategory.videoCategoryName;
        [self fetchMovieDataFromDB];
    }
    else if([self.mediaType isEqualToString:k_VOD])
    {
        sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_detailScreen, self.vod.videoName]);
//        self.navigationController.navigationBar.topItem.title = self.vodCategory.videoCategoryName;
        [self fetchVODDataFromDB];
    }
    else if([self.mediaType isEqualToString:k_Home])
    {
        sendGoogleAnalyticsScreenName([NSString stringWithFormat:ga_detailScreen, self.video.videoName]);
//        self.navigationController.navigationBar.topItem.title = self.video.videoCategoryName;
        [self fetchRelatedVideosFromServer];
    }
}

-(void) fetchChannelDataFromDB{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoCategoryId = %@",self.channel.videoCategoryId];;
    
    [arrChannels removeAllObjects];
    arrChannels = [RestKitManager getVideos:k_entity_channel predicate:predicate];
    [self.collectionView reloadData];
}

-(void) fetchMovieDataFromDB{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoCategoryId = %@",self.movie.videoCategoryId];;
    
    [arrMovies removeAllObjects];
    arrMovies = [RestKitManager getVideos:k_entity_movie predicate:predicate];
    [self.collectionView reloadData];
}

-(void) fetchVODDataFromDB{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"videoCategoryId = %@",self.vod.videoCategoryId];;
    
    [arrVODs removeAllObjects];
    arrVODs = [RestKitManager getVideos:k_entity_vod predicate:predicate];
    [self.collectionView reloadData];
}

-(void) fetchRelatedVideosFromServer{
    
    if(!isLoading)
        [self showLoadingView];
    
    NSString *url = [NSString stringWithFormat:g_getRelatedChannelsOrVODs, self.video.videoEntityId, self.video.isVideoChannel];
    [RestKitManager getRelatedVideos:url];
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

-(void) relatedVideosDownloaded:(NSNotification *)notification{

    if(isLoading)
        [self hideLoadingView];
    
    if((BOOL)[[notification object] integerValue])
    {
        NSArray *arrSections = [[notification userInfo] valueForKey:@"data"];
        self.section = (Section*)[arrSections objectAtIndex:0];
    }
    else
    {
//        showAlert(self, [[notification userInfo] valueForKey:@"error"]);
        showAlert(self, error_msg);
    }
    
    [self.collectionView reloadData];
}


-(void)playClicked:(UIGestureRecognizer*) gestureRecognizer{

    if(connected())
    {
        PlayViewController *playVC = [[PlayViewController alloc] init];
        if([self.mediaType isEqualToString:k_Channels] || self.mediaType == NULL)
        {
            playVC.channel = self.channel;
            playVC.mediaType = k_Channels;
        }
        else if([self.mediaType isEqualToString:k_Movies])
        {
            playVC.movie = self.movie;
            playVC.mediaType = k_Movies;
        }
        else if([self.mediaType isEqualToString:k_VOD])
        {
            playVC.vod = self.vod;
            playVC.mediaType = k_VOD;
        }
        else if([self.mediaType isEqualToString:k_Home])
        {
            playVC.video = self.video;
            playVC.mediaType = k_Home;
        }
        
        playVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController presentViewController:playVC animated:YES completion:nil];
    }
    else
        showAlert(self, error_Internet);
    
}

- (void)showMore:(id)sender {
    
    [self performSegueWithIdentifier:@"ShowMore" sender:nil];
}

@end
