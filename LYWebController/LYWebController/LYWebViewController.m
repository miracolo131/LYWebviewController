//
//  LYWebViewController.m
//  LYWebController
//
//  Created by 刘毅 on 2017/8/3.
//  Copyright © 2017年 halohily. All rights reserved.
//

#import "LYWebViewController.h"
#import "UIWebView+Jianshu.h"
#import "AvatorViewController.h"
#import "LYIconfont.h"

@interface LYWebViewController ()<UIWebViewDelegate>
{
    NSUInteger pages;
}
//首页的URL
@property (copy) NSURL *URL;
//VC的webview
@property (nonatomic, strong) UIWebView *webview;
//导航栏的返回按钮
@property (nonatomic, strong) UIBarButtonItem *backBtn;
//导航栏的关闭按钮
@property (nonatomic, strong) UIBarButtonItem *closeBtn;
//导航栏右侧按钮
@property (nonatomic, strong) UIBarButtonItem *rightBtn;

//标记webview一次载入后左侧按钮是否设置完成（因为若为简书效果，本站域名不显示关闭按钮的话，需要根据域名host判断，而每次会有两条request，后一条request为cookies）
@property (nonatomic, assign) BOOL backClicked;

@end

@implementation LYWebViewController

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super init];
    self.URL = URL;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewSubs];
//    [self.webview loadRequest:[NSURLRequest requestWithURL:self.URL]];
//    因为模仿简书风格，所以url默认为简书的一篇文章。否则使用注释掉的上一句代码，使用vc初始化时的url
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.jianshu.com/p/a7b0d6c630d3"]]];
//    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationItem setHidesBackButton:YES animated:NO];
}
#pragma mark VC setup
- (void)setupViewSubs
{
//    页面计数器初始化为1
    pages = 1;
    UIWebView *myWebview = [[UIWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:myWebview];
//    设置webview的个性化UI
    [myWebview setupJianshuUI];
    myWebview.delegate = self;
//    手动设置webview页码计数方式，默认为不计数
    myWebview.paginationMode = UIWebPaginationModeTopToBottom;
    self.webview = myWebview;
    [self setLeftBarButtonItemByRequest:NULL];
    [self setRightBarButtonItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//导航栏左侧按钮的显示设置
- (void)setLeftBarButtonItemByRequest:(nullable NSURLRequest *)request
{
//    若为简书域名，则只显示返回按钮
    if ([request.URL.host isEqualToString:@"www.jianshu.com"] || [request.URL.host isEqualToString:@"cookie.pingxx.com"])
    {
        self.navigationItem.leftBarButtonItems = @[self.backBtn];
        return;
    }
    if (self.webview.canGoForward && self.webview.canGoBack)
    {
//        若为可返回状态，则显示返回、关闭两个按钮
        self.navigationItem.leftBarButtonItems = @[self.backBtn,self.closeBtn];
    }
}

- (void)setRightBarButtonItem
{
    self.navigationItem.rightBarButtonItem = self.rightBtn;
}
#pragma mark private methods
//导航栏返回按钮点击事件
- (void)backBtnClicked
{
//    若为不可返回状态，返回按钮事件为页面退出
    if (!self.webview.canGoBack)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
//    可返回状态下，网页返回到前一页
    [self.webview goBack];
    pages-=2;
}
/*
导航栏关闭按钮点击事件
因为UIWebview没有提供返回首页的方法，所以这里采用记录页数然后手动返回的方式
连续调用n次goBack方法，运行效果和直接返回到首页肉眼无差，非常神奇，有待探究   TODO：：：why
*/
- (void)closeBtnClicked
{
    for(int i = 0; i < pages; i++)
    {
        if (self.webview.canGoBack)
        {
            [self.webview goBack];
        }
    }
    self.navigationItem.leftBarButtonItems = @[self.backBtn];
    [self homePageTitleReset];
}

- (void)rightBtnClicked
{
    
}
//首页title置空
- (void)homePageTitleReset
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.title = NULL;
    });
}
#pragma mark lazy load
- (UIBarButtonItem *)backBtn
{
    if (!_backBtn)
    {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        UIButton *backBtn = [LYIconfont LYIconfontButtonWithFrame:backView.frame code:@"\U0000e720" color:NavGary size:28.0];
        [backBtn addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:backBtn];
        UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithCustomView:backView];
        _backBtn = back;
    }
    return _backBtn;
}

- (UIBarButtonItem *)closeBtn
{
    if (!_closeBtn)
    {
        UIView *closeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        UIButton *closeBtn = [LYIconfont LYIconfontButtonWithFrame:closeView.frame code:@"\U0000e6e9" color:NavGary size:25.0];
        [closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [closeView addSubview:closeBtn];
        UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithCustomView:closeView];
        _closeBtn = close;
    }
    return _closeBtn;
}

- (UIBarButtonItem *)rightBtn
{
    if (!_rightBtn)
    {
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        UIButton *rightBtn = [LYIconfont LYIconfontButtonWithFrame:rightView.frame code:@"\U0000e8c4" color:NavGary size:28.0];
        [rightBtn addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [rightView addSubview:rightBtn];
        UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:rightView];
        _rightBtn = right;
    }
    return _rightBtn;
}
#pragma mark webview delegate
//webview每次load一个url之前调用，返回是否确定load此链接。在此处利用url的host、query等信息，可作特殊操作处理，比如，跳转至原生页面等
//此方法在调用goBack方法时也会触发
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"the url:::%@",request.URL);
//    页面计数增加
    pages++;
//    设置导航栏左侧按钮
    [self setLeftBarButtonItemByRequest:request];
    
    NSURL *destinationURL = request.URL;
    NSString *URLQuery = destinationURL.query;
//    简书点击文章中头像时跳转至原生页面。此处利用头像链接中的一个参数作判断
    if ([URLQuery containsString:@"utm_medium=note-author-link"])
    {
        NSLog(@"我跳转到个人主页啦");
        AvatorViewController *avatorVC = [[AvatorViewController alloc] init];
        [self.navigationController pushViewController:avatorVC animated:YES];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
//webview页面载入完成时触发。调用goBack也会触发
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *host = webView.request.URL.host;
    //    若为第三方页面，显示title
    if (![host isEqualToString:@"www.jianshu.com"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.title = [webView getPageTitle];
        });
    }
    //    若为简书域名下的页面，不显示title
    else
    {
        [self homePageTitleReset];
    }
    
}
@end
