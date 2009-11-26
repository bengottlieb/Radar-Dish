//
//  BR_BugReportController.h
//  BugReporter
//
//  Created by Ben Gottlieb on 10/31/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BR_TextMenuController.h"
#import "BR_TextEditController.h"
#import "BR_BugReport.h"

@interface BR_BugReportManager : NSObject <BR_TextMenuControllerDelegate, BR_TextEditControllerDelegate> {
	BR_BugReport						*_currentReport;
}

@property (nonatomic, readwrite, retain) BR_BugReport *currentReport;

- (void) selectProduct;
- (void) selectClassification;
- (void) selectReproducibility;
- (void) editTitle;
- (void) editDetails;
- (void) editVersion;

- (void) createNewBugReport;
- (void) resumeEditingCurrentReport;

- (void) deleteReport: (BR_BugReport *) report;
@end
