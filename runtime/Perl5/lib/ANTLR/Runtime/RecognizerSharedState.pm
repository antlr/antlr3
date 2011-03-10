package ANTLR::Runtime::RecognizerSharedState;

use ANTLR::Runtime::Token;

use Moose;

# Track the set of token types that can follow any rule invocation.
# Stack grows upwards.  When it hits the max, it grows 2x in size
# and keeps going.
has 'following' => (
    is  => 'rw',
    isa => 'ArrayRef[ANTLR::Runtime::BitSet]',
    default => sub { [] },
);

has '_fsp' => (
    is  => 'rw',
    isa => 'Int',
    default => -1,
);

# This is true when we see an error and before having successfully
# matched a token.  Prevents generation of more than one error message
# per error.
has 'error_recovery' => (
    is  => 'rw',
    isa => 'Bool',
    default => 0,
);

# The index into the input stream where the last error occurred.
# This is used to prevent infinite loops where an error is found
# but no token is consumed during recovery...another error is found,
# ad naseum.  This is a failsafe mechanism to guarantee that at least
# one token/tree node is consumed for two errors.
has 'last_error_index' => (
    is  => 'rw',
    isa => 'Int',
    default => -1,
);

# In lieu of a return value, this indicates that a rule or token
# has failed to match.  Reset to false upon valid token match.
has 'failed' => (
    is  => 'rw',
    isa => 'Bool',
    default => 0,
);

# Did the recognizer encounter a syntax error?  Track how many.
has 'syntax_errors' => (
    is  => 'rw',
    isa => 'Int',
    default => 0,
);

# If 0, no backtracking is going on.  Safe to exec actions etc...
# If >0 then it's the level of backtracking.
has 'backtracking' => (
    is  => 'rw',
    isa => 'Int',
    default => 0,
);

# An array[size num rules] of Map<Integer,Integer> that tracks
# the stop token index for each rule.  ruleMemo[ruleIndex] is
# the memoization table for ruleIndex.  For key ruleStartIndex, you
# get back the stop token for associated rule or MEMO_RULE_FAILED.
# This is only used if rule memoization is on (which it is by default).
has 'rule_memo' => (
    is  => 'rw',
    isa => 'Maybe[ArrayRef[HashRef[Int]]]',
);

# The goal of all lexer rules/methods is to create a token object.
# This is an instance variable as multiple rules may collaborate to
# create a single token.  nextToken will return this object after
# matching lexer rule(s).  If you subclass to allow multiple token
# emissions, then set this to the last token to be matched or
# something nonnull so that the auto token emit mechanism will not
# emit another token.
has 'token' => (
    is  => 'rw',
    isa => 'Maybe[ANTLR::Runtime::Token]',
);

# What character index in the stream did the current token start at?
# Needed, for example, to get the text for current token.  Set at
# the start of nextToken.
has 'token_start_char_index' => (
    is  => 'rw',
    isa => 'Int',
    default => -1,
);

# The line on which the first character of the token resides
has 'token_start_line' => (
    is  => 'rw',
    isa => 'Int',
);

# The character position of first character within the line
has 'token_start_char_position_in_line' => (
    is  => 'rw',
    isa => 'Int',
);

# The channel number for the current token
has 'channel' => (
    is  => 'rw',
    isa => 'Int',
);

# The token type for the current token
has 'type' => (
    is  => 'rw',
    isa => 'Int',
);

# You can set the text for the current token to override what is in
# the input char buffer.  Use setText() or can set this instance var.
has 'text' => (
    is  => 'rw',
    isa => 'Maybe[Str]',
);

no Moose;
__PACKAGE__->meta->make_immutable();
1;
__END__
