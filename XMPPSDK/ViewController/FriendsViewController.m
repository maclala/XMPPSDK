//
//  FriendsViewController.m
//  XMPPSDK
//
//  Created by 丁海伟 on 15-7-20.
//  Copyright (c) 2015年 dhwheavy. All rights reserved.
//

#import "FriendsViewController.h"
#import "ChatDelegate.h"
#import "AppDelegate.h"
#import "XmppCenter.h"
#import "ChatViewController.h"
#import "SearchFriendViewController.h"
#import "LoginViewController.h"
@interface FriendsViewController ()
{
    
}
@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _rosterArray = [NSMutableArray array];
    [self initRightBarButtonItem];
    [self initLeftBarButtonItem];
}
- (void)initRightBarButtonItem
{
    UIButton* rBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rBarBtn setTitle:@"添加好友" forState:UIControlStateNormal];
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
    [lBarBtn setTitle:@"下线" forState:UIControlStateNormal];
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
    SearchFriendViewController *search = [[SearchFriendViewController alloc]init];
    [self presentViewController:search animated:YES completion:^{
        
    }];
}
-(void)lBarBtnPressed:(UIButton *)sender
{
    [[self appDelegate].xmppCenter disconnect];
    LoginViewController *login = [[LoginViewController alloc]init];
    [self presentViewController:login animated:YES completion:^{
        
    }];
}
#pragma mark - Table view delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rosterArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"Cell";
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.indentationWidth = 5;
        cell.indentationLevel = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }
    cell.textLabel.text = [_rosterArray[indexPath.row]objectForKey:@"object"];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate*app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    ChatViewController *chat = [[ChatViewController alloc]init];
    chat.toName = [_rosterArray[indexPath.row]objectForKey:@"object"];
    [app.tabBarController.navigationController pushViewController:chat animated:YES];
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    [[self appDelegate].xmppCenter removeBuddy:_rosterArray[row]];
    [_rosterArray removeObjectAtIndex:row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                     withRowAnimation:UITableViewRowAnimationFade];
    
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

#pragma mark private
//取得当前程序的委托
-(AppDelegate *)appDelegate{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
#pragma mark chatDelegate
-(void)buddyRoster:(NSMutableArray *)rosterArray
{
    _rosterArray = rosterArray;
    [self.tableView reloadData];
}
-(void)didDisconnect
{
    NSLog(@"%s",__func__);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
