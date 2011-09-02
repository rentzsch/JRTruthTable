#import "JRTruthTable.h"

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
    
    assert([@"UpekUI" isEqualToString:truthTable.currentState]);
    
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
