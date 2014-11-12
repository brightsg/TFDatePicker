//
//  DatePickerTextField.h
//  ShootStudio
//
//  Created by Tom Fewster on 16/06/2010.
//  Copyright 2010 Tom Fewster. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TFDatePicker : NSDatePicker <NSDatePickerCellDelegate, NSPopoverDelegate>

/*!
 
 Class default timezone accessors.
 
 - timeZone defaults to this value
 
 */
+ (void)setDefaultTimeZone:(NSTimeZone *)defaultTimeZone;
+ (NSTimeZone *)defaultTimeZone;

/*!
 
 Class default calendar accessors.
 
 - calendar defaults to this value
 
 */
+ (void)setDefaultCalendar:(NSCalendar *)defaultCalendar;
+ (NSCalendar *)defaultCalendar;

/*!
 
 Class default date normalisation selector accessors.
 
 - defaultDateNormalisationSelector defaults to this value
 
 */
+ (void)setDefaultDateNormalisationSelector:(SEL)dateNormalisationSelector;
+ (SEL)defaultDateNormalisationSelector;

/*!
 
 Class default reference date accessors.
 
 - referenceDate defaults to this value
 
 */
+ (void)setDefaultReferenceDate:(NSDate *)date;
+ (NSDate *)defaultReferenceDate;

/*!
 
 Returns YES if no date displayed.
 
 */
@property (nonatomic, readonly) BOOL empty;

/*!
 
 If set to YES then a nil dateValue is displayed as an empty date.
 
 */
@property (nonatomic, assign) BOOL allowEmptyDate;


/*!
 
 If set to YES then a visual prompt image is displayed when the represented date is nil.
 
 */
@property (nonatomic, assign) BOOL showPromptWhenEmpty;


/*!
 
 The selector to use for date normalization. 
 Defaults to +defaultDateNormalisationSelector
 
 */
@property SEL dateNormalisationSelector;


/*!
 
 Reference date to use when editing an empty date.
 
 */
@property (nonatomic, strong) NSDate *referenceDate;

/*!
 
 Update the control's value.
 
 If the control is bound then the bound object is updated too.
 
 */
- (void)updateControlValue:(NSDate *)date;
@end
