//
//  DatePickerTextField.h
//  ShootStudio
//
//  Created by Tom Fewster on 16/06/2010.
//  Copyright 2010 Tom Fewster. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TFDatePicker : NSDatePicker <NSDatePickerCellDelegate, NSPopoverDelegate>
@property (nonatomic, readonly) BOOL empty;
@property (nonatomic, assign) BOOL allowEmptyDate;
@property (nonatomic, assign) BOOL showPromptWhenEmpty;
@property SEL dateNormalisationSelector;

+ (void)setDefaultTimeZone:(NSTimeZone *)defaultTimeZone;
+ (NSTimeZone *)defaultTimeZone;

+ (void)setDefaultDateNormalisationSelector:(SEL)dateNormalisationSelector;
+ (SEL)defaultDateNormalisationSelector;

@end
