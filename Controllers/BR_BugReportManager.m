//
//  BR_BugReportController.m
//  BugReporter
//
//  Created by Ben Gottlieb on 10/31/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import "BR_BugReportManager.h"
#import "BR_AppDelegate.h"
#import "BR_ReportEditorController.h"
#import "RD_Headers.h"
#import "BR_VersionEntryController.h"

typedef enum {
	bugReportField_product,
	bugReportField_classification,
	bugReportField_reproducibility,
	bugReportField_title,
	bugReportField_version,
	bugReportField_details
} bugReportField;

@implementation BR_BugReportManager
@synthesize currentReport = _currentReport;

- (id) init {
	if (self = [super init]) {
		NSString										*lastObjectIDString = [[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_lastReportID];
		NSURL											*lastObjectID = lastObjectIDString.length ? [NSURL URLWithString: lastObjectIDString] : nil;
		id												object = [g_appDelegate.context.persistentStoreCoordinator managedObjectIDForURIRepresentation: lastObjectID];
		
		if (object && lastObjectID) _currentReport = [[g_appDelegate.context objectWithID: object] retain];
	}
	return self;
}

- (void) createNewBugReport {
	self.currentReport = [NSEntityDescription insertNewObjectForEntityForName: @"BugReport" inManagedObjectContext: g_appDelegate.context];
	
	self.currentReport.product = [[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_LastUsedProduct];
	self.currentReport.version = [[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_LastUsedVersion];
	self.currentReport.reproducible = [[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_LastUsedReproducibility];
	self.currentReport.classification = [[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_LastUsedClassification];
	
	[self resumeEditingCurrentReport];
}

- (void) setCurrentReport: (BR_BugReport *) report {
	[_currentReport autorelease];
	_currentReport = [report retain];
	
	[[NSUserDefaults standardUserDefaults] setObject: [[[report objectID] URIRepresentation] absoluteString] forKey: kDefaults_lastReportID];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) resumeEditingCurrentReport {
	if (_currentReport == nil) return;

	if ([BR_ReportEditorController currentController]) 
		[g_appDelegate.navigationController popToViewController: [BR_ReportEditorController currentController] animated: YES];
	else {
		[g_appDelegate.navigationController popToRootViewControllerAnimated: NO];
		[g_appDelegate.navigationController pushViewController: [BR_ReportEditorController controller] animated: YES];
	}
}

- (void) deleteReport: (BR_BugReport *) report {
	if (report == nil) return;
	
	[g_appDelegate.context deleteObject: report];
	if (report == self.currentReport) {
		self.currentReport = nil;
		[g_appDelegate.navigationController popToRootViewControllerAnimated: YES];
	}
}

//=============================================================================================================================
#pragma mark Delegate
- (void) textEditController: (BR_TextEditController *) controller didEditText: (NSString *) newText {
	if (controller.view.tag == bugReportField_title)
		self.currentReport.title = newText;
	else if (controller.view.tag == bugReportField_details) {
		self.currentReport.details = newText;
	} else if (controller.view.tag == bugReportField_version) {
		self.currentReport.version = newText;
		[[NSUserDefaults standardUserDefaults] setObject: newText forKey: kDefaults_LastUsedVersion];
	}

	[g_appDelegate saveContext];
}

- (void) textEditControllerDidCancel: (BR_TextEditController *) controller {
	[g_appDelegate.navigationController popViewControllerAnimated: YES];
}

- (void) menuController: (BR_TextMenuController *) controller didSelectOption: (id) option {
	switch (controller.view.tag) {
		case bugReportField_product:
			self.currentReport.product = option;
			[[NSUserDefaults standardUserDefaults] setObject: option forKey: kDefaults_LastUsedProduct];
			break;
			
		case bugReportField_classification:
			self.currentReport.classification = option;
			[[NSUserDefaults standardUserDefaults] setObject: option forKey: kDefaults_LastUsedClassification];
			break;

		case bugReportField_reproducibility:
			self.currentReport.reproducible = option;
			[[NSUserDefaults standardUserDefaults] setObject: option forKey: kDefaults_LastUsedReproducibility];
			break;
	}
	[g_appDelegate saveContext];
	[g_appDelegate.navigationController popViewControllerAnimated: YES];
}

- (void) selectProduct {
	NSArray							*options = [NSArray arrayWithObjects: @"No Value", @"Mac OS X", @"Mac OS X Server", @"Developer Tools", 
												@"iPhone", @"iPhone SDK", @"iPod", @"Hardware", @"Safari", @"QuickTime", @"Java", @"iApps", 
												@"Documentation", @"Printing/Fax", @"Pro Apps", @"Bug Reporter", @"WebObjects", @"Other", nil];
	id								selected = self.currentReport.product;
	BR_TextMenuController			*controller = [BR_TextMenuController controllerWithOptions: options selected: selected delegate: self];
	
	controller.view.tag = bugReportField_product;
	controller.title = NSLocalizedString(@"Product", nil);
	[g_appDelegate.navigationController pushViewController: controller animated: YES];
}

- (void) selectClassification {
	NSArray							*options = [NSArray arrayWithObjects: @"No Value", @"Security", @"Crash/Hang/Data Lost", @"Performance", 
												@"UI/Usability", @"Serious Bug", @"Other Bug", @"Feature (New)", @"Enhancement", nil];
	id								selected = self.currentReport.classification;
	BR_TextMenuController			*controller = [BR_TextMenuController controllerWithOptions: options selected: selected delegate: self];
	
	controller.view.tag = bugReportField_classification;
	controller.title = NSLocalizedString(@"Classification", nil);
	[g_appDelegate.navigationController pushViewController: controller animated: YES];
}

- (void) selectReproducibility {
	NSArray							*options = [NSArray arrayWithObjects: @"No Value", @"Always", @"Sometimes", @"Rarely", @"Unable", @"I Didn't Try", @"Not Applicable", nil];
	id								selected = self.currentReport.reproducible;
	BR_TextMenuController			*controller = [BR_TextMenuController controllerWithOptions: options selected: selected delegate: self];
	
	controller.view.tag = bugReportField_reproducibility;
	controller.title = NSLocalizedString(@"Reproducible", nil);
	[g_appDelegate.navigationController pushViewController: controller animated: YES];
}

- (void) editTitle {
	UIViewController			*controller = [BR_TextEditController controllerForText: self.currentReport.title title: NSLocalizedString(@"Title", nil) label: nil multiline: YES delegate: self];
	
	controller.view.tag = bugReportField_title;
	[g_appDelegate.navigationController pushViewController: controller animated: YES];
}

- (void) editDetails {
	UIViewController			*controller = [BR_TextEditController controllerForText: self.currentReport.details title: NSLocalizedString(@"Details", nil) label: nil multiline: YES delegate: self];
	
	controller.view.tag = bugReportField_details;
	[g_appDelegate.navigationController pushViewController: controller animated: YES];
}

- (void) editVersion {
	UIViewController			*controller = [BR_VersionEntryController controller];
	
	[g_appDelegate.navigationController pushViewController: controller animated: YES];
}
@end
