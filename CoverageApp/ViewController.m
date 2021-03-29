//
//  ViewController.m
//  CoverageApp
//
//  Created by noxluna on 2021/3/29.
//

#import "ViewController.h"
#import "testView.h"

extern void __gcov_flush(void);
extern void llvm_delete_writeout_function_list(void);
extern void llvm_delete_flush_function_list(void);

@interface ViewController ()

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"gcda_files"];
  setenv("GCOV_PREFIX", [documentsDirectory cStringUsingEncoding:NSUTF8StringEncoding], 1);
  setenv("GCOV_PREFIX_STRIP", "14", 1);
  self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
  dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
  dispatch_source_set_event_handler(self.timer, ^{
    __gcov_flush();
  });
  dispatch_resume(self.timer);
  
  testView *view = [[testView alloc] initWithFrame:self.view.frame];
  [self.view addSubview:view];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  
  dispatch_source_cancel(self.timer);
  llvm_delete_writeout_function_list();
  llvm_delete_flush_function_list();
}

@end
