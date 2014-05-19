//
//  DatePickerTextField.m
//  ShootStudio
//
//  Created by Tom Fewster on 16/06/2010.
//  Copyright 2010 Tom Fewster. All rights reserved.
//

#import "TFDatePicker.h"
#import "TFDatePickerCell.h"
#import "TFDatePickerPopoverController.h"

static char TFValueBindingContext;

@interface TFDatePicker ()

@property (strong) TFDatePickerPopoverController *datePickerViewController;
@property (nonatomic) BOOL empty;
@property (strong) NSColor *prevTextColor;
@property (assign) BOOL warningIssued;

@property (strong) id valueBindingObservedObject;
@property (strong) NSString *valueBindingObservedKeyPath;

- (void)performClick:(id)sender;
@end

@implementation TFDatePicker

static NSTimeZone *m_defaultTimeZone;

#pragma mark -
#pragma mark Localization

+ (void)setDefaultTimeZone:(NSTimeZone *)defaultTimeZone
{
    m_defaultTimeZone = defaultTimeZone;
    
}

+ (NSTimeZone *)defaultTimeZone
{
    return m_defaultTimeZone;
}

#pragma mark -
#pragma mark Normalization

static SEL m_defaultDateNormalisationSelector;

+ (void)setDefaultDateNormalisationSelector:(SEL)dateNormalisationSelector
{
    m_defaultDateNormalisationSelector = dateNormalisationSelector;
}

+ (SEL)defaultDateNormalisationSelector
{
    return m_defaultDateNormalisationSelector;
}

