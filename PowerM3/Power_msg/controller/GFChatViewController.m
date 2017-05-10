//
//  GFChatViewController.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/7.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFChatViewController.h"
#import "GFChatViewController+CoreData.h"

#import "GFContactMessageRecord+CoreDataProperties.h"
#import "GFContactInformation+CoreDataProperties.h"
#import "NSString+Extension.h"
#import "GFMessageManager.h"
#import "PureLayout.h"
#import "MJRefresh.h"
#import "UIImage+Alisa.h"

#import "GFChatTextTableViewCell.h"
#import "GFChatImageTableViewCell.h"
#import "WSChatVoiceTableViewCell.h"
#import "WSChatTimeTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"

#import "XHVoiceRecordHelper.h"
#import "GFPickerHelper.h"

#import "Mp3Recorder.h"
#import "GFVoiceHUD.h"
#import "ChatKeyBoard.h"
//#import "FaceSourceManager.h"


@interface GFChatViewController ()<ChatKeyBoardDataSource, ChatKeyBoardDelegate,UITableViewDelegate,UITableViewDataSource,Mp3RecorderDelegate>

@property (nonatomic, strong) ChatKeyBoard *chatKeyBoard;
@property (nonatomic, strong) Mp3Recorder *mp3;
@property (nonatomic, strong) GFVoiceHUD *voiceHud;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation GFChatViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToBottom:) name:@"scrollToBottom" object:nil];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self scrollToBottom:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
    [self setUI];
    [self addCurrentContactToMessageList];
}

- (void)setUI{
    self.title = self.gf_Contact.userName;
    
    _mp3 = [[Mp3Recorder alloc]initWithDelegate:self];
    
       _tableView.separatorStyle       =   UITableViewCellSeparatorStyleNone;
    _tableView.keyboardDismissMode  =   UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMsg)];
    
    self.chatKeyBoard = [ChatKeyBoard keyBoard];
    self.chatKeyBoard.delegate = self;
    self.chatKeyBoard.dataSource = self;
    self.chatKeyBoard.placeHolder = @"请输入消息，请输入消息，请输入消息，请输入消息，请输入消息，请输入消息，请输入消息，请输入消息";
    self.chatKeyBoard.associateTableView = self.tableView;
    [self.view addSubview:self.chatKeyBoard];
}

// 添加 联系人 到 最近消息 列表
- (void)addCurrentContactToMessageList{
    GFContactInformation *contact = [GFContactInformation MR_findFirstByAttribute:@"userID" withValue:self.gf_Contact.userID];
    contact.latelyMessage = YES;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
    NSArray *array = [GFContactInformation MR_findByAttribute:@"latelyMessage" withValue:@(YES)];
    
    BLog(@"当前联系人 id:   %@",self.gf_Contact.userID);
    BLog(@"最近消息列表 count: %lu",(unsigned long)array.count);
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    GFContactMessageRecord *model = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    return [tableView fd_heightForCellWithIdentifier:kCellReuseID(model) configuration:^(GFChatBaseTableViewCell* cell){
        cell.model = model;
    }];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   	GFContactMessageRecord * model = (GFContactMessageRecord *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    GFChatBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseID(model) forIndexPath:indexPath];
    cell.model = model;
    return cell;
}


/**
 *  语音状态
 */
- (void)chatKeyBoardDidStartRecording:(ChatKeyBoard *)chatKeyBoard{
    
    
    NSLog(@"start*************************************record");
    [self.voiceHud setHidden:NO];
    [self timer];
    [_mp3 startRecord];
}
- (void)chatKeyBoardDidCancelRecording:(ChatKeyBoard *)chatKeyBoard{
    [self timerInvalue];
    [self.voiceHud setHidden:YES];
    [_mp3 cancelRecord];
}
- (void)chatKeyBoardDidFinishRecoding:(ChatKeyBoard *)chatKeyBoard{
    [self timerInvalue];
    self.voiceHud.hidden = YES;
    [_mp3 stopRecord];
}
- (void)chatKeyBoardWillCancelRecoding:(ChatKeyBoard *)chatKeyBoard{
    [_timer setFireDate:[NSDate distantPast]];
    _voiceHud.image  = [UIImage imageNamed:@"voice_1"];
    
}
- (void)chatKeyBoardContineRecording:(ChatKeyBoard *)chatKeyBoard{
    [_timer setFireDate:[NSDate distantFuture]];
    self.voiceHud.animationImages  = nil;
    self.voiceHud.image = [UIImage imageNamed:@"cancelVoice"];
}

- (void)failRecord{
    [self timerInvalue];
    self.voiceHud.animationImages = nil;
    self.voiceHud.image = [UIImage imageNamed:@"voiceShort"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.voiceHud.hidden = YES;
    });
}
- (void)endConvertWithData:(NSData *)voiceData{
    
}

/**
 *  输入状态
 */
