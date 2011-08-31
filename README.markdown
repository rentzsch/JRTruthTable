JRTruthTable is a simple class which matches current conditions against a user-supplied set of conditions and tells you what state you're in.

Here's my real-world example: 

Sony used to have a fingerprint scanner called, weirdly, the [Puppy](http://bssc.sel.sony.com/news/puppy/). I work on a Mac app that uses the Puppy for biometric identification.

Sony stopped making the Puppy. No problem, switch to another outfit called [Upek](http://www.upek.com/) -- they have a better SDK anyway (I had to reverse the Puppy's software to do what I needed to do).

Problem: most clients have Puppies, but new clients have Upeks. As Puppies break, they'll be replaced with Upeks.

When presenting the login screen, I'll show either the Puppy UI elements if the Puppy is attached, the Upek UI elements if the Upek is attached, the Upek UI if both are attached (since Upek is The Future) and no UI if neither is attached.

I can express that all with the following JRTruthTable object:

    JRTruthTable *truthTable = [[[JRTruthTable alloc] initWithColumnsAndRows:
                                 @"upekPresent", @"puppyPresent",    JRTruthTable_EndOfColumns,
                                 JRYES,          JRYES,              @"UpekUI",
                                 JRNO,           JRYES,              @"PuppyUI",
                                 JRYES,          JRNO,               @"UpekUI",
                                 JRNO,           JRNO,               @"NoUI",
                                 nil] autorelease];

The first line is the truth table's column headers. There are two conditions I'm keeping track of, `upekPresent` and `puppyPresent`. The rest of the lines list out every possible combination and the third column indicates what state that represents.

The first row of conditions is automatically assumed to be the current conditions, so `truthTable.currentState` would return `UpekUI` off the bat. Let's say I scan the USB bus and discover the Upek device isn't present. I issue a call to `[truthTable updateCondition:@"upekPresent" value:JRNO]` and `truthTable.currentState` would return `PuppyUI`.

The condition row's state doesn't have to be an `NSString` -- I just used it here for simplicity. It's an `id`, so it can be any object. A cool thing to stash in there is an `NSInvocation` to associate behavior with a specific state.