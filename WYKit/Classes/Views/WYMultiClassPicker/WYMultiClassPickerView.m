//
//  WYMultiClassPickerView.m
//  WYKit
//
//  Created by yingwang on 2016/11/28.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "UIColor+WYExtension.h"
#import "WYMultiClassPickerView.h"

@interface WYMultiClassPickerView () <UITableViewDelegate,
                                      UITableViewDataSource,
                                      UIScrollViewDelegate>
{
    NSInteger _currentIndex;
    NSInteger _maxSelectedIndex;
    NSMutableArray *_privateSelectedIndexPaths;
}

@property (nonatomic, strong) UIWindow *privateWindow;//私有window窗口
@property (nonatomic, strong) UIView *backgroundShadowView;//被禁遮罩层

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *headerBackgroundView;

@property (nonatomic, strong) UILabel *designatedTitleLabel;
@property (nonatomic, strong) UILabel *designatedContentLabel;
@property (nonatomic, strong) UIView *subheaderBackgoundView;
@property (nonatomic, strong) NSLayoutConstraint *subheaderHeightConstraint;

@property (nonatomic, strong) NSMutableArray *segmentors;
@property (nonatomic, strong) UIView *decoratorline;
@property (nonatomic, strong) UIScrollView *segmentScrollView;


@property (nonatomic, strong) NSMutableArray *pickTableViews;
@property (nonatomic, strong) UIScrollView *pickScrollView;

@end

static NSInteger TableViewIndicatorTag = 1001;

@implementation WYMultiClassPickerView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setDelegate:(id<WYMultiClassPickerViewDelegate>)delegate {
    _delegate = delegate;
    NSAssert(_delegate, @"WYMultiClassPickerView delegate cannot be nil!");
    NSAssert([_delegate conformsToProtocol:@protocol(WYMultiClassPickerViewDelegate)], @"WYMultiClassPickerView delegate should comform to WYMultiClassPickerViewDelegate protocol");
    NSAssert([_delegate respondsToSelector:@selector(maxNumberClassInPickerView:)], @"WYMultiClassPickerView delegate : method maxNumberClassInPickerView: are required");
    NSAssert([_delegate respondsToSelector:@selector(pickerItemHasSubClassAtIndexPath:)], @"WYMultiClassPickerView delegate : method pickerItemHasSubClassAtIndexPath: are required");
    NSAssert([_delegate respondsToSelector:@selector(pickerView:numberOfRowInClassIndex:)], @"WYMultiClassPickerView delegate : method pickerView:numberOfRowInClassIndex: are required");
    NSAssert([_delegate respondsToSelector:@selector(pickerView:textAtIndexPath:)], @"WYMultiClassPickerView delegate : method pickerView:textAtIndexPath: are required");
}

- (NSArray *)selectedIndexPaths {
    return _privateSelectedIndexPaths;
}

- (void)setHighlightedColor:(UIColor *)highlightedColor {
    _highlightedColor = highlightedColor;
    _decoratorline.backgroundColor = _highlightedColor;
    
    for (UIButton *segmentor in _segmentors) {
        [segmentor setTitleColor:_highlightedColor forState:UIControlStateSelected];
    }
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setDesignatedTitle:(NSString *)designatedTitle {
    _designatedTitle = designatedTitle;
    _designatedTitleLabel.text = designatedTitle;
}

- (void)setDesignatedText:(NSString *)designatedText {
    _designatedText = designatedText;
    _designatedContentLabel.text = designatedText;
}

//- (WYLoadResultView *)resultView {
//    if (!_resultView) {
//        _resultView = [[WYLoadResultView alloc] initWithFrame:[[_pickTableViews firstObject] bounds]
//                                                     message:nil
//                                                        type:WYLoadResultViewTypeFail];
//        
//        
//        _resultView.delegate = (UIViewController<WYLoadResultViewDelegate> *)self;
////        _resultView.hidden = YES;
//        self.resultView = _resultView;
//    }
//    
//    return _resultView;
//}

- (void)setShowSubtitleRow:(BOOL)showSubtitleRow {
    _showSubtitleRow = showSubtitleRow;
    
    _subheaderBackgoundView.hidden = !_showSubtitleRow;
    _subheaderHeightConstraint.constant = _showSubtitleRow ? 45 : 0.1;
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupSegmentors];
    [self setupPickViews];
    [self reloadData];
}

