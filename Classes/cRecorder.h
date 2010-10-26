//
//  cRecorder.h
//  audioRecorder
//
//  Created by maliy on 8/24/10.
//  Copyright 2010 interMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>


#define AUDIO_BUFFERS	5

@class cRecorder;

typedef struct AQCallbackStruct
{
	AudioStreamBasicDescription mDataFormat;
	AudioQueueRef queue;
	AudioQueueBufferRef mBuffers[AUDIO_BUFFERS];
	AudioFileID outputFile;
	unsigned long frameSize;
	long long recPtr;
	int run;
	AudioQueueLevelMeterState *_chan_lvls;
	cRecorder *recorder;	
} AQCallbackStruct;


@protocol cRecorderDelegate
@optional
- (void) recorder:(cRecorder *) recorder levels:(NSArray *) lvls;
@end


@interface cRecorder : NSObject
{
	AQCallbackStruct aqc;
	
	BOOL recording;
	
	id<cRecorderDelegate> delegate;
}

@property (nonatomic, readonly) NSString *fileName;
@property (nonatomic, readonly) BOOL recording;
@property (nonatomic, assign) id<cRecorderDelegate> delegate;

- (BOOL) start;
- (void) stop;

@end
