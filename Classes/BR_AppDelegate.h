//
//  BugReporterAppDelegate.h
//  BugReporter
//
//  Created by Ben Gottlieb on 10/30/09.
//  Copyright Stand Alone, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class BR_BugReportManager;

@interface BR_AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *_window;
	UINavigationController			*_navigationController;
	NSManagedObjectContext			*_context;
	NSPersistentStoreCoordinator	*_store;
	BR_BugReportManager			*_bugReportController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, readonly) UINavigationController *navigationController;
@property (nonatomic, readonly) NSManagedObjectContext *context;
@property (nonatomic, readonly) BR_BugReportManager *bugReportController;


- (void) saveContext;

@end


extern BR_AppDelegate		*g_appDelegate;