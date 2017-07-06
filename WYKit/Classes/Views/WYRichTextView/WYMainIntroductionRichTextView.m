//
//  WYMainIntroductionRichTextView.m
//  Pods
//
//  Created by yingwang on 2017/3/31.
//
//

#import "UIImageView+WebCache.h"
#import "WYMainIntroductionRichTextView.h"
#import "WYMainIntroductionRichTextView+WYParser.h"

@implementation WYMainRichTextViewParagraphStyle

@end

@implementation WYMainRichTextViewWidgetView

@end

@implementation WYMainRichTextViewImage

@end

@implementation WYMainRichTextViewVideo

@end

@implementation WYMainRichTextViewContent

- (NSString *)contentType {
    return _contentType ?: NSPlainTextDocumentType;
}

- (UIFont *)font {
    return _font ?: [UIFont systemFontOfSize:14.0];
}

- (UIColor *)fontColor {
    return _fontColor ?: [UIColor blackColor];
}


@end

@interface WYMainIntroductionRichTextContainer : NSTextContainer

@property (nonatomic, assign) CGRect rect;
@property (nonatomic, assign) NSRange textRange;
@property (nonatomic) NSInteger index;


/**
 创建新的文本容器
 用于横向排版的内容

 @param padding 文本边距
 @param canvasSize 画布大小，也可以说文本窗口大小
 @param index 横向位置
 */
+ (WYMainIntroductionRichTextContainer *)textContainerWithContentPadding:(UIEdgeInsets)padding
                                                       canvasSize:(CGSize)canvasSize
                                                  horizontalIndex:(NSInteger)index;

@end

@implementation WYMainIntroductionRichTextContainer

+ (WYMainIntroductionRichTextContainer *)textContainerWithContentPadding:(UIEdgeInsets)padding
                                                              canvasSize:(CGSize)canvasSize
                                                         horizontalIndex:(NSInteger)index {
    
    CGSize innerSize = CGSizeMake(canvasSize.width-padding.left-padding.right,
                                  canvasSize.height-padding.top-padding.bottom);
    
    WYMainIntroductionRichTextContainer *container = [[WYMainIntroductionRichTextContainer alloc] initWithSize:canvasSize];
    container.rect = CGRectMake(padding.left+index*(padding.left+padding.right+innerSize.width),
                                padding.top, innerSize.width, innerSize.height);
    container.index = index;
    
    return container;
}

@end

@interface WYMainIntroductionRichTextView ()


/**
 初始化时候的frame
 */
@property  (nonatomic) CGRect originalFrame;

/**
 富文本字符串
 */
@property (nonatomic, strong) NSMutableAttributedString *contentString;

/**
 文本仓库
 */
@property (nonatomic, strong) NSTextStorage *textStorage;

/**
 排版管理器
 */
@property (nonatomic, strong) NSLayoutManager *layoutManager;

/**
 文本容器
 */
@property (nonatomic, strong) NSMutableArray *textContainers;

/**
 图片集合
 */
@property (nonatomic, strong) NSMutableArray *imageViews;

@end

@interface WYMainIntroductionRichTextView (Util)

/**
 根据最大宽度缩放指定size
 */
+ (CGSize)resizeWidthByFixedRatioForSize:(CGSize)size maxWidth:(CGFloat)maxWidth;

/**
 居中rect
 */
+ (CGRect)centerRect:(CGRect)rect inDestinationRect:(CGRect)destinaionRect;

@end



/**
 绘制流程遵循：
            1.生产富文本字符串
            2.构建textKit框架
            3.计算头部及图片在文本中的位置
            4.根据上面计算得到的位置，由头部和图片大小算出文本中环绕路径
            5.设置好文本环绕路径
            6.绘制文本 和 图片
 */

@implementation WYMainIntroductionRichTextView

#pragma Setter and Getter

