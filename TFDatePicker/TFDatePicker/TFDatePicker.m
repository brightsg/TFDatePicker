//
//  DatePickerTextField.m
//  ShootStudio
//
//  Created by Tom Fewster on 16/06/2010.
//  Copyright 2010 Tom Fewster. All rights reserved.
//

#include <Carbon/Carbon.h>

#import "TFDatePicker.h"
#import "TFDatePickerCell.h"
#import "TFDatePickerPopoverController.h"

static char TFValueBindingContext;
static TFDatePickerPopoverController *m_currentDatePickerViewController;
static BOOL(^m_canDisplayPopOverBlock)(NSView *, BOOL force);

@interface TFDatePicker ()

// controllers
@property (strong) TFDatePickerPopoverController *datePickerViewController;

// views
@property (strong,nonatomic) NSButton *showPopoverButton;

// objects
@property (strong) NSColor *visibleTextColor;
@property (strong) NSImage *promptImage;

// primitives
@property (nonatomic) BOOL empty;
@property (assign) BOOL warningIssued;
@property CGFloat imageOffsetX;
@property CGFloat imageOffsetY;
@property CGFloat imageOpacity;

// methods
- (void)performClick:(id)sender;
@end

@implementation TFDatePicker


#pragma mark -
#pragma mark Localization defaults

static __strong NSTimeZone *m_defaultTimeZone;

+ (void)setDefaultTimeZone:(NSTimeZone *)defaultTimeZone
{
    m_defaultTimeZone = defaultTimeZone;
    
}

+ (NSTimeZone *)defaultTimeZone
{
    // defaults to nil
    return m_defaultTimeZone;
}

static __strong NSCalendar *m_defaultCalendar;

+ (void)setDefaultCalendar:(NSCalendar *)defaultCalendar
{
    m_defaultCalendar = defaultCalendar;
    
}

+ (NSCalendar *)defaultCalendar
{
    // defaults to nil
    return m_defaultCalendar;
}

static __strong NSLocale *m_defaultLocale;

+ (void)setDefaultLocale:(NSLocale *)defaultLocale
{
    m_defaultLocale = defaultLocale;
    
}

+ (NSLocale *)defaultLocale
{
    // defaults to nil
    return m_defaultLocale;
}

#pragma mark -
#pragma mark Date range defaults

static __strong NSDate *m_defaultMinDate;

+ (void)setDefaultMinDate:(NSDate *)defaultDate
{
    m_defaultMinDate = defaultDate;
}

+ (NSDate *)defaultMinDate
{
    // defaults to nil
    return m_defaultMinDate;
}

static __strong NSDate *m_defaultMaxDate;

+ (void)setDefaultMaxDate:(NSDate *)defaultDate
{
    m_defaultMaxDate = defaultDate;
}

+ (NSDate *)defaultMaxDate
{
    // defaults to nil
    return m_defaultMaxDate;
}

#pragma mark -
#pragma mark Delegate default

static __strong id m_defaultDelegate;

+ (void)setDefaultDelegate:(id)delegate
{
    m_defaultDelegate = delegate;
}

+ (id)defaultDelegate
{
    // defaults to nil
    return m_defaultDelegate;
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
    // defaults to nil
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
#pragma mark Blocks

+ (void)setCanDisplayPopOverBlock:(BOOL(^)(NSView *, BOOL force))value
{
    m_canDisplayPopOverBlock = value;
}

#pragma mark -
#pragma mark Reference date

static NSDate * m_referenceDate;

+ (void)setDefaultReferenceDate:(NSDate *)date
{
    m_referenceDate = date;
    
}

+ (NSDate *)defaultReferenceDate
{
    if (!m_referenceDate) {
        m_referenceDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    }
    return m_referenceDate;
}

#pragma mark -
#pragma mark Reference date

static __strong NSString *m_defaultDateFieldPlaceHolder;

+ (void)setDefaultDateFieldPlaceHolder:(NSString *)dateFieldPlaceHolder
{
    m_defaultDateFieldPlaceHolder = dateFieldPlaceHolder;
}

+ (NSString *)defaultDateFieldPlaceHolder
{
    return m_defaultDateFieldPlaceHolder;
}

#pragma mark -
#pragma mark Initialization

+ (void)initialize
{
    // this is ignored when unarchiving from a nib
    [self setCellClass:[TFDatePickerCell class]];
}

#pragma mark -
#pragma mark Lifecycle

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initConfig];
    }
    
    return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self initConfig];
    }
    
    return self;
}

