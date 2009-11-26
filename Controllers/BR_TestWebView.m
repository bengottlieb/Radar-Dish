//
//  BR_TestWebView.m
//  BugReporter
//
//  Created by Ben Gottlieb on 10/30/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import "BR_TestWebView.h"


@implementation BR_TestWebView
@synthesize webView = _webView;

+ (id) controller {
	return [[[self alloc] initWithNibName: @"TestWebView" bundle: nil] autorelease];
}

- (void) viewDidAppear: (BOOL) animated {
	[super viewDidAppear: animated];
	[self.webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: @"https://www.google.com/accounts/ServiceLogin?service=ah&continue=http://openradar.appspot.com/_ah/login%3Fcontinue%3Dhttp://openradar.appspot.com/page/1&ltmpl=gm&ahname=Open+Radar&sig=f1b3130e643411d633dfd820219de130"]]];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (BOOL) webView: (UIWebView *) webView shouldStartLoadWithRequest: (NSURLRequest *) request navigationType: (UIWebViewNavigationType) navigationType {
	NSLog(@"Loading request: %@", [request URL]);
	if ([request HTTPBody]) NSLog(@"Loading request: %s", [[request HTTPBody] bytes]);
	return YES;
}



@end
