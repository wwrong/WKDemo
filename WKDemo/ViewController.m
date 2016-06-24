//
//  ViewController.m
//  WKDemo
//
//  Created by Guan Nan Wang on 16/6/22.
//  Copyright © 2016年 Guan Nan Wang. All rights reserved.
//

#import "ViewController.h"
#import "GNFileManager.h"

@interface ViewController ()
@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) NSURL *htmlURL;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[WKWebView alloc]initWithFrame:self.view.bounds];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    GNFileManager *manager = [GNFileManager sharedfileManager];
    [manager addResources];
    [manager checkResources];

    self.htmlURL = manager.htmlURL;
    NSString *str = [NSString stringWithContentsOfURL:self.htmlURL encoding:NSUTF8StringEncoding error:nil];
    NSString *theS = manager.resourceURL.absoluteString;
    if ([theS hasSuffix:@"/"]) {
        [self.webView loadHTMLString:str baseURL:manager.resourceURL];
    }
    else{
        NSURL *theResource = [NSURL URLWithString:[theS stringByAppendingString:@"/"]];
        [self.webView loadHTMLString:str baseURL:theResource];
    }
    
    
}



- (NSArray*) allFilesAtPath:(NSString*) dirString {
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:10];
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    
    NSArray* tempArray = [fileMgr contentsOfDirectoryAtPath:dirString error:nil];
    
    for (NSString* fileName in tempArray) {
        
        BOOL flag = YES;
        
        NSString* fullPath = [dirString stringByAppendingPathComponent:fileName];
        
        if ([fileMgr fileExistsAtPath:fullPath isDirectory:&flag]) {
            
            if (!flag) {
                
                [array addObject:fullPath];
                
            }
            
        }
        
    }
    
    return array;
}


-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//直接读取文件夹中所有文件    ---accomplished
//新建一个临时目录，里面有备份，move进www文件夹，如果成功删除备份，如果不成功就把备份的拷进www文件夹。

@end
