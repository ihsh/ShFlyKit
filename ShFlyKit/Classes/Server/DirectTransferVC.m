//
//  DirectTransferVC.m
//  SHKit
//
//  Created by hsh on 2020/4/29.
//  Copyright © 2020 hsh. All rights reserved.
//

#import "DirectTransferVC.h"
#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "SystemInfo.h"
@import Masonry;


@interface DirectTransferVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)HTTPServer *server;
@property(nonatomic,strong)UILabel *ipLabel;            //Ip地址
@property(nonatomic,strong)UITableView *listView;       //列表视图
@property(nonatomic,strong)NSMutableArray *dataSource;  //文件名称
@property(nonatomic,strong)NSMutableArray *filePaths;   //文件路径
@end


@implementation DirectTransferVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //背景色
    self.view.backgroundColor = UIColor.whiteColor;
    //数组初始化
    self.dataSource = [NSMutableArray array];
    self.filePaths = [NSMutableArray array];
    //Ip地址显示
    self.ipLabel = [[UILabel alloc]init];
    self.ipLabel.textColor = UIColor.blackColor;
    [self.view addSubview:self.ipLabel];
    [self.ipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(150);
    }];
    
    //接口监听
    self.server = [[HTTPServer alloc]init];
    [self.server setType:@"_http._tcp."];
    
    NSString *webPath = [[NSBundle mainBundle]resourcePath];
    [self.server setDocumentRoot:webPath];
    [self.server setConnectionClass:[MyHTTPConnection class]];
    
    NSError *eror;
    if ([self.server start:&eror]) {
        self.ipLabel.text = [NSString stringWithFormat:@"%@:%hu",[SystemInfo deviceIPAdress],[self.server listeningPort]];
    }else{
        NSLog(@"%@",eror.localizedFailureReason);
    }
    //列表视图
    self.listView = [[UITableView alloc]init];
    self.listView.rowHeight = 40;
    self.listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.listView];
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(200);
    }];
    self.listView.dataSource = self;
    self.listView.delegate = self;
    
    //添加通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiveUploadFile:) name:kUploadFileNotificationName object:nil];
    [_dataSource addObject:@"1.mp3"];
    
}


-(void)receiveUploadFile:(NSNotification*)noti{
    NSDictionary *info = noti.userInfo;
    NSString *name = [info valueForKey:@"name"];
    NSString *path = [info valueForKey:@"path"];
    if ([_dataSource containsObject:name] == NO) {
        [_dataSource addObject:name];
        [_filePaths addObject:path];
        [self.listView reloadData];
    }
}


#pragma mark
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    cell.textLabel.text = _dataSource[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

                                            
@end