- (CGSize)canvasSize {
    CGSize size = CGSizeZero;
    
    size.width = self.textContainers.count * CGRectGetWidth(self.originalFrame);
    
    if (self.textContainers.count) {
        WYMainIntroductionRichTextContainer *container = [self.textContainers lastObject];
        size.height = CGRectGetMaxY(container.rect);
    }
    
    return size;
}

#pragma mark - Initialize
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.originalFrame = frame;
    }
    
    return self;
}

#pragma mark - Drawing

/**
 重新加载数据
 */
- (void)reloadData {
    
//    1.生产富文本字符串
    self.contentString = [self createAttributeStringByContent:self.content
                                               containerWidth:self.originalFrame.size.width];
//    2.构建textKit框架
    [self createTextFoundationWithAttributeString:self.contentString];
//    3.计算头部及图片在文本中的位置
//    4.根据上面计算得到的位置，由头部和图片大小算出文本中环绕路径
//    5.设置好文本环绕路径
    CGFloat headerHeight = 0;
    
    if ([_dataSource respondsToSelector:@selector(heightForHeaderInTextView:)]) {
        headerHeight = [_dataSource heightForHeaderInTextView:self];
    }
    
    self.textContainers = [self createTextContainersWithLayoutManager:self.layoutManager
                                                      canvasDirection:self.content.direction
                                                           canvasSize:self.originalFrame.size
                                                       contentPadding:self.content.contentPadding
                                                           topSpacing:headerHeight];
    [self calculateRectForImages:self.content.widgets
                   layoutManager:self.layoutManager
                 canvasDirection:self.content.direction
                      canvasSize:self.originalFrame.size
                  contentPadding:self.content.contentPadding
                  textContainers:self.textContainers
                      topSpacing:headerHeight];
    
    // 5.2 通知代理更新文本内容高度
    if ([_layoutDelegate respondsToSelector:@selector(textView:willLayoutInCanvasSize:)]) {
        [_layoutDelegate textView:self willLayoutInCanvasSize:self.canvasSize];
    }
    
//    6.绘制文本 和 图片
    // 6.1 绘制文本
    [self setNeedsDisplay];
    // 6.2 添加扩展图
    // 6.2.1 先把之前的图给去掉
    [self.imageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 6.2.2 创建扩展视图
    self.imageViews = [self createWidgetViewsWidthImages:self.content.widgets inView:self];
    // 6.2.3 加载扩展视图中的图片
    [self loadImagesInWidgets:self.content.widgets
                 widgetsViews:self.imageViews
                  layoutBlock:^{
                      [self layoutTextContainerIfNeed];
                  }];
    NSLog(@"%@", self.imageViews.description);
    // 6.3 添加头部
    UIView *headerView;
    if ([_dataSource respondsToSelector:@selector(headerViewInTextView:)]) {
        headerView = [_dataSource headerViewInTextView:self];
    }
    
    if (headerView) {
        headerView.frame = CGRectMake(self.content.contentPadding.left, 10, CGRectGetWidth(self.bounds)-self.content.contentPadding.left-self.content.contentPadding.right, headerHeight);
        [self addSubview:headerView];
    }
    
    // 通知布局代理，排版完成
    if ([self.layoutDelegate respondsToSelector:@selector(textViewDidLayout:)]) {
        [self.layoutDelegate textViewDidLayout:self];
    }
}

- (void)layoutTextContainerIfNeed {
    
    NSLog(@"layoutTextContainerIfNeed");
    
    // 1. 清除layoutManager的所有container的exclusionPath
    [self.layoutManager.textContainers enumerateObjectsUsingBlock:^(NSTextContainer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.exclusionPaths = @[];
    }];
    
    // 2.调整container
    CGFloat headerHeight = 0;
    
    if ([_dataSource respondsToSelector:@selector(heightForHeaderInTextView:)]) {
        headerHeight = [_dataSource heightForHeaderInTextView:self];
    }
    
    self.textContainers = [self createTextContainersWithLayoutManager:self.layoutManager
                                                      canvasDirection:self.content.direction
                                                           canvasSize:self.originalFrame.size
                                                       contentPadding:self.content.contentPadding
                                                           topSpacing:headerHeight];
    
    // 3.重新计算图片位置
    //   并为container添加占位框
    [self calculateRectForImages:self.content.widgets
                   layoutManager:self.layoutManager
                 canvasDirection:self.content.direction
                      canvasSize:self.originalFrame.size
                  contentPadding:self.content.contentPadding
                  textContainers:self.textContainers
                      topSpacing:headerHeight];
    
    // 4. 通知代理更新文本内容高度
    if ([_layoutDelegate respondsToSelector:@selector(textView:willLayoutInCanvasSize:)]) {
        [_layoutDelegate textView:self willLayoutInCanvasSize:self.canvasSize];
    }
    
    // 5.更新widgetView框架
    [self updateRectForWidgets:self.imageViews models:self.content.widgets];
    // 6.绘制文本
    [self setNeedsDisplay];
}


/**
 1.生产富文本字符串
 */
- (NSMutableAttributedString *)createAttributeStringByContent:(WYMainRichTextViewContent *)content
                                               containerWidth:(CGFloat)containerWidth {
    
    NSDictionary *stringAttributes;
    NSMutableAttributedString *attributeString;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setFirstLineHeadIndent:self.content.paragraphIndent];
    [paragraphStyle setParagraphSpacing:self.content.paragraphSpace];
    [paragraphStyle setLineSpacing:self.content.lineSpace];
    
    stringAttributes = @{NSFontAttributeName : content.font,
                         NSForegroundColorAttributeName : content.fontColor,
                         NSParagraphStyleAttributeName : paragraphStyle};
    
         // 纯文本
    if ([content.contentType isEqualToString:NSPlainTextDocumentType]) {
        attributeString = [[NSMutableAttributedString alloc] initWithString:content.content
                                                                 attributes:stringAttributes];
        
        // HTML 类型文本
    } else if ([content.contentType isEqualToString:NSHTMLTextDocumentType]) {
        NSError *error = nil;
        CGFloat maxWidth = containerWidth;
        NSArray *widgets = [WYMainIntroductionRichTextView parseImagesFromHTML:content.content
                                             attributeString:&attributeString
                                               maxImageWidth:maxWidth
                                                     options:stringAttributes
                                                       error:&error];
        content.widgets = widgets;
    }
    
    NSRange stringRange = NSMakeRange(0, attributeString.length);
    [attributeString addAttributes:stringAttributes range:stringRange];
    
    [content.attributes enumerateObjectsUsingBlock:^(WYMainRichTextViewParagraphStyle * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 如果是有效的range
        if (NSEqualRanges(NSUnionRange(obj.range, stringRange), stringRange) && obj.attributes) {
            [attributeString addAttributes:obj.attributes range:obj.range];
        }
    }];
    
    return attributeString;
}

