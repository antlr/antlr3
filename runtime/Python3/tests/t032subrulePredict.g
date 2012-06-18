grammar t032subrulePredict;
options {
  language = Python3;
}

a: 'BEGIN' b WS+ 'END';
b: ( WS+ 'A' )+;
WS: ' ';