- (void)show {
    
    [self.privateWindow addSubview:self];
    [self.privateWindow setHidden:NO];
    [self.privateWindow makeKeyAndVisible];
    
    self.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.bounds));
    
    [self reloadData];
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:0
                     animations:^{
                         //调整背景遮罩的透明度
                         self.backgroundShadowView.alpha = 0.6;
                         self.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {}];
}

- (void)hide {
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:0
                     animations:^{
                         //恢复背景遮罩的透明度为0
                         self.backgroundShadowView.alpha = 0.0;
                         self.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.bounds));
                     } completion:^(BOOL finished) {
                         self.privateWindow.hidden = YES;
                         [[[[UIApplication sharedApplication] delegate] window] makeKeyAndVisible];
                         
                         if ([_delegate respondsToSelector:@selector(pickerViewWillDismiss:)]) {
                             [_delegate pickerViewWillDismiss:self];
                         }
                     }];
}

- (void)handleSegmentorButtonAction:(UIButton *)sender {
    [_pickScrollView setContentOffset:CGPointMake(CGRectGetWidth(_pickScrollView.bounds)*sender.tag, 0)
                             animated:YES];
}

- (void)segmentPickToIndex:(NSInteger)index {
    
    NSAssert(index >= 0 && index < _segmentors.count, @"index should belong to segmentors index");
    
    if (index == _currentIndex) return;
    
    UIButton *segmentor = _segmentors[index];
    UIButton *currentSegmentor = _currentIndex < _segmentors.count ? _segmentors[_currentIndex] : nil;
    
    currentSegmentor.selected = NO;
    segmentor.selected = YES;
    
    if (_segmentScrollView.contentOffset.x > index*CGRectGetWidth(segmentor.bounds)) {
        [_segmentScrollView setContentOffset:CGPointMake(index*CGRectGetWidth(segmentor.bounds), 0) animated:YES];
    }
    
    if (_segmentScrollView.contentOffset.x < (index+1)*CGRectGetWidth(segmentor.bounds)-CGRectGetWidth(_segmentScrollView.bounds)) {
        [_segmentScrollView setContentOffset:CGPointMake((index+1)*CGRectGetWidth(segmentor.bounds)-CGRectGetWidth(_segmentScrollView.bounds),
                                                         0)
                                    animated:YES];
    }
    
    _currentIndex = index;
}

- (void)reloadData {
    
    if (!_segmentors.count) return;
    
    [_privateSelectedIndexPaths removeAllObjects];
    
    [self segmentPickToIndex:0];
    [_pickScrollView setContentSize:CGSizeMake(CGRectGetWidth(_pickScrollView.bounds),
                                               CGRectGetHeight(_pickScrollView.bounds))];
    
    UIButton *segmentor = [_segmentors firstObject];
    [segmentor setTitle:@"请选择" forState:UIControlStateNormal];
    
    [_segmentors enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = idx;
        obj.selected = !idx;
        [obj setTitle:@"请选择" forState:UIControlStateNormal];
    }];
    
    UITableView *tableView = _pickTableViews[0];
    
    if (_asynchronous) {
        UIActivityIndicatorView *indicator = [tableView viewWithTag:TableViewIndicatorTag];
        [indicator startAnimating];
    }
    
    [tableView reloadData];
//    self.resultView.hidden = YES;
    
    if (_asynchronous) {
        NSAssert([_delegate respondsToSelector:@selector(pickerViewWillLoadInitialClass:)], @"WYMultiClassPickerView delegate : method pickerViewWillLoadInitialClass: are required when asynchronous.");
        [_delegate pickerViewWillLoadInitialClass:self];
    }
}

