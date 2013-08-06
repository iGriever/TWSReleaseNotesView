//
//  TWSReleaseNotesDownloadOperation.m
//  TWSReleaseNotesViewSample
//
//  Created by Matteo Lallone on 03/08/13.
//  Copyright (c) 2013 Tapwings. All rights reserved.
//

#import "TWSReleaseNotesDownloadOperation.h"
#import <UIKit/UIKit.h>

static NSString *const kTWSReleaseNotesDownloadOperationSearchURL = @"http://itunes.apple.com/lookup";
static NSString *const kTWSReleaseNotesDownloadOperationResultsArrayKey = @"results";
static NSString *const kTWSReleaseNotesDownloadOperationReleaseNotesKey = @"releaseNotes";
static NSString *const kTWSReleaseNotesDownloadOperationErrorDomain = @"com.tapwings.open.error.releaseNotes";
static const NSInteger kTWSReleaseNotesDownloadOperationDecodeErrorCode = 0;

@interface TWSReleaseNotesDownloadOperation () <NSURLConnectionDelegate>

@property (strong, nonatomic) NSURL *requestURL;
@property (strong, nonatomic) NSURLConnection *urlConnection;
@property (readwrite, strong, nonatomic) NSError *error;
@property (readwrite, copy, nonatomic) NSString *releaseNotesText;
@property (strong, nonatomic) NSMutableData *bufferData;
@property (strong, nonatomic) NSData *appMetadata;
@property (assign, nonatomic) BOOL isExecuting;
@property (assign, nonatomic) BOOL isConcurrent;
@property (assign, nonatomic) BOOL isFinished;

- (void)extractReleaseNotes;

@end

@implementation TWSReleaseNotesDownloadOperation

#pragma mark - Init - dealloc Methods

- (id)initWithAppIdentifier:(NSString *)appIdentifier
{
    self = [super init];
    
    if (self)
    {
        // Setup request URL
        NSLocale *locale = [NSLocale currentLocale];
        NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
        _requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?id=%@&country=%@", kTWSReleaseNotesDownloadOperationSearchURL, appIdentifier, countryCode]];
    }
    
    return self;
}

#pragma mark - Instance Methods

- (void)start
{
    // Setup URL request
    NSURLRequest *request = [NSURLRequest requestWithURL:self.requestURL];
    self.isExecuting = YES;
    self.isConcurrent = YES;
    self.isFinished = NO;
    
    // Setup URL connection
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.urlConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    }];
}

- (void)setIsExecuting:(BOOL)isExecuting
{
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = isExecuting;
    [self didChangeValueForKey:@"isExecuting"];
    
    // Toggle network activity indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:isExecuting];
}

- (void)setIsFinished:(BOOL)isFinished
{
    [self willChangeValueForKey:@"isFinished"];
    _isFinished = isFinished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)cancel
{
    [super cancel];
    
    // Cancel URL connection
    [self.urlConnection cancel];
    self.isFinished = YES;
    self.isExecuting = NO;
}

#pragma mark - Private Methods

- (void)extractReleaseNotes
{
    // Decode data
    NSError *decodeError;
    id rootObject = [NSJSONSerialization JSONObjectWithData:self.appMetadata options:NSJSONReadingAllowFragments error:&decodeError];
    
    if (!decodeError && [rootObject isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *rootDictionary = (NSDictionary *)rootObject;
        id resultsObject = rootDictionary[kTWSReleaseNotesDownloadOperationResultsArrayKey];
        
        if ([resultsObject isKindOfClass:[NSArray class]])
        {
            NSArray *resultsArray = (NSArray *)resultsObject;
            if ([resultsArray count])
            {
                id metadataObject = resultsArray[0];
                
                if ([metadataObject isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *metadataDictionary = (NSDictionary *)metadataObject;
                    id releaseNotesObject = metadataDictionary[kTWSReleaseNotesDownloadOperationReleaseNotesKey];
                    
                    if ([releaseNotesObject isKindOfClass:[NSString class]])
                    {
                        // Set release note text
                        self.releaseNotesText = releaseNotesObject;
                        
                        self.isExecuting = NO;
                        self.isFinished = YES;
                        
                        return;
                    }
                }
            }
        }
    }
    
    decodeError = [NSError errorWithDomain:kTWSReleaseNotesDownloadOperationErrorDomain code:kTWSReleaseNotesDownloadOperationDecodeErrorCode userInfo:nil];
    self.error = decodeError;
    self.isExecuting = NO;
    self.isFinished = YES;
}

#pragma mark - NSURLConnectionDelegate Methods

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    return request;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Setup buffer
    self.bufferData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append data to buffer
    [self.bufferData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set release notes data
    self.appMetadata = self.bufferData;
    self.bufferData = nil;
    
    // Extract release notes text
    [self extractReleaseNotes];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // Set error
    self.error = error;
        
    self.isExecuting = NO;
    self.isFinished = YES;
}

@end
