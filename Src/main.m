//
//  main.m
//  BugReporter
//
//  Created by Ben Gottlieb on 10/30/09.
//  Copyright Stand Alone, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
