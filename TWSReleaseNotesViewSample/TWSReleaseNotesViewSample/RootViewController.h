//
//  RootViewController.h
//  TWSReleaseNotesViewSample
//
//  Created by Matteo Lallone on 02/08/13.
//  Copyright (c) 2013 Tapwings. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *localButton;
@property (weak, nonatomic) IBOutlet UIButton *remoteButton;
- (IBAction)showLocalButtonPressed:(id)sender;
- (IBAction)showRemoteButtonPressed:(id)sender;

@end
