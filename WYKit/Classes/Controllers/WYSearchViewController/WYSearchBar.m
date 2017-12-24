//
//  WYSearchBar.m
//  WYKit
//
//  Created by yingwang on 2017/5/18.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

#import "WYPodDefine.h"
#import "WYSearchBar.h"
#import "UITextField+WYPlaceholder.h"

@interface WYSearchBar () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end

@implementation WYSearchBar

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.textfield.placeholder = placeholder;
    self.style = _style;
}

- (void)setStyle:(WYSearchBarStyle)style {
    _style = style;
    
    NSString *iconName;
    UIColor *backgroundColor;
    UIColor *foregroundColor;
    UIColor *placeholderColor;
    
    switch (style) {
        case WYSearchBarStyleWhite:
            iconName = @"ic_basic_search_blue";
            backgroundColor = [UIColor whiteColor];
            foregroundColor = [UIColor darkGrayColor];
            placeholderColor = [UIColor lightGrayColor];
            break;
        case WYSearchBarStyleDefault:
            iconName = @"ic_basic_search";
            backgroundColor = [UIColor cyanColor];
            foregroundColor = [UIColor whiteColor];
            placeholderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
            break;
        default:
            break;
    }
    
    self.iconImageView.image = WYPodImageNamed(iconName);
    self.backgroundColor = backgroundColor;
    self.textfield.textColor = foregroundColor;
    [self.textfield wy_setPlaceholderColor:placeholderColor];
    self.textfield.tintColor = foregroundColor;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.layer.cornerRadius = 2.0;
    
    _textfield.delegate = self;
    self.style = WYSearchBarStyleDefault;
}

#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    if ([_delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        return [_delegate searchBarShouldBeginEditing:self];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if ([_delegate respondsToSelector:@selector(searchBarDidBeginEditing:)]) {
        [_delegate searchBarDidBeginEditing:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ([_delegate respondsToSelector:@selector(searchBarDidEndEditing:)]) {
        [_delegate searchBarDidEndEditing:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(searchBarConfirmSearch:)]) {
        [_delegate searchBarConfirmSearch:self];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([_delegate respondsToSelector:@selector(searchBar:shouldChangeTextToString:)]) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        return [_delegate searchBar:self shouldChangeTextToString:newString];
    }
    
    return YES;
}

@end