/**
 2.构建textKit框架
 */
- (void)createTextFoundationWithAttributeString:(NSAttributedString *)attributeString {
    
    self.textStorage = [[NSTextStorage alloc] initWithAttributedString:attributeString];
    
    self.layoutManager = [[NSLayoutManager alloc] init];
    self.layoutManager.delegate = self;
    
    [self.textStorage addLayoutManager:self.layoutManager];
}

/**
 2.1 构建文本容器
 
 @param direction 绘制方向
 @param canvasSize 画布大小
 @param topSpacing 顶部空白高度
 */
- (NSMutableArray *)createTextContainersWithLayoutManager:(NSLayoutManager *)layoutManager
                                     canvasDirection:(WYMainRichTextViewScrollDirection)direction
                                          canvasSize:(CGSize)canvasSize
                                      contentPadding:(UIEdgeInsets)padding
                                          topSpacing:(CGFloat)topSpacing {
    
    return [self updateTextContainersWithLayoutManager:layoutManager
                                       canvasDirection:direction
                                            canvasSize:canvasSize
                                        contentPadding:padding
                                            topSpacing:topSpacing];;
}

/**
 更新container
 */
- (NSMutableArray *)updateTextContainersWithLayoutManager:(NSLayoutManager *)layoutManager
                                          canvasDirection:(WYMainRichTextViewScrollDirection)direction
                                               canvasSize:(CGSize)canvasSize
                                           contentPadding:(UIEdgeInsets)padding
                                               topSpacing:(CGFloat)topSpacing {
    
    
    NSMutableArray *containers = layoutManager.textContainers;
    
    NSInteger lastLoc = 0; // 目前containers数组中所有container所能绘制的所有正文文本长度
    
    // 如果已经有container，那么从最后一个开始计算
    if (containers.count) {
        WYMainIntroductionRichTextContainer *container = [containers lastObject];
        NSRange range = [layoutManager glyphRangeForTextContainer:container];
        lastLoc = range.length;
    }
    
    // 从未能显示的文本位置开始
    NSInteger allTextLength = layoutManager.textStorage.string.length;
    NSInteger remainTextLength = allTextLength - lastLoc;
    
    // 水平方向
    if (direction == WYMainRichTextViewScrollHorizontal) {
        
        CGSize innerSize = CGSizeMake(canvasSize.width-padding.left-padding.right,
                                      canvasSize.height-padding.top-padding.bottom);
        NSInteger idx = containers.count;
        
        // 如果container数量不够，那么要添加
        while (remainTextLength > 0) {
            
            WYMainIntroductionRichTextContainer *container = [WYMainIntroductionRichTextContainer textContainerWithContentPadding:padding
                                                                                                                       canvasSize:canvasSize
                                                                                                                  horizontalIndex:idx];
            UIEdgeInsets realPadding = padding;
            
            if (!idx) {
                realPadding.top += topSpacing;
                container = [WYMainIntroductionRichTextContainer textContainerWithContentPadding:realPadding
                                                                                      canvasSize:canvasSize
                                                                                 horizontalIndex:idx];
            } else {
                container = [WYMainIntroductionRichTextContainer textContainerWithContentPadding:padding
                                                                                      canvasSize:canvasSize
                                                                                 horizontalIndex:idx];
            }
            
            [layoutManager addTextContainer:container];
            [containers addObject:container];
            
            NSRange range = [layoutManager glyphRangeForTextContainer:container];
            container.textRange = range;
            remainTextLength -= range.length;
            
            idx++;
        }
        
        // 去除多余的container
        // 这是由于动态图片加载过程，框架变化
        // 导致文本布局可能变大或者变小，故container的数量可能不够也可能缺少
        NSRangePointer rangePointer;
        // 寻找最后一个有效的container
        // 前提条件：最后一个container必定含有glyph，而不仅是exclusionPath
        WYMainIntroductionRichTextContainer *currentContainer;
        WYMainIntroductionRichTextContainer *lastValidContainer;
        for (NSInteger i = layoutManager.textContainers.count-1; i >= 0; ++i) {
            currentContainer = layoutManager.textContainers[i];
            NSRange range = [layoutManager glyphRangeForTextContainer:currentContainer];
            // 有效container
            if (range.length && range.location != NSNotFound) {
                break;
            } else {
                // 无效container
                lastValidContainer = currentContainer;
            }
        }
        
        // 有多余的container
        if (lastValidContainer) {
            NSInteger lastIndexOfContainers = lastValidContainer.index;
            while (layoutManager.textContainers.count > lastIndexOfContainers+1) {
                [layoutManager removeTextContainerAtIndex:layoutManager.textContainers.count-1];
            }
        }
        
        // 竖直方向
    } else {
        
        CGFloat height = 1000;
        CGSize realSize;
        WYMainIntroductionRichTextContainer *container;
        if (!containers.count) {
            realSize = CGSizeMake(canvasSize.width-padding.left-padding.right,
                                  height-padding.top-padding.bottom);
            container = [WYMainIntroductionRichTextContainer textContainerWithContentPadding:padding
                                                                                  canvasSize:realSize
                                                                             horizontalIndex:0];
            [layoutManager addTextContainer:container];
            
            remainTextLength = allTextLength - [layoutManager glyphRangeForTextContainer:container].length;
        } else {
            container = [layoutManager.textContainers lastObject];
            realSize = container.size;
        }
        
        // allTextLength相当于这个container剩下未能显示的文本长度
        // 如果不够显示，则增大container的大小
        // 直到能够显示完全
        while (remainTextLength > 0) {
            realSize.height += height;
            container.size = realSize;
            container.rect = CGRectMake(padding.left, topSpacing + padding.top, realSize.width, realSize.height);
            
            remainTextLength = allTextLength - [layoutManager glyphRangeForTextContainer:container].length;
        }
        
        // 实际的rect
        // 如果文本是从图片下方开始，也就是container起始是图片，那么realRect.origin.y会是图片下方开始
        CGRect realRect = [layoutManager boundingRectForGlyphRange:NSMakeRange(0, allTextLength) inTextContainer:container];
        // 所以高度要加上realRect.origin.y
        realRect.size.height += realRect.origin.y;
        container.size = CGSizeMake(container.size.width, CGRectGetHeight(realRect));
        container.rect = CGRectMake(padding.left, topSpacing + padding.top, container.size.width, CGRectGetHeight(realRect));
        
    }
    
    return containers;
}

