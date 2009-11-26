//
//  BR_OpenRadarSubmitter.m
//  BugReporter
//
//  Created by Ben Gottlieb on 11/5/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import "BR_OpenRadarSubmitter.h"
#import "BR_AppDelegate.h"
#import "RD_Headers.h"
#import "BR_BugReportManager.h"


@implementation BR_OpenRadarSubmitter

+ (BR_OpenRadarSubmitter *) submitter {
	static BR_OpenRadarSubmitter			*submitter = nil;
	
	if (submitter == nil) submitter = [[BR_OpenRadarSubmitter alloc] init];
	
	return submitter;
}

- (void) submitReport: (BR_BugReport *) report showProgress: (BOOL) progress {
	if (_queue == nil) _queue = [[NSMutableArray alloc] init];
	
	if (report.submittedToOpenRadar) return;
	[_queue addObject: report];
	
	_showProgress = progress;
	if (_currentReport == nil) {
		_currentReport = [report retain];
		[self continueSubmission];
	}
}

//=============================================================================================================================
#pragma mark Submission steps
- (void) continueSubmission {
	if (_webView == nil) {
		_webView = [[UIWebView alloc] initWithFrame: CGRectMake(0, 64, 320, 416)];
		_webView.alpha = 0.4;
		_webView.userInteractionEnabled = NO;
		_webView.delegate = self;
	}
	if (_showProgress) [g_appDelegate.window addSubview: _webView]; else [_webView removeFromSuperview];
	
	switch (_state) {
		case radar_submit_state_notStarted:
			[_webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: @"https://www.google.com/accounts/ServiceLogin?service=ah&continue=http://openradar.appspot.com/_ah/login%3Fcontinue%3Dhttp://openradar.appspot.com/page/1&ltmpl=gm&ahname=Open+Radar&sig=f1b3130e643411d633dfd820219de130"]]];
			_state = radar_submit_state_credentialEntryLoading;
			break;
			
		case radar_submit_state_credentialEntryLoading:
		case radar_submit_state_welcomeScreenLoading:
		case radar_submit_state_newProblemScreenLoading:
		case radar_submit_state_submitting:
			break;
			
		case radar_submit_state_idle:
			_state = _newProblemRequest ? radar_submit_state_newProblemScreenLoading : radar_submit_state_notStarted;
			[_webView loadRequest: _newProblemRequest ? _newProblemRequest : [NSURLRequest requestWithURL: [NSURL URLWithString: @"https://bugreport.apple.com/cgi-bin/WebObjects/RadarWeb.woa"]]];
			break;
	}

	[[NSNotificationCenter defaultCenter] postNotificationName: kNotification_connectionStatusChanged object: [NSNumber numberWithInt: _state]];
}

- (void) webViewDidFinishLoad: (UIWebView *) webView {
	NSString					*script = nil, *title = [_webView stringByEvaluatingJavaScriptFromString: @"document.title"];;
	
	NSLog(@"Loaded: %@", [_webView stringByEvaluatingJavaScriptFromString: @"document.title"]);
	
	switch (_state) {
		case radar_submit_state_credentialEntryLoading:
			if (title.length == 0) break;
			script = [NSString stringWithFormat: @"document.getElementById('Email').value = '%@'; document.getElementById('Passwd').value = '%@'; document.forms['gaia_loginform'].submit()", 
					  [[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_OpenRadarUsernameKey], [[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_OpenRadarPasswordKey]];
			[_webView stringByEvaluatingJavaScriptFromString: script];
			_state = radar_submit_state_welcomeScreenLoading;
			break;
			
		case radar_submit_state_welcomeScreenLoading:
			if ([title isEqualToString: @"Open Radar"]) {
				_state = radar_submit_state_newProblemScreenLoading;
				[_webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: @"http://openradar.appspot.com/myradars/add"]]];
			}
			break;
			
		case radar_submit_state_newProblemScreenLoading:
			if (_newProblemRequest == nil) _newProblemRequest = [webView.request retain];
			script = [NSString stringWithFormat:
					  @"document.forms[1]['title'].value = '%@';"
					  @"document.forms[1]['description'].value = '%@';"
					  @"document.forms[1]['product'].value = '%@';"
					  @"document.forms[1]['product_version'].value = '%@';"
					  @"document.forms[1]['classification'].value = '%@';"
					  @"document.forms[1]['reproducible'].value = '%@';"

					  @"document.forms[1]['number'].value = '%@';"
					  @"document.forms[1]['originated'].value = '%@';"
					  @"document.forms[1]['status'].value = '%@';"
					  @"document.forms[1]['resolved'].value = '%@';"
						,
						[_currentReport.title stringByReplacingOccurrencesOfString: @"'" withString: @"\\'"],
						(_currentReport.details ? [_currentReport.details stringByReplacingOccurrencesOfString: @"'" withString: @"\\'"] : @""),
						_currentReport.product ? _currentReport.product : @"",
						[_currentReport.version stringByReplacingOccurrencesOfString: @"'" withString: @"\\'"],
						_currentReport.classification ? _currentReport.classification : @"",
						_currentReport.reproducible ? _currentReport.reproducible : @"",
													
						_currentReport.radarID.length ? _currentReport.radarID : @"",
						_currentReport.originatedDateString,
						_currentReport.status ? _currentReport.status : @"",
						_currentReport.resolved ? _currentReport.resolved : @""
					];
													
			[_webView stringByEvaluatingJavaScriptFromString: script];
			[_webView stringByEvaluatingJavaScriptFromString: @"document.forms[1].submit()"];
			_webView.alpha = 0.35;
			_state = radar_submit_state_submitting;
			break;
			
		case radar_submit_state_submitting:
			script = @"document.getElementById('content').innerHTML";
			_currentReport.openRadarID = [self extractLatestRadarIDFromHTML: [_webView stringByEvaluatingJavaScriptFromString: script]];
			[g_appDelegate saveContext];
			_state = radar_submit_state_idle;
			[self finishCurrentReport];
			break;
			
		case radar_submit_state_idle:
			break;
	}
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName: kNotification_connectionStatusChanged object: [NSNumber numberWithInt: _state]];
}

- (NSString *) convertOption: (NSString *) option toValueForID: (NSString *) objectID {
	NSString				*script = [NSString stringWithFormat: @"var s = document.getElementById('%@'); for (var i = 0; i < s.options.length; i++) {if (s.options[i].text == '%@') break;} s.options[i].value;", 
									   objectID, [option stringByReplacingOccurrencesOfString: @"'" withString: @"\\'"]];
	
	return [_webView stringByEvaluatingJavaScriptFromString: script];
}

- (void) finishCurrentReport {
	[_queue removeObject: _currentReport];
	[_currentReport release];
	_currentReport = nil;
	_state = radar_submit_state_idle;
	if (_queue.count) [self submitReport: [_queue objectAtIndex: 0] showProgress: _showProgress];
}

- (NSString *) extractLatestRadarIDFromHTML: (NSString *) content {
	char				*chunk = nil, *raw = (char *) [content UTF8String];
	char				*nextChunk = raw;
	char				*searchString = "radar?id=";
	
	while (nextChunk = strstr(nextChunk, searchString)) {
		chunk = nextChunk;
		nextChunk = &nextChunk[1];
	}
	
	if (chunk) {
		int				number = atoi(&chunk[strlen(searchString)]);
		
		return [NSString stringWithFormat: @"%d", number];
	}
	NSLog(@"Parse This for ids:\n%@", content);
	return @"";
}
@end

