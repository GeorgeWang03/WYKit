//
//  WYViewsPart2ViewController.m
//  WYKit_Example
//
//  Created by yingwang on 2017/7/12.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

#import "WYViewsPart2ViewController.h"

#import "WYCollectionPicker.h"
#import "WYMultiClassPickerView.h"
#import "WYCircleItemSelectedView.h"

@interface WYViewsPart2ViewController () <WYCollectionPickerDelegate, WYMultiClassPickerViewDelegate>
{
    CGFloat _currrentTopEdgeY;
    dispatch_once_t onceToken;
}

@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, strong) WYCircleItemSelectedView *itemSelectedView;

@property (nonatomic, strong) WYCollectionPicker *collectionPicker;
@property (nonatomic, strong) NSArray<NSString *> *pickerTitles;
@property (nonatomic, strong) NSArray<NSString *> *pickerIcons;

@property (nonatomic, strong) WYMultiClassPickerView *pickerView;
@property (nonatomic, strong) NSArray *cityNames;

@end

@implementation WYViewsPart2ViewController

- (UIScrollView *)mainScrollView {
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.alwaysBounceVertical = YES;
        _mainScrollView.showsVerticalScrollIndicator = NO;
    }
    return _mainScrollView;
}

- (void)loadView {
    
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.mainScrollView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _currrentTopEdgeY = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCircleItemSelectedNotification:)
                                                 name:kWYCircleItemSelectedViewCellSelectedNotificationName
                                               object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    dispatch_once(&onceToken, ^{
        self.mainScrollView.frame = self.view.bounds;
        
        // setup WYCircleItemSelectedView
        [self setupCircleItemSelectedView];
        
        // setup WYCollectionPicker
        [self setupPickerView];
        
        //setup WYMultiClassPickerView
        [self setupWYMultiClassPickerView];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - WYCircleItemSelectedView
- (void)setupCircleItemSelectedView {
    
    _itemSelectedView = [[WYCircleItemSelectedView alloc] init];
    _itemSelectedView.fontSize = 13;
    _itemSelectedView.exactItemSpacing = 5;
    _itemSelectedView.exactLineSpacing = 5;
    _itemSelectedView.mutableSelection = NO; // default is NO
    
    _itemSelectedView.itemsTitle = @[@"Apple", @"Hello World!", @"iPhone", @"macBookPro", @"AppleWatch"];
    
    _itemSelectedView.frame = CGRectMake(20, _currrentTopEdgeY+50, CGRectGetWidth(self.view.bounds)-40, 50);
    [self.mainScrollView addSubview:_itemSelectedView];
    
    _currrentTopEdgeY += (CGRectGetMaxY(_itemSelectedView.frame));
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), _currrentTopEdgeY);
}

- (void)handleCircleItemSelectedNotification:(NSNotification *)notification {
    if (notification.object != self.itemSelectedView) return;
    
    NSUInteger idx = [notification.userInfo[kWYCircleItemSelectedViewCellNotifyInfoIndexPathKey] unsignedIntegerValue];
    // do something
}

#pragma mark - WYCollectionPicker
- (void)setupPickerView {
    
    self.collectionPicker = [[WYCollectionPicker alloc] init];
    self.collectionPicker.delegate = self;
    self.collectionPicker.title = @"Social Share";
    
    self.pickerTitles = @[@"Moment", @"Wechat", @"Sina", @"QQ", @"Zone"];
    self.pickerIcons = @[@"img_demo_share_001", @"img_demo_share_002", @"img_demo_share_003", @"img_demo_share_004", @"img_demo_share_005", ];
    
    UIButton *showButton = [[UIButton alloc] init];
    [showButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    showButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds)/2-80, _currrentTopEdgeY+50, 160, 40);
    [showButton setTitle:@"WYCollectionPicker" forState:UIControlStateNormal];
    [showButton addTarget:self.collectionPicker
                   action:@selector(show)
         forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainScrollView addSubview:showButton];
    
    _currrentTopEdgeY += 100;
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), _currrentTopEdgeY);
}

#pragma mark - WYCollectionPicker Delegate
- (NSInteger)numberOfItemInPicker:(WYCollectionPicker *)picker {
    return self.pickerTitles.count;
}
- (UIImage *)picker:(WYCollectionPicker *)picker imageForItemAtIndex:(NSInteger)index {
    return [UIImage imageNamed:self.pickerIcons[index]];
}
- (NSString *)picker:(WYCollectionPicker *)picker titleForItemAtIndex:(NSInteger)index {
    return self.pickerTitles[index];
}

- (void)picker:(WYCollectionPicker *)picker didSelectedItemAtIndex:(NSInteger)index {
    // do something after selected
}
- (void)pickerWillDismiss:(WYCollectionPicker *)picker {
    // do something after picker dismiss
}

#pragma mark - WYMultiClassPickerView
- (void)setupWYMultiClassPickerView {
    
    _pickerView = [[WYMultiClassPickerView alloc] init];
    _pickerView.delegate = self;
    _pickerView.asynchronous = YES;
    _pickerView.dismiassWhenSelectLastClass = YES;
    _pickerView.title = @"City Select";
    _pickerView.designatedTitle = @"Current City ：";
    _pickerView.designatedText = @"Guandong GuangZhou";
    _pickerView.highlightedColor = [UIColor blackColor];
    
    self.cityNames = @[@[@"Guandong", @[@"GuangZhou", @"ShenZhen"]],
                       @[@"ZheJiang", @[@"HangZhou", @"NingBo"]],
                       @[@"JiangSu", @[@"SuZhou", @"NanJing"]]
                       ];
    
    UIButton *showButton = [[UIButton alloc] init];
    [showButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    showButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds)/2-80, _currrentTopEdgeY+50, 160, 40);
    [showButton setTitle:@"WYMultiClassPickerView" forState:UIControlStateNormal];
    [showButton addTarget:self.pickerView
                   action:@selector(show)
         forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainScrollView addSubview:showButton];
    
    _currrentTopEdgeY += 100;
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), _currrentTopEdgeY);
}

#pragma mark - WYMultiClassPickerView Delegate
- (NSInteger)maxNumberClassInPickerView:(WYMultiClassPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(WYMultiClassPickerView *)pickerView numberOfRowInClassIndex:(NSInteger)classIndex {
    return [self.cityNames[classIndex][1] count];
}

- (NSString *)pickerView:(WYMultiClassPickerView *)pickerView textAtIndexPath:(NSIndexPath *)indexPath {
        return self.cityNames[indexPath.section][1][indexPath.row];
}

- (BOOL)pickerItemHasSubClassAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0;
}

- (void)pickerViewWillLoadInitialClass:(WYMultiClassPickerView *)pickerView {
    [self.pickerView finishLoadDataAtClassIndex:0 success:YES error:nil];
}

- (void)pickerView:(WYMultiClassPickerView *)pickerView willLoadSubClassFromIndexPath:(NSIndexPath *)indexPath{
    
    // async task
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // notify pickerView
        [self.pickerView finishLoadDataAtClassIndex:indexPath.section+1 success:YES error:nil];
    });
}

- (void)pickerViewWillDismiss:(WYMultiClassPickerView *)pickerView {
}

@end
