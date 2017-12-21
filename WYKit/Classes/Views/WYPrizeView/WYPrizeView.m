//
//  IPPrizeView.m
//  Pods
//
//  Created by yingwang on 2017/11/3.
//

#import "WYPrizeView.h"
#import "WYTimerDelegate.h"

#define UNIFORM_SPEED_INTERVAL 0.10
#define DECELERATION_SPEED_MAX_INTERVAL 0.6
#define CLOCKWISE_ROLLING_MIN_TIMES 3

@interface WYPrizeStrategy()
{
    bool **visitFlag; // 矩阵遍历标识
    NSUInteger currentRank; // 矩阵遍历的第几圈
}

@property (nonatomic, strong) NSIndexPath *currentIndexPath;

@property (nonatomic) BOOL isRolling;

@property (nonatomic) NSUInteger numberOfRows;
@property (nonatomic) NSUInteger numberOfColumns;

@property (nonatomic) NSUInteger currentTimes;
@property (nonatomic) NSUInteger desinationTimes;

- (NSIndexPath *)nextIndexPath;

@end

@implementation WYPrizeStrategy

- (void)updateIndexRecord {
    // 1. free memory firstly
    if (visitFlag != NULL) {
        int len = sizeof(visitFlag) / sizeof(visitFlag[0]);
        for (NSUInteger i = 0; i < len; ++i) {
            free(visitFlag[i]);
        }
        free(visitFlag);
    }
    
    // 2. alloc new memory secondly
    visitFlag = (bool **)malloc(sizeof(bool *)*self.numberOfRows);
    for (NSUInteger i = 0; i < self.numberOfRows; ++i) {
        visitFlag[i] = (bool *)malloc(sizeof(bool)*self.numberOfColumns);
        memset(visitFlag[i], false, sizeof(bool)*self.numberOfColumns);
    }
    
    // 3. update rank
    currentRank = 0;
    
    // 4. update current index
    self.currentIndexPath =  [NSIndexPath indexPathForRow:0 inSection:0];
}

- (void)updateTimesRecord {
    
    // update times
    self.currentTimes = 1;
    
    switch (self.rollingModel) {
        case kWYPrizeRollingClockwise:
        {
            self.desinationTimes = CLOCKWISE_ROLLING_MIN_TIMES*(self.numberOfRows*self.numberOfColumns-1)+1;
            self.currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            while (self.currentIndexPath.row != self.targetItemIndexPath.row
                   || self.currentIndexPath.section != self.targetItemIndexPath.section) {
                self.currentIndexPath = [self nextIndexPathForClockwiseFromCurrentIndexPath:self.currentIndexPath
                                                              currentRank:currentRank visitFlags:visitFlag];
                if (self.currentIndexPath.row != self.numberOfRows/2
                    || self.currentIndexPath.section != self.numberOfColumns/2) {
                    ++self.desinationTimes;
                }
            }
            
            [self updateIndexRecord];
        }
            break;
        case kWYPrizeRollingRandom:
            self.desinationTimes = 2*(self.numberOfRows*self.numberOfColumns-1);
            break;
        case kWYPrizeRollingAntiClockwise:
            self.desinationTimes = 0;
            break;
        default:
            break;
    }
}

- (void)setCurrentIndexPath:(NSIndexPath *)currentIndexPath {
    if (!NSLocationInRange(currentIndexPath.row, NSMakeRange(0, self.numberOfRows))
        || !NSLocationInRange(currentIndexPath.section, NSMakeRange(0, self.numberOfColumns))) {
        return;
    }
    
    _currentIndexPath = currentIndexPath;
    
    if (_currentIndexPath.row == 0 && currentIndexPath.section == 0) {
        for (NSUInteger i = 0; i < self.numberOfRows; ++i) {
            visitFlag[i] = (bool *)malloc(sizeof(bool)*self.numberOfColumns);
            memset(visitFlag[i], false, sizeof(bool)*self.numberOfColumns);
        }
    }
    
    if (_currentIndexPath.row == _currentIndexPath.section && _currentIndexPath.row < self.numberOfRows/2) {
        currentRank = _currentIndexPath.row;
    }
    
    visitFlag[_currentIndexPath.row][_currentIndexPath.section] = true;
}

- (NSIndexPath *)nextIndexPath {
    NSIndexPath *nextIndexPath = self.currentIndexPath;
    switch (self.rollingModel) {
        case kWYPrizeRollingClockwise:
        {
            nextIndexPath = [self nextIndexPathForClockwiseFromCurrentIndexPath:self.currentIndexPath
                                                                    currentRank:currentRank
                                                                     visitFlags:visitFlag];
        }
            break;
        case kWYPrizeRollingRandom:
            break;
        case kWYPrizeRollingAntiClockwise:
            break;
        default:
            break;
    }
    return nextIndexPath;
}

