//
//  CreateOrderViewController.m
//  BinaryRearrangement
//
//  Created by 邓亚洲 on 2022/5/7.
//

#import "CreateOrderViewController.h"
#import <BinaryRearrangement-Swift.h>
#import <dlfcn.h>
#import <libkern/OSAtomic.h>

void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,
                                                    uint32_t *stop) {
  static uint64_t N;  // Counter for the guards.
  if (start == stop || *start) return;  // Initialize only once.
  printf("INIT: %p %p\n", start, stop);

  for (uint32_t *x = start; x < stop; x++)
    *x = ++N;  // Guards should start from 1.
}

//原子队列
static  OSQueueHead symbolList = OS_ATOMIC_QUEUE_INIT;
//定义符号结构体
typedef struct {
    void *pc;
    void *next;
}SYNode;

void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
//    if (!*guard) return;  // Duplicate the guard check.
    void *PC = __builtin_return_address(0);
    SYNode *node = malloc(sizeof(SYNode));
    *node = (SYNode){PC,NULL};
    //进入
    OSAtomicEnqueue(&symbolList, node, offsetof(SYNode, next));
}

@interface CreateOrderViewController ()

@end

@implementation CreateOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"生成.order";
    self.view.backgroundColor = [UIColor whiteColor];
    
    XMSwiftModel *model = [[XMSwiftModel alloc] init];
    [model callXMModel];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSMutableArray <NSString *> * symbolNames = [NSMutableArray array];
        
    while (YES) {
        SYNode * node = OSAtomicDequeue(&symbolList, offsetof(SYNode, next));
        if (node == NULL) {
            break;
        }
        Dl_info info;
        dladdr(node->pc, &info);
        NSString * name = @(info.dli_sname);
        BOOL  isObjc = [name hasPrefix:@"+["] || [name hasPrefix:@"-["];
        NSString * symbolName = isObjc ? name: [@"_" stringByAppendingString:name];
        [symbolNames addObject:symbolName];
    }
    //取反
    NSEnumerator * emt = [symbolNames reverseObjectEnumerator];
    //去重
    NSMutableArray<NSString *> *funcs = [NSMutableArray arrayWithCapacity:symbolNames.count];
    NSString * name;
    while (name = [emt nextObject]) {
        if (![funcs containsObject:name]) {
            [funcs addObject:name];
        }
    }
    //干掉自己!
    [funcs removeObject:[NSString stringWithFormat:@"%s",__FUNCTION__]];
    //将数组变成字符串
    NSString * funcStr = [funcs  componentsJoinedByString:@"\n"];
    NSLog(@"%@",funcStr);
    
    NSString * filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"reset.order"];
    NSData * fileContents = [funcStr dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileContents attributes:nil];
    NSLog(@"%@",filePath);
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