/**
 3.计算头部及图片在文本中的位置
 4.根据上面计算得到的位置，由头部和图片大小算出文本中环绕路径
 5.设置好文本环绕路径
 */

- (void)calculateRectForImages:(NSArray *)images
                 layoutManager:(NSLayoutManager *)layoutManager
               canvasDirection:(WYMainRichTextViewScrollDirection)direction
                    canvasSize:(CGSize)canvasSize
                contentPadding:(UIEdgeInsets)padding
                textContainers:(NSMutableArray *)containers
                    topSpacing:(CGFloat)topSpacing {
    
    for (int idx = 0; idx < images.count; idx++) {
        
        WYMainRichTextViewImage *imageInfo = images[idx];
        // 更新图片宽度
        imageInfo.size = [WYMainIntroductionRichTextView resizeWidthByFixedRatioForSize:imageInfo.size maxWidth:canvasSize.width];
        
        WYMainIntroductionRichTextContainer *container;
        
        // find container for image
        NSUInteger indexOfContainer = 0;
            // 如果是竖直方向的话，只需要用唯一的一个container
        if (direction == WYMainRichTextViewScrollVertical) {
            container = containers[0];
            
            // 如果是水平方向的话，需要寻找是在哪个container中
        } else {
            for (int i = 0; i < _textContainers.count; ++i) {
                WYMainIntroductionRichTextContainer *tc = containers[i];
                if (tc.textRange.location <= imageInfo.range.location
                    && (tc.textRange.location+tc.textRange.length) > imageInfo.range.location) {
                    container = tc;
                    indexOfContainer = i;
                    break;
                }
            }
        }
        
        // calculate glyph rect
        CGRect glyphRect = [layoutManager boundingRectForGlyphRange:imageInfo.range
                                                     inTextContainer:container];
        // 第一个container有标题，所以container的坐标和后面的不一样，所有图片相对位置要改变
        // 保证了占位符的位置会在图片占位框的下面
        CGFloat imageOriginY = glyphRect.origin.y;
        
        // 图片竖直方向的间隔
        CGFloat imageVerticleMarggingTop = imageInfo.margin.top;
        CGFloat imageVerticleMarggingBottom = imageInfo.margin.bottom;
        // 图片的坐标相对于总的view， 而占位rect坐标相对于单个container
        // 而要想画出所有占位rect，由于是相对于总的view，故其坐标和相对于container时不一样
        CGRect rectOfImage;
        rectOfImage.size = imageInfo.size;
        // 占位框上下各增大面积一行
        rectOfImage.size.height += imageVerticleMarggingTop + imageVerticleMarggingBottom;
        // 占位框宽度等于container宽度
        rectOfImage.size.width = container.size.width;
        // 占位框的y坐标开始于占位符之下
        rectOfImage.origin = CGPointMake(padding.left, imageOriginY);
        // 图片的坐标， 为占位框各个方向减去间隔，图片位置相对整个textView，而不是相对于container
        CGFloat pointY = rectOfImage.origin.y+imageVerticleMarggingTop+CGRectGetMinY(container.rect);
        imageInfo.point = CGPointMake(CGRectGetMinX(container.rect) + (CGRectGetWidth(rectOfImage)-imageInfo.size.width)/2, pointY);
        
        // if image heigher than the space, put it on the next container
        // 如果剩下的container面积不够放图片
        // 水平画布情况下，放到下一个container
        // 竖直画布情况下，增大container 高度
        CGFloat imageBottomMarginToContainer = CGRectGetMinY(rectOfImage)+CGRectGetHeight(rectOfImage)
                                            - (CGRectGetMinY(container.rect) + CGRectGetHeight(container.rect));
        if ( imageBottomMarginToContainer > 0 ) {
            
            // 竖直画布
            if (direction == WYMainRichTextViewScrollVertical) {
                // 增大container 高度
                CGRect newRect = container.rect;
                newRect.size.height += imageBottomMarginToContainer;
                container.size = newRect.size;
                container.rect = newRect;
                
                imageInfo.enclosedRect = rectOfImage;
                
            // 水平画布
            } else {
                
                //在下一个container中放在最上方
                CGRect realBound = rectOfImage;
                realBound.origin = CGPointMake(padding.left, 0);
                
                // 由图片大小算出文本中环绕路径，并添加到container中
                UIBezierPath *path = [UIBezierPath bezierPathWithRect:realBound];
                // if current container is the lastest one, create new one
                // 如果当前的container是最后一个，那么增加一个
                if (indexOfContainer == containers.count-1) {
                    WYMainIntroductionRichTextContainer *container = [WYMainIntroductionRichTextContainer textContainerWithContentPadding:padding
                                                                                                                               canvasSize:canvasSize
                                                                                                                          horizontalIndex:indexOfContainer+1];
                    [layoutManager addTextContainer:container];
                    [containers addObject:container];
                }
                
                WYMainIntroductionRichTextContainer *nextContainer = containers[indexOfContainer+1];
                // 图片的坐标位于新的container中
                imageInfo.point = CGPointMake(CGRectGetMinX(nextContainer.rect)+10 + (CGRectGetWidth(realBound)-imageInfo.size.width)/2, imageVerticleMarggingTop);
                imageInfo.enclosedRect = realBound;
                
                NSMutableArray *currentExclusionPaths = [NSMutableArray arrayWithArray:nextContainer.exclusionPaths];
                [currentExclusionPaths addObject:path];
                [nextContainer setExclusionPaths:currentExclusionPaths];
                // 图片放在新的container之后，前一个container要腾出剩余所有空位
                rectOfImage.size.height = container.size.height - CGRectGetMinY(rectOfImage);
            }
            
        } else {
            imageInfo.enclosedRect = rectOfImage;
        }
        
        
        // 由图片大小算出文本中环绕路径，并添加到container中
        NSMutableArray *currentExclusionPaths = [NSMutableArray arrayWithArray:container.exclusionPaths];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:rectOfImage];
        
        [currentExclusionPaths addObject:path];
        [container setExclusionPaths:currentExclusionPaths];
        
        glyphRect = [layoutManager boundingRectForGlyphRange:imageInfo.range
                                             inTextContainer:container];
        
        [self updateTextContainersWithLayoutManager:layoutManager
                                    canvasDirection:direction
                                         canvasSize:canvasSize
                                     contentPadding:padding
                                         topSpacing:topSpacing];
    }
}

