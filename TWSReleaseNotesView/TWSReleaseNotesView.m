//
//  TWSReleaseNotesView.m
//  TWSReleaseNotesViewSample
//
//  Created by Matteo Lallone on 02/08/13.
//  Copyright (c) 2013 Tapwings. All rights reserved.
//

#import "TWSReleaseNotesView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+ImageEffects.h"
#import "TWSReleaseNotesDownloadOperation.h"

@interface TWSUnselectableTextView : UITextView

- (BOOL)canBecomeFirstResponder;

@end

@implementation TWSUnselectableTextView

- (BOOL)canBecomeFirstResponder
{
    return NO;
}

@end

static NSString *const kTWSReleaseNotesViewVersionKey = @"com.tapwings.open.kTWSReleaseNotesViewControllerVersionKey";
static const CGFloat kTWSReleaseNotesViewDefaultOverlayAlpha = 0.5f;
static const CGFloat kTWSReleaseNotesViewDefaultTextViewBackgroundAlpha = 0.8f;
static const CGFloat kTWSReleaseNotesViewContainerViewCornerRadius = 3.0f;
static const CGFloat kTWSReleaseNotesViewContainerViewWidth = 280.0f;
static const CGFloat kTWSReleaseNotesViewContainerViewMinVerticalPadding = 60.0f;
static const CGFloat kTWSReleaseNotesViewInnerContainerSidePadding = 6.0f;
static const CGFloat kTWSReleaseNotesViewBlurredImageViewCornerRadius = 5.0f;
static const CGFloat kTWSReleaseNotesViewTitleSidePadding = 6.0f;
static const CGFloat kTWSReleaseNotesViewTitleLabelHeight = 44.0f;
static const CGFloat kTWSReleaseNotesViewTextViewInsetHeight = 9.0f;
static const CGFloat kTWSReleaseNotesViewButtonBoxHeight = 44.0f;
static const CGFloat kTWSReleaseNotesViewSeparatorHeight = 1.0f;
static const CGFloat kTWSReleaseNotesViewAnimationSpringScaleFactor = 0.05f;
static const NSTimeInterval kTWSReleaseNotesViewTransitionDuration = 0.2f;

@interface TWSReleaseNotesView ()

@property (copy, nonatomic) NSString *releaseNotesTitle;
@property (copy, nonatomic) NSString *releaseNotesText;
@property (copy, nonatomic) NSString *closeButtonTitle;
@property (strong, nonatomic) UIView *popupView;
@property (strong, nonatomic) UIImageView *backgroundBlurredImageView;
@property (strong, nonatomic) UIView *backgroundOverlayView;
@property (strong, nonatomic) UIView *textContainerView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) TWSUnselectableTextView *textView;
@property (strong, nonatomic) UIButton *closeButton;

- (id)initWithReleaseNotesTitle:(NSString *)releaseNotesTitle text:(NSString *)releaseNotesText closeButtonTitle:(NSString *)closeButtonTitle;
- (void)setupSubviews;
- (void)updateSubviewsLayoutInContainerView:(UIView *)containerView;
- (void)prepareToShowInView:(UIView *)containerView;
- (void)applyBlurredImageBackgroundFromView:(UIView *)view;
- (UIView *)separatorInView:(UIView *)containerView belowView:(UIView *)topView;
- (CGFloat)expectedReleaseNotesTextHeightWithWidth:(CGFloat)width;
- (void)closeButtonTouchedDown:(id)sender;
- (void)closeButtonTouchedUp:(id)sender;
- (void)closeButtonDragExit:(id)sender;
- (void)closeButtonDragEnter:(id)sender;
- (void)dismiss;
+ (void)storeCurrentAppVersionString;

@end

@implementation TWSReleaseNotesView

#pragma mark - Init - dealloc Methods