- (void)chatKeyBoardTextViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"text1:    %@",textView.text);

}
- (void)chatKeyBoardSendText:(NSString *)text{
    GFContactMessageRecord *record = [self messageRecord];
    record.chatMessageType = GFChatCellType_Text;
    record.textChatContent = text;
    [GFMessageManager sendingAMessageToContact:self.gf_Contact messageModel:record data:nil completion:^{
        
    } failure:^{
        [GFAlertView alertWithTitle:@"发送失败"];
    }];
}
- (void)chatKeyBoardTextViewDidChange:(UITextView *)textView{
    
}

/**
 * 表情
 */
- (void)chatKeyBoardAddFaceSubject:(ChatKeyBoard *)chatKeyBoard{
    
}
- (void)chatKeyBoardSetFaceSubject:(ChatKeyBoard *)chatKeyBoard{
    
}

- (GFContactMessageRecord *)messageRecord{
     GFContactMessageRecord *record = [GFContactMessageRecord MR_createEntity];
    record.fileID   = [NSString guid];
    record.date     = [NSDate date];
    record.isSender = YES;
    record.contactInfomation = self.gf_Contact;
    return record;
}

/**
 *  更多功能
 */
- (void)chatKeyBoard:(ChatKeyBoard *)chatKeyBoard didSelectMorePanelItemIndex:(NSInteger)index{
    BLog(@"选择  index:  %ld",(long)index);
    if (index == 1) {
        __weak typeof(self)weakself = self;
        [GFPickerHelper pickerImages:self didFinishPicking:^(UIImage *image) {
            
            GFContactMessageRecord *record = [self messageRecord];
            record.chatMessageType = GFChatCellType_Image;
            record.textChatContent = @"[图片]";
            record.imageSize = [weakself scaleImage:image toWidth:200];
            [GFMessageManager sendingAMessageToContact:weakself.gf_Contact messageModel:record  data:UIImagePNGRepresentation(image) completion:^{
                
            } failure:^{
                
            }];
        }];
    }
}


- (NSString *)scaleImage:(UIImage *)image toWidth:(CGFloat)scaleWidth{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGSize size ;
    if (width >scaleWidth) {
        CGFloat scale = width/scaleWidth;
        CGFloat newHeght = height/scale;
        if (newHeght>scaleWidth) {
            CGFloat scale = newHeght/scaleWidth;
            size = CGSizeMake(scaleWidth/scale, scaleWidth);
        }else{
            size = CGSizeMake(scaleWidth, newHeght);
        }
    }else{
        if (height>200) {
            CGFloat scale = height/scaleWidth;
            size = CGSizeMake(width/scale, scaleWidth);
        }else{
            size = CGSizeMake(width, height);
        }
    }
    return NSStringFromCGSize(size);

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)timerInvalue
{
    [_timer invalidate];
    _timer  = nil;
}

- (void)progressChange{
    AVAudioRecorder *recorder = _mp3.recorder ;
    [recorder updateMeters];
    float power= [recorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0,声音越大power绝对值越小
    CGFloat progress = (1.0/160)*(power + 160);
    self.voiceHud.progress = progress;
    NSLog(@"progress:  %f",progress);
}

#pragma mark -- ChatKeyBoardDataSource
- (NSArray<MoreItem *> *)chatKeyBoardMorePanelItems
{
    MoreItem *item1 = [MoreItem moreItemWithPicName:@"sharemore_location" highLightPicName:nil itemName:@"位置"];
    MoreItem *item2 = [MoreItem moreItemWithPicName:@"sharemore_pic" highLightPicName:nil itemName:@"图片"];
    MoreItem *item3 = [MoreItem moreItemWithPicName:@"sharemore_video" highLightPicName:nil itemName:@"拍照"];
    return @[item1, item2, item3];
}
- (NSArray<ChatToolBarItem *> *)chatKeyBoardToolbarItems
{
    ChatToolBarItem *item1 = [ChatToolBarItem barItemWithKind:kBarItemFace normal:@"face" high:@"face_HL" select:@"keyboard"];
    
    ChatToolBarItem *item2 = [ChatToolBarItem barItemWithKind:kBarItemVoice normal:@"voice" high:@"voice_HL" select:@"keyboard"];
    
    ChatToolBarItem *item3 = [ChatToolBarItem barItemWithKind:kBarItemMore normal:@"more_ios" high:@"more_ios_HL" select:nil];
    
    ChatToolBarItem *item4 = [ChatToolBarItem barItemWithKind:kBarItemSwitchBar normal:@"switchDown" high:nil select:nil];
    
    return @[item1, item2, item3, item4];
}

- (NSArray<FaceThemeModel *> *)chatKeyBoardFacePanelSubjectItems
{
    return nil;
}


#pragma mark ------  getter
- (GFVoiceHUD *)voiceHud
{
    if (!_voiceHud) {
        _voiceHud = [[GFVoiceHUD alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
        _voiceHud.hidden = YES;
        [self.view addSubview:_voiceHud];
        _voiceHud.center = CGPointMake(KW/2, KH/2);
    }
    return _voiceHud;
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer =[NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(progressChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

@end
