//
//  BR_StatusReportWidget.h
//  BugReporter
//
//  Created by Ben Gottlieb on 11/5/09.
//  Copyright 2009 Stand Alone, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RD_Headers.h"

@interface BR_StatusReportWidget : UIView {
	radar_submit_state			_status;
}

- (NSString *) stateDescription: (radar_submit_state) state;
@end
