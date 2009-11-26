//
//  BR_CredentialsController.h
//  BugReporter
//
//  Created by Ben Gottlieb on 11/4/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BR_CredentialsController : UIViewController {
	UITableViewCell					*_radarUsernameCell, *_radarPasswordCell;
	UITableViewCell					*_openRadarUsernameCell, *_openRadarPasswordCell;


	UITextField						*_radarUsernameField, *_radarPasswordField;
	UITextField						*_openRadarUsernameField, *_openRadarPasswordField;
	
	UITableView						*_tableView;
	BOOL							_keyboardVisible;
}

@property (nonatomic, readwrite, assign) IBOutlet UITableView *tableView;
@property (nonatomic, readwrite, retain) IBOutlet UITableViewCell *radarUsernameCell, *radarPasswordCell, *openRadarUsernameCell, *openRadarPasswordCell;
@property (nonatomic, readwrite, assign) IBOutlet UITextField *radarUsernameField, *radarPasswordField, *openRadarUsernameField, *openRadarPasswordField;

- (void) saveFields;
- (void) done: (id) sender;

+ (id) controller;


@end