- (void)pickItemAtIndexPath:(NSIndexPath *)indexPath text:(NSString *)itemText {
    
    [_pickScrollView setContentSize:CGSizeMake(CGRectGetWidth(_pickScrollView.bounds)*(indexPath.section+2),
                                               CGRectGetHeight(_pickScrollView.bounds))];
    
    BOOL hasSubclass = [_delegate pickerItemHasSubClassAtIndexPath:indexPath];
    
    UITableView *tableView;
    UIButton *segmentor;
    
//    self.resultView.hidden = YES;
    segmentor = _segmentors[indexPath.section];
    [segmentor setTitle:itemText forState:UIControlStateNormal];
    
    for (NSInteger idx = indexPath.section+1; idx < _segmentors.count; ++idx) {
        segmentor = _segmentors[idx];
        segmentor.hidden = !((idx == indexPath.section+1) && hasSubclass);
        [segmentor setTitle:@"请选择" forState:UIControlStateNormal];
        
        tableView = _pickTableViews[idx];
        
        if (_asynchronous && idx == indexPath.section+1 && hasSubclass) {
            UIActivityIndicatorView *indicator = [tableView viewWithTag:TableViewIndicatorTag];
            [indicator startAnimating];
        }
        
        [tableView reloadData];
    }
    
    while (_privateSelectedIndexPaths.count > indexPath.section) {
        [_privateSelectedIndexPaths removeLastObject];
    }
    [_privateSelectedIndexPaths addObject:indexPath];
}

- (void)finishLoadDataAtClassIndex:(NSInteger)classIndex success:(BOOL)success error:(NSError *)error {
    
    if (!_asynchronous) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UITableView *tableView = _pickTableViews[classIndex];
        UIActivityIndicatorView *indicator = [tableView viewWithTag:TableViewIndicatorTag];
        [indicator stopAnimating];
        
        if (!success) {
            tableView.tableFooterView = [[UIView alloc] initWithFrame:tableView.bounds];
//            [tableView.tableFooterView addSubview:self.resultView];
//            self.resultView.textLabel.text = error.domain;
//            self.resultView.hidden = NO;
        } else {
            tableView.tableFooterView = [UIView new];
//            self.resultView.hidden = YES;
            [tableView reloadData];
        }
    });
}

#pragma mark - setup subviews
- (void)setupSubviews {
    [self initializeSubviews];
    [self setupConstraints];
}

- (void)initializeSubviews {
    
    CGRect screenbBounds = [UIScreen mainScreen].bounds;
    
    self.frame = CGRectMake(0, 0.4*CGRectGetHeight(screenbBounds), CGRectGetWidth(screenbBounds), 0.6*CGRectGetHeight(screenbBounds));
    self.backgroundColor = [UIColor colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1.0];
    
    _privateWindow  = [[UIWindow alloc] initWithFrame:screenbBounds];
    _privateWindow.windowLevel = UIWindowLevelStatusBar;
    _privateWindow.backgroundColor = [UIColor clearColor];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:_privateWindow.frame];
    backgroundView.backgroundColor = [UIColor darkGrayColor];
    backgroundView.alpha = 0.0;
    [_privateWindow addSubview:backgroundView];
    _backgroundShadowView = backgroundView;
    
    UITapGestureRecognizer *recognize = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(hide)];
    [_backgroundShadowView addGestureRecognizer:recognize];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:16.f];
    _titleLabel.textColor = [UIColor darkGrayColor];
    
    _headerBackgroundView = [[UIView alloc] init];
    _headerBackgroundView.backgroundColor = [UIColor whiteColor];
    [_headerBackgroundView addSubview:_titleLabel];
    [self addSubview:_headerBackgroundView];
    
    _designatedTitleLabel = [[UILabel alloc] init];
    _designatedTitleLabel.textColor = [UIColor grayColor];
    _designatedTitleLabel.font = [UIFont systemFontOfSize:13.f];
    
    _designatedContentLabel = [[UILabel alloc] init];
    _designatedContentLabel.textColor = [UIColor grayColor];
    _designatedContentLabel.font = [UIFont systemFontOfSize:13.f];
    
    _subheaderBackgoundView = [[UIView alloc] init];
    _subheaderBackgoundView.backgroundColor = [UIColor whiteColor];
    [_subheaderBackgoundView addSubview:_designatedTitleLabel];
    [_subheaderBackgoundView addSubview:_designatedContentLabel];
    [self addSubview:_subheaderBackgoundView];
    
    _segmentScrollView = [[UIScrollView alloc] init];
    _segmentScrollView.decelerationRate = 0.2;
    _segmentScrollView.backgroundColor = [UIColor whiteColor];
    _segmentScrollView.showsVerticalScrollIndicator = NO;
    _segmentScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_segmentScrollView];
    
    _pickScrollView = [[UIScrollView alloc] init];
    _pickScrollView.backgroundColor = [UIColor whiteColor];
    _pickScrollView.pagingEnabled = YES;
    _pickScrollView.delegate = self;
    _pickScrollView.showsVerticalScrollIndicator = NO;
    _pickScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_pickScrollView];
}

