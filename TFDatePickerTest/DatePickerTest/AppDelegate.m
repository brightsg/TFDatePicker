//
//  AppDelegate.m
//  DatePickerTest
//
//  Created by Tom Fewster on 18/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import "AppDelegate.h"
#import <TFDatePicker/TFDatePicker.h>
#import "NSDate+DatePickerTest.h"

@interface AppDelegate ()
@property (weak) IBOutlet TFDatePicker *datePicker1;
@property (weak) IBOutlet TFDatePicker *datePicker2;
@property (weak) IBOutlet TFDatePicker *datePicker3;
@property (weak) IBOutlet TFDatePicker *datePicker4;

@property (assign) IBOutlet NSWindow *window;

@property (strong) NSDate *date1;
@property (strong) NSDate *date2;
@property (strong) NSDate *date3;
@property (strong) NSDate *date4;
@property (nonatomic, assign) BOOL allDay;

@end

@implementation AppDelegate

+ (void)initialize
{
    // default localization and date normalisation
    
    // always use UTC
    [TFDatePicker setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    // normalise dates to midnight UTC
    [TFDatePicker setDefaultDateNormalisationSelector:@selector(dpt_normalise)];
    
    // default reference date to today
    [TFDatePicker setDefaultReferenceDate:[NSDate date]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	self.datePicker1.delegate = self;
	self.datePicker2.delegate = self;

    // allow empty dates and nil binding.
    // if this property is not set then the date picker behaves like its superclass.
    self.datePicker1.allowEmptyDate = YES;
    self.datePicker1.showPromptWhenEmpty = YES;
    
    self.datePicker2.allowEmptyDate = YES;
    self.datePicker2.showPromptWhenEmpty = YES;
    
    self.datePicker4.allowEmptyDate = YES;
    self.datePicker4.showPromptWhenEmpty = NO;  // just to be different
    self.datePicker4.referenceDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0]; // just to be different
    
	self.date1 = nil;
	self.date2 = [NSDate date];
    self.date3 = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    self.date4 = nil;
    
    self.allDay = YES;
}

- (void)setAllDay:(BOOL)allDay {
	_allDay = allDay;
	if (!allDay) {
		self.datePicker1.datePickerElements = NSYearMonthDayDatePickerElementFlag | NSHourMinuteDatePickerElementFlag;
		self.datePicker2.datePickerElements = NSYearMonthDayDatePickerElementFlag | NSHourMinuteDatePickerElementFlag;
		self.datePicker3.datePickerElements = NSYearMonthDayDatePickerElementFlag | NSHourMinuteDatePickerElementFlag;
        self.datePicker4.datePickerElements = NSYearMonthDayDatePickerElementFlag | NSHourMinuteDatePickerElementFlag;
	} else {
		self.datePicker1.datePickerElements = NSYearMonthDayDatePickerElementFlag;
		self.datePicker2.datePickerElements = NSYearMonthDayDatePickerElementFlag;
		self.datePicker3.datePickerElements = NSYearMonthDayDatePickerElementFlag;
        self.datePicker4.datePickerElements = NSYearMonthDayDatePickerElementFlag;
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
