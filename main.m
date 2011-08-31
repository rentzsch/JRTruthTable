#import <Foundation/Foundation.h>
#import "JRTruthTable.h"

int main(int argc, const char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    JRTruthTable *truthTable = [[[JRTruthTable alloc] initWithColumnsAndRows:
                                 @"upekPresent", @"puppyPresent",    JRTruthTable_EndOfColumns,
                                 JRYES,          JRYES,              @"UpekUI",
                                 JRNO,           JRYES,              @"PuppyUI",
                                 JRYES,          JRNO,               @"UpekUI",
                                 JRNO,           JRNO,               @"NoUI",
                                 nil] autorelease];
    
    assert([@"UpekUI" isEqualToString:truthTable.currentState]);
    
    [truthTable updateCondition:@"upekPresent" value:JRNO];
    assert([@"PuppyUI" isEqualToString:truthTable.currentState]);
    
    [truthTable updateCondition:@"upekPresent" value:JRYES];
    assert([@"UpekUI" isEqualToString:truthTable.currentState]);
    
    [truthTable updateCondition:@"upekPresent" value:JRNO];
    [truthTable updateCondition:@"puppyPresent" value:JRNO];
    assert([@"NoUI" isEqualToString:truthTable.currentState]);
    
    [pool drain];
    
    printf("success\n");
    return 0;
}
