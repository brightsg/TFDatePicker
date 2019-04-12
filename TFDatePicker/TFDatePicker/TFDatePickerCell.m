//
//  TFDatePickerCell.m
//  TFDatePicker
//
//  Created by Jonathan Mitchell on 14/05/2014.
//  Copyright (c) 2014 Tom Fewster. All rights reserved.
//

#import "TFDatePickerCell.h"
#import "TFDatePicker.h"

@interface NSDatePickerCell()
- (IBAction)_stepperCellValueChanged:(id)sender;
@end

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

// this is a private method.
// seems like the only way to intercept the stepper call
- (IBAction)_stepperCellValueChanged:(id)sender
{
    // exception raised if no picker elements defined.
    // defining no elements and setting style to text only results in a collapsed control.
    if (self.datePickerElements == 0) {
        return;
    }
    [super _stepperCellValueChanged:sender];
}
@end