#pragma mark - layout subviews
- (void)setupConstraints {
    
    CGFloat width;
    CGFloat height;
    CGFloat multiper;
    CGFloat constant;
    
    NSLayoutConstraint *constraintTop;
    NSLayoutConstraint *constraintLeft;
    NSLayoutConstraint *constraintBottom;
    NSLayoutConstraint *constraintRight;
    NSLayoutConstraint *constraintWidth;
    NSLayoutConstraint *constraintHeight;
    NSLayoutConstraint *constraintCenterX;
    NSLayoutConstraint *constraintCenterY;
    
    UIEdgeInsets padding;
    
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _headerBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    
    padding = UIEdgeInsetsMake(0, 0, 0, 0);
    multiper = 108.0/750;
    constraintTop = [NSLayoutConstraint constraintWithItem:_headerBackgroundView
                                                 attribute:NSLayoutAttributeTop
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:self
                                                 attribute:NSLayoutAttributeTop
                                                multiplier:1.0 constant:padding.top];
    constraintLeft = [NSLayoutConstraint constraintWithItem:_headerBackgroundView
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0 constant:padding.left];
    constraintRight = [NSLayoutConstraint constraintWithItem:_headerBackgroundView
                                                   attribute:NSLayoutAttributeRight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeRight
                                                  multiplier:1.0 constant:padding.right];
    constraintHeight = [NSLayoutConstraint constraintWithItem:_headerBackgroundView
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self
                                                    attribute:NSLayoutAttributeWidth
                                                   multiplier:multiper constant:0];
    [self addConstraints:@[constraintTop, constraintLeft, constraintRight, constraintHeight]];
    
    constraintCenterX = [NSLayoutConstraint constraintWithItem:_titleLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_headerBackgroundView
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0 constant:0];
    constraintCenterY = [NSLayoutConstraint constraintWithItem:_titleLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_headerBackgroundView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0 constant:0];
    [_headerBackgroundView addConstraints:@[constraintCenterX,constraintCenterY]];
    
    _subheaderBackgoundView.translatesAutoresizingMaskIntoConstraints = NO;
    _designatedTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _designatedContentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    padding = UIEdgeInsetsMake(1, 0, 0, 0);
    constant = _showSubtitleRow ? 45 : 0.1;
    _subheaderBackgoundView.hidden = !_showSubtitleRow;
    constraintTop = [NSLayoutConstraint constraintWithItem:_subheaderBackgoundView
                                                 attribute:NSLayoutAttributeTop
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:_headerBackgroundView
                                                 attribute:NSLayoutAttributeBottom
                                                multiplier:1.0 constant:padding.top];
    constraintLeft = [NSLayoutConstraint constraintWithItem:_subheaderBackgoundView
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0 constant:padding.left];
    constraintRight = [NSLayoutConstraint constraintWithItem:_subheaderBackgoundView
                                                   attribute:NSLayoutAttributeRight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeRight
                                                  multiplier:1.0 constant:padding.right];
    constraintHeight = [NSLayoutConstraint constraintWithItem:_subheaderBackgoundView
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:nil
                                                    attribute:NSLayoutAttributeWidth
                                                   multiplier:1.0 constant:constant];
    
    [self addConstraints:@[constraintTop, constraintLeft, constraintRight, constraintHeight]];
    
    
    padding = UIEdgeInsetsMake(0, 15, 0, 0);
    constraintLeft = [NSLayoutConstraint constraintWithItem:_designatedTitleLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_subheaderBackgoundView
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0
                                                      constant:padding.left];
    constraintCenterY = [NSLayoutConstraint constraintWithItem:_designatedTitleLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_subheaderBackgoundView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0];
    
    [_subheaderBackgoundView addConstraints:@[constraintLeft, constraintCenterY]];
    
    padding = UIEdgeInsetsMake(0, 0, 0, 0);
    constraintLeft = [NSLayoutConstraint constraintWithItem:_designatedContentLabel
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:_designatedTitleLabel
                                                  attribute:NSLayoutAttributeRight
                                                 multiplier:1.0
                                                   constant:padding.left];
    constraintCenterY = [NSLayoutConstraint constraintWithItem:_designatedContentLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_subheaderBackgoundView
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0];
    [_subheaderBackgoundView addConstraints:@[constraintLeft, constraintCenterY]];
    
    padding = UIEdgeInsetsMake(1, 0, 0, 0);
    multiper = 104.0/750;
    constraintTop = [NSLayoutConstraint constraintWithItem:_segmentScrollView
                                                 attribute:NSLayoutAttributeTop
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:_subheaderBackgoundView
                                                 attribute:NSLayoutAttributeBottom
                                                multiplier:1.0 constant:padding.top];
    constraintLeft = [NSLayoutConstraint constraintWithItem:_segmentScrollView
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0 constant:padding.left];
    constraintRight = [NSLayoutConstraint constraintWithItem:_segmentScrollView
                                                   attribute:NSLayoutAttributeRight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeRight
                                                  multiplier:1.0 constant:padding.right];
    constraintHeight = [NSLayoutConstraint constraintWithItem:_segmentScrollView
                                                    attribute:NSLayoutAttributeHeight
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self
                                                    attribute:NSLayoutAttributeWidth
                                                   multiplier:multiper constant:0];
    
    _segmentScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:@[constraintTop, constraintLeft, constraintRight, constraintHeight]];
    
    padding = UIEdgeInsetsMake(0, 0, 0, 0);
    constraintTop = [NSLayoutConstraint constraintWithItem:_pickScrollView
                                                 attribute:NSLayoutAttributeTop
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:_segmentScrollView
                                                 attribute:NSLayoutAttributeBottom
                                                multiplier:1.0 constant:padding.top];
    constraintLeft = [NSLayoutConstraint constraintWithItem:_pickScrollView
                                                  attribute:NSLayoutAttributeLeft
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:self
                                                  attribute:NSLayoutAttributeLeft
                                                 multiplier:1.0 constant:padding.left];
    constraintRight = [NSLayoutConstraint constraintWithItem:_pickScrollView
                                                   attribute:NSLayoutAttributeRight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeRight
                                                  multiplier:1.0 constant:-padding.right];
    constraintBottom = [NSLayoutConstraint constraintWithItem:_pickScrollView
                                                    attribute:NSLayoutAttributeBottom
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self
                                                    attribute:NSLayoutAttributeBottom
                                                   multiplier:1.0 constant:-padding.bottom];
    
    _pickScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:@[constraintTop, constraintLeft, constraintRight, constraintBottom]];
}

