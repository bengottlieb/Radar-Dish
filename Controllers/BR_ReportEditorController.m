//
//  BR_ReportEditorController.m
//  BugReporter
//
//  Created by Ben Gottlieb on 11/3/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import "BR_ReportEditorController.h"
#import "BR_AppDelegate.h"
#import "BR_BugReportManager.h"
#import "BR_BugReport.h"
#import "BR_RadarSubmitter.h"
#import "BR_OpenRadarSubmitter.h"

typedef enum {
	reportEditAction_delete,
	reportEditAction_submit
} reportEditAction;

static BR_ReportEditorController *s_currentController = nil;

@implementation BR_ReportEditorController
@synthesize tableView = _tableView, titleField = _titleField, detailsField = _detailsField;
@synthesize titleCell = _titleCell, classificationCell = _classificationCell, detailsCell = _detailsCell, productCell = _productCell, reproducibleCell = _reproducibleCell, versionCell = _versionCell;
@synthesize deleteButton = _deleteButton, submitToRadarButton = _submitToRadarButton, submitToOpenRadarButton = _submitToOpenRadarButton;

- (void) dealloc {
	self.titleCell = nil;
	self.classificationCell = nil;
	self.detailsCell = nil;
	self.productCell = nil;
	self.reproducibleCell = nil;
	self.versionCell = nil;
	
	s_currentController = nil;
	[super dealloc];
}

+ (id) controller {
	if (s_currentController) return s_currentController;
	
	s_currentController = [[[BR_ReportEditorController alloc] initWithNibName: @"ReportEditor" bundle: nil] autorelease];
	
	s_currentController.classificationCell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: @""] autorelease];
	s_currentController.productCell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: @""] autorelease];
	s_currentController.reproducibleCell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: @""] autorelease];
	s_currentController.versionCell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: @""] autorelease];
	return s_currentController;
}

+ (id) currentController {
	return [[s_currentController retain] autorelease];
}

- (void) viewWillAppear: (BOOL) animated {
	self.title = NSLocalizedString(@"Editor", nil);
	[super viewWillAppear: animated];
	[self updateFields];
}

