//
//  GFTabBarController.m
//  PowerM3
//
//  Created by ImperialSeal on 16/12/5.
//  Copyright © 2016年 qymgc. All rights reserved.
//

#import "GFTabBarController.h"
#import "LoginDataSource.h"
#import "GFWebViewController.h"
#import "GFSettingViewController.h"
#import "GFMenuViewController.h"
#import "GFDrawViewController.h"
#import "GFCommonHelper.h"
#import "GFConversationListViewController.h"
#import "GFRCloudHelper.h"
#import "GFBaseNavigationController.h"
@interface GFTabBarController ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UINavigationController *menuNavigationController;
@property (nonatomic, strong) GFWebViewController  *projecCentertWebViewController;
@property (nonatomic) BOOL showPorjectList;
@end

static NSInteger _selectedIndex;// 默认显示 tabbar index

@implementation GFTabBarController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    BLog(@"will appear");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickedMenuNavigationItem) name:@"reloadWebView" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}






- (void)viewDidLoad {
    [super viewDidLoad];
    
    BLog(@"did load");

    self.view.backgroundColor = [UIColor whiteColor];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:GFThemeColor} forState:UIControlStateSelected];
    // 登录
    
    if (![GFCommonHelper lookupWebViewCookieDeleteOrNot:NO]) {
        // 本地cookie 失效 重新调用登录的接口
        
        BLog(@"*********  login ***********");

         [self autoLogin];
    }else{
        __weak typeof(self)weakself = self;
        [GFCommonHelper validateCookieSessionidCompletion:^{
            [weakself addControllers];
        }];
    }
    

    // 链接融云
     [self connectRCloud];
}


// 导航 添加项目按钮
- (void)ShowLeftNavigationItem:(UIViewController *)controller{
    UIView *wrapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickedMenuNavigationItem)];
    [wrapView addGestureRecognizer:tap];
    UIImageView *leftBarIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_menu"]];
    leftBarIcon.tag = 1002;
    [wrapView addSubview:leftBarIcon];
    controller.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:wrapView];
    GFDrawViewController *drawViewController =  (GFDrawViewController *)self.parentViewController;
    drawViewController.clickedMaskView = ^{
        leftBarIcon.transform = CGAffineTransformIdentity;
    };
}

#pragma mark - click func
- (void)didClickedMenuNavigationItem{
    static BOOL selected = YES;
    UIImageView *barIcon = [self.view viewWithTag:1002];
    GFDrawViewController *drawViewController =  (GFDrawViewController *)self.parentViewController;
    if (selected) {
        barIcon.transform = CGAffineTransformMakeRotation(M_PI_2);
        [drawViewController showShowMenuViewControllerWithAnimation];
    }else{
        barIcon.transform = CGAffineTransformIdentity;
        [drawViewController dismiss];
    }
    selected = !selected;
}






#pragma mark ----- 登录
- (void)autoLogin{
    __weak typeof(self) weakSelf = self;
    NSString *userName = [GFCommonHelper currentWebSite].admin;
    NSString *code     = [GFCommonHelper currentWebSite].password;
    
    assert(userName.length);
    
    [MBProgressHUD showMessag:@"正在登录...." toView:self.view];
    [GFCommonHelper login:userName code:code completion:^(LoginSuccessedDataSource *obj) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf addControllers];
    }failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        [GFAlertView showAlertWithTitle:@"提示" message:[GFDomainError localizedDescription:error] completionBlock:^(NSUInteger buttonIndex, GFAlertView *alertView) {
            if (buttonIndex == 0) {
                [GFNotification postNotificationName:@"LoginOrNot" object:@(NO)];
            }else{
                [weakSelf autoLogin];
            }
        } cancelButtonTitle:@"重新登录" otherButtonTitles:@"重试",nil];
    }];
}