- (void)setupSegmentors {
    
    if (_segmentors) return;
    
    _segmentors = [NSMutableArray array];
    
    CGFloat itemWidth = 140.f;
    CGFloat itemHeight = CGRectGetHeight(_segmentScrollView.bounds);
    NSInteger numberOfClass = [_delegate maxNumberClassInPickerView:self];
    
    _segmentScrollView.contentSize = CGSizeMake(numberOfClass*itemWidth, itemHeight);
    
    for (NSInteger idx = 0; idx < numberOfClass; ++ idx) {
        
        UIButton *segmentor = [[UIButton alloc] initWithFrame:CGRectMake(idx*itemWidth, 0, itemWidth, itemHeight)];
        segmentor.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        NSString *title = @"请选择";
        segmentor.titleLabel.textAlignment = NSTextAlignmentCenter;
        segmentor.titleLabel.font = [UIFont systemFontOfSize:13.f];
        [segmentor setTitle:title forState:UIControlStateNormal];
        [segmentor setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [segmentor setTitleColor:_highlightedColor ?: [UIColor wy_colorWithRed:0 green:153 blue:0]
                        forState:UIControlStateSelected];
        [segmentor addTarget:self action:@selector(handleSegmentorButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
        segmentor.tag = idx;
        segmentor.hidden = idx;
        
        [_segmentScrollView addSubview:segmentor];
        [_segmentors addObject:segmentor];
    }
    
    _decoratorline = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_segmentScrollView.bounds)-2, itemWidth, 2)];
    _decoratorline.backgroundColor = _highlightedColor ?: [UIColor colorWithRed:0 green:153.0/255 blue:0 alpha:1.f];
    [_segmentScrollView addSubview:_decoratorline];
    
    _currentIndex = 1;
    _maxSelectedIndex = 0;
    [self segmentPickToIndex:0];
}