- (NSDate *)normalizeDate:(NSDate *)date
{
    if (self.dateNormalisationSelector && date) {
        
        // potential warning leak warning leak : date = [date performSelector:self.dateNormalisationSelector];
        // hence the invocation
        
        SEL selector = self.dateNormalisationSelector;
        NSMethodSignature *methodSig = [[date class] instanceMethodSignatureForSelector:selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
        [invocation setSelector:selector];
        [invocation setTarget:date];
        [invocation invoke];
        [invocation getReturnValue:&date];
    }
    
    return date;
}
#pragma mark -
#pragma mark Initialization

+ (void)initialize
{
    // this is ignored when unarchiving from a nib
    [self setCellClass:[TFDatePickerCell class]];
}

#pragma mark -
#pragma mark Nib loading

- (void)awakeFromNib
{    
    // button
	NSButton *showPopoverButton = [[NSButton alloc] initWithFrame:NSZeroRect];
	showPopoverButton.buttonType = NSMomentaryChangeButton;
	showPopoverButton.bezelStyle = NSInlineBezelStyle;
	showPopoverButton.bordered = NO;
	showPopoverButton.imagePosition = NSImageOnly;
    showPopoverButton.toolTip = NSLocalizedString(@"Show date picker panel", "Datepicker button tool tip");
    
	NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
	showPopoverButton.image = [frameworkBundle imageForResource:@"calendar"];
	[showPopoverButton.cell setHighlightsBy:NSContentsCellMask];

	[showPopoverButton setTranslatesAutoresizingMaskIntoConstraints:NO];
	showPopoverButton.target = self;
	showPopoverButton.action = @selector(performClick:);
	[self addSubview:showPopoverButton];

    // button constraints
    // TODO: this only works when unarchiving. Refactor so that these constraints get added and removed when datePickerStyle is set.
	NSDictionary *views = NSDictionaryOfVariableBindings(showPopoverButton);
    if ([self.cell datePickerStyle] == NSTextFieldAndStepperDatePickerStyle) {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[showPopoverButton(16)]-(20)-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(3)-[showPopoverButton(16)]" options:0 metrics:nil views:views]];
        
    } else {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[showPopoverButton(16)]-(4)-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(-2)-[showPopoverButton(16)]" options:0 metrics:nil views:views]];
    }
    
    // override timezone with default
    if ([[self class] defaultTimeZone]) {
        self.timeZone = [[self class] defaultTimeZone];
    }
    
    // override date normalization selector
    if ([[self class] defaultDateNormalisationSelector]) {
        self.dateNormalisationSelector  = [[self class] defaultDateNormalisationSelector];
    }

}

#pragma mark -
#pragma mark Auto layout

- (NSSize)intrinsicContentSize
{
    NSSize size = [super intrinsicContentSize];
    
   return NSMakeSize(size.width + 22.0f, size.height);
}

#pragma mark -
#pragma mark NSDatePickerCellDelegate

- (void)datePickerCell:(NSDatePickerCell *)aDatePickerCell validateProposedDateValue:(NSDate **)proposedDateValue timeInterval:(NSTimeInterval *)proposedTimeInterval {
	if (self.delegate) {
		[self.delegate datePickerCell:aDatePickerCell validateProposedDateValue:proposedDateValue timeInterval:proposedTimeInterval];
	}
}

#pragma mark -
#pragma mark Actions

- (void)performClick:(id)sender {
    
    if (self.datePickerViewController) {
        return;
    }
    
    self.datePickerViewController = [[TFDatePickerPopoverController alloc] init];
    
	if (self.isEnabled) {
        
        if (self.empty) {
            [self updateControlValue:[self referenceDate]];
        }
        
        // configure the popover date picker
		self.datePickerViewController.datePicker.dateValue = self.dateValue;
        self.datePickerViewController.datePicker.calendar = self.calendar;
        self.datePickerViewController.datePicker.timeZone = self.timeZone;
        self.datePickerViewController.datePicker.locale = self.locale;
		[self.datePickerViewController.datePicker setDatePickerElements:self.datePickerElements];
        
		self.datePickerViewController.delegate = self;
        self.datePickerViewController.allowEmptyDate = self.allowEmptyDate;
        
		[_datePickerViewController showDatePickerRelativeToRect:[sender bounds] inView:sender completionHander:^(NSDate *selectedDate) {
            
            [self updateControlValue:selectedDate];
            
		}];
	}
}


#pragma mark -
#pragma mark NSPopoverDelegate

- (void)popoverDidClose:(NSNotification *)notification
{
    self.datePickerViewController = nil;
}

#pragma mark -
#pragma mark Accessors

- (void)setDatePickerElements:(NSDatePickerElementFlags)elementFlags
{
    [super setDatePickerElements:elementFlags];
    [self invalidateIntrinsicContentSize];
}

- (void)setDateValue:(NSDate *)dateValue
{
    if (self.allowEmptyDate) {
        self.empty = !dateValue || (id)dateValue == [NSNull null] ? YES : NO;
    } else {
        self.empty = NO;
    }
    
    if (self.empty) {
        dateValue = [NSDate distantFuture];
        [self setNeedsDisplay];
    }
    
    dateValue = [self normalizeDate:dateValue];
    
    [super setDateValue:dateValue];
}

- (NSDate *)dateValue
{
    if (self.empty) {
        return nil;
    }
    
    return [super dateValue];
}

- (void)setEmpty:(BOOL)empty
{
    if (!self.allowEmptyDate) {
        empty = NO;
    }
    
    _empty = empty;
    
    // there is no effective way of overridding the cell interior drawing (believe me, I really really tried)
    // hence we camouflage the text.
    if (empty) {
        
        // cell class warning
        if (![self.cell isKindOfClass:[TFDatePickerCell class]] && !self.warningIssued) {
            self.warningIssued = YES;
            NSLog(@"%@ requires cell of class %@ to be set in the nib in order to function correctly. This warning will be issued for each instance of the control that assigns the empty property to YES", [self className], [[[self class] cellClass] className]);
        }

        // match text to background
        if (!self.prevTextColor) {
            self.prevTextColor = self.textColor;
            [super setTextColor:self.backgroundColor];
        }
    } else {
        
        // reset text color
        if (self.prevTextColor) {
            [super setTextColor:self.prevTextColor];
            self.prevTextColor = nil;
        }
    }
}

- (NSDate *)referenceDate
{
    return [NSDate dateWithTimeIntervalSinceReferenceDate:0];
}

- (void)setTextColor:(NSColor *)color
{
    if (self.empty && self.prevTextColor) {
        self.prevTextColor = color;
    } else {
        [super setTextColor:color];
    }
}

- (void)setBackgroundColor:(NSColor *)color
{
    if (self.empty) {
        [super setTextColor:color];
    }
    
    [super setBackgroundColor:color];
}

#pragma mark -
#pragma mark Binding support

- (void)updateControlValue:(NSDate *)date
{
    // if we have bindings, update the bound "value", otherwise just update the value in the datePicker
    NSDictionary *bindingInfo = [self infoForBinding:NSValueBinding];
    if (bindingInfo) {
        
        // normalise the date
        date = [self normalizeDate:date];
        
        // transform the binding value if a transformer is defined
        id bindingValue = date;
        NSDictionary *options = [bindingInfo valueForKey:NSOptionsKey];
        NSValueTransformer *valueTransformer = nil;
        
        // use named transformer
       id transformerNameOption = options[NSValueTransformerNameBindingOption];
        if (transformerNameOption && ![transformerNameOption isEqual:[NSNull null]]) {
            valueTransformer = [NSValueTransformer valueTransformerForName:transformerNameOption];
        }
        
        // use transformer instance
        id transformerOption = options[NSValueTransformerBindingOption];
        if (transformerOption && ![transformerOption isEqual:[NSNull null]]) {
            valueTransformer = transformerOption;
        }
        
        // apply transformer
        if (valueTransformer) {
            bindingValue = [valueTransformer reverseTransformedValue:bindingValue];
        }
        
        // update the bound object
        NSString *keyPath = [bindingInfo valueForKey:NSObservedKeyPathKey];
        [[bindingInfo objectForKey:NSObservedObjectKey] setValue:bindingValue forKeyPath:keyPath];
        
    } else {
        self.dateValue = date;
    }
}

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
    if ([binding isEqual:NSValueBinding]) {
        [self removeValueBindingObservation];
    }

    [super bind:binding toObject:observable withKeyPath:keyPath options:options];
    
    // observe when the value binding changes
    if ([binding isEqual:NSValueBinding]) {
        [self addValueBindingObservationForObject:observable keyPath:keyPath];
    }
}

