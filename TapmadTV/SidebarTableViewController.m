//
//  SidebarTableViewController.m
//  SidebarDemo
//
//  Created by Simon Ng on 10/11/14.
//  Copyright (c) 2014 AppCoda. All rights reserved.
//

#import "SidebarTableViewController.h"
#import "SWRevealViewController.h"
#import "MainCollectionViewController.h"
#import "HomeCollectionViewController.h"
#import "AboutTableViewController.h"
#import "Constants.h"
#import "Utilities.h"

@interface SidebarTableViewController ()

@end

@implementation SidebarTableViewController {
    NSArray *menuItems;
    NSIndexPath *selectedIndex;
}

@synthesize tblMenu = _tblMenu, headerView = _headerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    menuItems = @[@"Home", @"Live Channels", @"Video On Demand", @"Movies", @"Invite Friends", @"About"];
    menuItems = @[@"Home", @"Live Channels", @"Video On Demand", @"Movies", @"About"];
    _tblMenu.backgroundColor = [UIColor colorWithRed:238.0f/255.0f green:238.0f/255.0f blue:238.0f/255.0f alpha:1];
    _tblMenu.separatorColor = [UIColor clearColor];
    _headerView.backgroundColor = [UIColor colorWithRed:128.0f/255.0f green:170.0f/255.0f blue:85.0f/255.0f alpha:1];
}

-(void)viewDidAppear:(BOOL)animated{
    
    if(selectedIndex)
    {
        UITableViewCell *cell = [_tblMenu cellForRowAtIndexPath:selectedIndex];
        cell.contentView.backgroundColor = [UIColor colorWithRed:206.0f/255.0f green:206.0f/255.0f blue:206.0f/255.0f alpha:1];
    }
    else
    {
        selectedIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell *cell = [_tblMenu cellForRowAtIndexPath:selectedIndex];
        cell.contentView.backgroundColor = [UIColor colorWithRed:206.0f/255.0f green:206.0f/255.0f blue:206.0f/255.0f alpha:1];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return menuItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [menuItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *arrCells = [tableView visibleCells];
    for(UITableViewCell *cell in arrCells)
        cell.contentView.backgroundColor = [UIColor clearColor];
    
    UITableViewCell *sCell = [tableView cellForRowAtIndexPath:indexPath];
    sCell.contentView.backgroundColor = [UIColor colorWithRed:206.0f/255.0f green:206.0f/255.0f blue:206.0f/255.0f alpha:1];
    selectedIndex = indexPath;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Set the title of navigation bar by using the menu items
//    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
//    destViewController.title = [[menuItems objectAtIndex:indexPath.row] capitalizedString];

    if ([segue.identifier isEqualToString:@"ShowHome"]) {
        UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
        HomeCollectionViewController *vc = (HomeCollectionViewController*)[destViewController.viewControllers firstObject];
        vc.mediaType = k_Home;
        // set ViewController Name
        setViewControllerNameForKey(k_HomeCVC, k_SelectedViewControllerName);
        // set google analytics screen name
        sendGoogleAnalyticsScreenName(ga_homeScreen);
    }
    
    if ([segue.identifier isEqualToString:@"ShowLiveChannels"]) {
        UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
        MainCollectionViewController *vc = (MainCollectionViewController*)[destViewController.viewControllers firstObject];
        vc.mediaType = k_Channels;
        setViewControllerNameForKey(k_ChannelsCVC, k_SelectedViewControllerName);
        // set google analytics screen name
        sendGoogleAnalyticsScreenName(ga_channelsScreen);
    }
    
    if ([segue.identifier isEqualToString:@"ShowMovies"]) {
        UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
        MainCollectionViewController *vc = (MainCollectionViewController*)[destViewController.viewControllers firstObject];
        vc.mediaType = k_Movies;
        setViewControllerNameForKey(k_MoviesCVC, k_SelectedViewControllerName);
        // set google analytics screen name
        sendGoogleAnalyticsScreenName(ga_moviesScreen);
    }
    
    if ([segue.identifier isEqualToString:@"ShowVODs"]) {
        UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
        MainCollectionViewController *vc = (MainCollectionViewController*)[destViewController.viewControllers firstObject];
        vc.mediaType = k_VOD;
        setViewControllerNameForKey(k_VODsCVC, k_SelectedViewControllerName);
        // set google analytics screen name
        sendGoogleAnalyticsScreenName(ga_vodScreen);
    }
    
    if ([segue.identifier isEqualToString:@"ShowAbout"]) {
//        UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
//        AboutTableViewController *vc = (AboutTableViewController*)[destViewController.viewControllers firstObject];
        setViewControllerNameForKey(k_AboutTVC, k_SelectedViewControllerName);
        // set google analytics screen name
        sendGoogleAnalyticsScreenName(ga_aboutScreen);
    }
}


@end
