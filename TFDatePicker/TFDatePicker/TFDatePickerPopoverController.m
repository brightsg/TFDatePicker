//
//  DatePickerPopoverController.m
//  ShootStudio
//
//  Created by Tom Fewster on 03/10/2011.
//  Copyright (c) 2011 Tom Fewster. All rights reserved.
//

#import "TFDatePickerPopoverController.h"
#import "TFDatePicker.h"

@interface TFDatePickerPopoverController ()

@property (strong) IBOutlet NSDatePicker *datePicker;

@property (copy) void(^completionHandler)(NSDate *selectedDate);
@end

@implementation TFDatePickerPopoverController

#pragma mark -
#pragma mark Setup

- (id)init {
    
    // load nib from framework bundle
	if ((self = [super initWithNibName:@"TFDatePicker" bundle:[NSBundle bundleForClass:[TFDatePicker class]]])) {
        
        // load the nib now
        [self view];
 	}

	return self;
}

- (void)dealloc
{
    // remove observers
    
    // unregister for notifications
    
    // set any non-weak delegates to nil
    _popover.delegate = nil;
    
    // invalidate any timers

}

#pragma mark -
#pragma mark Accessors


#pragma mark -
#pragma mark Display

- (IBAction)showDatePickerRelativeToRect:(NSRect)rect inView:(NSView *)view completionHander:(void(^)(NSDate *selectedDate))completionHandler {
	self.completionHandler = completionHandler;
	self.popover = [[NSPopover alloc] init];
	self.popover.delegate = self;
	self.popover.contentViewController = self;
	self.popover.behavior = NSPopoverBehaviorTransient;
	[self.popover showRelativeToRect:rect ofView:view preferredEdge:NSMaxXEdge];
    self.updateControlValueOnClose = YES;
}

#pragma mark -
#pragma mark Popover handling

- (void)popoverDidClose:(NSNotification *)notification
{
    [self.delegate popoverDidClose:notification];
}


#pragma mark -
#pragma mark Actions

- (IBAction)dateChanged:(id)sender {
	_completionHandler(_datePicker.dateValue);
}

- (IBAction)today:(id)sender
{
    _completionHandler([NSDate date]);
    [self.popover performClose:sender];
}

- (IBAction)clear:(id)sender
{
    _completionHandler(nil);
    [self.popover performClose:sender];
}

#pragma mark -
#pragma mark Todo

#ifdef IS_THE_FUTURE

/*
 
 Add an NSTextField to the nib and parse the date from user input
 
 */
- (NSDate *)parseDateString:(NSString *)input
{
    NSDate *date = nil;
    
    if (!input || [input length] == 0) return date;
    
    NSError *error;
    NSDataDetector *guess = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:&error];
    NSArray *matches = [guess matchesInString:input options:0 range:NSMakeRange(0, [input length])];
    
    if ([matches count]) {
        date = ((NSTextCheckingResult *)[matches objectAtIndex:0]).date;
    }
    return date;
}
#endif

@end
