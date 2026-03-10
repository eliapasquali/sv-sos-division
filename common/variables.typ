// Sans in math mode
#let sNum = $sans("Num")$
#let sVar = $sans("Var")$
#let sAexp = $sans("Aexp")$
#let sBexp = $sans("Bexp")$
#let sStm = $sans("Stm")$
#let sState =$sans("State")$
#let sWhile = $sans("While")$

// Values
#let tt = $sans("tt")$
#let ff = $sans("ff")$
#let exc = $sans("exc")$
#let undef = $sans("undef")$
// otherwise values
#let excotherwise = $exc "otherwise"$
#let undefotherwise = $undef "otherwise"$

// Utils
#let ymapstov = $[y mapsto v]$
#let ymapstoa0 = $[y mapsto a_0]$

#let transition = $triangle.small.r$

#let singleStm(stm, state) = [
  $chevron.l stm, state chevron.r$
]

#let composeStm(s1, s2, state,) = [
  $chevron.l s1; s2, state chevron.r$
]

// Semantic functions S
#let S(stm, state) = $cal(S)bracket.l.stroked stm bracket.r.stroked state$

// Arithmetic expressions
#let A(aexp, state) = $cal(A)bracket.l.stroked aexp bracket.r.stroked state$
#let generalAexp = $#A($a$,"s")$

#let a1 = A($a_1$, $s$)
// exceptions
#let a1exc = $a1 = exc$
#let a1noexc = $a1 != exc$
// partial
#let a1undef = $a1 = undef$
#let a1noundef = $a1 != undef$

#let a2 = A($a_2$, $s$)
// exceptions
#let a2exc = $a2 = exc$
#let a2noexc = $a2 != exc$
// partial
#let a2undef = $a2 = undef$
#let a2noundef = $a2 != undef$

// Boolean expressions
#let B(bexp, state) = $cal(B)bracket.l.stroked bexp bracket.r.stroked state$
#let generalBexp = $#B($b$,"s")$

#let b1 = B($b_1$, $s$)
// exceptions
#let b1exc = $b1 = exc$
#let b1noexc = $b1 != exc$
// partial
#let b1undef = $b1 = undef$
#let b1noundef = $b1 != undef$

#let b2 = B($b_2$, $s$)
// exceptions
#let b2exc = $b2 = exc$
#let b2noexc = $b2 != exc$
// partial
#let b2undef = $b2 = undef$
#let b2noundef = $b2 != undef$
