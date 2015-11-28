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

// outlets
@property (strong) IBOutlet NSDatePicker *datePicker;
@property (weak) IBOutlet NSTextField *dateTextField;

// properties
@property (copy) void(^completionHandler)(NSDate *selectedDate);
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (assign, nonatomic) BOOL dateIsValid;

@end

@implementation TFDatePickerPopoverController

#pragma mark -
#pragma mark Lifecycle

- (id)init
{
    self = [super initWithNibName:@"TFDatePicker" bundle:[NSBundle bundleForClass:[TFDatePicker class]]];
	if (self) {

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

- (void)awakeFromNib
{
}

- (void)setDate:(NSDate *)date locale:(NSLocale *)locale calendar:(NSCalendar *)calendar timezone:(NSTimeZone *)timezone elements:(NSDatePickerElementFlags)elements
{
    NSAssert(self.datePicker, @"View not loaded");
    
    // setup date picker
    self.datePicker.dateValue = date;
    self.datePicker.calendar = calendar;
    self.datePicker.timeZone = timezone;
    self.datePicker.locale = locale;
    self.datePicker.datePickerElements = elements;
    self.datePicker.hidden = NO;
    
    // setup date formatter
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.calendar = calendar;
    self.dateFormatter.timeZone = timezone;
    self.dateFormatter.locale = locale;
    
    self.dateFormatter.dateFormat = @"d MMM yyyy";
    
    [self showFormattedDate:date];
}

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
    
    // get the field editor now and assign delegate so that can tab out of the date text field
    NSText *fieldEditor = [self.view.window fieldEditor:YES forObject:nil];
    fieldEditor.delegate = self;
}

#pragma mark -
#pragma mark Popover handling

-(void)popoverWillShow:(NSNotification *)notification
{
    self.dateTextField.window.initialFirstResponder = self.dateTextField;
}

- (void)popoverDidClose:(NSNotification *)notification
{
    [self.delegate popoverDidClose:notification];
}

#pragma mark -
#pragma mark Accessors

- (void)setDateIsValid:(BOOL)dateIsValid
{
    _dateIsValid = dateIsValid;
    if (!_dateIsValid) {
        self.datePicker.dateValue = [NSDate date];
    }
}

- (void)showFormattedDate:(NSDate *)date
{
    NSString *dateString = nil;
    if (date) {
        dateString = [self.dateFormatter stringFromDate:date];
    }
    if (!dateString) {
        dateString = @"";
    }
    self.dateTextField.stringValue = dateString;
    
    self.dateIsValid = dateString.length > 0;
}

- (void)setDateFieldPlaceholder:(NSString *)dateFieldPlaceholder
{
    _dateFieldPlaceholder = dateFieldPlaceholder;
    self.dateTextField.placeholderString = dateFieldPlaceholder;
}

#pragma mark -
#pragma mark Actions

- (IBAction)dateChanged:(id)sender {
    
    NSDate *datePickerDate = _datePicker.dateValue;

    [self showFormattedDate:datePickerDate];
    
    // run the block
	self.completionHandler(datePickerDate);
}

- (IBAction)today:(id)sender
{
    NSDate *date = [NSDate date];
    
    [self showFormattedDate:date];
    self.completionHandler(date);

    if (self.popover.shown) {
        [self.popover close];
    }
}

- (IBAction)clear:(id)sender
{
    [self showFormattedDate:nil];
    self.completionHandler(nil);
}

#pragma mark -
#pragma mark Date detection

- (NSDate *)detectDateInTextField
{
    NSDate *date = nil;

    // get date string from text field
    NSString *dateTextString = [self.dateTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (!dateTextString || dateTextString.length == 0) {
        return date;
    }
    
    // detect date
    NSError *error;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:&error];
    NSTextCheckingResult *result = [detector firstMatchInString:dateTextString options:0 range:NSMakeRange(0, [dateTextString length])];
    
    if (result) {
        date = result.date;
    }
    return date;
}

- (void)endDateFieldEdit
{
    NSDate *date = [self detectDateInTextField];
    if (date) {
        self.datePicker.dateValue = date;
        self.completionHandler(date);
        self.dateIsValid = YES;
        
        if (self.popover.shown) {
            [self.popover close];
        }
    }
    else {
        self.dateIsValid = NO;
    }
}

#pragma mark -
#pragma mark NSTextView delegate

// the text view here is the field editor

- (void)textDidChange:(NSNotification *)note
{
    NSDate *date = [self detectDateInTextField];
    if (date) {
        self.datePicker.dateValue = date;
        self.dateIsValid = YES;
    }
    else {
        self.dateIsValid = NO;
    }
}

- (void)textDidEndEditing:(NSNotification *)note
{
    [self endDateFieldEdit];
}

- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    //  select next key view when tab selected rather than enter tab into NSTextView
    if (commandSelector == @selector(insertTab:)) {
        
        // end the edit
        [self endDateFieldEdit];
        
        if (self.popover.shown) {
            [self.popover close];
        }
        
        // select next key view
        [[NSApp keyWindow] selectNextKeyView:self];
        
        // return YES if delegate handled command
        return YES;
    }
    
    return NO;
}

@end