- (id)initWithReleaseNotesTitle:(NSString *)releaseNotesTitle text:(NSString *)releaseNotesText closeButtonTitle:(NSString *)closeButtonTitle
{
    self = [super init];
    
    if (self)
    {
        // Setup user-defined properties
        _releaseNotesTitle = [releaseNotesTitle copy];
        _releaseNotesText = [releaseNotesText copy];
        _closeButtonTitle = [closeButtonTitle copy];
        
        // Setup default properties
        _overlayAlpha = kTWSReleaseNotesViewDefaultOverlayAlpha;
        _textViewAlpha = kTWSReleaseNotesViewDefaultTextViewBackgroundAlpha;
        _textViewBackgroundColor = [UIColor blackColor];
        _darkSeparatorColor = [UIColor colorWithRed:16.0f/255.0f green:16.0f/255.0f blue:16.0f/255.0f alpha:1.0];
        _lightSeparatorColor = [UIColor colorWithRed:58.0f/255.0f green:58.0f/255.0f blue:65.0f/255.0f alpha:1.0];
        _viewShadowColor = [UIColor blackColor];
        _viewShadowOffset = CGSizeMake(0.0f, 3.0f);
        _viewShadowRadius = 3.0f;
        _viewShadowOpacity = 1.0f;
        _titleFont = [UIFont systemFontOfSize:16.0f];
        _titleColor = [UIColor whiteColor];
        _titleShadowColor = [UIColor blackColor];
        _titleShadowOffset = CGSizeMake(0.0f, -1.0f);
        _releaseNotesFont = [UIFont systemFontOfSize:14.0f];
        _releaseNotesColor = [UIColor whiteColor];
        _releaseNotesShadowColor = [UIColor blackColor];
        _releaseNotesShadowOffset = CGSizeMake(0.0f, -1.0f);
        _closeButtonFont = [UIFont systemFontOfSize:16.0f];
        _closeButtonColor = [UIColor whiteColor];
        _closeButtonShadowColor = [UIColor blackColor];
        _closeButtonShadowOffset = CGSizeMake(0.0f, -1.0f);
        
        // Orientation change notification
        __weak TWSReleaseNotesView *weakSelf = self;
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidChangeStatusBarOrientationNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note){
            double delayInSeconds = 0.01f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Refresh blurred image background
                TWSReleaseNotesView *strongSelf = weakSelf;
                UIView *containerView = [strongSelf superview];
                [strongSelf removeFromSuperview];
                [strongSelf applyBlurredImageBackgroundFromView:containerView];
                [strongSelf updateSubviewsLayoutInContainerView:containerView];
                [containerView addSubview:strongSelf];
            });
        }];

        // Setup subview hierarchy
        [self setupSubviews];
    }
    
    return self;
}

- (void)dealloc
{
    // Remove orientation change notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

#pragma mark - Class Methods

+ (TWSReleaseNotesView *)viewWithReleaseNotesTitle:(NSString *)releaseNotesTitle text:(NSString *)releaseNotesText closeButtonTitle:(NSString *)closeButtonTitle
{
    // Setup release controller
    TWSReleaseNotesView *releaseNotesView = [[TWSReleaseNotesView alloc] initWithReleaseNotesTitle:releaseNotesTitle text:releaseNotesText closeButtonTitle:closeButtonTitle];
    return releaseNotesView;
}

+ (void)setupViewWithAppIdentifier:(NSString *)appIdentifier releaseNotesTitle:(NSString *)releaseNotesTitle closeButtonTitle:(NSString *)closeButtonTitle completionBlock:(void (^)(TWSReleaseNotesView *, NSString *, NSError *))completionBlock
{
    // Setup operation queue
    NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 1;
    TWSReleaseNotesDownloadOperation *operation = [[TWSReleaseNotesDownloadOperation alloc] initWithAppIdentifier:appIdentifier];
    
    __weak TWSReleaseNotesDownloadOperation *weakOperation = operation;
    [operation setCompletionBlock:^{
        TWSReleaseNotesDownloadOperation *strongOperation = weakOperation;
        if (completionBlock)
        {
            if (strongOperation.error)
            {
                NSError *error = strongOperation.error;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Perform completion block with error
                    completionBlock(nil, nil, error);
                }];
            }
            else
            {
                // Get release note text
                NSString *releaseNotesText = strongOperation.releaseNotesText;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Create and show release notes view
                    TWSReleaseNotesView *releaseNotesView = [TWSReleaseNotesView viewWithReleaseNotesTitle:releaseNotesTitle text:releaseNotesText closeButtonTitle:closeButtonTitle];
                    
                    // Perform completion block 
                    completionBlock(releaseNotesView, releaseNotesText, nil);
                }];
            }
        }
    }];
    
    // Add operation
    [operationQueue addOperation:operation];
}

+ (BOOL)isAppVersionUpdated
{
    // Read stored version string and current version string
    NSString *previousAppVersion = [[NSUserDefaults standardUserDefaults] stringForKey:kTWSReleaseNotesViewVersionKey];
    NSString *currentAppVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
 
    // Flag app as updated if a previous version string is found and it does not match with the current version string
    BOOL isUpdated = (previousAppVersion && ![previousAppVersion isEqualToString:currentAppVersion]) ? YES : NO;

    if (isUpdated || !previousAppVersion)
    {
        // Store current app version if needed
        [self storeCurrentAppVersionString];
    }
    
    return isUpdated;
}