/**
 6.绘制文本 和 图片
 */
- (void)drawRect:(CGRect)rect {
    
    for (int idx = 0; idx < self.textContainers.count; ++idx) {
        
        WYMainIntroductionRichTextContainer *container = self.textContainers[idx];
        //CGSize size = container.size;
        NSRange range = [_layoutManager glyphRangeForTextContainer:container];
        [_layoutManager drawBackgroundForGlyphRange:range atPoint:container.rect.origin];
        [_layoutManager drawGlyphsForGlyphRange:range atPoint:container.rect.origin];
    }
    
    // 画出图片占位框，用于调试
//        CGContextRef ctx = UIGraphicsGetCurrentContext();
//        CGContextSetLineWidth(ctx, 3);
//        CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
//        for (WYMainRichTextViewImage *imageInfo in self.content.widgets) {
//            WYMainIntroductionRichTextContainer *ctn = [self.textContainers firstObject];
//            CGContextAddRect(ctx, CGRectOffset(imageInfo.enclosedRect, 0, CGRectGetMinY(ctn.rect)));
//        }
//        CGContextStrokePath(ctx);
    
}

/**
 6.1 添加widget视图
 */
- (NSMutableArray *)createWidgetViewsWidthImages:(NSArray *)widgets inView:(WYMainIntroductionRichTextView *)view {
    NSMutableArray *array = [NSMutableArray array];
    
    NSInteger idx = 0;
    for (WYMainRichTextViewWidgetView *image in widgets) {
        CGRect frame = CGRectMake(image.point.x, image.point.y, image.size.width, image.size.height);
        UIView *widgetView;
        
        if ([image isKindOfClass:[WYMainRichTextViewImage class]]) {
            widgetView = [[UIImageView alloc] initWithFrame:frame];
            
        } else if ([image isKindOfClass:[WYMainRichTextViewVideo class]]) {
            
            widgetView = [[UIView alloc] initWithFrame:frame];
        }
        
        NSAssert([_dataSource respondsToSelector:@selector(textView:widgetView:index:)], @"WYMainIntroductionRichTextView dataSource must respond to method textView:widgetView:index: and return a vaild view.");
        [_dataSource textView:view widgetView:widgetView index:idx];
        
        
        widgetView.tag = idx;
        widgetView.userInteractionEnabled = YES;
        widgetView.layer.cornerRadius = image.cornerRadius;
        widgetView.layer.masksToBounds = YES;
        
        UITapGestureRecognizer *rg = [[UITapGestureRecognizer alloc] initWithTarget:view
                                                                             action:@selector(handleWidgetViewTapGestureRecognizer:)];
        [widgetView addGestureRecognizer:rg];
        
        [view addSubview:widgetView];
        [array addObject:widgetView];
        
        ++idx;
    }
    
    return array;
}

