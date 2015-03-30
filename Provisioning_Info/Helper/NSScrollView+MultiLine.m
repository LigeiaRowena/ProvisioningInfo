

#import "NSScrollView+MultiLine.h"

@implementation NSScrollView (MultiLine)

- (void)appendStringValue:(NSString*)string
{
    NSTextView *textfield = (NSTextView*)self.documentView;
    NSString *newValue = [textfield.textStorage.mutableString stringByAppendingFormat:@"\n%@", string];
    [textfield setString:newValue];
}

- (void)setStringValue:(NSString*)string
{
    NSTextView *textfield = (NSTextView*)self.documentView;
    textfield.font = [NSFont fontWithName:@"Courier" size:18];
    [textfield setString:string];
}

@end