- (void)setupPickViews {
    
    if (_pickTableViews) return;
    
    _pickTableViews = [NSMutableArray array];
    _privateSelectedIndexPaths = [NSMutableArray array];
    
    CGFloat itemWidth = CGRectGetWidth(_pickScrollView.bounds);
    CGFloat itemHeight = CGRectGetHeight(_pickScrollView.bounds);
    
    _pickScrollView.contentSize = CGSizeMake(itemWidth, itemHeight);
    
    NSInteger numberOfClass = [_delegate maxNumberClassInPickerView:self];
    
    for (NSInteger idx = 0; idx < numberOfClass; ++ idx) {
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(idx*itemWidth, 0, itemWidth, itemHeight)];
        tableView.tag = idx;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[UITableViewCell class]
          forCellReuseIdentifier:@"cell"];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.tag = TableViewIndicatorTag;
        [tableView addSubview:indicator];
        
        indicator.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *constraintCenterY = [NSLayoutConstraint constraintWithItem:indicator
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:tableView
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0];
        NSLayoutConstraint *constraintCenterX = [NSLayoutConstraint constraintWithItem:indicator
                                                                             attribute:NSLayoutAttributeCenterX
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:tableView
                                                                             attribute:NSLayoutAttributeCenterX
                                                                            multiplier:1.0
                                                                              constant:0];
        [tableView addConstraints:@[constraintCenterX, constraintCenterY]];
        
        [_pickScrollView addSubview:tableView];
        [_pickTableViews addObject:tableView];
    }
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < 0) [scrollView setContentOffset:CGPointMake(0, 0)];
    if (scrollView.contentOffset.x > scrollView.contentSize.width-CGRectGetWidth(scrollView.bounds))
        [scrollView setContentOffset:CGPointMake(scrollView.contentSize.width-CGRectGetWidth(scrollView.bounds), 0)];
    
    if (scrollView == _pickScrollView) {
        NSInteger index = roundf(scrollView.contentOffset.x/CGRectGetWidth(_pickScrollView.bounds));
        [self segmentPickToIndex:index];
        
        CGFloat coe = CGRectGetWidth(_decoratorline.bounds)/CGRectGetWidth(_pickScrollView.bounds);
        CGFloat centerX = CGRectGetWidth(_decoratorline.bounds)/2+scrollView.contentOffset.x*coe;
        _decoratorline.center = CGPointMake(centerX, _decoratorline.center.y);
    }
}

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger maxClassIndex = round(_pickScrollView.contentSize.width/CGRectGetWidth(_pickScrollView.bounds))-1;
    UIActivityIndicatorView *indicator = [tableView viewWithTag:TableViewIndicatorTag];
    // 如果为异步 且 为未加载tableView(标识是indicator正在转动)
    return (_asynchronous && tableView.tag >= maxClassIndex && [indicator isAnimating]) ?
                0
            : [_delegate pickerView:self numberOfRowInClassIndex:tableView.tag];
}

#pragma mark - UITableView datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    cell.textLabel.text = [_delegate pickerView:self
                                textAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:tableView.tag]];
    cell.textLabel.font = [UIFont systemFontOfSize:13.f];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = _highlightedColor;
    
    [self pickItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:tableView.tag] text:cell.textLabel.text];
    
    NSInteger numberOfClass = [_delegate maxNumberClassInPickerView:self];
    BOOL hasSubclass = [_delegate pickerItemHasSubClassAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:tableView.tag]];
    
    if (hasSubclass) {
        [_pickScrollView setContentOffset:CGPointMake(CGRectGetWidth(_pickScrollView.bounds)*(_currentIndex+1), 0) animated:YES];
    }
    
    if ([_delegate respondsToSelector:@selector(pickerView:didSelectedItemAtIndexPath:)]) {
        [_delegate pickerView:self didSelectedItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                                 inSection:tableView.tag]];
    }
    
    if (_asynchronous && tableView.tag != numberOfClass-1 && hasSubclass) {
        NSAssert([_delegate respondsToSelector:@selector(pickerView:willLoadSubClassFromIndexPath:)], @"WYMultiClassPickerView delegate : method pickerView:willLoadSubClassFromIndexPath: are required when asynchronous.");
        [_delegate pickerView:self willLoadSubClassFromIndexPath:[NSIndexPath indexPathForRow:indexPath.row
                                                                                    inSection:tableView.tag]];
    }
    
    if (_dismiassWhenSelectLastClass && (tableView.tag == numberOfClass-1 || !hasSubclass)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hide];
        });
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor lightGrayColor];
}

@end
