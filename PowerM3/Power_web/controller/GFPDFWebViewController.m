//
//  GFPDFWebViewController.m
//  PowerM3
//
//  Created by 顾玉玺 on 2017/1/12.
//  Copyright © 2017年 qymgc. All rights reserved.
//

#import "GFPDFWebViewController.h"

@interface GFPDFWebViewController ()

@property (nonatomic, strong) NSURL *url;

@end

@implementation GFPDFWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];
    
    NSData *data = [NSData dataWithContentsOfURL:self.url];
    
    [webView loadData:data MIMEType:@"application/pdf" textEncodingName:@"UTF-8" baseURL:self.url];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
