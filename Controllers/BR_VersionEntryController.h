//
//  BR_VersionEntryController.h
//  BugReporter
//
//  Created by Ben Gottlieb on 11/5/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BR_VersionEntryController : UIViewController {
	UITextField							*_otherVersionField;
	UITableView							*_tableView;
	
	NSMutableArray						*_options;
	NSString							*_selected;
}

@property (nonatomic, readwrite, assign) IBOutlet UITextField *otherVersionField;
@property (nonatomic, readwrite, assign) IBOutlet UITableView *tableView;
@property (nonatomic, readwrite, retain) NSString *selected;

+ (id) controller;

@end
