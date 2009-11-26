//
//  BR_RadarSubmitter.m
//  BugReporter
//
//  Created by Ben Gottlieb on 11/5/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import "BR_RadarSubmitter.h"
#import "BR_AppDelegate.h"
#import "RD_Headers.h"
#import "BR_BugReportManager.h"
#import "BR_OpenRadarSubmitter.h"


@implementation BR_RadarSubmitter

+ (BR_RadarSubmitter *) submitter {
	static BR_RadarSubmitter			*submitter = nil;
	
	if (submitter == nil) submitter = [[BR_RadarSubmitter alloc] init];
	
	return submitter;
}

- (void) submitReport: (BR_BugReport *) report showProgress: (BOOL) progress {
	if (_queue == nil) _queue = [[NSMutableArray alloc] init];
	
	if (report.submittedToRadar) return;
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
		_webView.alpha = 0.7;
		_webView.userInteractionEnabled = NO;
		_webView.delegate = self;
	}
	if (_showProgress) [g_appDelegate.window addSubview: _webView]; else [_webView removeFromSuperview];
	
	switch (_state) {
		case radar_submit_state_notStarted:
			[_webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: @"https://bugreport.apple.com/cgi-bin/WebObjects/RadarWeb.woa"]]];
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
	NSString					*script = nil;
	NSString					*title = [_webView stringByEvaluatingJavaScriptFromString: @"document.title"];
	
	NSLog(@"Loaded: %@", title);
	
	switch (_state) {
		case radar_submit_state_credentialEntryLoading:
			if (title.length == 0) break;
			script = [NSString stringWithFormat: @"document.forms['appleConnectForm'].elements['theAccountName'].value = '%@'; document.forms['appleConnectForm'].elements['theAccountPW'].value = '%@'; document.forms['appleConnectForm'].submit();", 
					  [[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_RadarUsernameKey], [[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_RadarPasswordKey]];
			[_webView stringByEvaluatingJavaScriptFromString: script];
			_state = radar_submit_state_welcomeScreenLoading;
			break;
			
		case radar_submit_state_welcomeScreenLoading:
			if ([title isEqualToString: @"RadarWeb iPhone"]) {
				_state = radar_submit_state_newProblemScreenLoading;
				script = [NSString stringWithFormat: @"document.Home.txtHomeHidden.value='NewProblem'; document.forms['Home'].submit()"];
				[_webView stringByEvaluatingJavaScriptFromString: script];
			}
			break;
			
		case radar_submit_state_newProblemScreenLoading:
			if (_newProblemRequest == nil) _newProblemRequest = [webView.request retain];
			script = [NSString stringWithFormat:	@"document.getElementById('textareaTitle').value = '%@';"
					  @"document.getElementById('textareaDesc').value = '%@';"
					  @"document.getElementById('popupProduct').value = '%@';"
					  @"document.getElementById('popupClass').value = '%@';"
					  @"document.getElementById('popupReprod').value = '%@';"
					  @"document.getElementById('textfieldVersion').value = '%@';"
						,
						[_currentReport.title stringByReplacingOccurrencesOfString: @"'" withString: @"\\'"],
						(_currentReport.details ? [_currentReport.details stringByReplacingOccurrencesOfString: @"'" withString: @"\\'"] : @""),
						[self convertOption: _currentReport.product toValueForID: @"popupProduct"],
						[self convertOption: _currentReport.classification toValueForID: @"popupClass"],
						[self convertOption: _currentReport.reproducible toValueForID: @"popupReprod"],
													
					  [_currentReport.version stringByReplacingOccurrencesOfString: @"'" withString: @"\\'"]
					];
													
			[_webView stringByEvaluatingJavaScriptFromString: script];
			[_webView stringByEvaluatingJavaScriptFromString: @"document.forms['NewProblemSubmit'].submit()"];
			_webView.alpha = 0.35;
			_state = radar_submit_state_submitting;
			break;
			
		case radar_submit_state_submitting:
			script = @"document.getElementById('txtProblemID').value";
			_currentReport.radarID = [_webView stringByEvaluatingJavaScriptFromString: script];
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
	if (_currentReport.autoSubmitToOpenRadar) [[BR_OpenRadarSubmitter submitter] submitReport: _currentReport showProgress: _showProgress];
	[_queue removeObject: _currentReport];
	[_currentReport release];
	_currentReport = nil;
	_state = radar_submit_state_idle;
	if (_queue.count) [self submitReport: [_queue objectAtIndex: 0] showProgress: _showProgress];
}
@end

