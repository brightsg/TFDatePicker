//
//  AppDelegate.m
//  DatePickerTest
//
//  Created by Tom Fewster on 18/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import "AppDelegate.h"
#import <TFDatePicker/TFDatePicker.h>

@interface AppDelegate ()
@property (weak) IBOutlet TFDatePicker *datePicker1;
@property (weak) IBOutlet TFDatePicker *datePicker2;
@property (weak) IBOutlet TFDatePicker *datePicker3;
@end

@implementation AppDelegate

@synthesize allDay = _allDay;
@synthesize datePicker1 = _datePicker1;
@synthesize datePicker2 = _datePicker2;
@synthesize date1 = _date1;
@synthesize date2 = _date2;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	self.datePicker1.delegate = self;
	self.datePicker2.delegate = self;

    // allow empty dates and nil binding
    self.datePicker1.allowEmptyDate = YES;
    self.datePicker2.allowEmptyDate = YES;
    
	self.date1 = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
	self.date2 = [NSDate date];

    self.allDay = YES;
}


- (void)setAllDay:(BOOL)allDay {
	_allDay = allDay;
	if (!allDay) {
		self.datePicker1.datePickerElements = NSYearMonthDayDatePickerElementFlag | NSHourMinuteDatePickerElementFlag;
		self.datePicker2.datePickerElements = NSYearMonthDayDatePickerElementFlag | NSHourMinuteDatePickerElementFlag;
		self.datePicker3.datePickerElements = NSYearMonthDayDatePickerElementFlag | NSHourMinuteDatePickerElementFlag;
	} else {
		self.datePicker1.datePickerElements = NSYearMonthDayDatePickerElementFlag;
		self.datePicker2.datePickerElements = NSYearMonthDayDatePickerElementFlag;
		self.datePicker3.datePickerElements = NSYearMonthDayDatePickerElementFlag;
	}
}

const NSTimeInterval timeStep = 5.0f * 60.0f; // 5 mins

- (void)datePickerCell:(NSDatePickerCell *)aDatePickerCell validateProposedDateValue:(NSDate **)proposedDateValue timeInterval:(NSTimeInterval *)proposedTimeInterval {
	NSDate *date = *proposedDateValue;

	NSTimeInterval timeInterval = [date timeIntervalSinceReferenceDate] - (timeStep/2.0);

	if(timeStep != 0) {
		double remainder = fmod(timeInterval, timeStep);
		if (remainder != 0.0f) {
			timeInterval = timeInterval - remainder;
		}
	}

	*proposedDateValue = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
}


@end
