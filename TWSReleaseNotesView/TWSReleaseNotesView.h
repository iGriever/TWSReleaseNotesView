//
//  TWSReleaseNotesView.h
//  TWSReleaseNotesViewSample
//
//  Created by Matteo Lallone on 02/08/13.
//  Copyright (c) 2013 Tapwings. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Use the `TWSReleaseNotesView` class to display a custom release notes view, to be shown when the app is opened for the first time after an update.
 
 If you want to check if the app is on its first launch, you can use the <isAppOnFirstLaunch> method. This method will check a previously stored app version string. If a stored app version string does not exist, it will return `YES`, storing the current version string.
 
 In order to check if the app was updated, the <isAppVersionUpdated> method can be used. This method will check a previously stored app version string. If a stored app version string is present but it does not match the current version string, it will return `YES`, storing the current version string.
 
 The release notes view can be initialized using the <viewWithReleaseNotesTitle:text:closeButtonTitle:> class method, if the release notes text is set directly when calling the method. If the release notes must be retrieved from the App Store, you must use the <setupViewWithAppIdentifier:releaseNotesTitle:closeButtonTitle:completionBlock:> class method.
 
 The appearance of the view can be customized using its alpha, color and font properties, to be set before showing the release notes view with the <showInView:> instance method.
 */
@interface TWSReleaseNotesView : UIView


/** @name Setting main properties */

/// The alpha value for the overlay to be applied to the container view. Default is `0.5f`.
@property (assign, nonatomic) CGFloat overlayAlpha;

/// The alpha value for the background color to be applied to the text container view. Default is `0.8f`.
@property (assign, nonatomic) CGFloat textViewAlpha;

/// The background color to be applied to the text container view. Default is `[UIColor blackColor]`.
@property (strong, nonatomic) UIColor *textViewBackgroundColor;

/// The dark separator color. Default is `[UIColor colorWithRed:16.0f/255.0f green:16.0f/255.0f blue:16.0f/255.0f alpha:1.0]`.
@property (strong, nonatomic) UIColor *darkSeparatorColor;

/// The light separator color. Default is `[UIColor colorWithRed:58.0f/255.0f green:58.0f/255.0f blue:65.0f/255.0f alpha:1.0]`.
@property (strong, nonatomic) UIColor *lightSeparatorColor;

/// The shadow color for the release notes view. Default is `[UIColor blackColor]`.
@property (strong, nonatomic) UIColor *viewShadowColor;

/// The shadow offset for the release notes view. Default is `(0.0f, 3.0f)`.
@property (assign, nonatomic) CGSize viewShadowOffset;

/// The shadow radius for the release notes view. Default is `3.0f`.
@property (assign, nonatomic) CGFloat viewShadowRadius;

/// The shadow opacity for the release notes view. Default is `1.0f`.
@property (assign, nonatomic) CGFloat viewShadowOpacity;

/// The font for the title label. Default is `[UIFont systemFontOfSize:16.0f]`.
@property (strong, nonatomic) UIFont *titleFont;

/// The color for the title label. Default is `[UIColor whiteColor]`.
@property (strong, nonatomic) UIColor *titleColor;

/// The shadow color for the title label. Default is `[UIColor blackColor]`.
@property (strong, nonatomic) UIColor *titleShadowColor;

/// The shadow offset for the title label. Default is `(0.0f, -1.0f)`.
@property (assign, nonatomic) CGSize titleShadowOffset;

/// The font for the release notes text view. Default is `[UIFont systemFontOfSize:14.0f]`.
@property (strong, nonatomic) UIFont *releaseNotesFont;

/// The color for the release notes text view. Default is `[UIColor whiteColor]`.
@property (strong, nonatomic) UIColor *releaseNotesColor;

/// The shadow color for the release notes text view. Default is `[UIColor blackColor]`.
@property (strong, nonatomic) UIColor *releaseNotesShadowColor;

/// The shadow offset for the release notes text view. Default is `(0.0f, -1.0f)`.
@property (assign, nonatomic) CGSize releaseNotesShadowOffset;

/// The font for the close button. Default is `[UIFont systemFontOfSize:16.0f]`.
@property (strong, nonatomic) UIFont *closeButtonFont;

/// The color for the close button. Default is `[UIColor whiteColor]`.
@property (strong, nonatomic) UIColor *closeButtonColor;

/// The shadow color for the close button. Default is `[UIColor blackColor]`.
@property (strong, nonatomic) UIColor *closeButtonShadowColor;

/// The shadow offset for the close button. Default is `(0.0f, -1.0f)`.
@property (assign, nonatomic) CGSize closeButtonShadowOffset;


/** @name Creating the release notes view */

/**
 Returns a release notes view initialized with custom parameters.
 @param releaseNotesTitle The title for the release notes view.
 @param releaseNotesText The release notes text.
 @param closeButtonTitle The title for the close button.
 @return The initialized release notes view.
 */
+ (TWSReleaseNotesView *)viewWithReleaseNotesTitle:(NSString *)releaseNotesTitle text:(NSString *)releaseNotesText closeButtonTitle:(NSString *)closeButtonTitle;

/**
 Creates a release notes view initialized with custom parameters and returns it in the completion block.
 @param appIdentifier The App Store app identifier for remote release notes retrieval.
 @param releaseNotesTitle The title for the release notes view.
 @param closeButtonTitle The title for the close button.
 @param completionBlock The block to be used as a completion handler. If the release notes retrieval is successful, a reference to the initialized release notes view is passed to the block. A `NSError` object is passed to the block otherwise.
 */
+ (void)setupViewWithAppIdentifier:(NSString *)appIdentifier releaseNotesTitle:(NSString *)releaseNotesTitle closeButtonTitle:(NSString *)closeButtonTitle completionBlock:(void (^)(TWSReleaseNotesView *releaseView, NSString *releaseNoteText, NSError *error))completionBlock;


/** @name Checking the app version */

/**
 Checks for app update state, using the `CFBundleVersion` key in the application `Info.plist`.
 @return  Returns `YES` if a previous app version string was stored and if it does not match the current version string, `NO` otherwise.
 */
+ (BOOL)isAppVersionUpdated;

/**
 Checks if the app version key is currently stored or not.
 @return  Returns `YES` if no previous app version string was stored, `NO` otherwise.
 */
+ (BOOL)isAppOnFirstLaunch;


/** @name Showing the release notes view */

/**
 Shows the release notes view in the specified container view.
 @param containerView The container view in which the release notes view must be shown.
 */
- (void)showInView:(UIView *)containerView;

@end