- (NSIndexPath *)nextIndexPathForClockwiseFromCurrentIndexPath:(NSIndexPath *)currentIndexPath
                                                   currentRank:(NSUInteger)currentRank
                                                    visitFlags:(bool **)visitFlags {
    // tips: section equal to column !
    NSIndexPath *targetIndexPath;
    NSIndexPath *cIdxp = currentIndexPath;
    if (cIdxp.row == currentRank) {
        // top edge, not reach right edge
        if ( (cIdxp.section+1 < self.numberOfColumns) && !visitFlags[cIdxp.row][cIdxp.section+1]) {
            // turn right
            targetIndexPath = [NSIndexPath indexPathForRow:cIdxp.row inSection:cIdxp.section+1];
        } else {
            // top edge, reach right edge
            // turn dowm
            if (cIdxp.row != self.numberOfRows-currentRank) {
                targetIndexPath = [NSIndexPath indexPathForRow:cIdxp.row+1 inSection:cIdxp.section];
            }
        }
        
    } else if (cIdxp.row == self.numberOfRows-currentRank-1) {
        // bottom edge, not reach left edge
        if ( (cIdxp.section-1 >= 0) && !visitFlags[cIdxp.row][cIdxp.section-1]) {
            // turn left
            targetIndexPath = [NSIndexPath indexPathForRow:cIdxp.row inSection:cIdxp.section-1];
        } else {
            // top edge, reach right edge
            // turn up
            if (cIdxp.row != currentRank+1) {
                targetIndexPath = [NSIndexPath indexPathForRow:cIdxp.row-1 inSection:cIdxp.section];
            }
        }
        
    } else if (cIdxp.section == self.numberOfColumns-currentRank-1) {
        
        // right edge, not reach bottom edge
        if ( (cIdxp.row+1 < self.numberOfRows) && !visitFlags[cIdxp.row+1][cIdxp.section]) {
            // turn down
            targetIndexPath = [NSIndexPath indexPathForRow:cIdxp.row+1 inSection:cIdxp.section];
        } else {
            // right edge, reach bottom edge
            // turn left
            if (cIdxp.section != currentRank) {
                targetIndexPath = [NSIndexPath indexPathForRow:cIdxp.row+1 inSection:cIdxp.section];
            }
        }
        
    } else {
        // left edge, not reach top edge
        if ( (cIdxp.row-1 >=0) && !visitFlags[cIdxp.row-1][cIdxp.section]) {
            // turn up
            targetIndexPath = [NSIndexPath indexPathForRow:cIdxp.row-1 inSection:cIdxp.section];
        } else {
            // left edge, reach top edge
            // turn right, start a new rank !
            if (!visitFlags[cIdxp.row][cIdxp.section+1]) {
                targetIndexPath = [NSIndexPath indexPathForRow:cIdxp.row inSection:cIdxp.section+1];
            }
        }
    }
    
    if (!targetIndexPath) {
        targetIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    return targetIndexPath;
}

- (void)dealloc {
    // free memory
    if (visitFlag != NULL) {
        int len = sizeof(visitFlag) / sizeof(visitFlag[0]);
        for (NSUInteger i = 0; i < len; ++i) {
            free(visitFlag[i]);
        }
        free(visitFlag);
    }
}

@end

@interface WYPrizeViewItemCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation WYPrizeViewItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _indicator.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _titleLabel.font = [UIFont systemFontOfSize:13*CGRectGetHeight(_titleLabel.bounds)/25.0];
}

