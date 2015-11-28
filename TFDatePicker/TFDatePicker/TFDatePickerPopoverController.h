//
//  DatePickerPopoverController.h
//  ShootStudio
//
//  Created by Tom Fewster on 03/10/2011.
//  Copyright (c) 2011 Tom Fewster. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TFDatePickerPopoverController : NSViewController <NSPopoverDelegate, NSTextDelegate>;

@property (strong) NSPopover *popover;
@property (weak) id <NSPopoverDelegate> delegate;
@property (assign) BOOL allowEmptyDate;
@property (assign) BOOL updateControlValueOnClose;
@property (strong, nonatomic) NSString *dateFieldPlaceholder;

- (IBAction)showDatePickerRelativeToRect:(NSRect)rect inView:(NSView *)view completionHander:(void(^)(NSDate *selectedDate))completionHandler;

- (void)setDate:(NSDate *)date locale:(NSLocale *)locale calendar:(NSCalendar *)calendar timezone:(NSTimeZone *)timezone elements:(NSDatePickerElementFlags)elements;


@end