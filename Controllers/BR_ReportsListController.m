//
//  BR_BugReportsController.m
//  BugReporter
//
//  Created by Ben Gottlieb on 10/31/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import "BR_ReportsListController.h"
#import "BR_BugReportManager.h"
#import "BR_CredentialsController.h"

@implementation BR_ReportsListController
@synthesize tableView = _tableView;

- (void) dealloc {
	[_fetchRequest release];
	[_bugReports release];
	[super dealloc];
}

+ (id) controller {
	return [[[BR_ReportsListController alloc] initWithNibName: @"BugReports" bundle: nil] autorelease];
}

- (void) viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Bug Reports", nil);
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd target: self action: @selector(createBugReport)] autorelease]; 
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"Settings.png"] style: UIBarButtonItemStyleBordered target: self action: @selector(showSettings)] autorelease]; 
	_fetchRequest = [[NSFetchRequest alloc] init];
	_fetchRequest.entity = [NSEntityDescription entityForName: @"BugReport" inManagedObjectContext: g_appDelegate.context];
	_fetchRequest.sortDescriptors = [NSArray arrayWithObject: [[[NSSortDescriptor alloc] initWithKey: @"title" ascending: YES] autorelease]]; 
}

- (void) reloadData {
	NSError								*error = nil;
	
	[_bugReports release];
	_bugReports = [[g_appDelegate.context executeFetchRequest: _fetchRequest error: &error] mutableCopy];
	[self.tableView reloadData];
}

//=============================================================================================================================
#pragma mark View Controller Overrides
- (void) viewWillAppear: (BOOL) animated {
	[super viewWillAppear: animated];
	[self reloadData];
}

- (void) viewDidDisappear: (BOOL) animated {
	[super viewDidDisappear: animated];
	[_bugReports release];
	_bugReports = nil;
}

- (void) viewDidAppear: (BOOL) animated {
	[super viewDidAppear: animated];
	
	NSIndexPath				*selected = [self.tableView indexPathForSelectedRow];
	
	if (selected) [self.tableView deselectRowAtIndexPath: selected animated: YES];
}

//=============================================================================================================================
#pragma mark Actions
- (IBAction) createBugReport {
	[g_appDelegate.bugReportController createNewBugReport];
}

- (IBAction) showSettings {
	[self.navigationController presentModalViewController: [BR_CredentialsController controller] animated: YES];
}

//=============================================================================================================================
#pragma mark tableView
- (id) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
	NSString					*ident = @"bugReportCell";
	UITableViewCell				*cell = [tableView dequeueReusableCellWithIdentifier: ident];
	
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: ident];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	BR_BugReport				*report = [_bugReports objectAtIndex: indexPath.row];
	
	cell.textLabel.text = report.title;
	cell.detailTextLabel.text = report.bugReportIDsText;
	
	return cell;
}

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
	return _bugReports.count;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
	BR_BugReport						*report = [_bugReports objectAtIndex: indexPath.row];
	
	g_appDelegate.bugReportController.currentReport = report;
	[g_appDelegate.bugReportController resumeEditingCurrentReport];
}

- (void) tableView: (UITableView *) tableView commitEditingStyle: (UITableViewCellEditingStyle) editingStyle forRowAtIndexPath: (NSIndexPath *) indexPath {
	BR_BugReport				*report = [_bugReports objectAtIndex: indexPath.row];

	[tableView beginUpdates];
	[g_appDelegate.bugReportController deleteReport: report];
	
	[tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: UITableViewRowAnimationRight];
	[_bugReports removeObjectAtIndex: indexPath.row];
	[tableView endUpdates];
}

- (UITableViewCellEditingStyle) tableView: (UITableView *) tableView editingStyleForRowAtIndexPath: (NSIndexPath *) indexPath {
	return UITableViewCellEditingStyleDelete;
}

@end