+ (BOOL)isAppOnFirstLaunch
{
    // Read stored version string
    NSString *previousAppVersion = [[NSUserDefaults standardUserDefaults] stringForKey:kTWSReleaseNotesViewVersionKey];

    // Flag app as on first launch if no previous app string is found
    BOOL isFirstLaunch = (!previousAppVersion) ? YES : NO;

    if (isFirstLaunch)
    {
        // Store current app version if needed
        [self storeCurrentAppVersionString];
    }
    
    return isFirstLaunch;
}

#pragma mark - Private Methods

- (void)setupSubviews
{
    // Main properties
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    // Main text container view
    _popupView = [[UIView alloc] initWithFrame:CGRectZero];
    [_popupView setBackgroundColor:[UIColor clearColor]];
    [_popupView setClipsToBounds:NO];
    [_popupView.layer setCornerRadius:kTWSReleaseNotesViewContainerViewCornerRadius];
    [_popupView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self addSubview:_popupView];
    
    // Blurred background view
    _backgroundBlurredImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_backgroundBlurredImageView setContentMode:UIViewContentModeCenter];
    [_backgroundBlurredImageView setClipsToBounds:YES];
    [_backgroundBlurredImageView.layer setCornerRadius:kTWSReleaseNotesViewBlurredImageViewCornerRadius];
    [_backgroundBlurredImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_popupView addSubview:_backgroundBlurredImageView];
    
    // Background overlay view
    _backgroundOverlayView = [[UIView alloc] initWithFrame:CGRectZero];
    [_backgroundOverlayView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_backgroundOverlayView setClipsToBounds:YES];
    [_backgroundOverlayView.layer setCornerRadius:kTWSReleaseNotesViewContainerViewCornerRadius];
    [_backgroundBlurredImageView addSubview:_backgroundOverlayView];
    
    // Main text container view
    _textContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    [_textContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_textContainerView.layer setBorderWidth:1.0f];
    [_textContainerView.layer setShadowOffset:CGSizeMake(0.0f, 1.0f)];
    [_textContainerView.layer setShadowRadius:0.0f];
    [_textContainerView.layer setShadowOpacity:1.0f];
    [_popupView addSubview:_textContainerView];
    
    // Title label
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setNumberOfLines:2];
    [_titleLabel.layer setShadowRadius:0.0f];
    [_titleLabel.layer setShadowOpacity:1.0f];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setText:_releaseNotesTitle];
    [_popupView addSubview:_titleLabel];
    
    // Release notes text view
    _textView = [[TWSUnselectableTextView alloc] initWithFrame:CGRectZero];
    [_textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_textView setBackgroundColor:[UIColor clearColor]];
    [_textView.layer setShadowRadius:0.0f];
    [_textView.layer setShadowOpacity:1.0f];
    [_textView setEditable:NO];
    [_textView setText:_releaseNotesText];
    [_popupView addSubview:_textView];
    
    // Close button
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [_closeButton setTitle:_closeButtonTitle forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeButtonTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
    [_closeButton addTarget:self action:@selector(closeButtonTouchedDown:) forControlEvents:UIControlEventTouchDown];
    [_closeButton addTarget:self action:@selector(closeButtonDragExit:) forControlEvents:UIControlEventTouchDragExit];
    [_closeButton addTarget:self action:@selector(closeButtonDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
    [_popupView addSubview:_closeButton];
}

- (void)updateSubviewsLayoutInContainerView:(UIView *)containerView
{
    // Update main properties
    CGRect containerBounds = [containerView bounds];
    [self setFrame:containerBounds];
    
    // Calculate text view height
    CGFloat textViewWidth = kTWSReleaseNotesViewContainerViewWidth - 2*kTWSReleaseNotesViewInnerContainerSidePadding;
    CGFloat textViewContentHeight = [self expectedReleaseNotesTextHeightWithWidth:textViewWidth];
    
    // Calculate popup view vertical padding
    CGFloat popupViewExpectedHeight = kTWSReleaseNotesViewTitleLabelHeight + textViewContentHeight + kTWSReleaseNotesViewButtonBoxHeight + 2*kTWSReleaseNotesViewSeparatorHeight + 2*kTWSReleaseNotesViewInnerContainerSidePadding;
    CGFloat popupViewExpectedVerticalPadding = floorf((containerBounds.size.height - popupViewExpectedHeight) / 2.0f);
    CGFloat popupViewVerticalPadding = MAX(popupViewExpectedVerticalPadding, kTWSReleaseNotesViewContainerViewMinVerticalPadding);
    
    // Popup view
    [self.popupView setFrame:CGRectInset(containerBounds, floorf((containerBounds.size.width - kTWSReleaseNotesViewContainerViewWidth)/2.0f), popupViewVerticalPadding)];
    [self.popupView.layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.popupView.bounds] CGPath]];

    // Background blurred image view
    [self.backgroundBlurredImageView setFrame:self.popupView.bounds];
    
    // Background overlay view
    [self.backgroundOverlayView setFrame:self.popupView.bounds];
    
    // Text container view
    [self.textContainerView setFrame:CGRectInset(self.popupView.bounds, kTWSReleaseNotesViewInnerContainerSidePadding, kTWSReleaseNotesViewInnerContainerSidePadding)];
    
    // Title label frame
    CGRect titleLabelFrame = CGRectInset(self.textContainerView.frame, kTWSReleaseNotesViewTitleSidePadding, 0.0f);
    titleLabelFrame.size.height = kTWSReleaseNotesViewTitleLabelHeight;
    [self.titleLabel setFrame:titleLabelFrame];
    
    // Top separator
    UIView *topSeparatorView = [self separatorInView:self.textContainerView belowView:self.titleLabel];
    [topSeparatorView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
    [self.textContainerView addSubview:topSeparatorView];
    
    // Text view frame
    CGRect textViewFrame = self.textContainerView.frame;
    textViewFrame.origin.y = CGRectGetMinY(textViewFrame) + kTWSReleaseNotesViewTitleLabelHeight + 2*kTWSReleaseNotesViewSeparatorHeight;
    textViewFrame.size.height = self.textContainerView.frame.size.height - kTWSReleaseNotesViewTitleLabelHeight - 3*kTWSReleaseNotesViewSeparatorHeight - kTWSReleaseNotesViewButtonBoxHeight;
    [self.textView setFrame:textViewFrame];
    
    // Bottom separator
    UIView *bottomSeparatorView = [self separatorInView:self.textContainerView belowView:self.textView];
    [bottomSeparatorView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [self.textContainerView addSubview:bottomSeparatorView];
    
    // Close button
    CGRect closeButtonFrame = self.textContainerView.frame;
    closeButtonFrame.origin.y = CGRectGetMaxY(closeButtonFrame) - kTWSReleaseNotesViewButtonBoxHeight;
    closeButtonFrame.size.height = kTWSReleaseNotesViewButtonBoxHeight;
    [self.closeButton setFrame:closeButtonFrame];
}

- (void)prepareToShowInView:(UIView *)containerView
{
    // Update subviews layout
    [self updateSubviewsLayoutInContainerView:containerView];

    // Initial properties for show animation
    [self setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f]];
    
    [self.popupView setAlpha:0.0f];
    [self.popupView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.0f, 0.0f)];
    [self.popupView.layer setShadowColor:[self.viewShadowColor CGColor]];
    [self.popupView.layer setShadowOffset:self.viewShadowOffset];
    [self.popupView.layer setShadowRadius:self.viewShadowRadius];
    [self.popupView.layer setShadowOpacity:self.viewShadowOpacity];
    
    [self.backgroundOverlayView setBackgroundColor:[self.textViewBackgroundColor colorWithAlphaComponent:self.textViewAlpha]];
    
    [self.textContainerView.layer setBorderColor:[self.darkSeparatorColor CGColor]];
    [self.textContainerView.layer setShadowColor:[self.lightSeparatorColor CGColor]];
    
    [self.titleLabel setFont:self.titleFont];
    [self.titleLabel setTextColor:self.titleColor];
    [self.titleLabel.layer setShadowColor:[self.titleShadowColor CGColor]];
    [self.titleLabel.layer setShadowOffset:self.titleShadowOffset];
    
    [self.textView setFont:self.releaseNotesFont];
    [self.textView setTextColor:self.releaseNotesColor];
    [self.textView.layer setShadowColor:[self.releaseNotesShadowColor CGColor]];
    [self.textView.layer setShadowOffset:self.releaseNotesShadowOffset];
    
    [self.closeButton.titleLabel setFont:self.closeButtonFont];
    [self.closeButton setTitleColor:self.closeButtonColor forState:UIControlStateNormal];
    [self.closeButton setTitleShadowColor:self.closeButtonShadowColor forState:UIControlStateNormal];
    [self.closeButton.titleLabel setShadowOffset:self.closeButtonShadowOffset];
    
    [self applyBlurredImageBackgroundFromView:containerView];

    // Add to container view
    [containerView addSubview:self];
}

