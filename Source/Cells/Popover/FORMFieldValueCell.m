#import "FORMFieldValueCell.h"

#import "FORMFieldValue.h"

#import "UIFont+FORMStyles.h"
#import "UIColor+FORMColors.h"

@implementation FORMFieldValueCell

#pragma mark - Initializers

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (!self) return nil;

    self.textLabel.font = [UIFont FORMMediumSize];
    self.textLabel.textColor = [UIColor FORMDarkBlue];
    self.textLabel.highlightedTextColor = [UIColor whiteColor];
    self.textLabel.textAlignment = NSTextAlignmentLeft;

    self.detailTextLabel.font = [UIFont FORMSmallSize];
    self.detailTextLabel.textColor = [UIColor FORMDarkBlue];
    self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
    self.detailTextLabel.textAlignment = NSTextAlignmentLeft;

    self.selectionStyle = UITableViewCellSelectionStyleGray;
    self.backgroundColor = [UIColor whiteColor];
    self.separatorInset = UIEdgeInsetsZero;

    UIView *selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = [UIColor FORMCallToActionPressed];
    self.selectedBackgroundView = selectedBackgroundView;
    self.separatorInset = UIEdgeInsetsZero;

    return self;
}

#pragma mark - Setters

- (void)setFieldValue:(FORMFieldValue *)fieldValue
{
    _fieldValue = fieldValue;

    self.textLabel.text = fieldValue.title;

    if (fieldValue.subtitle) {
        self.detailTextLabel.text = fieldValue.subtitle;
    }
}

#pragma mark - Overwritables

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

@end
