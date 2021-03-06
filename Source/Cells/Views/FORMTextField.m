#import "FORMTextField.h"

#import "FORMBaseFieldCell.h"

#import "UIColor+FORMColors.h"
#import "UIColor+Hex.h"
#import "UIFont+FORMStyles.h"
#import "FORMTextFieldTypeManager.h"

static const CGFloat FORMTextFieldClearButtonWidth = 30.0f;
static const CGFloat FORMTextFieldClearButtonHeight = 20.0f;

@interface FORMTextField () <UITextFieldDelegate>

@property (nonatomic, getter = isModified) BOOL modified;

@end

@implementation FORMTextField

@synthesize rawText = _rawText;

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    self.layer.borderWidth = FORMFieldCellBorderWidth;
    self.layer.borderColor = [UIColor FORMBlue].CGColor;
    self.layer.cornerRadius = FORMFieldCellCornerRadius;

    self.delegate = self;

    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    self.backgroundColor = [UIColor FORMFieldBackground];
    self.font = [UIFont FORMTextFieldFont];
    self.textColor = [UIColor FORMDarkBlue];

    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, FORMFieldCellLeftMargin, 0.0f)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;

    [self addTarget:self action:@selector(textFieldDidUpdate:) forControlEvents:UIControlEventEditingChanged];
    [self addTarget:self action:@selector(textFieldDidReturn:) forControlEvents:UIControlEventEditingDidEndOnExit];

    self.returnKeyType = UIReturnKeyDone;

    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:[UIImage imageNamed:@"ic_mini_clear"] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearButtonAction) forControlEvents:UIControlEventTouchUpInside];
    clearButton.frame = CGRectMake(0.0f, 0.0f, FORMTextFieldClearButtonWidth, FORMTextFieldClearButtonHeight);
    self.rightView = clearButton;
    self.rightViewMode = UITextFieldViewModeWhileEditing;

    return self;
}

#pragma mark - Setters

- (NSRange)currentRange
{
    NSInteger startOffset = [self offsetFromPosition:self.beginningOfDocument
                                          toPosition:self.selectedTextRange.start];
    NSInteger endOffset = [self offsetFromPosition:self.beginningOfDocument
                                        toPosition:self.selectedTextRange.end];
    NSRange range = NSMakeRange(startOffset, endOffset-startOffset);

    return range;
}

- (void)setText:(NSString *)text
{
    UITextRange *textRange = self.selectedTextRange;
    NSString *newRawText = [self.formatter formatString:text reverse:YES];
    NSRange range = [self currentRange];

    BOOL didAddText  = (newRawText.length > self.rawText.length);
    BOOL didFormat   = (text.length > super.text.length);
    BOOL cursorAtEnd = (newRawText.length == range.location);

    if ((didAddText && didFormat) || (didAddText && cursorAtEnd)) {
        self.selectedTextRange = textRange;
        [super setText:text];
    } else {
        [super setText:text];
        self.selectedTextRange = textRange;
    }
}

- (void)setActive:(BOOL)active
{
    _active = active;

    if (active) {
        self.backgroundColor = [UIColor FORMFieldBackgroundActive];
        self.layer.borderColor = [UIColor FORMBlue].CGColor;
    } else {
        self.backgroundColor = [UIColor FORMFieldBackground];
        self.layer.borderColor = [UIColor FORMBlue].CGColor;
    }
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];

    if (enabled) {
        self.backgroundColor = [UIColor FORMFieldBackground];
        self.layer.borderColor = [UIColor FORMBlue].CGColor;
        self.textColor = [UIColor FORMDarkBlue];
    } else {
        self.backgroundColor = [UIColor FORMLightGray];
        self.layer.borderColor = [UIColor FORMFieldDisabledText].CGColor;
        self.textColor = [UIColor grayColor];
    }
}

- (void)setRawText:(NSString *)rawText
{
    BOOL shouldFormat = (self.formatter && (rawText.length >= _rawText.length ||
                                            ![rawText isEqualToString:_rawText]));

    if (shouldFormat) {
        self.text = [self.formatter formatString:rawText reverse:NO];
    } else {
        self.text = rawText;
    }

    _rawText = rawText;
}

- (void)setValid:(BOOL)valid
{
    _valid = valid;

    if (!self.isEnabled) return;

    if (valid) {
        self.backgroundColor = [UIColor FORMFieldBackground];
        self.layer.borderColor = [UIColor FORMBlue].CGColor;
    } else {
        self.backgroundColor = [UIColor FORMFieldBackgroundInvalid];
        self.layer.borderColor = [UIColor FORMRed].CGColor;
    }
}

