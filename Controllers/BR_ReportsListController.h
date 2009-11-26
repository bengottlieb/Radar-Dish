//
//  BR_BugReportsController.h
//  BugReporter
//
//  Created by Ben Gottlieb on 10/31/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BR_BugReport.h"
#import "BR_AppDelegate.h"

@interface BR_ReportsListController : UIViewController {
	UITableView					*_tableView;
	NSFetchRequest				*_fetchRequest;
	NSMutableArray				*_bugReports;
}

@property (nonatomic, readwrite, assign) IBOutlet UITableView *tableView;

+ (id) controller;

- (void) reloadData;
- (IBAction) showSettings;
@end