- (void)applyBlurredImageBackgroundFromView:(UIView *)view
{
    // Clone background image
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0f);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *cloneImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Apply blur effect
    UIImage *blurredImage = [cloneImage applySubtleEffect];
    self.backgroundBlurredImageView.image = blurredImage;
    [self.backgroundBlurredImageView setNeedsDisplay];
}

- (UIView *)separatorInView:(UIView *)containerView belowView:(UIView *)topView
{
    // Setup separator view
    CGRect topViewFrame = [containerView convertRect:topView.frame fromView:[topView superview]];
    CGRect separatorFrame = CGRectMake(containerView.bounds.origin.x, CGRectGetMaxY(topViewFrame), containerView.bounds.size.width, kTWSReleaseNotesViewSeparatorHeight);
    UIView *separatorView = [[UIView alloc] initWithFrame:separatorFrame];
    [separatorView setBackgroundColor:self.darkSeparatorColor];

    return separatorView;
}

- (CGFloat)expectedReleaseNotesTextHeightWithWidth:(CGFloat)width;
{
    CGSize maximumLabelSize = CGSizeMake(width, MAXFLOAT);
    CGSize expectedLabelSize = [self.releaseNotesText sizeWithFont:self.releaseNotesFont constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    return expectedLabelSize.height + 2*kTWSReleaseNotesViewTextViewInsetHeight;
}

- (void)closeButtonTouchedUp:(id)sender
{
    // Un-highlight button on touch up
    [self.closeButton setBackgroundColor:[UIColor clearColor]];

    // Dismiss release notes view
    [self dismiss];
}

- (void)closeButtonTouchedDown:(id)sender
{
    // Highlight button on touch down
    [self.closeButton setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
}

- (void)closeButtonDragExit:(id)sender
{
    // Un-highlight button on exit
    [self.closeButton setBackgroundColor:[UIColor clearColor]];
}

- (void)closeButtonDragEnter:(id)sender
{
    // Highlight button on enter
    [self.closeButton setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
}

- (void)dismiss
{
    // Dismiss release notes view
    [UIView animateWithDuration:kTWSReleaseNotesViewTransitionDuration/2.0f animations:^{
        [self.popupView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.0f + kTWSReleaseNotesViewAnimationSpringScaleFactor, 1.0f + kTWSReleaseNotesViewAnimationSpringScaleFactor)];
    } completion:^(BOOL finished){
        if (finished)
        {
            [UIView animateWithDuration:kTWSReleaseNotesViewTransitionDuration animations:^{
                [self setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f]];
                [self.popupView setAlpha:0.0f];
                [self.popupView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.0f, 0.0f)];
            } completion:^(BOOL finished){
                if (finished)
                {
                    [self removeFromSuperview];
                }
            }];
        }
    }];
}