- (void)initConfig
{
    _showPopoverOnFirstResponderWhenEmpty = YES;
    _showPopoverOnClickWhenEmpty = YES;
    _canDisplayPopOverBlock = m_canDisplayPopOverBlock;
}

- (void)awakeFromNib
{
    // access framework bundle
	NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
    self.promptImage = [frameworkBundle imageForResource:@"prompt"];
    
    // button
	NSButton *showPopoverButton = self.showPopoverButton;
	[self addSubview:showPopoverButton];

    self.imageOffsetY = 3;
    self.imageOpacity = 0.8;
    
    // button constraints
    // TODO: this only works when unarchiving. Refactor so that these constraints get added and removed when datePickerStyle is set.
	NSDictionary *views = NSDictionaryOfVariableBindings(showPopoverButton);
    if ([self.cell datePickerStyle] == NSTextFieldAndStepperDatePickerStyle) {
        self.imageOffsetX = 5 + 16 + 20;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[showPopoverButton(16)]-(20)-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(3)-[showPopoverButton(16)]" options:0 metrics:nil views:views]];
        
    } else {
        self.imageOffsetX = 5 + 16 + 4;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[showPopoverButton(16)]-(4)-|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(-2)-[showPopoverButton(16)]" options:0 metrics:nil views:views]];
    }

    // override -calendar with default
    if ([[self class] defaultCalendar]) {
        self.calendar = [[self class] defaultCalendar];
    }

    // override -timezone with default
    if ([[self class] defaultTimeZone]) {
        self.timeZone = [[self class] defaultTimeZone];
    }

    // override -locale with default
    if ([[self class] defaultLocale]) {
        self.locale = [[self class] defaultLocale];
    }
    
    // override date normalization selector
    if ([[self class] defaultDateNormalisationSelector]) {
        self.dateNormalisationSelector  = [[self class] defaultDateNormalisationSelector];
    }

    // override -minDate with default
    if ([[self class] defaultMinDate]) {
        self.minDate = [[self class] defaultMinDate];
    }

    // override -maxDate with default
    if ([[self class] defaultMaxDate]) {
        self.maxDate = [[self class] defaultMaxDate];
    }
    
    // override -delegate with default
    if ([[self class] defaultDelegate]) {
        [(NSDatePickerCell *)(self.cell) setDelegate:[[self class] defaultDelegate]];
    }
    
    // override -dateFieldPlaceHolder with default
    if ([[self class] defaultDateFieldPlaceHolder]) {
        self.dateFieldPlaceHolder = [[self class] defaultDateFieldPlaceHolder];
    }
    
    // set reference date
    self.referenceDate = [self.class defaultReferenceDate];
}

- (void)dealloc
{
    [self removeValueBindingObservation];
    self.delegate = nil;
}

#pragma mark -
#pragma mark Auto layout

- (NSSize)intrinsicContentSize
{
    NSSize size = [super intrinsicContentSize];
    
   return NSMakeSize(size.width + 22.0f, size.height);
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
    // do default drawing
    [super drawRect:rect];
    
    BOOL drawImage = NO;
    NSImage *image = self.promptImage;
    
    if (self.empty && self.showPromptWhenEmpty) {
        drawImage = YES;
        image = self.promptImage;
    }
    
    if (drawImage) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if ([image respondsToSelector:@selector(setFlipped:)]) {
            [image setFlipped:NO];
        }
#pragma clang diagnostic pop
        
        CGFloat imageHeight = image.size.height;
        CGFloat imageWidth = image.size.width;
        
        NSRect rectForBorders = NSMakeRect(rect.size.width - imageWidth - self.imageOffsetX, self.imageOffsetY, imageWidth, imageHeight);
        [image drawInRect:rectForBorders fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:self.imageOpacity];
    }
}

#pragma mark -
#pragma mark NSDatePickerCellDelegate

- (void)datePickerCell:(NSDatePickerCell *)aDatePickerCell validateProposedDateValue:(NSDate **)proposedDateValue timeInterval:(NSTimeInterval *)proposedTimeInterval {
    
    // forward delegate request from popover date picker cell
	if (self.delegate) {
		[self.delegate datePickerCell:aDatePickerCell validateProposedDateValue:proposedDateValue timeInterval:proposedTimeInterval];
	}
    
}

#pragma mark -
#pragma mark Actions

