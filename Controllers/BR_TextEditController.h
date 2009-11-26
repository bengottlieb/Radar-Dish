//
//  M8_TextEditController.h
//  Medic8
//
//  Created by Ben Gottlieb on 7/2/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BR_TextEditController;

@protocol BR_TextEditControllerDelegate <NSObject>
- (void) textEditController: (BR_TextEditController *) controller didEditText: (NSString *) newText;
- (void) textEditControllerDidCancel: (BR_TextEditController *) controller;
@end


@interface BR_TextEditController : UIViewController {
	id <BR_TextEditControllerDelegate>					_delegate;
	BOOL												_multiline;
	NSString											*_text, *_label;
	UILabel												*_labelView;
	UITextField											*_textField;
	UITextView											*_textView;
	BOOL												_readonly;
}

@property (nonatomic, readwrite, retain) IBOutlet UITextField *textField;
@property (nonatomic, readwrite, retain) IBOutlet UITextView *textView;
@property (nonatomic, readwrite, retain) IBOutlet UILabel *labelView;

@property (nonatomic, readwrite, retain) NSString *text, *label;
@property (nonatomic, readwrite) BOOL multiline;
@property (nonatomic, readwrite, assign) id <BR_TextEditControllerDelegate> delegate;
@property (nonatomic, readwrite) BOOL readonly;


+ (id) controllerForText: (NSString *) text title: (NSString *) title label: (NSString *) label multiline: (BOOL) multiline delegate: (id <BR_TextEditControllerDelegate>) delegate;
+ (id) readonlyControllerForText: (NSString *) text title: (NSString *) title label: (NSString *) label;
+ (id) controller;

- (void) save: (id) sender;
@end
