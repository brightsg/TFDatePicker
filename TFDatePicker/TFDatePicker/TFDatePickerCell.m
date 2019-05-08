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
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    // this is never called
    [super drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
