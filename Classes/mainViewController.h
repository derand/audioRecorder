//
//  mainViewController.h
//
//  Created by maliy on 7/15/10.
//  Copyright 2010 interMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cRecorder.h"

@interface mainViewController : UIViewController <cRecorderDelegate>
{
	cRecorder *recorder;
	UIProgressView *pv;
	
	CGFloat minLevel;
}

@end
