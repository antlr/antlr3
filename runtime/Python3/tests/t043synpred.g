grammar t043synpred;
options {
  language = Python3;
}

a: ((s+ P)=> s+ b)? E;
b: P 'foo';

s: S;


S: ' ';
P: '+';
E: '>';
