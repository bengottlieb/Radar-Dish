//
//  BR_RadarSubmitter.h
//  BugReporter
//
//  Created by Ben Gottlieb on 11/5/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RD_Headers.h"

@class BR_BugReport;

@interface BR_RadarSubmitter : NSObject <UIWebViewDelegate> {
	UIWebView					*_webView;
	BR_BugReport				*_currentReport;
	NSMutableArray				*_queue;
	radar_submit_state			_state;
	BOOL						_showProgress;
	NSURLRequest				*_newProblemRequest;
}

+ (BR_RadarSubmitter *) submitter;

- (void) submitReport: (BR_BugReport *) report showProgress: (BOOL) progress;
- (void) continueSubmission;

- (NSString *) convertOption: (NSString *) option toValueForID: (NSString *) objectID;

- (void) finishCurrentReport;
@end
