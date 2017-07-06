//
//  WYMainIntroductionRichTextView.h
//  Pods
//
//  Created by yingwang on 2017/3/31.
//
//

#import <UIKit/UIKit.h>

/**
 富文本滑动方向

 - WYMainRichTextViewScrollVertical: 竖直
 - WYMainRichTextViewScrollHorizontal: 水平
 */
typedef NS_ENUM(NSInteger, WYMainRichTextViewScrollDirection) {
    WYMainRichTextViewScrollVertical = 0,
    WYMainRichTextViewScrollHorizontal
};

@interface WYMainRichTextViewParagraphStyle : NSObject

/**
 属性
 */
@property (nonatomic, strong) NSDictionary *attributes;

/**
 文本范围
 */
@property (nonatomic) NSRange range;

@end

@interface WYMainRichTextViewWidgetView : NSObject

/**
 图片大小
 */
@property (nonatomic) CGSize size;

/**
 宽度占屏幕百分比
 */
@property (nonatomic) CGFloat widthPercentage;

/**
 圆角
 */
@property (nonatomic) CGFloat cornerRadius;

/**
 图片在正文中的range，用于计算图片在视图中的位置，重要
 */
@property (nonatomic) NSRange range;

/**
 图片与文本边距
 */
@property (nonatomic) UIEdgeInsets margin;

/**
 图片在文本中的位置，这个由内部计算，外部无关
 */
@property (nonatomic) CGPoint point;

/**
 图片在文本中的占位，这个由内部计算，外部无关
 */
@property (nonatomic) CGRect enclosedRect;

/**
 标记
 */
@property (nonatomic) NSInteger tag;

@end

/**
 内容图片模型
 */
@interface WYMainRichTextViewImage : WYMainRichTextViewWidgetView

/**
 图片链接
 */
@property (nonatomic, strong) NSString *url;

/**
 占位图
 */
@property (nonatomic, strong) UIImage *placeholderImage;

/**
 是否需要在加载完成之后重新设置大小
 主要用于当图片大小在加载之前未知时
 */
@property (nonatomic) BOOL shouldResizeAfterLoading;

/**
 图片标示，供内部使用
 */
@property (nonatomic, strong) NSString *identify;

@end

/**
 内容视频模型
 */
@interface WYMainRichTextViewVideo : WYMainRichTextViewWidgetView

@end

/**
 内容模型
 */
@interface WYMainRichTextViewContent : NSObject

/**
 文本
 */
@property (nonatomic, strong) NSString *content;

/**
 扩展视图模型
 */
@property (nonatomic, strong) NSArray *widgets;

/**
 内容类型，属于 NSDocumentTypeDocumentAttribute 类型，
 如：NSPlainTextDocumentType、NSHTMLTextDocumentType
 */
@property (nonatomic, strong) NSString *contentType;

/**
 字体
 */
@property (nonatomic, strong) UIFont *font;

/**
 边距
 */
@property (nonatomic) UIEdgeInsets contentPadding;

/**
 行间距
 */
@property (nonatomic) CGFloat lineSpace;

/**
 段落间距
 */
@property (nonatomic) CGFloat paragraphSpace;

/**
 段落首行缩进，以point为单位，建议和fontSize对齐
 比如：fontSize为 13.0，那么缩进两个单位就是26.0
 */
@property (nonatomic) NSInteger paragraphIndent;

/**
 文本渲染方向
 */
@property (nonatomic) WYMainRichTextViewScrollDirection direction;

/**
 文本颜色
 */
@property (nonatomic, strong) UIColor *fontColor;

/**
 段落样式
 */
@property (nonatomic, strong) NSArray<WYMainRichTextViewParagraphStyle *> *attributes;

@end

@class WYMainIntroductionRichTextView;

@protocol WYMainIntroductionRichTextViewLayoutDelegate <NSObject>

@optional

/**
 绘制需要的画布大小
 */
- (void)textView:(WYMainIntroductionRichTextView *)textView willLayoutInCanvasSize:(CGSize)size;

/**
 排版完成
 */
- (void)textViewDidLayout:(WYMainIntroductionRichTextView *)textView;

@end

@protocol WYMainIntroductionRichTextViewDelegate <NSObject>
@required

@optional

/**
 选择某张图片
 */
- (void)textView:(WYMainIntroductionRichTextView *)textView didSelectedWidgetAtIndex:(NSInteger)index;

@end

@protocol WYMainIntroductionRichTextViewDataSource <NSObject>
@required

/**
 头部的高度
 */
- (CGFloat)heightForHeaderInTextView:(WYMainIntroductionRichTextView *)textView;

/**
 头部视图
 */
- (UIView *)headerViewInTextView:(WYMainIntroductionRichTextView *)textView;

@optional

/**
 扩展视图
 */
- (void)textView:(WYMainIntroductionRichTextView *)textView widgetView:(UIView *)widgetView index:(NSInteger)index;

@end

@interface WYMainIntroductionRichTextView : UIView

/**
 数据源
 */
@property (nonatomic, weak) id<WYMainIntroductionRichTextViewDataSource> dataSource;

/**
 代理方法
 */
@property (nonatomic, weak) id<WYMainIntroductionRichTextViewDelegate> delegate;

/**
 代理方法
 */
@property (nonatomic, weak) id<WYMainIntroductionRichTextViewLayoutDelegate> layoutDelegate;

/**
 内容描述
 */
@property (nonatomic, strong) WYMainRichTextViewContent *content;

/**
 需要的画布大小，只读
 */
@property (nonatomic, readonly) CGSize canvasSize;

/**
 必需用 initWithFrame 指定画布大小
 */
- (instancetype)init __attribute__((unavailable("use initWithFrame: instead")));

/**
 重新加载数据
 */
- (void)reloadData;

@end



