+ (void)storeCurrentAppVersionString
{
    // Store current app version string in the user defaults
    NSString *currentAppVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    [[NSUserDefaults standardUserDefaults] setObject:currentAppVersion forKey:kTWSReleaseNotesViewVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Instance Methods

- (void)showInView:(UIView *)containerView
{    
    // Setup view before animation
    [self prepareToShowInView:containerView];

    // Show release notes view
    [UIView animateWithDuration:kTWSReleaseNotesViewTransitionDuration animations:^{
        [self setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:self.overlayAlpha]];
        [self.popupView setAlpha:1.0f];
        [self.popupView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.0f + kTWSReleaseNotesViewAnimationSpringScaleFactor, 1.0f + kTWSReleaseNotesViewAnimationSpringScaleFactor)];
    } completion:^(BOOL finished){
        if (finished)
        {
            [UIView animateWithDuration:kTWSReleaseNotesViewTransitionDuration/2.0f animations:^{
                [self.popupView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.0f - kTWSReleaseNotesViewAnimationSpringScaleFactor, 1.0f - kTWSReleaseNotesViewAnimationSpringScaleFactor)];
            } completion:^(BOOL finished){
                if (finished)
                {
                    [UIView animateWithDuration:kTWSReleaseNotesViewTransitionDuration/2.0f animations:^{
                        [self.popupView setTransform:CGAffineTransformIdentity];
                    }];
                }
            }];
        }
    }];
}

@end
