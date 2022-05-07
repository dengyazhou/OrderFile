//
//  ViewController.m
//  BinaryRearrangement
//
//  Created by xmly on 2022/5/7.
//

#import "ViewController.h"
#import "CreateOrder/CreateOrderViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
#pragma mark 二进制重排优化是在链接阶段对即将生成的可执行文件进行重新排列

#pragma mark 第一步
    //Build Settings 中搜索"Write Link Map File",No改为Yes，然后Command+B,build一下，就会生成LinkMap文件
    //LinkMap 所在路径为和Products平级的Intermediates.noindex/BinaryRearrangement.build/Debug-iphonesimulator/BinaryRearrangement.build/BinaryRearrangement-LinkMap-normal-x86_64.txt
    
#pragma mark 第二步
    //编写reset.order文件，里面的内容是方法的调用顺序
    //Build Settings 中搜索"Order File",配置为reset.order的路径
    //重新编译一下，会发现LinkMap里面的方法顺序变成了reset.order中的方法顺序
    
#pragma mark 第三步如何生成.order文件
    //1、Build Settings 搜索 other c flags，添加-fsanitize-coverage=func,trace-pc-guard参数
    //2、在Build Settings搜索other swift flags，如果是OC项目，里面没有Swift文件，那么搜索不到Other Swift Flags，只有项目里面有了Swift文件才会搜索到。添加参数-sanitize-coverage=func 和 -sanitize=undefined
    
    //把得到的reset.order文件拷贝到项目的根目录下。
    //Build Settings中搜索order file，添加reset.order文件的地址(./reset.order或者${SRCROOT}/reset.order)
    //Build Settings 中搜索 link map,如果是Yes则改回No
    //去掉 Other C Flags的参数 -fsanitize-coverage=func,trace-pc-guard
    //去掉 Other Swift Flags的参数 -sanitize-coverage=func 和 -sanitize=undefined
    //注销__sanitizer_cov_trace_pc_guard_init和__sanitizer_cov_trace_pc_guard方法
    //结束，打包上线
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    CreateOrderViewController *vc = [[CreateOrderViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
