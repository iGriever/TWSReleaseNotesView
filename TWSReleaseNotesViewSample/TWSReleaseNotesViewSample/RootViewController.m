//
//  RootViewController.m
//  TWSReleaseNotesViewSample
//
//  Created by Matteo Lallone on 02/08/13.
//  Copyright (c) 2013 Tapwings. All rights reserved.
//

#import "RootViewController.h"
#import "TWSReleaseNotesView.h"

@interface RootViewController ()

- (void)showLocalReleaseNotesView;
- (void)showRemoteReleaseNotesView;

@end

@implementation RootViewController

#pragma mark - Init - dealloc Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Check for app update
    if ([TWSReleaseNotesView isAppVersionUpdated])
    {
        [self showLocalReleaseNotesView];
    }
}

#pragma mark - Private Methods

- (void)showLocalReleaseNotesView
{
    // Create the release notes view
    NSString *currentAppVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    TWSReleaseNotesView *releaseNotesView = [TWSReleaseNotesView viewWithReleaseNotesTitle:[NSString stringWithFormat:@"What's new in version %@:", currentAppVersion] text:@"• Create custom stations of your favorite podcasts that update automatically with new episodes\n• Choose whether your stations begin playing with the newest or oldest unplayed episode\n• Your stations are stored in iCloud and kept up-to-date on all of your devices\n• Create an On-The-Go playlist with your own list of episodes\n• Playlists synced from iTunes now appear in the Podcasts app\n• The Now Playing view has been redesigned with easier to use playback controls\n• Addressed an issue with resuming playback when returning to the app\n• Additional performance and stability improvements" closeButtonTitle:@"Close"];
    
    // Show the release notes view
    [releaseNotesView showInView:self.view];
}

- (void)showRemoteReleaseNotesView
{
    NSString *currentAppVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    [TWSReleaseNotesView setupViewWithAppIdentifier:@"329670577" releaseNotesTitle:[NSString stringWithFormat:@"What's new in version %@:", currentAppVersion] closeButtonTitle:@"Close" completionBlock:^(TWSReleaseNotesView *releaseNotesView, NSString *releaseNotesText, NSError *error){
        if (error)
        {
            NSLog(@"An error occurred: %@", [error localizedDescription]);
        }
        else
        {
            NSLog(@"Received data:\n\n%@", releaseNotesText);
            
            // Create and show release notes view
            [releaseNotesView showInView:self.view];
        }
    }];
}

#pragma mark - Control Methods

- (IBAction)showLocalButtonPressed:(id)sender
{
    [self showLocalReleaseNotesView];
}

- (IBAction)showRemoteButtonPressed:(id)sender
{
    [self showRemoteReleaseNotesView];
}

@end
