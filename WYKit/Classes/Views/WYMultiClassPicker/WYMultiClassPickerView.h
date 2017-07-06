//
//  WYMultiClassPickerView.h
//  WYKit
//
//  Created by yingwang on 2016/11/28.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WYMultiClassPickerView;
@protocol WYMultiClassPickerViewDelegate <NSObject>

@required
- (BOOL)pickerItemHasSubClassAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)maxNumberClassInPickerView:(WYMultiClassPickerView *)pickerView;
- (NSInteger)pickerView:(WYMultiClassPickerView *)pickerView numberOfRowInClassIndex:(NSInteger)classIndex;
- (NSString *)pickerView:(WYMultiClassPickerView *)pickerView textAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (void)pickerViewWillDismiss:(WYMultiClassPickerView *)pickerView;
- (void)pickerView:(WYMultiClassPickerView *)pickerView didSelectedClassAtIndex:(NSInteger)classIndex;
- (void)pickerView:(WYMultiClassPickerView *)pickerView didSelectedItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)pickerViewWillLoadInitialClass:(WYMultiClassPickerView *)pickerView;
- (void)pickerView:(WYMultiClassPickerView *)pickerView willLoadSubClassFromIndexPath:(NSIndexPath *)indexPath;

@end

@interface WYMultiClassPickerView : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *designatedTitle;
@property (nonatomic, strong) NSString *designatedText;

@property (nonatomic) BOOL asynchronous;
@property (nonatomic) BOOL dismiassWhenSelectLastClass;
@property (nonatomic) BOOL showSubtitleRow;

@property (nonatomic, strong) UIColor *highlightedColor;

@property (nonatomic, weak) id<WYMultiClassPickerViewDelegate> delegate;

@property (nonatomic, readonly) NSArray *selectedIndexPaths;

- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;

- (void)show;
- (void)reloadData;
- (void)finishLoadDataAtClassIndex:(NSInteger)classIndex success:(BOOL)success error:(NSError *)error;

@end
