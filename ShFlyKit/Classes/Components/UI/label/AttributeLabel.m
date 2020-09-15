//
//  AttributeLabel.m
//  AFNetworking
//
//  Created by hsh on 2018/12/6.
//

#import "AttributeLabel.h"
#import <CoreText/CoreText.h>


//范围模型
@interface AttributeRange : NSObject
@property(nonatomic,assign)NSInteger startIndex;        //匹配出来的起点
@property(nonatomic,assign)NSInteger endIndex;          //匹配出来的终点
@property(nonatomic,copy)NSString *content;             //匹配对应的内容
@end


@interface AttributeLabel ()
@property(nonatomic,copy)NSMutableArray *compareArray;
@end


@implementation AttributeLabel


-(void)setContent:(NSString *)content config:(AttributeConfig*)config{
    //没有区间不处理
    if (config.startStr == nil || config.endStr == nil) {
        self.text = content;
        return;
    }
    _compareArray = [NSMutableArray array];
    self.numberOfLines = 0;
    //没有数据的时候防崩溃
    config.replaceStart = config.replaceStart ? config.replaceStart : config.startStr;
    config.replaceEnd = config.replaceEnd ? config.replaceEnd : config.endStr;
    config.elements.hightFont = config.elements.hightFont ? config.elements.hightFont : config.elements.normalFont;
    //生成首尾替换字符串
    NSMutableString *startReplaceStr = [NSMutableString string];
    for (NSInteger i = 0; i < config.replaceStart.length; i+=1) {
        [startReplaceStr appendString:@"X"];
    }
    NSMutableString *endReplaceStr = [NSMutableString string];
    for (NSInteger i = 0; i < config.replaceEnd.length; i+=1) {
        [endReplaceStr appendString:@"Y"];
    }
    //先替换字符串
    content = [content stringByReplacingOccurrencesOfString:config.startStr withString:config.replaceStart];
    content = [content stringByReplacingOccurrencesOfString:config.endStr withString:config.replaceEnd];
    //中间物
    NSString *copyStr = content;
    //循环获取位置
    while ([copyStr rangeOfString:config.replaceStart].location != NSNotFound)
    {
        AttributeRange *model = [[AttributeRange alloc]init];
        //起点的位置
        NSRange startRange = [copyStr rangeOfString:config.replaceStart];
        model.startIndex = startRange.location;
        model.endIndex = startRange.location;
        copyStr = [copyStr stringByReplacingCharactersInRange:NSMakeRange(startRange.location, startRange.length) withString:startReplaceStr];
        //获取末尾的位置
        if ([copyStr rangeOfString:config.replaceEnd].location != NSNotFound) {
            NSRange endRange = [copyStr rangeOfString:config.replaceEnd];
            model.endIndex = endRange.location;
            copyStr = [copyStr stringByReplacingCharactersInRange:NSMakeRange(endRange.location, endRange.length) withString:endReplaceStr];
        }
        if (model.startIndex != model.endIndex) {
            [_compareArray addObject:model];
        }
    }
    //生成对应字符串
    for (AttributeRange *range in _compareArray) {
        NSString *sub = [content substringWithRange:NSMakeRange(range.startIndex,range.endIndex-range.startIndex+1)];
        if (config.containsRange == NO) {
            sub = [sub stringByReplacingOccurrencesOfString:config.replaceStart withString:@""];
            sub = [sub stringByReplacingOccurrencesOfString:config.replaceEnd withString:@""];
        }
        range.content = sub;
    }
    //属性字符串生成
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc]init];
    for (NSInteger index = 0; index < content.length; index += 1) {
        NSString *sub = [content substringWithRange:NSMakeRange(index, 1)];
        AttributeRange *range = [self rangeOfindex:index compareType:config.containsRange ? 0 : 1];
        if (range) {
            NSMutableAttributedString *attri = [[NSMutableAttributedString alloc]initWithString:sub attributes:@{NSForegroundColorAttributeName:config.elements.hightColor,NSFontAttributeName:config.elements.hightFont}];
            [attriStr appendAttributedString:attri];
            if (config.elements.bottomLine) {
                [attri addAttributes:@{NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],NSBaselineOffsetAttributeName : @(NSUnderlineStyleSingle)} range:NSMakeRange(0, attri.length)];
            }
        }else{
            NSAttributedString *attri = [[NSAttributedString alloc]initWithString:sub attributes:@{NSForegroundColorAttributeName:config.elements.normalColor,NSFontAttributeName:config.elements.normalFont}];
            [attriStr appendAttributedString:attri];
        }
    }
    //属性字符串赋值
    self.attributedText = attriStr;
    //需要添加点击事件
    if (_compareArray.count) {
        //添加点击事件
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureClick:)];
        [self addGestureRecognizer:tap];
    }
}



