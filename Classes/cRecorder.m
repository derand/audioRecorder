//
//  cRecorder.m
//  audioRecorder
//
//  Created by maliy on 8/24/10.
//  Copyright 2010 interMobile. All rights reserved.
//

#import "cRecorder.h"
#import <AudioToolbox/AudioToolbox.h>


@implementation cRecorder
@synthesize delegate;

static void AQInputCallback(
							void *aqr,
							AudioQueueRef inQ,
							AudioQueueBufferRef inQB,
							const AudioTimeStamp *timestamp,
							unsigned long frameSize,
							const AudioStreamPacketDescription *mDataFormat)
{
	AQCallbackStruct *aqc = (AQCallbackStruct *) aqr;

	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	if ([((NSObject *)aqc->recorder.delegate) respondsToSelector:@selector(recorder:levels:)])
	{
		UInt32 data_sz = sizeof(AudioQueueLevelMeterState)*aqc->mDataFormat.mChannelsPerFrame;
		OSErr status = AudioQueueGetProperty(inQ, kAudioQueueProperty_CurrentLevelMeterDB, aqc->_chan_lvls, &data_sz);
		if (status == noErr)
		{
			if (aqc->_chan_lvls)
			{
				NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:aqc->mDataFormat.mChannelsPerFrame];
				for (int i=0; i<aqc->mDataFormat.mChannelsPerFrame; i++)
				{
					[arr addObject:[NSNumber numberWithFloat:aqc->_chan_lvls[i].mAveragePower]];
				}
				[aqc->recorder.delegate recorder:aqc->recorder levels:arr];
				[arr release];
			}
		}
	}

	NSLog(@"%p", inQB);
	if (AudioFileWritePackets(aqc->outputFile, false, inQB->mAudioDataByteSize, mDataFormat, aqc->recPtr, &frameSize, inQB->mAudioData) == noErr)
	{
		aqc->recPtr += frameSize;
	}
	
	if (!aqc->run)
		return ;
	
	AudioQueueEnqueueBuffer(aqc->queue, inQB, 0, NULL);

	[pool release];
}

#pragma mark lifeCycle
- (void) dealloc
{
	if (aqc._chan_lvls)
	{
		free(aqc._chan_lvls);
	}

	[super dealloc];
}


#pragma mark -


- (BOOL) start
{
	AudioFileTypeID fileFormat;
	
	aqc.mDataFormat.mFormatID = kAudioFormatLinearPCM;
	aqc.mDataFormat.mSampleRate = 44100;
	aqc.mDataFormat.mChannelsPerFrame = 1;
	aqc.mDataFormat.mBitsPerChannel = 16;
	aqc.mDataFormat.mBytesPerPacket =
	aqc.mDataFormat.mBytesPerFrame = aqc.mDataFormat.mChannelsPerFrame * sizeof(short int);
	aqc.mDataFormat.mFramesPerPacket = 1;
	aqc.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsBigEndian
								| kLinearPCMFormatFlagIsSignedInteger
								| kLinearPCMFormatFlagIsPacked;
	if (aqc._chan_lvls)
	{
		free(aqc._chan_lvls);
	}
	aqc._chan_lvls = malloc(sizeof(AudioQueueLevelMeterState)*aqc.mDataFormat.mChannelsPerFrame);
	aqc.frameSize = 0;
	aqc.recorder = self;
	
	AudioQueueNewInput(&aqc.mDataFormat, AQInputCallback, &aqc, NULL, kCFRunLoopCommonModes, 0, &aqc.queue);

	int frames;
	CGFloat buffDuration = 0.1;
	frames = (int)ceil(buffDuration * aqc.mDataFormat.mSampleRate);
	aqc.frameSize = frames * aqc.mDataFormat.mBytesPerFrame;

    fileFormat = kAudioFileAIFFType;
    CFURLRef fn = CFURLCreateFromFileSystemRepresentation(NULL,
														  (const UInt8 *)[self.fileName cStringUsingEncoding:NSUTF8StringEncoding],
														  [self.fileName length],
														  false);
	
	AudioFileCreateWithURL(fn, fileFormat, &aqc.mDataFormat, kAudioFileFlags_EraseFile, &aqc.outputFile);
	
	for (int i=0; i<AUDIO_BUFFERS; i++)
	{
		AudioQueueAllocateBuffer(aqc.queue, aqc.frameSize, &aqc.mBuffers[i]);
		AudioQueueEnqueueBuffer(aqc.queue, aqc.mBuffers[i], 0, NULL);
	}
	
	aqc.recPtr = 0;
	aqc.run = 1;
	
	AudioQueueStart(aqc.queue, NULL);
	
	recording = YES;
	
	return YES;
}

- (void) stop
{
	AudioQueueStop(aqc.queue, true);
	aqc.run = 0;
	
	AudioQueueDispose(aqc.queue, true);
	AudioFileClose(aqc.outputFile);
	recording = NO;
}

- (NSString *) fileName
{
	NSString *pathDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];                                                                      
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];                                                                                             
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	NSString *rv = [pathDir stringByAppendingPathComponent:
					[NSString stringWithFormat:@"%@.aiff", [dateFormatter stringFromDate:[NSDate date]]]
					];
	[dateFormatter release];
	return rv;
}

- (BOOL) recording
{
	return recording;
}

@end
