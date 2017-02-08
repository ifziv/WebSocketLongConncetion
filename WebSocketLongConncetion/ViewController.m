//
//  ViewController.m
//  WebSocketLongConncetion
//
//  Created by zivInfo on 16/12/15.
//  Copyright © 2016年 xiwangtech.com. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<SRWebSocketDelegate>
{
    SRWebSocket *socket;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://192.168.1.20:9502"]]]; //ws://echo.websocket.org
    
    socket.delegate = self;    // 实现这个 SRWebSocketDelegate 协议
    [socket open];             // open 就是直接连接了
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"连接成功，可以立刻登录你公司后台的服务器了，还有开启心跳");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self sendMessageConncetion];
        [NSTimer scheduledTimerWithTimeInterval:180.0f target:self selector:@selector(sendMessageConncetion) userInfo:nil repeats:true];
        [[NSRunLoop currentRunLoop] run];
        
    });
}

-(void)sendMessageConncetion
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"name":@"zhiwei",@"pwd":@"hello006",@"macaddress":@"skajamaadas"} options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [socket send:jsonString];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"连接失败，这里可以实现掉线自动重连，要注意以下几点");
    NSLog(@"1.判断当前网络环境，如果断网了就不要连了，等待网络到来，在发起重连");
    NSLog(@"2.判断调用层是否需要连接，例如用户都没在聊天界面，连接上去浪费流量");
    NSLog(@"3.连接次数限制，如果连接失败了，重试10次左右就可以了，不然就死循环了。或者每隔1，2，4，8，10，10秒重连...f(x) = f(x-1) * 2, (x<5)  f(x)=10, (x>=5)");
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
    NSLog(@"连接断开，清空socket对象，清空该清空的东西，还有关闭心跳！");
    socket = nil;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message  {
    
    NSLog(@"收到数据了，注意 message 是 id 类型的，学过C语言的都知道，id 是 (void *)void* 就厉害了，二进制数据都可以指着，不详细解释 void* 了");
    NSLog(@"我这后台约定的 message 是 json 格式数据收到数据，就按格式解析吧，然后把数据发给调用层");
    NSLog(@"message:%@",message);
    
}
                
                

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