// 加载 tabbar controllers
- (void)addControllers{
    __weak typeof (self)weakself = self;
    
    [MBProgressHUD showMessag:@"加载数据...." toView:self.view];
    [GFNetworkHelper GET:WebViewURL parameters:nil success:^(id responseObject) {
        [MBProgressHUD hideHUDForView:weakself.view animated:YES];
        if (![responseObject[@"success"] boolValue]) {
            [weakself showAlert];
        }else{
            NSError *jsonErr;
            NSArray *buttonItems = [NSJSONSerialization JSONObjectWithData:[responseObject[@"data"][@"app_mainbutton"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&jsonErr];
            if (jsonErr) {
                [weakself showAlert];
                return ;
            }else{
                _selectedIndex = [responseObject[@"data"][@"selectedIndex"] integerValue];
                [weakself loadTabbar:buttonItems];
            }
        }
    } failure:^(NSError *err) {
        [MBProgressHUD hideHUDForView:weakself.view animated:YES];
        [weakself showAlert];}
     ];
}


- (void)showAlert{
    [GFAlertView showAlertWithTitle:@"提示" message:@"数据加载失败..." completionBlock:^(NSUInteger buttonIndex, GFAlertView *alertView) {
        if (buttonIndex == 0) {
            [GFNotification postNotificationName:@"LoginOrNot" object:@(NO)];
        }else{
            [self addControllers];
        }
    } cancelButtonTitle:@"重新登录" otherButtonTitles:@"重试",nil];
}

// set UI
- (void)loadTabbar:(NSArray *)buttonItems{
    BLog(@"thread: %@",[NSThread currentThread]);
    
    NSMutableArray *navigationControllerArray = [NSMutableArray array];
    
    for (int i = 0; i<buttonItems.count; i++) {
        NSDictionary *dic = buttonItems[i];
        LoginWebViewURL *model = [[LoginWebViewURL alloc]initWithJsonDict:dic];
        [model replaceEpsProjIdOrHumainId];
        
        UIViewController *controller = nil;
        controller.view.tag = i+100;
        if (i<buttonItems.count-2) {
            controller = [[GFWebViewController alloc]init];
            [controller setValue:model.url forKey:@"url"];
            if (i==0) {
                [self ShowLeftNavigationItem:controller];
                [[NSUserDefaults standardUserDefaults] setValue:model.titleid forKey:@"epsprojid"];
                [GFCommonHelper websiteSetValue:model.title forKey:@"epsprojectID"];
            }
        }else if(i == buttonItems.count-2){
            controller = [[GFConversationListViewController alloc]init];
        }else{
            
            controller = MAINSTORYBOARD(@"GFVoiceRecordViewController");
            //controller = [[GFSettingViewController alloc]init];
        }
        controller.navigationItem.title = model.title;
        
        UIImage *normal = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.icon]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *select = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.iconselected]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        controller.tabBarItem = [[UITabBarItem alloc]initWithTitle:model.name image:normal selectedImage:select];
        GFBaseNavigationController *navigationController  = [[GFBaseNavigationController alloc]initWithRootViewController:controller];
        [navigationController setNavigationBarItemColor:GFThemeColor];
        [navigationControllerArray addObject:navigationController];
        // 设置导航条样式
        navigationController.navigationBar.barStyle = UIBarStyleDefault;
    }
    self.viewControllers = navigationControllerArray;
    self.selectedIndex = _selectedIndex;
}

#pragma mark ----- 链接融云
- (void)connectRCloud{
    
    GFWebsiteCoreDataModel *coredataInfo = [GFCommonHelper currentWebSite];
    RCUserInfo *userinfo = [[RCUserInfo alloc] initWithUserId:coredataInfo.humanID name:coredataInfo.name portrait:coredataInfo.headImage];
    
    BLog(@" user id: %@ ",coredataInfo.humanID);
    [GFNetworkHelper POST:GetRongCloudToken parameters:@{@"userid":coredataInfo.humanID,@"name":@"",@"portraituri":coredataInfo.headImage} success:^(id responseObject) {
        [[GFRCloudHelper shareInstace] loginRongCloudWithUserInfo:userinfo withToken:responseObject[@"token"]];
        
    } failure:^(NSError *error) {
        
        BLog(@"error: %@",error.description);
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