-(void)setContent:(NSString *)content compares:(NSArray<NSString *> *)compares config:(AttributeConfig *)config{
    _compareArray = [NSMutableArray array];
    self.numberOfLines = 0;
    //获取对应字符串
    for (NSString *subStr in compares) {
        NSRange range = [content rangeOfString:subStr];
        NSString *rangeStr = [content substringWithRange:range];
        AttributeRange *model = [[AttributeRange alloc]init];
        model.startIndex = range.location;
        model.endIndex = range.location + range.length;
        if (config.containsRange == NO) {
            if (config.replaceStart) {
                rangeStr = [rangeStr stringByReplacingOccurrencesOfString:config.replaceStart withString:@""];
            }
            if (config.replaceEnd) {
                rangeStr = [rangeStr stringByReplacingOccurrencesOfString:config.replaceEnd withString:@""];
            }
        }
        model.content = rangeStr;
        [_compareArray addObject:model];
    }
    //属性字符串生成
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc]init];
    for (NSInteger index = 0; index < content.length; index += 1) {
        NSString *sub = [content substringWithRange:NSMakeRange(index, 1)];
        AttributeRange *range = [self rangeOfindex:index compareType:2];
        if (range) {
            NSMutableAttributedString *attri = [[NSMutableAttributedString alloc]initWithString:sub attributes:@{NSForegroundColorAttributeName:config.elements.hightColor,NSFontAttributeName:config.elements.hightFont}];
            if (config.elements.bottomLine) {
                [attri addAttributes:@{NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],NSBaselineOffsetAttributeName : @(NSUnderlineStyleSingle)} range:NSMakeRange(0, attri.length)];
            }
            [attriStr appendAttributedString:attri];
        }else{
            NSAttributedString *attri = [[NSAttributedString alloc]initWithString:sub attributes:@{NSForegroundColorAttributeName:config.elements.normalColor,NSFontAttributeName:config.elements.normalFont}];
            [attriStr appendAttributedString:attri];
        }
    }
    //属性字符串赋值
    self.attributedText = attriStr;
    //需要添加点击事件
    if (_compareArray.count) {
        //添加点击事件
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureClick:)];
        [self addGestureRecognizer:tap];
    }
    
}












//判断是否是边缘 0闭区间 1开区间 2前闭后开
-(AttributeRange*)rangeOfindex:(NSInteger)index compareType:(NSInteger)type{
    for (AttributeRange *range in _compareArray) {
        if (type == 0) {
            if (index >= range.startIndex && index <= range.endIndex) {
                return range;
            }
        }else if(type == 1){
            if (index > range.startIndex && index < range.endIndex) {
                return range;
            }
        }else if (type == 2){
            if (index >= range.startIndex && index < range.endIndex) {
                return range;
            }
        }
    }
    return nil;
}



//触摸点击
-(void)tapGestureClick:(UITapGestureRecognizer*)recognizer{
    CGPoint point = [recognizer locationInView:self];
    [self touchPoint:point];
}



//通过触摸点识别字符位置
- (void)touchPoint:(CGPoint)p
{
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedText);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    CTFrameRef  frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.attributedText.length), path, NULL);
    CFRange     range = CTFrameGetVisibleStringRange(frame);
    if (self.attributedText.length > range.length) {
        UIFont *font = nil;
        if ([self.attributedText attribute:NSFontAttributeName atIndex:0 effectiveRange:nil]) {
            font = [self.attributedText attribute:NSFontAttributeName atIndex:0 effectiveRange:nil];
        } else if (self.font){
            font = self.font;
        } else {
            font = [UIFont systemFontOfSize:17];
        }
        CGPathRelease(path);
        path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height + font.lineHeight));
        frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    }
    CFArrayRef  lines = CTFrameGetLines(frame);
    CFIndex     count = CFArrayGetCount(lines);
    NSInteger   numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines,count) : count;
    if (!numberOfLines) {
        CFRelease(frame);
        CFRelease(framesetter);
        CGPathRelease(path);
        return;
    }
    CGPoint origins[count];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), origins);
    
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.f, -1.f);;
    CGFloat verticalOffset = 0;
    
    for (CFIndex i = 0; i < numberOfLines; i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        CGFloat ascent = 0.0f;
        CGFloat descent = 0.0f;
        CGFloat leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat height = ascent + fabs(descent*2) + leading;
        
        CGRect flippedRect = CGRectMake(p.x, p.y , width, height);
        CGRect rect = CGRectApplyAffineTransform(flippedRect, transform);
        
        rect = CGRectInset(rect, 0, 0);
        rect = CGRectOffset(rect, 0, verticalOffset);
        
        NSParagraphStyle *style = [self.attributedText attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:nil];
        
        CGFloat lineSpace;
        if (style) {
            lineSpace = style.lineSpacing;
        } else {
            lineSpace = 0;
        }
        
        CGFloat lineOutSpace = (self.bounds.size.height - lineSpace * (count - 1) -rect.size.height * count) / 2;
        rect.origin.y = lineOutSpace + rect.size.height * i + lineSpace * i;
        
        if (CGRectContainsPoint(rect, p)) {
            CGPoint relativePoint = CGPointMake(p.x, p.y);
            CFIndex index = CTLineGetStringIndexForPosition(line, relativePoint);
            CGFloat offset;
            CTLineGetOffsetForStringIndex(line, index, &offset);
            
            if (offset > relativePoint.x) {
                index = index - 1;
            }
            //找出对应的范围
            for (int j = 0; j < self.compareArray.count; j++) {
                AttributeRange *range = self.compareArray[j];
                if (index > range.startIndex && index < range.endIndex) {
                    if (_delegate) {
                        [_delegate clickForText:range.content];
                    }
                }
            }
        }
    }
    CFRelease(frame);
    CFRelease(framesetter);
    CGPathRelease(path);
}

@end















@implementation AttributeConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.elements = [[AttributeElements alloc]init];
    }
    return self;
}
@end


@implementation AttributeElements

-(void)setNormalFont:(UIFont *)normalFont{
    _normalFont = normalFont;
    _hightFont = normalFont;
}

@end


@implementation AttributeRange
@end
