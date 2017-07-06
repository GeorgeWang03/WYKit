//
//  WYCollectionPickerView.h
//  WYKit
//
//  Created by yingwang on 2016/12/26.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WYCollectionPickerView;
@protocol WYCollectionPickerViewDelegate <NSObject>

@required
- (NSInteger)numberOfItemInPickerView:(WYCollectionPickerView *)pickerView;
- (UIImage *)pickerView:(WYCollectionPickerView *)pickerView imageForItemAtIndex:(NSInteger)index;
- (NSString *)pickerView:(WYCollectionPickerView *)pickerView titleForItemAtIndex:(NSInteger)index;

@optional
- (void)pickerView:(WYCollectionPickerView *)pickerView didSelectedItemAtIndex:(NSInteger)index;

@end

@interface WYCollectionPickerView : UIView

@property (nonatomic, weak) id<WYCollectionPickerViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end
