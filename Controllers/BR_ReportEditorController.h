//
//  BR_ReportEditorController.h
//  BugReporter
//
//  Created by Ben Gottlieb on 11/3/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BR_ReportEditorController : UIViewController <UIActionSheetDelegate> {
	UITableView									*_tableView;
	UITableViewCell								*_titleCell, *_classificationCell, *_detailsCell, *_productCell, *_reproducibleCell, *_versionCell;
	
	UITextView									*_titleField, *_detailsField;
	
	UIButton									*_deleteButton, *_submitToRadarButton, *_submitToOpenRadarButton;
	BOOL										_titleEditPrompted;
	
	float										_detailsHeight, _titleHeight;
}

@property(nonatomic, readwrite, assign) IBOutlet UITableView *tableView;
@property(nonatomic, readwrite, retain) IBOutlet UITableViewCell *titleCell, *classificationCell, *detailsCell, *productCell, *reproducibleCell, *versionCell;
@property(nonatomic, readwrite, assign) IBOutlet UITextView *titleField, *detailsField;

@property (nonatomic, readwrite, assign) IBOutlet UIButton *deleteButton, *submitToRadarButton, *submitToOpenRadarButton;

+ (id) controller;
+ (id) currentController;


- (IBAction) deleteBugReport;
- (IBAction) submitToApple;
- (IBAction) submitToOpenRadar;

- (void) updateFields;
@end
