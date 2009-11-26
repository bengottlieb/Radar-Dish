//
//  BR_TextMenu.m
//  BugReporter
//
//  Created by Ben Gottlieb on 10/31/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import "BR_TextMenuController.h"


@implementation BR_TextMenuController
@synthesize tableView = _tableView, options = _options, delegate = _delegate, selected = _selected;

- (void) dealloc {
	self.options = nil;
	self.selected = nil;
	self.delegate = nil;
	[super dealloc];
}

+ (id) controllerWithOptions: (NSArray *) options selected: (id) selected delegate: (id <BR_TextMenuControllerDelegate>) delegate {
	BR_TextMenuController				*controller = [[[BR_TextMenuController alloc] initWithNibName: @"TextMenu" bundle: nil] autorelease];
	
	controller.options = options;
	controller.delegate = delegate;
	controller.selected = selected;
	
	return controller;
}


//==========================================================================================
#pragma mark Table DataSource/Delegate
- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath {
	NSString								*cellIdentifier = @"cell";
	UITableViewCell							*cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
	id										option = [self.options objectAtIndex: indexPath.row];
	
	if (cell == nil) cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier] autorelease];
	cell.accessoryType = ([self.selected isEqual: option]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	cell.textLabel.text = [option description];
	
	return cell;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView {
	return 1;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section {
	return self.options.count;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
	[self.delegate menuController: self didSelectOption: [self.options objectAtIndex: indexPath.row]];
	
	int								currentIndex = self.selected ? [self.options indexOfObject: self.selected] : NSNotFound;
	UITableViewCell					*cell = [tableView cellForRowAtIndexPath: indexPath];
	
	if (currentIndex != NSNotFound) {
		cell = [tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow: currentIndex inSection: 0]];
		
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	self.selected = [self.options objectAtIndex: indexPath.row];
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
}

/*
- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath {
	return 44;
}

- (NSString *) tableView: (UITableView *) tableView titleForHeaderInSection: (NSInteger) section {
	return @;
}

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


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

@end
