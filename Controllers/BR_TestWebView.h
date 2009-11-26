//
//  BR_TestWebView.h
//  BugReporter
//
//  Created by Ben Gottlieb on 10/30/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BR_TestWebView : UIViewController {
	UIWebView						*_webView;
}

@property (nonatomic, readwrite, assign) IBOutlet UIWebView *webView;

+ (id) controller;
@end
