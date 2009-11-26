//
//  BR_TextMenu.h
//  BugReporter
//
//  Created by Ben Gottlieb on 10/31/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BR_TextMenuController;

@protocol BR_TextMenuControllerDelegate
- (void) menuController: (BR_TextMenuController *) controller didSelectOption: (id) option;
@end


@interface BR_TextMenuController : UIViewController {
	UITableView							*_tableView;
	
	NSArray								*_options;
	id <BR_TextMenuControllerDelegate>	_delegate;
	id									_selected;
}

@property (nonatomic, readwrite, assign) IBOutlet UITableView *tableView;
@property (nonatomic, readwrite, retain) NSArray *options;
@property (nonatomic, readwrite, retain) id selected;
@property (nonatomic, readwrite, assign) id <BR_TextMenuControllerDelegate> delegate;

+ (id) controllerWithOptions: (NSArray *) options selected: (id) selected delegate: (id <BR_TextMenuControllerDelegate>) delegate;

@end