// 加载图片和上方创建图片视图分开
// 因为可能存在所有图片在创建完返回之前，部分图片就加载完了
// 这个时候重新调整布局作用对象是旧的imageView
// 这会导致布局失常
- (void)loadImagesInWidgets:(NSArray *)widgets
               widgetsViews:(NSArray *)widgetViews
                layoutBlock:(void(^)())layoutBlock {
    
    [widgets enumerateObjectsUsingBlock:^(WYMainRichTextViewImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([image isKindOfClass:[WYMainRichTextViewImage class]]) {
            UIImageView *imageView = widgetViews[idx];
            
            [WYMainIntroductionRichTextView loadImage:image
                                            imageView:imageView
                                     placeholderImage:image.placeholderImage
                                            completed:^(BOOL success, NSError *error) {
                                                if (success) {
                                                    // 图片加载成功
                                                    if ([(id)image shouldResizeAfterLoading]) {
                                                        if (layoutBlock) {
                                                            // 重新布局
                                                            layoutBlock();
                                                        }
                                                        // 高度已经计算出来，故后续不需要再次计算更新
                                                        ((WYMainRichTextViewImage *)image).shouldResizeAfterLoading = NO;
                                                    }
                                                }
                                            }];
        }
    }];
}

/**
 加载图片

 @param imageModel 图片模型
 @param imageView 图片视图
 */