- (void)setTypeString:(NSString *)typeString
{
    _typeString = typeString;

    FORMTextFieldType type;
    if ([typeString isEqualToString:@"name"]) {
        type = FORMTextFieldTypeName;
    } else if ([typeString isEqualToString:@"username"]) {
        type = FORMTextFieldTypeUsername;
    } else if ([typeString isEqualToString:@"phone"]) {
        type = FORMTextFieldTypePhoneNumber;
    } else if ([typeString isEqualToString:@"number"]) {
        type = FORMTextFieldTypeNumber;
    } else if ([typeString isEqualToString:@"float"]) {
        type = FORMTextFieldTypeFloat;
    } else if ([typeString isEqualToString:@"address"]) {
        type = FORMTextFieldTypeAddress;
    } else if ([typeString isEqualToString:@"email"]) {
        type = FORMTextFieldTypeEmail;
    } else if ([typeString isEqualToString:@"date"]) {
        type = FORMTextFieldTypeDate;
    } else if ([typeString isEqualToString:@"select"]) {
        type = FORMTextFieldTypeSelect;
    } else if ([typeString isEqualToString:@"text"]) {
        type = FORMTextFieldTypeDefault;
    } else if ([typeString isEqualToString:@"password"]) {
        type = FORMTextFieldTypePassword;
    } else if (!typeString.length) {
        type = FORMTextFieldTypeDefault;
    } else {
        type = FORMTextFieldTypeUnknown;
    }

    self.type = type;
}

- (void)setType:(FORMTextFieldType)type
{
    _type = type;

    FORMTextFieldTypeManager *typeManager = [[FORMTextFieldTypeManager alloc] init];
    [typeManager setUpType:type forTextField:self];
}

#pragma mark - Getters

- (NSString *)rawText
{
    if (self.formatter) {
        return [self.formatter formatString:_rawText reverse:YES];
    }

    return _rawText;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(FORMTextField *)textField
{
    BOOL selectable = (textField.type == FORMTextFieldTypeSelect ||
                       textField.type == FORMTextFieldTypeDate);

    if (selectable && [self.textFieldDelegate respondsToSelector:@selector(textFormFieldDidBeginEditing:)]) {
        [self.textFieldDelegate textFormFieldDidBeginEditing:self];
    }

    return !selectable;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.active = YES;
    self.modified = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.active = NO;
    if ([self.textFieldDelegate respondsToSelector:@selector(textFormFieldDidEndEditing:)]) {
        [self.textFieldDelegate textFormFieldDidEndEditing:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string || [string isEqualToString:@"\n"]) return YES;

    BOOL validator = (self.inputValidator && [self.inputValidator respondsToSelector:@selector(validateReplacementString:withText:withRange:)]);

    if (validator) return [self.inputValidator validateReplacementString:string withText:self.rawText withRange:range];

    return YES;
}

#pragma mark - UIResponder Overwritables

- (BOOL)becomeFirstResponder
{
    if ([self.textFieldDelegate respondsToSelector:@selector(textFormFieldDidBeginEditing:)]) {
        [self.textFieldDelegate textFormFieldDidBeginEditing:self];
    }

    return [super becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    BOOL isTextField = (self.type != FORMTextFieldTypeSelect &&
                        self.type != FORMTextFieldTypeDate);

    return (isTextField && self.enabled) ?: [super canBecomeFirstResponder];
}

#pragma mark - Notifications

- (void)textFieldDidUpdate:(UITextField *)textField
{
    if (!self.isValid) {
        self.valid = YES;
    }

    self.modified = YES;
    self.rawText = self.text;

    if ([self.textFieldDelegate respondsToSelector:@selector(textFormField:didUpdateWithText:)]) {
        [self.textFieldDelegate textFormField:self didUpdateWithText:self.rawText];
    }
}

- (void)textFieldDidReturn:(UITextField *)textField
{
    if ([self.textFieldDelegate respondsToSelector:@selector(textFormFieldDidReturn:)]) {
        [self.textFieldDelegate textFormFieldDidReturn:self];
    }
}

#pragma mark - Actions

- (void)clearButtonAction
{
    self.rawText = nil;

    if ([self.textFieldDelegate respondsToSelector:@selector(textFormField:didUpdateWithText:)]) {
        [self.textFieldDelegate textFormField:self didUpdateWithText:self.rawText];
    }
}


@end
