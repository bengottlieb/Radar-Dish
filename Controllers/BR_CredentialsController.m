//
//  BR_CredentialsController.m
//  BugReporter
//
//  Created by Ben Gottlieb on 11/4/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import "BR_CredentialsController.h"
#import "RD_Headers.h"

@implementation BR_CredentialsController
@synthesize tableView = _tableView, radarUsernameCell = _radarUsernameCell, radarPasswordCell = _radarPasswordCell, openRadarUsernameCell = _openRadarUsernameCell;
@synthesize openRadarPasswordCell = _openRadarPasswordCell, radarUsernameField = _radarUsernameField, radarPasswordField = _radarPasswordField, openRadarUsernameField = _openRadarUsernameField, openRadarPasswordField = _openRadarPasswordField;

- (void) dealloc {
    [super dealloc];
}

+ (id) controller {
	BR_CredentialsController				*controller = [[[BR_CredentialsController alloc] initWithNibName: @"Credentials" bundle: nil] autorelease];
	
	[[NSNotificationCenter defaultCenter] addObserver: controller selector: @selector(keyboardDidShow:) name: UIKeyboardDidShowNotification object: nil];
	[[NSNotificationCenter defaultCenter] addObserver: controller selector: @selector(keyboardDidHide:) name: UIKeyboardDidHideNotification object: nil];
	
	return controller;
}

- (void) viewWillAppear: (BOOL) animated {
	[super viewWillAppear: animated];
	
	self.title = NSLocalizedString(@"Settings", nil);
	self.radarUsernameField.text = [[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_RadarUsernameKey];
	self.radarPasswordField.text = [[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_RadarPasswordKey];
	self.openRadarUsernameField.text = [[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_OpenRadarUsernameKey];
	self.openRadarPasswordField.text = [[NSUserDefaults standardUserDefaults] stringForKey: kDefaults_OpenRadarPasswordKey];
}

- (void) viewDidAppear: (BOOL) animated {
	[super viewDidAppear: animated];
	if ([[[NSUserDefaults standardUserDefaults] objectForKey: kDefaults_RadarUsernameKey] length] == 0 && [[[NSUserDefaults standardUserDefaults] objectForKey: kDefaults_OpenRadarUsernameKey] length] == 0) {
		[self.radarUsernameField becomeFirstResponder];
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void) viewDidUnload {
	self.radarUsernameCell = nil;
	self.radarPasswordCell = nil;
	self.openRadarUsernameCell = nil;
	self.openRadarPasswordCell = nil;
}

- (void) saveFields {
	[[NSUserDefaults standardUserDefaults] setObject: self.radarUsernameField.text forKey: kDefaults_RadarUsernameKey];
	[[NSUserDefaults standardUserDefaults] setObject: self.radarPasswordField.text forKey: kDefaults_RadarPasswordKey];
	[[NSUserDefaults standardUserDefaults] setObject: self.openRadarUsernameField.text forKey: kDefaults_OpenRadarUsernameKey];
	[[NSUserDefaults standardUserDefaults] setObject: self.openRadarPasswordField.text forKey: kDefaults_OpenRadarPasswordKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) viewWillDisappear: (BOOL) animated {
	[super viewWillDisappear: animated];
	[self saveFields];
}

//=============================================================================================================================
#pragma mark Actions
- (void) done: (id) sender {
	[self saveFields];
	[self dismissModalViewControllerAnimated: YES];
}

//=============================================================================================================================
#pragma mark Notifications
- (void) keyboardDidShow: (NSNotification *) note {
	if (_keyboardVisible) return;
	
	_keyboardVisible = YES;
	CGRect						frame = self.tableView.frame;
	CGRect						kbdFrame = [[note.userInfo objectForKey: UIKeyboardBoundsUserInfoKey] CGRectValue];
	
	frame.size.height -= kbdFrame.size.height;
	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, frame.size.height, 0);
}

- (void) keyboardDidHide: (NSNotification *) note {
	if (!_keyboardVisible) return;
	
	_keyboardVisible = NO;
	
	CGRect						frame = self.tableView.frame;
	CGRect						kbdFrame = [[note.userInfo objectForKey: UIKeyboardBoundsUserInfoKey] CGRectValue];
	
	frame.size.height += kbdFrame.size.height;
	self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

//=============================================================================================================================
#pragma mark Delegate Methods
- (BOOL) textFieldShouldReturn: (UITextField *) textField {
	if (textField == self.radarUsernameField) {
		[self.radarPasswordField becomeFirstResponder];
	} else if (textField == self.radarPasswordField) {
		[self.openRadarUsernameField becomeFirstResponder];
	} else if (textField == self.openRadarUsernameField) {
		[self.openRadarPasswordField becomeFirstResponder];
	} else if (textField == self.openRadarPasswordField) {
		[self done: nil];
	}
	return NO;
}

- (BOOL) textFieldShouldBeginEditing: (UITextField *) textField {
	UITableViewCell					*cell = nil;
	UITableViewScrollPosition		position = UITableViewScrollPositionBottom;
	
	if (textField == self.radarUsernameField) {
		cell = self.radarUsernameCell;
		position = UITableViewScrollPositionTop;
	} else if (textField == self.radarPasswordField) {
		cell = self.radarPasswordCell;
	} else if (textField == self.openRadarUsernameField) {
		cell = self.openRadarUsernameCell;
		position = UITableViewScrollPositionTop;
	} else if (textField == self.openRadarPasswordField) {
		position = UITableViewScrollPositionTop;
		cell = self.openRadarPasswordCell;
	}
	
	if (cell) [self.tableView scrollToRowAtIndexPath: [self.tableView indexPathForCell: cell] atScrollPosition: position animated: YES];
	return YES;
}

//==========================================================================================
#pragma mark Table DataSource/Delegate
- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
	UITableViewCell											*cell;
	
	switch (indexPath.section) {
		case 0:						//radar info
			return indexPath.row == 0 ? self.radarUsernameCell : self.radarPasswordCell;
			
		case 1:						//open radar info
			return indexPath.row == 0 ? self.openRadarUsernameCell : self.openRadarPasswordCell;
			
		case 2:	
			cell = [tableView dequeueReusableCellWithIdentifier: @"cell"];
			if (cell == nil) cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier: @"cell"] autorelease];
			
			return cell;
	}
	return nil;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView {
	return 2;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
	if (section == 2) return 3;
	return 2;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0: return NSLocalizedString(@"Apple Bug Reporter Info", nil);
		case 1: return NSLocalizedString(@"Open Radar Info", nil);
		case 3: return NSLocalizedString(@"Default Values", nil);
	}
	return @"";
}

@end
