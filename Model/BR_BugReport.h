//
//  BR_BugReport.h
//  BugReporter
//
//  Created by Ben Gottlieb on 10/31/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface BR_BugReport : NSManagedObject {

}

@property (nonatomic, readwrite, retain) NSString *title, *classification, *details, *openRadarID, *radarID, *product, *reproducible, *version, *status, *resolved;
@property (nonatomic, readwrite, retain) NSDate *creationDate, *openRadarSubmissionDate, *radarSubmissionDate;
@property (nonatomic, readonly) NSString *bugReportIDsText, *originatedDateString;
@property (nonatomic, readwrite) BOOL autoSubmitToOpenRadar;

@property (nonatomic, readonly) BOOL readyToSubmit, submittedToRadar, submittedToOpenRadar;
@end