- (void)setupSubviews {
    
    self.backgroundColor = [UIColor whiteColor];
    
    _backgroundImageView = [[UIImageView alloc] init];
    _backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    
    _icon = [[UIImageView alloc] init];
    _icon.contentMode = UIViewContentModeScaleAspectFit;
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [UIColor grayColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:13];
    _titleLabel.numberOfLines = 2;
    _titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    _centerLabel = [[UILabel alloc] init];
    _centerLabel.textColor = [UIColor whiteColor];
    _centerLabel.textAlignment = NSTextAlignmentCenter;
    _centerLabel.font = [UIFont systemFontOfSize:15];
    _centerLabel.numberOfLines = 2;
    _centerLabel.lineBreakMode = NSLineBreakByCharWrapping;
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _indicator.hidesWhenStopped = YES;
    
    [self addSubview:_backgroundImageView];
    [self addSubview:_icon];
    [self addSubview:_titleLabel];
    [self addSubview:_centerLabel];
    [self addSubview:_indicator];
    
    _backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _icon.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _centerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *metrics = @{ @"top":@5,
                               @"left":@0,
                               @"bottom":@0,
                               @"right":@0 };
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_icon, _titleLabel, _backgroundImageView, _centerLabel);
    
    NSLayoutFormatOptions opt = 0;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_titleLabel
                                                      attribute:NSLayoutAttributeHeight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self
                                                       attribute:NSLayoutAttributeHeight
                                                      multiplier:25.0/80.0
                                                        constant:0]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[_icon]-bottom-[_titleLabel]-bottom-|"
                                                                 options:opt
                                                                 metrics:metrics
                                                                   views:views]];
    opt = NSLayoutFormatAlignAllLeft|NSLayoutFormatAlignAllRight;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[_icon]-right-|"
                                                                 options:opt
                                                                 metrics:metrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[_titleLabel]-right-|"
                                                                 options:opt
                                                                 metrics:metrics
                                                                   views:views]];
    
    metrics = @{ @"top":@0,
                 @"left":@0,
                 @"bottom":@0,
                 @"right":@0 };
    
    opt = NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[_backgroundImageView]-bottom-|"
                                                                 options:opt
                                                                 metrics:metrics
                                                                   views:views]];
    opt = NSLayoutFormatAlignAllLeft|NSLayoutFormatAlignAllRight;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[_backgroundImageView]-right-|"
                                                                 options:opt
                                                                 metrics:metrics
                                                                   views:views]];
    
    opt = NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[_centerLabel]-bottom-|"
                                                                 options:opt
                                                                 metrics:metrics
                                                                   views:views]];
    opt = NSLayoutFormatAlignAllLeft|NSLayoutFormatAlignAllRight;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[_centerLabel]-right-|"
                                                                 options:opt
                                                                 metrics:metrics
                                                                   views:views]];
}

@end

@interface WYPrizeView() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, readonly) NSUInteger numberOfRows;
@property (nonatomic, readonly) NSUInteger numberOfColumns;

@property (nonatomic, strong) WYTimerDelegate *timerDelegate;

@property (nonatomic, weak) WYPrizeViewItemCell *centerCell;

@end

@implementation WYPrizeView
@synthesize strategy = _strategy;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupSubviews];
}

- (void)setupSubviews {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 1;
    layout.minimumInteritemSpacing = 1;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    
    [collectionView registerClass:[WYPrizeViewItemCell class]
       forCellWithReuseIdentifier:@"Cell"];
    
    self.collectionView = collectionView;
    [self addSubview:collectionView];
    
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *metrics = @{ @"top":@0,
                               @"left":@0,
                               @"bottom":@0,
                               @"right":@0 };
    
    NSDictionary *views = NSDictionaryOfVariableBindings(collectionView);
    
    NSLayoutFormatOptions opt = NSLayoutFormatAlignAllTop|NSLayoutFormatAlignAllBottom;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[collectionView]-bottom-|"
                                                                 options:opt
                                                                 metrics:metrics
                                                                   views:views]];
    opt = NSLayoutFormatAlignAllLeft|NSLayoutFormatAlignAllRight;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-left-[collectionView]-right-|"
                                                                 options:opt
                                                                 metrics:metrics
                                                                   views:views]];
}

- (void)reloadData {
    
    self.strategy.numberOfRows = self.numberOfRows;
    self.strategy.numberOfColumns = self.numberOfColumns;
    
    [self.strategy updateIndexRecord];
    [self.collectionView reloadData];
}

- (BOOL)isRolling {
    return self.strategy.isRolling;
}

#pragma mark - Rolling Logic
- (void)handleRollingAction {
    
    if (!self.async) {
        [self startRolling];
    } else {
        self.centerCell.userInteractionEnabled = NO;
        self.centerCell.centerLabel.hidden = YES;
        [self.centerCell.indicator startAnimating];
    }
    
    if ([self.delegate respondsToSelector:@selector(prizeViewDidStartedRolling:)]) {
        [self.delegate prizeViewDidStartedRolling:self];
    }
}

