//
//  TWSReleaseNotesDownloadOperation.h
//  TWSReleaseNotesViewSample
//
//  Created by Matteo Lallone on 03/08/13.
//  Copyright (c) 2013 Tapwings. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Use the `TWSReleaseNotesDownloadOperation` class to create an operation with the purpose of downloading the release notes text for a specified app, using the iTunes Search API.
 
 The result of the operation is accessible in the `completionBlock`, using the <releaseNotesText> and the <error> properties.
 
 */
@interface TWSReleaseNotesDownloadOperation : NSOperation


/** @name Getting main properties */

/// The downloaded release notes text.
@property (readonly, copy, nonatomic) NSString *releaseNotesText;

/// An error object associated to the failed operation.
@property (readonly, strong, nonatomic) NSError *error;


/** @name Creating the operation */

/**
 Creates and operation with custom parameters.
 @param appIdentifier The App Store app identifier for remote release notes retrieval.
 @return The initialized operation.
 */
- (id)initWithAppIdentifier:(NSString *)appIdentifier;

@end
