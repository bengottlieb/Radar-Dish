//
//  BR_VersionEntryController.m
//  BugReporter
//
//  Created by Ben Gottlieb on 11/5/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import "BR_VersionEntryController.h"
#import "RD_Headers.h"
#import "BR_BugReport.h"
#import "BR_AppDelegate.h"
#import "BR_BugReportManager.h"

@implementation BR_VersionEntryController
@synthesize otherVersionField = _otherVersionField, tableView = _tableView, selected = _selected;


- (void) dealloc {
    [super dealloc];
}

+ (id) controller {
	return [[[BR_VersionEntryController alloc] initWithNibName: @"VersionEntry" bundle: nil] autorelease];
}

- (void) viewDidLoad {
	[super viewDidLoad];
	
	self.selected = g_appDelegate.bugReportController.currentReport.version;
	_options = [[[NSUserDefaults standardUserDefaults] objectForKey: kDefaults_versionOptions] mutableCopy];
	if (_options == nil) _options = [[NSMutableArray alloc] init];
}

//=============================================================================================================================
#pragma mark Tableview

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
	NSString								*cellIdentifier = @"cell";
	UITableViewCell							*cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
	NSString								*option = [_options objectAtIndex: indexPath.row];
	
	if (cell == nil) cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier] autorelease];
	cell.accessoryType = ([self.selected isEqual: option]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	cell.textLabel.text = option;
	
	return cell;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView {
	return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
	return _options.count;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
//	[self.delegate menuController: self didSelectOption: [self.options objectAtIndex: indexPath.row]];
	
	int								currentIndex = self.selected ? [_options indexOfObject: self.selected] : NSNotFound;
	UITableViewCell					*cell = [tableView cellForRowAtIndexPath: indexPath];
	
	if (currentIndex != NSNotFound) {
		cell = [tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow: currentIndex inSection: 0]];
		
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	self.selected = [_options objectAtIndex: indexPath.row];
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	
	g_appDelegate.bugReportController.currentReport.version = [_options objectAtIndex: indexPath.row];
	[self.navigationController popViewControllerAnimated: YES];
	
}

- (void) tableView: (UITableView *) tableView commitEditingStyle: (UITableViewCellEditingStyle) editingStyle forRowAtIndexPath: (NSIndexPath *) indexPath {
	[tableView beginUpdates];
	[tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: UITableViewRowAnimationRight];
	[_options removeObjectAtIndex: indexPath.row];
	[[NSUserDefaults standardUserDefaults] setObject: _options forKey: kDefaults_versionOptions];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[tableView endUpdates];
}

- (UITableViewCellEditingStyle) tableView: (UITableView *) tableView editingStyleForRowAtIndexPath: (NSIndexPath *) indexPath {
	return UITableViewCellEditingStyleDelete;
}

//=============================================================================================================================
#pragma mark Delegate

- (BOOL) textFieldShouldReturn: (UITextField *) textField {
	if (textField.text.length) {
		[_options removeObject: textField.text];
		[_options insertObject: textField.text atIndex: 0];
		[[NSUserDefaults standardUserDefaults] setObject: _options forKey: kDefaults_versionOptions];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		g_appDelegate.bugReportController.currentReport.version = textField.text;
		[self.navigationController popViewControllerAnimated: YES];

		[[NSUserDefaults standardUserDefaults] setObject: textField.text forKey: kDefaults_LastUsedVersion];
	} else {
		[textField resignFirstResponder];
	}
	return NO;
}



@end