- (void)startRolling {
    if (self.strategy.isRolling) return;
    
    if (self.strategy.targetItemIndexPath.row == self.strategy.numberOfRows/2
        && self.strategy.targetItemIndexPath.section == self.strategy.numberOfColumns/2) {
        return;
    }
    
    if (self.centerCell.indicator.isAnimating) {
        self.centerCell.centerLabel.hidden = NO;
        [self.centerCell.indicator stopAnimating];
    }
    
    self.centerCell.userInteractionEnabled = NO;
    self.strategy.isRolling = YES;
    [self checkoutTargetItemIndexPath];
    [self.strategy updateIndexRecord];
    [self.strategy updateTimesRecord];
    [self rollingStepWithMode:self.strategy.rollingModel rollingSpeed:self.strategy.rollSpeedStyle];
}

- (void)cancelRolling {
    if (self.strategy.isRolling) return;
    
    if (self.centerCell.indicator.isAnimating) {
        self.centerCell.userInteractionEnabled = YES;
        self.centerCell.centerLabel.hidden = NO;
        [self.centerCell.indicator stopAnimating];
    }
}

- (void)rollingStepWithMode:(WYPrizeRollingMode)rollingMode rollingSpeed:(WYPrizeRollingSpeedStyle)speedStyle {
    [self updateCellAppearence];
    
    NSTimeInterval interval = 0;
    
    switch (self.strategy.rollSpeedStyle) {
        case kWYPrizeRollingDeceleration:
            interval = (DECELERATION_SPEED_MAX_INTERVAL/powf(self.strategy.desinationTimes, 2)) * powf(self.strategy.currentTimes, 2);
            break;
        case kWYPrizeRollingUniformSpeed:
            interval = UNIFORM_SPEED_INTERVAL;
            break;
        default:
            break;
    }
    
    __weak WYPrizeView *weakSelf = self;
    [self.timerDelegate startTimerWithTimeInterval:interval
                                             block:^(NSTimer *timer) {
                                                 
                                                 weakSelf.strategy.currentIndexPath = [weakSelf.strategy nextIndexPath];
                                                 if ((weakSelf.strategy.currentIndexPath.row == weakSelf.strategy.numberOfRows/2)
                                                     && (weakSelf.strategy.currentIndexPath.section == weakSelf.strategy.numberOfColumns/2) ) {
                                                     weakSelf.strategy.currentIndexPath = [weakSelf.strategy nextIndexPath];
                                                 }
                                                 
                                                 ++weakSelf.strategy.currentTimes;
                                                 //                                                 NSLog(@"%@", [weakSelf.strategy.currentIndexPath description]);
                                                 
                                                 if (weakSelf.strategy.desinationTimes == weakSelf.strategy.currentTimes) {
                                                     
                                                     [weakSelf updateCellAppearence];
                                                     weakSelf.strategy.isRolling = NO;
                                                     weakSelf.centerCell.userInteractionEnabled = YES;
                                                     if ([weakSelf.delegate respondsToSelector:@selector(prizeViewDidEndedRolling:)]) {
                                                         [weakSelf.delegate prizeViewDidEndedRolling:weakSelf];
                                                     }
                                                     
                                                 } else {
                                                     [weakSelf rollingStepWithMode:rollingMode
                                                                      rollingSpeed:speedStyle];
                                                 }
                                                 
                                             } userInfo:nil repeats:NO];
}

- (void)updateCellAppearence {
    NSUInteger numberOfRows = [self.delegate numberOfRowInPrizeView:self];
    NSUInteger numberOfColumns = [self.delegate numberOfColumnInPrizeView:self];
    
    WYPrizeViewItemCell *cell;
    for (NSUInteger i = 0; i < numberOfRows; ++i) {
        for (NSUInteger j = 0; j < numberOfColumns; ++j) {
            if ((i == numberOfRows/2) && (j == numberOfColumns/2)) {
                continue;
            }
            
            cell = (WYPrizeViewItemCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i*numberOfColumns+j
                                                                                                          inSection:0]];
            if (i == self.strategy.currentIndexPath.row
                && j == self.strategy.currentIndexPath.section) {
                cell.backgroundImageView.image = self.highlightedBackgroundImageForItems;
            } else {
                cell.backgroundImageView.image = self.normalBackgroundImageForItems;
            }
        }
    }
}