+ (void)loadImage:(WYMainRichTextViewImage *)imageModel
        imageView:(UIImageView *)imageView
 placeholderImage:(UIImage *)placeholderImage
        completed:(void(^)(BOOL success, NSError *error))completed {
    
    BOOL shouldResize = imageModel.shouldResizeAfterLoading;
    NSURL *imageURL = [NSURL URLWithString:imageModel.url];
    
    [imageView sd_setImageWithURL:imageURL
                 placeholderImage:placeholderImage
                          options:SDWebImageCacheMemoryOnly
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            
                            if (!error) {
                                imageView.image = image;
                                
                                if (shouldResize) {
                                    CGFloat maxWidth = imageModel.size.width*imageModel.widthPercentage;
                                    imageModel.size = [WYMainIntroductionRichTextView resizeWidthByFixedRatioForSize:image.size maxWidth:maxWidth];
                                }
                                
                                if (completed) completed(YES, nil);
                                
                            } else {
                                // 出错
                                if (completed) completed(NO, error);
                            }
                        }];
}

/**
 更新扩展图的位置和大小

 @param widgets 扩展视图集合
 @param models 扩展视图模型
 */
- (void)updateRectForWidgets:(NSArray *)widgets models:(NSArray *)models {
    
    NSLog(@"updateRectForWidgets");
    [widgets enumerateObjectsUsingBlock:^(UIView *widgetView, NSUInteger idx, BOOL * _Nonnull stop) {
        WYMainRichTextViewWidgetView *model = models[idx];
        CGRect frame = CGRectMake(model.point.x, model.point.y, model.size.width, model.size.height);
        widgetView.frame = frame;
        NSLog(@"imageView : %p, rect: %@", widgetView, NSStringFromCGRect(frame));
    }];
}

