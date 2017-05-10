//
//  NSString+Extension.h
//  BasicFramework
//
//  Created by Rainy on 16/10/26.
//  Copyright © 2016年 Rainy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@interface NSString (Extension)

// 判断空字符
+ (BOOL)isNULL:(id)string;
- (BOOL)isChinese;
- (BOOL)isEmail;
- (BOOL)isPhoneNumber;
- (BOOL)isCarNumber;
- (BOOL)isDigit;//数字
- (BOOL)isNumeric;//数字
- (BOOL)isUrl;
- (BOOL)isMinLength:(NSUInteger)length;
- (BOOL)isMaxLength:(NSUInteger)length;
- (BOOL)isMinLength:(NSUInteger)min andMaxLength:(NSUInteger)max;
- (BOOL)isEmpty;
- (BOOL)isPureInt:(NSString*)string;
- (BOOL)isPureFloat:(NSString*)string;




// 计算字符串 高度
- (CGSize)sizeWithFont:(UIFont *)font;
- (CGSize)sizeWithFont:(UIFont *)font andMaxW:(CGFloat)maxW;

//构造URL,如果没有http前缀,则添加http://
- (NSString *)HTTPURLFromString;

// 根据汉字字符串, 返回大写拼音首字母
- (NSString *)getFirstLetter;
- (NSString *)getPinyin;


/*!
 注意：中英文输出样式不一样，如果有国际化的请注意输出样式，
 本样式为中文输出环境，模拟器可能输出为英文样式
 */

/*! 手机号码格式化样式：344【中间空格】，示例：13855556666 --> 138 5555 6666 */
+ (NSString *)ba_phoneNumberFormatterSpace:(NSString *)phoneNumber;

/*! 手机号码格式化样式：3*4【中间4位为*】，示例：13855556666 --> 138****6666 */
+ (NSString *)ba_phoneNumberFormatterCenterStar:(NSString *)phoneNumber;

/*! 数字格式化样式，示例：12345678.89 --> 12,345,678.89 */
+ (NSString *)ba_stringFormatterWithStyle:(NSNumberFormatterStyle)numberStyle numberString:(NSString *)numberString;

/*! 格式化为带小数点的数字，示例：12345678.89 --> 12,345,678.89 */
+ (NSString *)ba_stringFormatterWithDecimalStyleWithNumberString:(NSString *)numberString;

/*! 格式化为货币样式，示例：12345678.89 --> 12,345,678.89 */
+ (NSString *)ba_stringFormatterWithCurrencyStyleWithNumberString:(NSString *)numberString;

/*! 格式化为百分比样式，示例：12345678.89 --> 1,234,567,889% */
+ (NSString *)ba_stringFormatterWithPercentStyleWithNumberString:(NSString *)numberString;

/*! 格式化为科学计数样式，示例：12345678.89 --> 1.234567889E7 */
+ (NSString *)ba_stringFormatterWithScientificStyleWithNumberString:(NSString *)numberString;

/*! 格式化为英文输出样式（注：此处根据系统语言输出），示例：12345678.89 --> 一千二百三十四万五千六百七十八点八九 */
+ (NSString *)ba_stringFormatterWithSpellOutStyleWithNumberString:(NSString *)numberString;

/*! 格式化为序数样式，示例：12345678.89 --> 第1234,5679 */
+ (NSString *)ba_stringFormatterWithOrdinalStyleWithNumberString:(NSString *)numberString;
// 给金额字符串添加分割标示，例：33，345，434.98

+ (NSString *)ResetAmount:(NSString *)Amount_str segmentation_index:(int)segmentation_index segmentation_str:(NSString *)segmentation_str;

/*! 格式化为四舍五入样式，示例：12345678.89 --> 12,345,679 */
+ (NSString *)ba_stringFormatterWithCurrencyISOCodeStyleWithNumberString:(NSString *)numberString;

/*! 格式化为货币多样式，示例：12345678.89 --> USD 12,345,678.89 */
+ (NSString *)ba_stringFormatterWithCurrencyPluralStyleWithNumberString:(NSString *)numberString;

/*! 保留纯数字 */
- (NSString *)ba_removeStringSaveNumber;







//根据当前语言国际化
+ (NSString *)LanguageInternationalizationCH:(NSString *)Chinese EN:(NSString *)English;

//掉头反转字符串
- (NSString *)StringReverse;

// 编码反编码
- (NSString *)EncodingString;
- (NSString *)RemovingEncoding;
- (NSString *)base64Decode;
- (NSString *)base64Encoding;
/**
 *  创建一个MD5字符串
 */
- (NSString *)MD5string;
- (NSString *)SHA1;
- (NSString *)SHA256;
- (NSString *)SHA512;
+ (NSString *)guid;



// 把JSON格式的字符串转换成字典
- (NSDictionary *)StringOfJsonConversionDictionary;

// 字符串添加图片
- (NSMutableAttributedString *)insertImg:(UIImage *)Img atIndex:(NSInteger )index IMGrect:(CGRect )IMGrect;

//不同颜色不同字体大小字符串
- (NSMutableAttributedString *)setOtherColor:(UIColor *)Color font:(CGFloat)font forStr:(NSString *)forStr;
// 在文字上添加删除线（例如过去的价格）
- (NSAttributedString *)AddRemoveLineOnStringRange:(NSRange )range lineWidth:(NSInteger )lineWidth;
// 给button底部文字划线
+ (void)stringToBeUnderlineWithRange:(NSRange)range button:(UIButton *)btn lineColor:(UIColor *)color controlstate:(UIControlState)state;


@end
