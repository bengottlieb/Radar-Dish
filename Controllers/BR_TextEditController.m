//
//  M8_TextEditController.m
//  Medic8
//
//  Created by Ben Gottlieb on 7/2/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import "BR_TextEditController.h"

@implementation BR_TextEditController

@synthesize textField = _textField, textView = _textView, labelView = _labelView;
@synthesize text = _text, label = _label, delegate = _delegate, multiline = _multiline, readonly = _readonly;

- (void) dealloc {
	self.textField = nil;
	self.textView = nil;
	self.label = nil;
	self.labelView = nil;
	self.delegate = nil;
	self.text = nil;
	
    [super dealloc];
}

+ (id) controller {
	return [[[BR_TextEditController alloc] initWithNibName: @"TextEdit" bundle: nil] autorelease];
}

+ (id) controllerForText: (NSString *) text title: (NSString *) title label: (NSString *) label multiline: (BOOL) multiline delegate: (id <BR_TextEditControllerDelegate>) delegate {
	BR_TextEditController					*controller = [self controller];
	
	controller.label = label;
	controller.text = text;
	controller.title = title;
	controller.multiline = multiline;
	controller.delegate = delegate;
	
	return controller;
}

+ (id) readonlyControllerForText: (NSString *) text title: (NSString *) title label: (NSString *) label {
	BR_TextEditController					*controller = [self controller];
	
	controller.label = label;
	controller.text = text;
	controller.title = title;
	controller.readonly = YES;
	controller.multiline = YES;
	
	return controller;
}

- (void) viewDidLoad {
	self.labelView.text = self.label;
	if (_multiline) {
		CGRect							frame = self.textView.frame;

		self.textView.text = self.text;
		self.textField.hidden = YES;
		
		if (self.label.length == 0) {
			frame.origin.y -= self.labelView.frame.size.height;
			frame.size.height += self.labelView.frame.size.height;
		}
		
		if (self.readonly) frame.size.height += 216;

		self.textView.frame = frame;
		[self.textView becomeFirstResponder];
	} else {
		self.textField.text = self.text;
		self.textView.hidden = YES;
		

		if (self.label.length == 0) {
			CGRect							frame = self.textField.frame;
			
			frame.origin.y -= self.labelView.frame.size.height;
			frame.size.height += self.labelView.frame.size.height;
			
			self.textField.frame = frame;
		}
		[self.textField becomeFirstResponder];
	}
		
	if (self.readonly) {
		self.textView.editable = NO;
	} else {
	//	if (self.text.length > 0)
	//		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target: self action: @selector(cancel:)] autorelease];
//		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemSave target: self action: @selector(save:)] autorelease];
	}
	
}

- (void) viewWillDisappear: (BOOL) animated {
	[super viewWillDisappear: animated];
	[self save: nil];
}

- (BOOL) presentModally {return YES;}

//=============================================================================================================================
#pragma mark Actions
- (void) save: (id) sender {	
	[_delegate textEditController: self didEditText: _multiline ? self.textView.text : self.textField.text];
	//	[self dismiss: sender];
}

- (void) cancel: (id) sender {	
	if ([_delegate respondsToSelector: @selector(textEditControllerDidCancel:)]) [_delegate textEditControllerDidCancel: self];
	//	[self dismiss: sender];
}


//=============================================================================================================================
#pragma mark Delgate
- (BOOL) textFieldShouldReturn: (UITextField *) textField {
	[self save: nil];
	return NO;
}
@end
