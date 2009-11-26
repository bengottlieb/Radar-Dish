//
//  BR_StatusReportWidget.m
//  BugReporter
//
//  Created by Ben Gottlieb on 11/5/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import "BR_StatusReportWidget.h"
#import "RD_Headers.h"

@implementation BR_StatusReportWidget


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(connectionStatusChanged:) name: kNotification_connectionStatusChanged object: nil];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		self.alpha = 0.0;
    }
    return self;
}

- (void) didMoveToSuperview {
	CGRect					bounds = self.superview.bounds;
	float					height = 15;
	
	self.frame = CGRectMake(0, bounds.size.height - height, bounds.size.width, height);
}

- (void) connectionStatusChanged: (NSNotification *) note {
	_status = [note.object intValue];
	
	[self setNeedsDisplay];

	[UIView beginAnimations: nil context: nil];
	if (_status == radar_submit_state_idle) {
		self.alpha = 0.0;
	} else {
		self.alpha = 0.65;
	}
	[UIView commitAnimations];
	
}

- (NSString *) stateDescription: (radar_submit_state) state {
	return [[NSArray arrayWithObjects: @"Connecting…",
			@"Loading Credentials Form…",
			@"Submitting Credentials…",
			@"Loading Problem Entry…",
			@"Submitting Problem…",
			@"", nil] objectAtIndex: state];
}

- (void) drawRect: (CGRect) rect {
	NSString					*desc = [self stateDescription: _status];
	
	[[UIColor blackColor] set];
	UIRectFill([self bounds]);
	
	[[UIColor whiteColor] set];
	
	UIFont					*font = [UIFont systemFontOfSize: 12];
	CGSize					size = [desc sizeWithFont: font];
	CGRect					bounds = self.bounds;
	CGPoint					drawPoint = CGPointMake((bounds.size.width - size.width) / 2, (bounds.size.height - size.height) / 2);
	
	[desc drawAtPoint: drawPoint withFont: font];
}


- (void)dealloc {
    [super dealloc];
}


@end