- (void)unbind:(NSString *)binding
{
    if ([binding isEqual:NSValueBinding]) {
        [self removeValueBindingObservation];
    }
    
    [super unbind:binding];
}

- (void)addValueBindingObservationForObject:(id)object keyPath:(NSString *)keyPath
{
    self.valueBindingObservedObject = object;
    self.valueBindingObservedKeyPath = keyPath;
    
    [self.valueBindingObservedObject addObserver:self
                                      forKeyPath:self.valueBindingObservedKeyPath
                                         options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                                         context:&TFValueBindingContext];
}

- (void)removeValueBindingObservation
{
    if (self.valueBindingObservedObject) {
        
        @try {
            [self.valueBindingObservedObject removeObserver:self forKeyPath:self.valueBindingObservedKeyPath];
        } @catch (NSException *e) {
            
        }
        
        self.valueBindingObservedObject = nil;
        self.valueBindingObservedKeyPath = nil;
    }
}

#pragma mark -
#pragma mark KVO


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &TFValueBindingContext) {
        NSDate *date = [object valueForKeyPath:keyPath];
        
        if (!date && self.allowEmptyDate) {
            self.empty = YES;
        } else {
            self.empty = NO;
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -
#pragma mark Event handling

- (void)keyDown:(NSEvent *)theEvent
{
    if (self.empty) {
        [self updateControlValue:[self referenceDate]];
    }
    [super keyDown:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    // TODO: add a context menu to allow clearing of current date
    if (self.empty) {
        [self updateControlValue:[self referenceDate]];
    }
    [super mouseDown:theEvent];
}

#pragma mark -
#pragma mark KVO

- (void)dealloc
{
    [self removeValueBindingObservation];
}

@end
