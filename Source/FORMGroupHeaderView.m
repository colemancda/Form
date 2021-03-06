#import "FORMGroupHeaderView.h"

#import "UIColor+Hex.h"
#import "UIScreen+HYPLiveBounds.h"
#import "UIColor+FORMColors.h"
#import "UIFont+FORMStyles.h"

@interface FORMGroupHeaderView ()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation FORMGroupHeaderView

#pragma mark - Initializers

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    self.backgroundColor = [UIColor whiteColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [self addSubview:self.headerLabel];

    self.layer.masksToBounds = NO;
    self.layer.cornerRadius = 5;
    self.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.layer.shadowRadius = 1;
    self.layer.shadowOpacity = 0.2;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(headerTappedAction)];
    [self addGestureRecognizer:tapGestureRecognizer];

    return self;
}

#pragma mark - Getters

- (UILabel *)headerLabel
{
    if (_headerLabel) return _headerLabel;

    CGRect bounds = [[UIScreen mainScreen] bounds];
    CGFloat width = CGRectGetWidth(bounds) - (FORMTitleMargin * 2);

    _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(FORMTitleMargin, 0.0f, width, FORMHeaderHeight)];
    _headerLabel.backgroundColor = [UIColor clearColor];
    _headerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _headerLabel.font = [UIFont FORMMediumSize];
    _headerLabel.textColor = [UIColor FORMDarkBlue];

    return _headerLabel;
}

#pragma mark - Actions

- (void)headerTappedAction
{
    if ([self.delegate respondsToSelector:@selector(formHeaderViewWasPressed:)]) {
        [self.delegate formHeaderViewWasPressed:self];
    }
}

@end