- (void)performClick:(id)sender {
    
    // validate if can display datepicker pop over
    if (self.canDisplayPopOverBlock && !self.canDisplayPopOverBlock(self, NO)) return;
    
    // if datepicker is up ignore
    if (self.datePickerViewController && self.datePickerViewController.popover.isShown) {
        return;
    }
    
    // validate the sender
    NSView *senderView = nil;
    if (![sender isKindOfClass:[NSView class]] || !sender) {
        senderView = self;
    }
    else {
        senderView = sender;
    }
    if (!senderView.window) {
        return;
    }
    
    if (m_currentDatePickerViewController) {
        [m_currentDatePickerViewController.popover close];
        m_currentDatePickerViewController = nil;
    }
    
	if (self.isEnabled) {
        
        NSDate *date = nil;
        if (!self.empty) {
            date = self.dateValue;
        }
        
        if (self.window.firstResponder != self) {
            [self.window makeFirstResponder:self];
        }
        
        // create view controller
        self.datePickerViewController = [[TFDatePickerPopoverController alloc] init];
        m_currentDatePickerViewController = self.datePickerViewController;
        [self.datePickerViewController view]; // load
        [self.datePickerViewController setDate:date
                                        locale:self.locale
                                      calendar:self.calendar
                                      timezone:self.timeZone
                                      elements:self.datePickerElements];
        
        // configure the popover date picker
		self.datePickerViewController.delegate = self;
        self.datePickerViewController.allowEmptyDate = self.allowEmptyDate;
        self.datePickerViewController.dateFieldPlaceholder = self.dateFieldPlaceHolder;
        
        // get display location
        NSEvent *event = [NSApp currentEvent];
        NSRect clickRect = [senderView bounds];
        if (event.type == NSLeftMouseDown || event.type == NSRightMouseDown) {
            NSPoint pt = [senderView convertPoint:[event locationInWindow] fromView:nil];
            clickRect = NSMakeRect(pt.x, pt.y, 1, 1);
        }
        
        // show the popover
        __weak TFDatePicker *welf = self;
		[self.datePickerViewController showDatePickerRelativeToRect:clickRect inView:senderView completionHander:^(NSDate *selectedDate) {
            
            if (welf.datePickerViewController.updateControlValueOnClose) {
                [welf updateControlValue:selectedDate];
            }
            
		}];
	}
}

#pragma mark -
#pragma mark NSPopoverDelegate

- (void)popoverDidClose:(NSNotification *)notification
{
    if (self.datePickerViewController == m_currentDatePickerViewController) {
        m_currentDatePickerViewController = nil;
    }
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
    }
    else {
        self.empty = NO;
    }
    
    if (self.empty) {
        dateValue = [NSDate distantFuture];
        [self setNeedsDisplay];
    }
    
    dateValue = [self normalizeDate:dateValue];
    
    [super setDateValue:dateValue];
}

- (void)setAllowEmptyDate:(BOOL)allowEmptyDate
{
    _allowEmptyDate = allowEmptyDate;
    self.dateValue = self.dateValue;
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
        if (!self.visibleTextColor) {
            self.visibleTextColor = self.textColor;
            [super setTextColor:self.backgroundColor];
        }
    }
    else {
        
        // reset text color
        if (self.visibleTextColor) {
            [super setTextColor:self.visibleTextColor];
            self.visibleTextColor = nil;
        }
    }
}

