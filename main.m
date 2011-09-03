#import "JRTruthTable.h"

@interface StateChangeNotificationCatcher : NSObject {
#ifndef NOIVARS
  @protected
    NSNotification *lastNotification;    
#endif
}
@property(retain) NSNotification *lastNotification;
- (id)initWithTruthTable:(JRTruthTable*)truthTable_;
@end

int main(int argc, const char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableDictionary *conditions = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       JRYES, @"upekPresent",
                                       JRYES, @"puppyPresent",
                                       nil];
    JRTruthTableDictionaryConditionSource *conditionSource = [[[JRTruthTableDictionaryConditionSource alloc] init] autorelease];
    conditionSource.dictionary = conditions;
    
    JRTruthTable *truthTable = [[[JRTruthTable alloc] initWithConditionSource:conditionSource
                                                               columnsAndRows:
                                 @"upekPresent", @"puppyPresent",    JRTruthTable_EndOfColumns,
                                 JRYES,          JRYES,              @"UpekUI",
                                 JRNO,           JRYES,              @"PuppyUI",
                                 JRYES,          JRNO,               @"UpekUI",
                                 JRNO,           JRNO,               @"NoUI",
                                 nil] autorelease];
    
    StateChangeNotificationCatcher *catcher = [[[StateChangeNotificationCatcher alloc] initWithTruthTable:truthTable] autorelease];
    
    assert([@"UpekUI" isEqualToString:truthTable.currentState]);
    assert(catcher.lastNotification != nil);
    
    [conditions setObject:JRNO forKey:@"upekPresent"];
    [truthTable reload];
    assert([@"PuppyUI" isEqualToString:truthTable.currentState]);
    
    [conditions setObject:JRYES forKey:@"upekPresent"];
    [truthTable reload];
    assert([@"UpekUI" isEqualToString:truthTable.currentState]);
    
    [conditions setObject:JRNO forKey:@"upekPresent"];
    [conditions setObject:JRNO forKey:@"puppyPresent"];
    [truthTable reload];
    assert([@"NoUI" isEqualToString:truthTable.currentState]);
    
    [pool drain];
    
    printf("success\n");
    return 0;
}

@implementation StateChangeNotificationCatcher
@synthesize lastNotification;

- (id)initWithTruthTable:(JRTruthTable*)truthTable_ {
    self = [super init];
    if (self) {
        [truthTable_ addStateChangeObserver:self selector:@selector(stateChanged:)];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[lastNotification release];
	[super dealloc];
}

- (void)stateChanged:(NSNotification*)notification_ {
    self.lastNotification = notification_;
}

@end
