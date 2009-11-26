//
//  BR_BugReport.m
//  BugReporter
//
//  Created by Ben Gottlieb on 10/31/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import "BR_BugReport.h"


@implementation BR_BugReport
@dynamic title, classification, details, openRadarID, radarID, product, reproducible, version, status, resolved;
@dynamic creationDate, openRadarSubmissionDate, radarSubmissionDate;


- (void)dealloc {
    [super dealloc];
}

- (NSString *) bugReportIDsText {
	if (!self.readyToSubmit) return NSLocalizedString(@"Incomplete Report", nil);
	
	if (self.radarID && self.openRadarID) {
		return [NSString stringWithFormat: @"rdar://%@, openrdar://%@", self.radarID, self.openRadarID];
	} else if (self.radarID) {
		return [NSString stringWithFormat: @"rdar://%@", self.radarID];
	} else if (self.openRadarID) {
		return [NSString stringWithFormat: @"openrdar://%@", self.openRadarID];
	}
	return NSLocalizedString(@"Not Submitted", nil);
}

- (BOOL) readyToSubmit {
	return (self.title.length > 0 && self.classification.length > 0 && self.details.length > 0 && self.product.length > 0 && self.version.length > 0 && self.reproducible.length > 0);
}

- (BOOL) submittedToRadar {
	return self.radarID.length > 0;
}

- (BOOL) submittedToOpenRadar {
	return self.openRadarID.length > 0;
}

- (NSString *) originatedDateString {
	if (self.creationDate == nil) return @"";
	
	NSDateFormatter			*formatter = [[[NSDateFormatter alloc] init] autorelease];
	
	[formatter setDateStyle: NSDateFormatterShortStyle];
	[formatter setTimeZone: [NSTimeZone localTimeZone]];
	return [formatter stringFromDate: self.creationDate];
}

- (void) setAutoSubmitToOpenRadar: (BOOL) autoSubmitToOpenRadar {[self setPrimitiveValue: [NSNumber numberWithBool: autoSubmitToOpenRadar] forKey: @"autoSubmitToOpenRadar"];}
- (BOOL) autoSubmitToOpenRadar {return [[self primitiveValueForKey: @"autoSubmitToOpenRadar"] boolValue];}

@end