#pragma mark - Other

- (void)handleWidgetViewTapGestureRecognizer:(UIGestureRecognizer *)recognizer {
    
    if ([_delegate respondsToSelector:@selector(textView:didSelectedWidgetAtIndex:)]) {
        [_delegate textView:self didSelectedWidgetAtIndex:recognizer.view.tag];
    }
}

@end


@implementation WYMainIntroductionRichTextView (Util)

/**
 根据最大宽度缩放指定size
 */
+ (CGSize)resizeWidthByFixedRatioForSize:(CGSize)size maxWidth:(CGFloat)maxWidth {
    
    if (size.width < maxWidth) {
        return size;
    } else {
        CGFloat ratio = maxWidth/size.width;
        size.width = maxWidth;
        size.height *= ratio;
        return size;
    }
}

/**
 居中rect
 */
+ (CGRect)centerRect:(CGRect)rect inDestinationRect:(CGRect)destinaionRect {
    
    CGFloat x = (CGRectGetWidth(destinaionRect) - CGRectGetWidth(rect))/2;
    CGFloat y = (CGRectGetHeight(destinaionRect) - CGRectGetHeight(rect))/2;
    rect.origin = CGPointMake(x, y);
    
    return rect;
}

#pragma mark - layout manager delegate
- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager lineSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    
    return self.content.lineSpace;
}

- (CGFloat)layoutManager:(NSLayoutManager *)layoutManager paragraphSpacingAfterGlyphAtIndex:(NSUInteger)glyphIndex withProposedLineFragmentRect:(CGRect)rect {
    
    return self.content.paragraphSpace;
}

@end