- (void) updateFields {
	_detailsHeight = MAX([g_appDelegate.bugReportController.currentReport.details sizeWithFont: self.detailsField.font constrainedToSize: CGSizeMake(270, 10000) lineBreakMode: UILineBreakModeWordWrap].height + 20, 44);
	_titleHeight = MAX([g_appDelegate.bugReportController.currentReport.title sizeWithFont: self.titleField.font constrainedToSize: CGSizeMake(280, 10000) lineBreakMode: UILineBreakModeWordWrap].height + 20, 44);

	self.titleField.text = g_appDelegate.bugReportController.currentReport.title;
	self.detailsField.text = g_appDelegate.bugReportController.currentReport.details;
	
	self.classificationCell.textLabel.text = NSLocalizedString(@"Classification", nil);
	self.classificationCell.detailTextLabel.text = g_appDelegate.bugReportController.currentReport.classification;
	
	self.productCell.textLabel.text = NSLocalizedString(@"Product", nil);
	self.productCell.detailTextLabel.text = g_appDelegate.bugReportController.currentReport.product;
	
	self.reproducibleCell.textLabel.text = NSLocalizedString(@"Reproducible", nil);
	self.reproducibleCell.detailTextLabel.text = g_appDelegate.bugReportController.currentReport.reproducible;
	
	self.versionCell.textLabel.text = NSLocalizedString(@"Version", nil);
	self.versionCell.detailTextLabel.text = g_appDelegate.bugReportController.currentReport.version;
		
	if (g_appDelegate.bugReportController.currentReport.submittedToRadar) {
		_submitToRadarButton.enabled = NO;
		_submitToRadarButton.titleLabel.text = [NSString stringWithFormat: NSLocalizedString(@"rdar://%@", nil), g_appDelegate.bugReportController.currentReport.radarID];
	}

	if (g_appDelegate.bugReportController.currentReport.submittedToOpenRadar) {
		_submitToOpenRadarButton.enabled = NO;
		_submitToOpenRadarButton.titleLabel.text = [NSString stringWithFormat: NSLocalizedString(@"openrdar://%@", nil), g_appDelegate.bugReportController.currentReport.openRadarID];
	}
	[self.tableView reloadData];
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

- (void) viewDidAppear: (BOOL) animated {
	[super viewDidAppear: animated];
	
	NSIndexPath				*selected = [self.tableView indexPathForSelectedRow];
	
	if (selected) [self.tableView deselectRowAtIndexPath: selected animated: YES];
	
	if (g_appDelegate.bugReportController.currentReport.title.length == 0 && !_titleEditPrompted) [g_appDelegate.bugReportController editTitle];
	_titleEditPrompted = YES;
}

//=============================================================================================================================
#pragma mark Actions
- (IBAction) deleteBugReport {
	UIActionSheet					*sheet = [[[UIActionSheet alloc] initWithTitle: NSLocalizedString(@"Are you sure you want to delete this bug report?\n\nThis cannot be undone", nil) 
																		  delegate: self 
																 cancelButtonTitle: NSLocalizedString(@"Cancel", nil) 
															destructiveButtonTitle: NSLocalizedString(@"Delete", nil) 
																 otherButtonTitles: nil] autorelease];
	
	sheet.tag = reportEditAction_delete;
	[sheet showInView: self.view];
}

- (IBAction) submitToApple {
	if ([[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_RadarUsernameKey].length == 0 || [[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_RadarPasswordKey].length == 0) {
		[[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Credentials Missing", nil)
									 message: NSLocalizedString(@"Please enter your radar credentials.", nil) 
									delegate: nil
						   cancelButtonTitle: NSLocalizedString(@"OK", nil)
						   otherButtonTitles: nil] autorelease] show];
		return;
	}
	if (g_appDelegate.bugReportController.currentReport.readyToSubmit) {
		
		UIActionSheet					*confirm = [[[UIActionSheet alloc] initWithTitle: NSLocalizedString(@"Are you sure you're ready to file this report?", nil)
																				delegate: self 
																	   cancelButtonTitle: NSLocalizedString(@"Cancel", nil)
																  destructiveButtonTitle: nil 
																	   otherButtonTitles: NSLocalizedString(@"File Report", nil), NSLocalizedString(@"File to Open Radar, Too", nil), nil] autorelease];
		confirm.tag = reportEditAction_submit;
		[confirm showInView: self.view];
	} else {
		[[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Information Missing", nil)
									message: NSLocalizedString(@"Please fill out all fields.", nil) 
								   delegate: nil
						  cancelButtonTitle: NSLocalizedString(@"OK", nil)
						  otherButtonTitles: nil] autorelease] show];
	}
}

- (IBAction) submitToOpenRadar {
	if ([[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_OpenRadarUsernameKey].length == 0 || [[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_OpenRadarPasswordKey].length == 0) {
		[[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Credentials Missing", nil)
									 message: NSLocalizedString(@"Please enter your Open Radar credentials.", nil) 
									delegate: nil
						   cancelButtonTitle: NSLocalizedString(@"OK", nil)
						   otherButtonTitles: nil] autorelease] show];
		return;
	}
	[[BR_OpenRadarSubmitter submitter] submitReport: g_appDelegate.bugReportController.currentReport showProgress: NO];
}

//=============================================================================================================================
#pragma mark Action sheet delegate
- (void) actionSheet: (UIActionSheet *) actionSheet clickedButtonAtIndex: (NSInteger) buttonIndex {
	if (actionSheet.tag == reportEditAction_delete) {
		if (buttonIndex == actionSheet.destructiveButtonIndex) {
			[g_appDelegate.bugReportController deleteReport: g_appDelegate.bugReportController.currentReport];
		}
	} else if (actionSheet.tag == reportEditAction_submit) {
		if (buttonIndex == actionSheet.cancelButtonIndex) return;
		
		g_appDelegate.bugReportController.currentReport.autoSubmitToOpenRadar = (buttonIndex == 1);
		[[BR_RadarSubmitter submitter] submitReport: g_appDelegate.bugReportController.currentReport showProgress: NO];
	}
}
//==========================================================================================
#pragma mark Table DataSource/Delegate
- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
	UITableViewCell						*cell = nil;
	
	switch (indexPath.section) {
		case 0:						
			cell = self.titleCell;
			break;
			
		case 1:	
			switch (indexPath.row) {
				case 0:	cell = self.productCell; break;
				case 1:	cell = self.versionCell; break;
				case 2:	cell = self.classificationCell; break;
				case 3:	cell = self.reproducibleCell; break;
			}
			
			break;
			
		case 2:	
			cell = self.detailsCell;
			break;
	}

	cell.selectionStyle = g_appDelegate.bugReportController.currentReport.submittedToRadar ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
	cell.accessoryType = g_appDelegate.bugReportController.currentReport.submittedToRadar ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.textColor = g_appDelegate.bugReportController.currentReport.submittedToRadar ? [UIColor grayColor] : [UIColor blackColor];
	
	return cell;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView {
	return 3;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
	switch (section) {
		case 0:	return 1;
		case 1:	return 4;
		case 2: return 1;
	}
	return 0;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
	if (g_appDelegate.bugReportController.currentReport.submittedToRadar) return;
	
	switch (indexPath.section) {
		case 0:	[g_appDelegate.bugReportController editTitle]; break;
		case 1:	
			switch (indexPath.row) {
				case 0:	[g_appDelegate.bugReportController selectProduct]; break;
				case 1:	
					[g_appDelegate.bugReportController editVersion]; 
					break;
					
				case 2:	[g_appDelegate.bugReportController selectClassification]; break;
				case 3:	[g_appDelegate.bugReportController selectReproducibility]; break;
			}
			break;
			
		case 2:	[g_appDelegate.bugReportController editDetails]; break;
	}
}

- (NSString *) tableView: (UITableView *) tableView titleForHeaderInSection: (NSInteger) section {
	switch (section) {
		case 0:	return NSLocalizedString(@"Title", nil);
		case 2: return NSLocalizedString(@"Details", nil);;
	}
	return @"";
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
	if (indexPath.section == 2) return _detailsHeight;
	if (indexPath.section == 0) return _titleHeight;
	return [self tableView: tableView cellForRowAtIndexPath: indexPath].bounds.size.height;
}


/*
- (UIView *) tableView: (UITableView *) tableView viewForHeaderInSection: (NSInteger) sectionIndex {
	return nil;
}

- (UIView *) tableView: (UITableView *) tableView viewForFooterInSection: (NSInteger) sectionIndex {
 return nil;
}

- (CGFloat) tableView: (UITableView *) tableView heightForHeaderInSection: (NSInteger) section {
	return 0;
}

- (CGFloat) tableView: (UITableView *) tableView heightForFooterInSection: (NSInteger) section {
	return 0;
}

- (BOOL) tableView: (UITableView *) tableView canEditRowAtIndexPath: (NSIndexPath *) indexPath {
	return YES;
}

- (void) tableView: (UITableView *) tableView willBeginEditingRowAtIndexPath: (NSIndexPath *) indexPath {
}

- (void) tableView: (UITableView *) tableView didEndEditingRowAtIndexPath: (NSIndexPath *) indexPath {
}
*/

@end
