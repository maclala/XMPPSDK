//
//  GroupTableViewController.m
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-23.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import "GroupTableViewController.h"
#import "CreateGroupViewController.h"
#import "AppDelegate.h"
@interface GroupTableViewController ()

@end

@implementation GroupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLeftBarButtonItem];
    [self initRightBarButtonItem];
}
-(void)viewWillAppear:(BOOL)animated
{
    
}
- (void)initRightBarButtonItem
{
    UIButton* rBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rBarBtn setTitle:@"创建组群" forState:UIControlStateNormal];
    [rBarBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    rBarBtn.frame = CGRectMake(0, 0, 78, 26);
    rBarBtn.clipsToBounds = YES;
    [rBarBtn addTarget:self action:@selector(rBarBtnPressed:)
      forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* rBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:rBarBtn];
    self.navigationItem.rightBarButtonItem = rBarBtnItem;
}
- (void)initLeftBarButtonItem
{
    UIButton* lBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [lBarBtn setTitle:@"获取房间" forState:UIControlStateNormal];
    [lBarBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    lBarBtn.frame = CGRectMake(0, 0, 78, 26);
    lBarBtn.clipsToBounds = YES;
    [lBarBtn addTarget:self action:@selector(lBarBtnPressed:)
      forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* lBarBtnItem = [[UIBarButtonItem alloc] initWithCustomView:lBarBtn];
    self.navigationItem.leftBarButtonItem = lBarBtnItem;
}
-(void)rBarBtnPressed:(UIButton*)sender
{
    CreateGroupViewController *createGroup = [[CreateGroupViewController alloc]init];
    [self.navigationController presentViewController:createGroup animated:YES completion:^{
        
    }];
}
-(void)lBarBtnPressed:(UIButton *)sender
{
    [self getRoom];
}
-(void)getRoom
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    app.xmppCenter.roomDelegate = self;
    [app.xmppCenter getExistRoom];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}



@end
