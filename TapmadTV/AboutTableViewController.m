//
//  AboutTableViewController.m
//  TapmadTV
//
//  Created by Apple MacBook Pro on 1/2/17.
//  Copyright © 2017 pitv. All rights reserved.
//

#import "AboutTableViewController.h"
#import "Constants.h"
#import "Utilities.h"
#import "SWRevealViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <MessageUI/MessageUI.h>


@interface AboutTableViewController ()<MFMailComposeViewControllerDelegate>

@end

@implementation AboutTableViewController

static NSString * const kCellIdentifier1 = @"TVAboutCell1";

-(void) viewWillAppear:(BOOL)animated{

    // jugar for landscape orientation
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    // set ViewController Name
//    setViewControllerNameForKey(k_AboutTVC, k_CurrentViewControllerName);
//    
//    // set google analytics screen name
//    sendGoogleAnalyticsScreenName(ga_aboutScreen);
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:128.0f/255.0f green:170.0f/255.0f blue:85.0f/255.0f alpha:1];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        // increasing the -ve value reduce the width of the side Menu
        self.revealViewController.rearViewRevealWidth = -50;
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((headerView.frame.size.width-300)/2, 20, 300, 150)];
    [imageView setImage:[UIImage imageNamed:@"tapmadIconGreen.png"]];
    [headerView addSubview:imageView];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height-30, imageView.frame.size.width, 30)];
    labelView.text = @"Anytime, Anywhere, Anynetwork";
    labelView.textAlignment = NSTextAlignmentCenter;
    [imageView addSubview:labelView];
    self.tableView.tableHeaderView = headerView;
    
    self.tableView.separatorColor = [UIColor clearColor];
    
}

//-(void)viewDidAppear:(BOOL)animated{
//    // keep in Portrait
//    restrictRotation(YES);
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 7;
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 55.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier1];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier1];
    }
    
    if(indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 4)
    {
        if(indexPath.row == 0)
        {
            cell.textLabel.text = g_app_version;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if(indexPath.row == 3)
            cell.textLabel.text = g_CallUs;
        else if(indexPath.row == 4)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy"];
            NSString *year = [formatter stringFromDate:[NSDate date]];
            cell.textLabel.text = [NSString stringWithFormat:@"Copyrights @ %@",year];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    else{
        if(indexPath.row == 1)
        {
            cell.textLabel.text = @"Contact us";
            [cell.imageView setImage:[UIImage imageNamed:@"emailIcon.png"]];
        }
        else if(indexPath.row == 2)
        {
            cell.textLabel.text = @"Visit our website";
            [cell.imageView setImage:[UIImage imageNamed:@"linkIcon.png"]];
        }
//        else if(indexPath.row == 3)
//        {
////            cell.textLabel.text = @"Like us on Facebook:";
////            [cell.imageView setImage:[UIImage imageNamed:@"fbIcon.png"]];
//            
//            UILabel *lblFB = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 185, 60)];
//            lblFB.text = @"Like us on Facebook:";
//            lblFB.textAlignment = NSTextAlignmentLeft;
//            
//            UIView *vu = [[UIView alloc] initWithFrame:cell.frame];
//            [vu addSubview:lblFB];
//            
//            FBSDKLikeControl *likeButton = [[FBSDKLikeControl alloc] initWithFrame:CGRectMake(185, 15, 200, 40)];
//            likeButton.likeControlStyle = FBSDKLikeControlStyleBoxCount;
//            likeButton.transform = CGAffineTransformMakeScale(1, 1); //doubles the button's size
//            likeButton.objectID = @"https://www.facebook.com/TapmadTV/?fref=ts";
//            [vu addSubview:likeButton];
//            [cell.contentView addSubview:vu];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        }
//        else if(indexPath.row == 4)
//        {
//            cell.textLabel.text = @"Rate us on Play Store";
//            [cell.imageView setImage:[UIImage imageNamed:@"playStoreIcon.png"]];
//        }
    }
    UIImageView *bottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 59.5, [[UIScreen mainScreen] bounds].size.width, 0.5)];
    bottomLine.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:bottomLine];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 1) // Email
    {
        if ([MFMailComposeViewController canSendMail]) {
            
            MFMailComposeViewController* composeVC = [[MFMailComposeViewController alloc] init];
            composeVC.mailComposeDelegate = self;
            
            // Configure the fields of the interface.
            [composeVC setToRecipients:@[@"info@pitelevision.com"]];
            [composeVC setSubject:@":: Pitelevision Inquiry."];
            [composeVC setMessageBody:@"" isHTML:NO];
            
            // Present the view controller modally.
            [self presentViewController:composeVC animated:YES completion:nil];
        }
        else{
//            NSLog(@"Mail services are not available.");
            return;
        }
    }
    else if(indexPath.row == 2) // Website
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.tapmad.com/"]];
    }
//    else if(indexPath.row == 3) // Facebook
//    {
////        NSLog(@"Token is available : %@",[[FBSDKAccessToken currentAccessToken]tokenString]);
////        if ([[FBSDKAccessToken currentAccessToken]tokenString] != NULL)
////        {
////            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, picture.type(large), email ,friends , friendlists"}]
////             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
////                 if (!error)
////                 {
////                     NSLog(@"resultis:%@",result);
////                 }
////                 else
////                 {
////                     NSLog(@"Error %@",error);
////                 }
////             }];
////        }
////        else{
////            
////            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
////            [loginManager logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]
////                                fromViewController:self
////                                           handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
////                                               //TODO: process error or result
////                                               [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, picture.type(large), email ,friends , friendlists"}]
////                                                startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
////                                                    if (!error)
////                                                    {
////                                                        NSLog(@"resultis:%@",result);
////                                                    }
////                                                    else
////                                                    {
////                                                        NSLog(@"Error %@",error);
////                                                    }
////                                                }];
////                                               
////                                           }];
////        }
//    }
//    else if(indexPath.row == 4) // PlayStore
//    {
//        
//    }
    else if(indexPath.row == 3) // Call on Number
    {
        NSString *phoneNum = @"+922135302095"; // This is tapmad Office contact number
        
        NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phoneNum]];

        
        if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
            [[UIApplication sharedApplication] openURL:phoneUrl];
        } else
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"Call facility is not available !!!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

#pragma mark -MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // Check the result or perform other tasks.
    
    // Dismiss the mail compose view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
