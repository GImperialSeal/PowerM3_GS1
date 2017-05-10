//
//  GFChatServerDef.h
//  PowerM3
//
//  Created by 顾玉玺 on 2017/3/6.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#ifndef GFChatServerDef_h
#define GFChatServerDef_h

#define kCellReuseIDWithSenderAndType(isSender,chatCellType)    ([NSString stringWithFormat:@"%d-%d",isSender,chatMessageType])

//根据模型得到可重用Cell的 重用ID
#define kCellReuseID(model)  (model.chatMessageType == GFChatCellType_Time)?kTimeCellReusedID:[NSString stringWithFormat:@"%d-%ld",model.isSender,(long)model.chatMessageType]

/**
 *  @brief  消息类型
 */
typedef NS_OPTIONS(NSInteger,GFChatCellType)
{
    GFChatCellType_Text = 1,
    
    GFChatCellType_Image = 2,
    
    GFChatCellType_Audio = 3,
    
    GFChatCellType_Video = 4,
    
    GFChatCellType_Time  = 0
};

#endif /* GFChatServerDef_h */
