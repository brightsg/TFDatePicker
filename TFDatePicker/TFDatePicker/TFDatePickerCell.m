//
//  TFDatePickerCell.m
//  TFDatePicker
//
//  Created by Jonathan Mitchell on 14/05/2014.
//  Copyright (c) 2014 Tom Fewster. All rights reserved.
//

#import "TFDatePickerCell.h"
#import "TFDatePicker.h"

@implementation TFDatePickerCell

- (void)setShowsFirstResponder:(BOOL)showFR
{
    // prevent highlight from being drawn on empty
    TFDatePicker *datePicker = (id)self.controlView;
    if (datePicker.empty) {
        showFR = NO;
    }
    
    [super setShowsFirstResponder:showFR];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    // this draws all
    [super drawWithFrame:cellFrame inView:controlView];
    
    TFDatePicker *datePicker = (TFDatePicker *)controlView;
    if (datePicker.enabled == NO && datePicker.empty) {
        
        // ugh. macOS 13 doesnt play nicely with setting text color to match background for nil values.
        // nil values are rendered visible.
        // rather than risk breaking that legacy logic we obliterate the problem.
        if ([NSProcessInfo.new operatingSystemVersion].majorVersion >= 13) {
            CGFloat imageOffsetX = 0;
            if ([self datePickerStyle] == NSTextFieldAndStepperDatePickerStyle) {
                imageOffsetX = 5 + 16 +2;
            } else {
                imageOffsetX = 5 + 2;
            }
            
            NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(cellFrame.origin.x + 2, cellFrame.origin.y +2, cellFrame.size.width - imageOffsetX, cellFrame.size.height - 4)];
            [self.backgroundColor set];
            [path fill];
        }
    }
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    // this is never called
    [super drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
