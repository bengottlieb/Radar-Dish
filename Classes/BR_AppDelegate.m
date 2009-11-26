//
//  BugReporterAppDelegate.m
//  BugReporter
//
//  Created by Ben Gottlieb on 10/30/09.
//  Copyright Stand Alone, Inc. 2009. All rights reserved.
//

#import "BR_AppDelegate.h"
#import "BR_TestWebView.h"
#import "BR_ReportsListController.h"
#import "BR_BugReportManager.h"
#import "BR_CredentialsController.h"
#import "RD_Headers.h"
#import "BR_StatusReportWidget.h"

@implementation BR_AppDelegate

@synthesize window = _window, navigationController = _navigationController, context = _context;
@synthesize bugReportController = _bugReportController;

BR_AppDelegate		*g_appDelegate = nil;

- (void) dealloc {
    [_window release];
    [super dealloc];
}

- (id) init {
	if (self = [super init]) {
		g_appDelegate = self;
		_navigationController = [[UINavigationController alloc] init];

		NSDictionary			*options = [NSDictionary dictionaryWithObjectsAndKeys: (id) kCFBooleanTrue, NSMigratePersistentStoresAutomaticallyOption, (id) kCFBooleanTrue, NSInferMappingModelAutomaticallyOption, nil];
		NSError					*error = nil;
		NSString				*path = [@"~/Documents/BugReports.db" stringByExpandingTildeInPath];
		NSManagedObjectModel	*model = [[[NSManagedObjectModel alloc] initWithContentsOfURL: [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: @"BugReport" ofType: @"mom"]]] autorelease];

		_store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: model];
		[_store addPersistentStoreWithType: NSSQLiteStoreType configuration: nil URL: [NSURL fileURLWithPath: path] options: options error: &error];
		
		if (error) NSLog(@"Error while creating persistant store: %@", [error localizedDescription]);
		
		_context = [[NSManagedObjectContext alloc] init];
		[_context setPersistentStoreCoordinator: _store];
		
		_bugReportController = [[BR_BugReportManager alloc] init];
	}
	return self;
}

- (void) applicationDidFinishLaunching: (UIApplication *) application {		
	[_navigationController pushViewController: [BR_ReportsListController controller] animated: NO];
	
	[_window addSubview: _navigationController.view];
    [_window makeKeyAndVisible];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey: kDefaults_RadarUsernameKey] length] == 0 && [[[NSUserDefaults standardUserDefaults] objectForKey: kDefaults_OpenRadarUsernameKey] length] == 0) {
		[self.navigationController presentModalViewController: [BR_CredentialsController controller] animated: YES];
	}
	
	//[self.navigationController pushViewController: [BR_TestWebView controller] animated: YES];
	
	BR_StatusReportWidget			*status = [[[BR_StatusReportWidget alloc] initWithFrame: CGRectZero] autorelease];
	
	[self.window addSubview: status];
}

- (void) applicationWillTerminate: (UIApplication *) application {
	[self saveContext];
}

- (void) saveContext {
	NSError								*error = nil;
	
	[self.context save: &error];
	if (error) NSLog(@"Error while saving context: %@", error);
}




@end