- (void)checkoutTargetItemIndexPath {
    if (!self.strategy.targetItemIndexPath
        || (self.strategy.targetItemIndexPath.row == self.numberOfRows/2 && self.strategy.targetItemIndexPath.section == self.numberOfColumns/2) ) {
        NSLog(@"IPPrizeView: Target item indexPath should not be nil or equal to start button indexPath, it would be auto set to (0, 0)");
        self.strategy.targetItemIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
}

#pragma mark - Setter
- (void)setImageForStartButton:(UIImage *)imageForStartButton {
    _imageForStartButton = imageForStartButton;
    self.centerCell.backgroundImageView.image = self.imageForStartButton;
}

- (void)setTitleForStartButton:(NSString *)titleForStartButton {
    _titleForStartButton = titleForStartButton;
    self.centerCell.centerLabel.text = _titleForStartButton;
}

#pragma mark - Getter
- (WYPrizeStrategy *)strategy {
    if (!_strategy) {
        _strategy = [[WYPrizeStrategy alloc] init];
    }
    return _strategy;
}

- (WYTimerDelegate *)timerDelegate {
    if (!_timerDelegate) {
        _timerDelegate = [[WYTimerDelegate alloc] init];
    }
    return _timerDelegate;
}

- (NSUInteger)numberOfRows {
    NSAssert(self.delegate && [self.delegate respondsToSelector:@selector(numberOfRowInPrizeView:)], @"IPPrizeView: Delegate must realize numberOfRowInPrizeView: method!");
    NSUInteger numberOfRows = [self.delegate numberOfRowInPrizeView:self];
//    NSAssert(numberOfRows >= 3 && numberOfRows&1, @"IPPrizeView: Number of Rows must be odd and greater than 3.");
    return numberOfRows;
}

- (NSUInteger)numberOfColumns {
    NSAssert(self.delegate && [self.delegate respondsToSelector:@selector(numberOfColumnInPrizeView:)], @"IPPrizeView: Delegate must realize numberOfColumnInPrizeView: method!");
    NSUInteger numberOfColumns = [self.delegate numberOfColumnInPrizeView:self];
//    NSAssert(numberOfColumns >= 3 && numberOfColumns&1, @"IPPrizeView: Number of Columns must be odd and greater than 3.");
    return numberOfColumns;
}

#pragma mark - UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger numberOfItems = self.numberOfRows*self.numberOfColumns;
    return numberOfItems;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ( (indexPath.item/self.numberOfRows == self.numberOfRows/2) && (indexPath.item%self.numberOfRows == self.numberOfColumns/2) ) {
        [self handleRollingAction];
    }
}

#pragma mark - UICollectionView DelegateLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize size;
    CGFloat boundsWidth = CGRectGetWidth(self.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.bounds);
    
    size = CGSizeMake((boundsWidth - self.itemSpacing*(self.numberOfColumns-1))/self.numberOfColumns,
                      (boundsHeight - self.lineSpacing*(self.numberOfRows-1))/self.numberOfRows);
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - UICollectionView DataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WYPrizeViewItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    if ( (indexPath.item/self.numberOfRows == self.numberOfRows/2)
        && (indexPath.item%self.numberOfRows == self.numberOfColumns/2) ) {
        
        self.centerCell = cell;
        cell.icon.image = nil;
        cell.titleLabel.text = nil;
        cell.backgroundImageView.image = self.imageForStartButton;
        
        if (self.attributeTitleForStartButton) {
            cell.centerLabel.attributedText = self.attributeTitleForStartButton;
        } else {
            cell.centerLabel.text = self.titleForStartButton;
        }
        
    } else {
        
        cell.centerLabel.text = nil;
        if (indexPath.row == self.strategy.currentIndexPath.row) {
            cell.backgroundImageView.image = self.highlightedBackgroundImageForItems;
        } else {
            cell.backgroundImageView.image = self.normalBackgroundImageForItems;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(prizeView:titleOfItemAtIndexPath:)]) {
            cell.titleLabel.text = [self.delegate prizeView:self titleOfItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.item/self.numberOfColumns
                                                                                                           inSection:indexPath.item%self.numberOfColumns]];
        } else if (self.delegate && [self.delegate respondsToSelector:@selector(prizeView:configureTitleLabel:indexPath:)]) {
            [self.delegate prizeView:self configureTitleLabel:cell.titleLabel indexPath:[NSIndexPath indexPathForRow:indexPath.item/self.numberOfColumns
                                                                                                           inSection:indexPath.item%self.numberOfColumns]];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(prizeView:imageOfItemAtIndexPath:)]) {
            cell.icon.image = [self.delegate prizeView:self imageOfItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.item/self.numberOfColumns
                                                                                                      inSection:indexPath.item%self.numberOfColumns]];
        } else if (self.delegate && [self.delegate respondsToSelector:@selector(prizeView:configureImageView:indexPath:)]) {
            [self.delegate prizeView:self configureImageView:cell.icon indexPath:[NSIndexPath indexPathForRow:indexPath.item/self.numberOfColumns
                                                                                                    inSection:indexPath.item%self.numberOfColumns]];
        }
    }
    
    return cell;
}

@end