- (void)setTextColor:(NSColor *)color
{
    if (self.empty && self.visibleTextColor) {
        self.visibleTextColor = color;
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

- (void)setShowPromptWhenEmpty:(BOOL)showPromptWhenEmpty
{
    _showPromptWhenEmpty = showPromptWhenEmpty;
    
    [self needsDisplay];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    self.showPopoverButton.enabled = enabled;
}

- (NSButton *)showPopoverButton
{
    if (!_showPopoverButton) {
        NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];
        
        _showPopoverButton = [[NSButton alloc] initWithFrame:NSZeroRect];
        _showPopoverButton.buttonType = NSMomentaryChangeButton;
        _showPopoverButton.bezelStyle = NSInlineBezelStyle;
        _showPopoverButton.bordered = NO;
        _showPopoverButton.imagePosition = NSImageOnly;
        _showPopoverButton.toolTip = NSLocalizedString(@"Show date picker panel", "Datepicker button tool tip");
        
        _showPopoverButton.image = [frameworkBundle imageForResource:@"calendar"];
        [_showPopoverButton.cell setHighlightsBy:NSContentsCellMask];
        
        [_showPopoverButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        _showPopoverButton.target = self;
        _showPopoverButton.action = @selector(performClick:);
    }
    
    return _showPopoverButton;
}

- (void)setObjectValue:(id)objectValue
{
    [super setObjectValue:objectValue];
}

- (void)setStringValue:(NSString *)stringValue
{
    [super setStringValue:stringValue];
}

- (BOOL)becomeFirstResponder
{
    BOOL result = [super becomeFirstResponder];

    if (result && self.empty && self.showPopoverOnFirstResponderWhenEmpty) {
        
        // allow popup if we have navigated using the TAB key
        NSEvent *event = [NSApp currentEvent];
        if (event.type == NSEventTypeKeyDown) {
            if (event.keyCode != kVK_Tab) {
                return result;
            }
        }
        
        // allow popup if we have actually clicked the control.
        // this prevents popups from occurring spontaneously which just looks odd in many cases.
        else if (event.type == NSLeftMouseUp) {
            NSPoint pt = [self convertPoint:[event locationInWindow] fromView:nil];
            if (!NSPointInRect(pt, self.bounds)) {
                return result;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performClick:self];
        });
    }

    return result;
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
        
        // get the observed object and the key path
        id observedObject = [bindingInfo objectForKey:NSObservedObjectKey];
        NSString *keyPath = [bindingInfo valueForKey:NSObservedKeyPathKey];
        
        // validate now?
        BOOL isValid = YES;
        NSError *error = nil;
        if ([options[NSValidatesImmediatelyBindingOption] boolValue]) {
            isValid = [observedObject validateValue:&bindingValue forKeyPath:keyPath error:&error];
        }
        
        // update the bound object
        if (isValid) {
            if (![[observedObject valueForKeyPath:keyPath] isEqual:bindingValue]) {
                [observedObject setValue:bindingValue forKeyPath:keyPath];
            }
        }
        else {
            
            // close the popover
            self.datePickerViewController.updateControlValueOnClose = NO;
            [self.datePickerViewController.popover close];
            
            // show error alert
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSAlertFirstButtonReturn) {
                }
            }];
        }
        
    }
    else {
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
    [object addObserver:self
             forKeyPath:keyPath
                options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                context:&TFValueBindingContext];
}

- (void)removeValueBindingObservation
{
    NSDictionary *bindingInfo = [self infoForBinding:NSValueBinding];
    id valueBindingObservedObject = bindingInfo[NSObservedObjectKey];
    
    if (valueBindingObservedObject) {
        
        NSString *valueBindingObservedKeyPath = bindingInfo[NSObservedKeyPathKey];
        
        @try {
            [valueBindingObservedObject removeObserver:self forKeyPath:valueBindingObservedKeyPath];
        } @catch (NSException *e) {
            
        }
    }
}

#pragma mark -
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &TFValueBindingContext) {
        
        // keyValue may not be a date if a binding value transformer is used
        id keyValue = [object valueForKeyPath:keyPath];
        
        // keyValue may be a no selection marker on occasion
        if ((!keyValue || keyValue == NSNoSelectionMarker) && self.allowEmptyDate) {
            self.empty = YES;
        }
        else {
            self.empty = NO;
        }
        
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -
#pragma mark Event handling

- (void)keyDown:(NSEvent *)theEvent
{
    if (self.empty) {
        [self performClick:self];
    }
    [super keyDown:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [super mouseUp:theEvent];
    
    if (self.empty && theEvent.clickCount == 1 && ![self eventInStepper:theEvent]) {
        [self performClick:self];
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [super mouseDown:theEvent];
    
    if (theEvent.clickCount == 1) {
        if (![self eventInStepper:theEvent] && self.empty && self.showPopoverOnClickWhenEmpty) {
            [self performClick:self];
        }
    }
    else if (theEvent.clickCount == 2) {
        if (![self eventInStepper:theEvent]) {
            [self performClick:self];
        }
    }
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    if (![self eventInStepper:theEvent]) {
        [self.window makeFirstResponder:self];
        [self performClick:self];
    } else {
        [super mouseDown:theEvent];
    }
}

- (BOOL)eventInStepper:(NSEvent *)event
{
    NSPoint pt = [self convertPoint:[event locationInWindow] fromView:nil];
    return self.bounds.size.width - pt.x <= 20 ? YES : NO;
}

@end
