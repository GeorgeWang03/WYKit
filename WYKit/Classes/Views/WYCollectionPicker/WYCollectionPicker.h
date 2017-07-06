//
//  WYCollectionPicker.h
//  WYKit
//
//  Created by yingwang on 2016/12/26.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WYCollectionPicker;
@protocol WYCollectionPickerDelegate <NSObject>

@required
- (NSInteger)numberOfItemInPicker:(WYCollectionPicker *)picker;
- (UIImage *)picker:(WYCollectionPicker *)picker imageForItemAtIndex:(NSInteger)index;
- (NSString *)picker:(WYCollectionPicker *)picker titleForItemAtIndex:(NSInteger)index;

@optional
- (void)picker:(WYCollectionPicker *)picker didSelectedItemAtIndex:(NSInteger)index;
- (void)pickerWillDismiss:(WYCollectionPicker *)picker;

@end

@interface WYCollectionPicker : NSObject

@property (nonatomic, weak) id<WYCollectionPickerDelegate> delegate;
@property (nonatomic, strong) NSString *title;

- (void)show;
- (void)hide;

@end
