//
//  GFChatTableViewCell.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/7.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFChatTableViewCell.h"
#import "GFContactMessageRecord+CoreDataProperties.h"
#import "GFContactInformation+CoreDataProperties.h"
#import <objc/runtime.h>
#import "UIImage+Alisa.h"
#import "UIButton+GFWebCache.h"
#define padding  8
#define headButtonHeight 40

@implementation GFChatTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    GFChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    if (!cell) {
        cell = [[self alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.headButton = [[UIButton alloc]init];
        self.bodyButton = [[UIButton alloc]init];
        
        self.bodyButton.titleLabel.numberOfLines = 0;
        self.bodyButton.titleEdgeInsets = UIEdgeInsetsMake(10, 12, 10, 12);
        [self.headButton addTarget:self action:@selector(didClickedHeadButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.bodyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        self.headButton.layer.masksToBounds = YES;
        self.headButton.layer.cornerRadius = 20;
        [self.contentView addSubview:self.headButton];
        [self.contentView addSubview:self.bodyButton];
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return self;
}

- (void)setMessageRecordModel:(GFContactMessageRecord *)messageRecordModel{
    _messageRecordModel = messageRecordModel;
    if (messageRecordModel.chatMessageType == 0) {
        [self.bodyButton setTitle:messageRecordModel.textChatContent forState:UIControlStateNormal];
    }else if(messageRecordModel.chatMessageType == 1){
        [self.bodyButton gf_loadImagesWithURL:messageRecordModel.textChatContent];
        BLog(@"------------>%@", messageRecordModel.textChatContent);
    }else{
        
    }
    [self layoutGFChatTableViewCellSubViewsFrameWithMessage:messageRecordModel];
}


#pragma mark - 设置frame
- (void)layoutGFChatTableViewCellSubViewsFrameWithMessage:(GFContactMessageRecord *)messageRecordModel{
    BOOL isSender = messageRecordModel.isSender;
    CGSize size ;
    if (messageRecordModel.chatMessageType == 0) {
        size = [self.bodyButton.titleLabel sizeThatFits:CGSizeMake(300, 1000)];
    }else if(messageRecordModel.chatMessageType == 1){
        size = [self.bodyButton.currentImage gf_scaleImageToWidth:120].size;
        BLog(@"bodyButton  current image:%@ ",self.bodyButton.currentImage);
        [self.bodyButton addTarget:self action:@selector(clickButtonTypeWithImages:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        size = CGSizeMake(100-24, 60-20);
        [self.bodyButton addTarget:self action:@selector(clickButtonTypeWithVoices:) forControlEvents:UIControlEventTouchUpInside];
        self.bodyButton.imageView.animationDuration = 1;
        self.bodyButton.imageView.animationRepeatCount = 0;
    }

    if (!isSender) {

        [self leftMessageContent:size];
    }else{
        [self rightMessageContent:size];
    }
    
    objc_setAssociatedObject(messageRecordModel, @"cellRowHeight", @(size.height+20 + 16), OBJC_ASSOCIATION_RETAIN);

}

//TODO:  设置 消息类型
- (void)leftMessageContent:(CGSize )bodyButtonSize{
    self.bodyButton.imageEdgeInsets = UIEdgeInsetsMake(10, 20, 20, 15);
    self.headButton.frame = CGRectMake(padding, padding, headButtonHeight, headButtonHeight);
    
    UIImage *image = [UIImage imageNamed:@"weChatBubble_Receiving_Solid"];
    [self.bodyButton setBackgroundImage:[image stretchableImageWithLeftCapWidth:30 topCapHeight:30] forState:UIControlStateNormal];
    if (self.messageRecordModel.chatMessageType == 3) {
        [self.bodyButton setImage:[UIImage imageNamed:@"ReceiverVoiceNodePlaying"] forState:UIControlStateNormal];
        self.bodyButton.imageView.animationImages = @[
      [UIImage imageNamed:@"ReceiverVoiceNodePlaying000"],
      [UIImage imageNamed:@"ReceiverVoiceNodePlaying001"],
      [UIImage imageNamed:@"ReceiverVoiceNodePlaying002"],
      [UIImage imageNamed:@"ReceiverVoiceNodePlaying003"]];
    }else{
        
    }
    self.bodyButton.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 20, 15);
    self.bodyButton.frame = CGRectMake(CGRectGetMaxX(self.headButton.frame)+padding, padding, bodyButtonSize.width+35, bodyButtonSize.height+30);
   
}

//TODO:  设置 消息类型

- (void)rightMessageContent:(CGSize )bodyButtonSize{

    self.headButton.frame = CGRectMake(KW-headButtonHeight-padding, padding, headButtonHeight, headButtonHeight);
    


    UIImage *image = [UIImage imageNamed:@"weChatBubble_Sending_Solid"];
    [self.bodyButton setBackgroundImage:[image stretchableImageWithLeftCapWidth:30 topCapHeight:30] forState:UIControlStateNormal];
    if (self.messageRecordModel.chatMessageType == 1) {
        [self.bodyButton setImage:[UIImage imageNamed:@"SenderVoiceNodePlaying"] forState:UIControlStateNormal];
        self.bodyButton.imageView.animationImages = @[
          [UIImage imageNamed:@"SenderVoiceNodePlaying000"],
          [UIImage imageNamed:@"SenderVoiceNodePlaying001"],
          [UIImage imageNamed:@"SenderVoiceNodePlaying002"],
          [UIImage imageNamed:@"SenderVoiceNodePlaying003"]];
    }else{
        
    }
    self.bodyButton.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 20, 15);
    self.bodyButton.frame = CGRectMake(CGRectGetMinX(self.headButton.frame)-bodyButtonSize.width-24, padding, bodyButtonSize.width+35, bodyButtonSize.height+30);
    
}

#pragma mark - click   头像 / vioce button
- (void)clickButtonTypeWithVoices:(UIButton *)voiceButton{
    [voiceButton.imageView startAnimating];
    
    NSLog(@"----------------------点击voices");
}

- (void)clickButtonTypeWithImages:(UIButton *)imageButton{
    NSLog(@"----------------------点击images");

}


- (void)didClickedHeadButton:(UIButton *)headButton{
    NSLog(@"----------------------点击头像");
}


#pragma mark - 缩放图片
- (CGSize )scaleImage:(UIImage *)image width:(CGFloat)scaleWidth{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGSize size ;
    if (width >200) {
        CGFloat scale = width/200;
        CGFloat newHeght = height/scale;
        if (newHeght>200) {
            CGFloat scale = newHeght/200;
            size = CGSizeMake(200/scale, 200);
        }else{
            size = CGSizeMake(200, newHeght);
        }
    }else{
        if (height>200) {
            CGFloat scale = height/200;
            size = CGSizeMake(width/scale, 200);
        }else{
            size = CGSizeMake(width, height);
        }
    }
    return size;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
