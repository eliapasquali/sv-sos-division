#import "@preview/touying:0.6.1"
#import "utils/unipd.typ": *
#import "../common/variables.typ": *
#import "../common/grammars.typ": *
#import "../common/rules.typ": *

#show: unipd-theme

#set math.cases(gap: 10pt)

#title-slide(
  authors: "Elia Pasquali",
  title: "Divisions in Operational Semantics",
  // Extend Aexp to include integer division a1 ÷ a2 , introducing the possibility of a run-time error (“division by zero”). Modify the operational semantics of Aexp, Bexp and Stm accordingly.
  subtitle: "How to handle an operation that introduces the possibility of having run-time errors",
  date: "December 2025",
)

== Outline
#slide[
  - Introduction
  - Syntactic categories // Those are the same for both approaches 
  - What is left unchanged
  - Partial functions approach
  - Explicit extensions modelling
  // extensions mostly for exception based model
  - Conclusions 
]

#slide[
  For both approaches we will discuss
  - Semantic categories
    - Arithmetic Expressions
    - Boolean Expressions
    - Statements
  - Transition system
  - Rules // Show that the error is checked soundly
  - Analysis of the approach // Discuss termination, looping, stuck
  - Lazy evaluators
  - Possible extensions
]

== Introduction 
#slide[
  In the basic _SOS_ we saw only total operations. What if we add division?

  That operation introduced is mathematically undefined when the divisor is equal to 0.

  Our goal is to find a way to extend the _SOS_ semantics for _While_ in order to manage that edge case.
]

#slide[
  Two approaches proposed:

  *Partial functions*

  With this tool we allow the semantics to be undefined for those cases when the division by zero causes the run-time error.

  *Error as value*

  By modelling the error as an explicit value, we can implement a `try-catch` mechanism to manage *exceptions*. 
]

== Syntactic categories
#slide[
  The syntactic categories of the semantics remain the same, except for the insertion of division in the arithmetic.
  
  The basic one for literals

  - numerals: $n in sNum$
 
  - variables: $x in sVar$
] 

== Arithmetic Expressions
#slide[
  - arithmetic expressions: $a in sAexp$
    #grammarAexp
]

== Boolean Expressions
#slide[
  - boolean expressions: $b in sBexp$
    #grammarBexp

  Logical operators are strict. We will introduce their lazy versions later
]

== Statements
#slide[
  - statements: $s in sStm$
  #grammarStm

  we will add `try-catch` in the exception based model.
]

// !!! PARTIAL

#filled-slide[
  First, the partial functions approach
]

== Semantic categories
#slide[
  // Numerals, variables and states
  We will follow the standard While definitions:

  - Numerals are integers $n in ZZ$ and $cal(N) : sNum -> ZZ$
  
  - Truth values are booleans $t in TT = {tt, ff}$

  - State lookup and update are the classic ones:
 
    - $s x$ that returns the value of variable $x$ in $s$

    - $s' ymapstov$ where $s' x = display(cases(s x "if" x != y, v "if" x = y))$

    for $s in sState = sVar -> ZZ$
]

== Semantics of arithmetics
#slide[
  
  #example-block[Semantic function of Arithmetic Expressions][
    $ cal(A): sAexp -> sState arrow.r.hook ZZ $
  ]

  The function is now partial to handle undefined cases for division.
]

#slide[
=== Base cases
  // num and var
  Exactly the same as in basic SOS.

  // Numeral eval
  #normal-block[Numeral evaluation][$#A($n$, $s$) = n$]

  // Variable eval 
  #normal-block[Variable evaluation][$#A($x$, $s$) = s x$]
]

#slide[
=== "Old" operations
  // + - *
  #normal-block[Addition evaluation][
    $#A($a_1 + a_2$, $s$) = cases(
      a1 + a2 "if" a1noundef and a2noundef,
      undefotherwise
    )$
  ]

  #normal-block[Subtraction evaluation][
    $#A($a_1 - a_2$, $s$) = cases(
      a1 - a2 "if" a1noundef and a2noundef,
      undefotherwise
    )$
  ]

  #normal-block[Multiplication evaluation][
    $#A($a_1 * a_2$, $s$) = cases(
      a1 * a2 "if" a1noundef and a2noundef,
      undefotherwise
    )$
  ]
]

#slide[
=== Division
  // div
  #alert-block[Division evaluation][
    $#A($a_1 div a_2$, $s$) = cases(
      undef "if" a2 = 0,
      a1 div a2 "if" a1noundef and a2noundef,
      undefotherwise
    )$
  ]

  To handle division, we follow the same pattern that validates both subexpressions before evaluating them.

  If $a2$, which is the critical component, evaluate to 0, then we remain undefined.
]

== Semantics of booleans
#slide[
  #example-block[Semantic function of Boolean Expressions][
    $ cal(B): sBexp -> sState arrow.r.hook TT $
  ]

  Here partiality is needed to handle undefined arithmetic expressions in conditions.
]

#slide[
=== Truth values
  // tt ff
  #normal-block[True evaluation][#B("true", $s$) =  tt]

  #normal-block[False evaluation][#B("false", $s$) =  ff]
]

#slide[
=== Arithmetic comparison
  // equal and less than 
  #normal-block[Arithmetic equality][
    //#set text(size: 22pt)
    #B($a_1 = a_2$, $s$) = $cases(
      tt "if" a1 = a2 and (a1noundef and a2noundef),
      ff "if" a1 != a2 and (a1noundef and a2noundef),
      undefotherwise
    )$
  ]

  #normal-block[Arithmetic less than or equal to][
    //#set text(size: 22pt)
    #B($a_1 <= a_2$, $s$) = $cases(
      tt "if" a1 lt.eq a2 and (a1noundef and a2noundef),
      ff "if" a1 lt.eq.not a2 and (a1noundef and a2noundef),
      undefotherwise
    )$
  ]

  Those evaluation can proceed only if both subexpressions are defined.
]

#slide[
=== Recursive cases
  // not & and
  #normal-block[Negation][
    #B($not b$, $s$) = $cases(
      tt "if" generalBexp = ff,
      ff "if" generalBexp = tt,
      undefotherwise
    )$
  ]

  If $b$ is an arithmetic expression, then possible undefined evaluation are managed by recursion into it's evaluation.
]

#slide[
  #normal-block[Logical conjunction][
    #set text(size: 22pt)
    #B($b_1 and b_2$, $s$) = $cases(
      tt "if" (b1 = tt and b2 = tt), // and (b1noundef and b2noundef),
      ff "if" (b1 = ff or b2 = ff) and (b1noundef and b2noundef),
      undefotherwise
    )$
  ]

  This is a _strict operation_ because we check that both subconditions are valid before returning a truth value.    
]

== What didn't change
#slide[
  - Free variables 
  - Substitutions in expressions
  - Substitutions in states

  Added to be complete and coherent with basic SOS, but the only difference is the new operation in the free variables evaluation.
]

== Free Variables
#slide[
  #example-block[$F V : sAexp -> scr(P)("Var") $][
  
    $F V(n) = emptyset$

    $F V(x) = {x}$

    $F V(a_1 op a_2) = F V(a_1) union F V(a_2)$
  ]

  where $op in {+, -, *, #text(red)[$div$]}$
]

== Substitutions in expressions 
#slide[
  // in expr 
  For all $a, a_0 in sAexp, forall y in sVar$

  #example-block[$a ymapstoa0$][

    $n ymapstoa0 eq.delta display(cases(a_0 "if" x = y, x "if" x != y))$

    $(a_1 op a_2) ymapstoa0 eq.delta (a_1 ymapstoa0) op (a_2 ymapstoa0)$
  ]

  where $op in {+, -, *, #text(red)[$div$]}$
]

== Substitutions in states
#slide[
  // in states 
  For all $s in sState, y in sVar, v in ZZ$

  #example-block[$s ymapstov$][

    $(s ymapstov)x eq.delta display(cases(v "if" x = y, s x "if" x != y))$

  ]
]

== Transition system
#slide[
  // general description
  A transition systems is a mathematical model to describe dynamic behaviour of a computation system.
 
  #alert-block[Transition systems $(Gamma, Tau, transition)$][
    - $Gamma$: a set of configurations
    - $Tau$: a set of terminal configurations 
    - #transition: a transition relation $Gamma triangle.small.r Gamma$
  ]
]

== Possible transitions
#slide[
  After one step of computation, it can:

  1. *not been completed*: $(S,s) => (S', s')$

    This means that from a configuration (initial or partial) we reached another partial one.

  2. *be completed*: $(S,s) => s'$,

    This instead indicates that we have reached a valid state that belongs to #sState, which is our set of final states $Tau$
]

== Derivation sequence
#slide[
  A derivation sequence $gamma_1 => gamma_2 => ...$ can be 

  - *finite*: $gamma_1, gamma_2, ..., gamma_k "where" gamma_i => gamma_(i+1) "and" gamma_k arrow.double.r.not$
  - *infinite*: $gamma_1, gamma_2, ..., "where" gamma_i => gamma_(i+1)$

  The first one happens when we conclude the computation either by successful computation or by abnormal termination, while the second when we enter an infinite loop.
]

== Determinism and _stuckness_
#slide[
  #example-block[Deterministic transition systems][
    A transition system is said to be *deterministic* if $gamma transition gamma' "and" gamma transition gamma''$ we have $gamma' eq gamma''$.
  ]
  
  Nothing modified from the basic one, still deterministic.

  #alert-block[Stuck configurations][
    We call $gamma$ a *stuck configuration* if there are no $gamma'$ such that $gamma transition gamma'$.
  ]

  We will define the rules in order to get a stuck configuration when a run-time error caused by a division arise.
]

== Termination and loops
#slide[
  The execution of a statement $S$ on a state $s$:

  - *terminates*: if and only if there is a finite derivation sequence starting with $chevron.l S, s chevron.r$
  
  - *terminates successfully* if $chevron.l S, s chevron.r scripts(=>)^* s'$ for some state $s'$.

  - *terminates abnormally* if we reach a stuck configuration (by convention $chevron.l S, s chevron.r scripts(=>)^0$)

  - *loops* if and only if there is an infinite derivation sequence starting with $chevron.l S, s chevron.r$
]

== Partial approach system 
#slide[
  // partial model definition
  // describe meaning of gamma tau and relation
  // For our extended semantics we don't to modify it from the standard definition.
  #alert-block[Extended transition system: $(Gamma, Tau, arrow.double.r)$][
    - $Gamma : {(S,s) | S in sWhile, s in sState} union sState$

    - $Tau : sState$
    
    - $=> subset.eq {(S,s) | S in sWhile, s in sState} times Gamma$
  ]

  For this approach, we do not modify the transition system of the basic SOS.
]

== Semantics of programs
#slide[
  #alert-block[Semantic functions for Statements][
    $#S($S$, "s") = display(cases(s' "if" singleStm(S, s )scripts(=>)^* s', underline("undef") "otherwise" ))$
  ]

  Undefined computation can emerge from $cal(S)$ because of an infinite loop or a division by zero at some point.
]

== Rules
#slide[
  //=== Skip and assignment
  #normal-block[Skip][
    #grid(
      // name, rule, conditions
      columns: (3em, auto),
      column-gutter: 1em,
      align: (right, auto),
      row-gutter: 1em,
      [ [skip] ], [#skip],
    )
  ]

  The skip rule is standard.
  
  #alert-block[Assignments][
    #grid(
      // name, rule, conditions
      columns: (3em, auto),
      column-gutter: 1em,
      align: (right, auto),
      row-gutter: 1em,
      [ [ass] ], [#ass #ass_side],
    )
  ]

  The assignment checks if the evaluation of $a$ returns a value.

  If it is not the case, meaning that we had an error, then the assignment is stuck.
]

#slide[
  //=== Composition 
  #normal-block[Composition][
    #set align(horizon)
    #grid(
      // name, rule, conditions
      columns: (auto, auto),
      column-gutter: 1em,
      align: (right, auto),
      row-gutter: 1em,
      [ [$"comp"^1$] ], [#comp1],
      [ [$"comp"^2$] ], [#comp2],
    )
  ]

  Nothing changed here because we relies on the validation done from semantic functions for each type of expression.
]

#slide[
  //=== Conditional 
  #normal-block[Conditional][
    #set align(horizon)
    #grid(
      // name, rule, conditions
      columns: (auto, auto),
      column-gutter: 1em,
      align: (right, auto),
      row-gutter: 1em,
      [ [$"if"^" tt"$] ], [#if_tt, #if_tt_side],
      [ [$"if"^" ff"$] ], [#if_ff, #if_ff_side],
    )
  ]

  Same concept of composition holds here.
]

#slide[
  //=== Loop
    #normal-block[Loop unfolding rule][
    #set align(horizon)
    #grid(
      // name, rule, conditions
      columns: (auto, auto),
      column-gutter: 1em,
      align: (right, auto),
      row-gutter: 1em,
      [ [while] ], [#while_full],
    )
  ]

  Because of the property of the unfolding rule, everything is delegated to the various rules for the if statement.

  This means that we need one step of computation to translate the while and only after that we will find if we can proceed with the evaluation.
]

== Lazy evaluators
#slide[
  #grammarLazyBexp
  
  #B($b_1 \& b_2$, $s$) = $display(cases(
    ff "if" b1 = ff,
    b2 "otherwise"
  ))$

  Lazy `and` operator enables defensive guards in conditions.

  #B($b_1 || b_2$, $s$) = $display(cases(
    tt "if" b1 = tt,
    b2 "if" b1 = ff,
    undef "if" b1undef
  ))$

  This instead extends the range of possible condition that can be evaluated without remain undefined.
]

== Limitations of this approach
#slide[
  When we evaluate a program through $cal(S)$ we reach either a final state or the function is undefined.

  When a run-time error occur, the computation reach a stuck configuration and then $cal(S) = underline(undef)$.

  If we enter an infinite loop, the derivation sequence is infinite, but again $cal(S)$ is undefined.

  This means that "from the outside", errors and non termination evaluate the same.
]

// !!! EXCEPTIONS

#filled-slide[
  Now, lets move to modelling exceptions...
]

== Semantic categories
#slide[
  // Numerals, variables and states
  
  These categories will follow the basic SOS, the changes will be in the semantic functions as in the previous approach.

  Just to recap:

  - Numerals are integers $n in ZZ$ and $cal(N) : sNum -> ZZ$
  
  - Truth values are booleans $t in TT = {tt, ff}$

  - State lookup and update are the classic ones, \
    for $s in sState = sVar -> ZZ$
]

== Exceptions as values
#slide[

  By _"exception as values"_ we mean that errors in our programs become possible valid final output values.

  To manage this, we create two extended sets:

  - $ZZ_exc = ZZ union {exc}$, for arithmetic operations

  - $TT_exc = TT union {exc}$, for boolean operations

  where the #exc is our run-time error caused by division.
]

== Semantics of arithmetics
#slide[
  #example-block[Semantic function of Arithmetic Expressions][
    $ cal(A): sAexp -> sState -> ZZ_exc $
  ]

  In this approach we will use total functions.
]

#slide[
=== Base cases
  // num and var
  Still the same.

  // Numeral eval
  #normal-block[Numeral evaluation][$#A($n$, $s$) = n$]

  // Variable eval 
  #normal-block[Variable evaluation][$#A($x$, $s$) = s x$]

]

#slide[
=== "Old" operations
  // + - *
  #normal-block[Addition evaluation][
    $#A($a_1 + a_2$, $s$) = cases(
      a1 + a2 "if" a1noexc "and" a2noexc,
      excotherwise
    )$
  ]

  #normal-block[Subtraction evaluation][
    $#A($a_1 - a_2$, $s$) = cases(
      a1 - a2 "if" a1noexc "and" a2noexc,
      excotherwise
    )$
  ]

  #normal-block[Multiplication evaluation][
    $#A($a_1 * a_2$, $s$) = cases(
      a1 * a2 "if" a1noexc "and" a2noexc,
      excotherwise
    )$
  ]
]

#slide[
=== Division
  // div
  #alert-block[Division evaluation][
    $#A($a_1 div a_2$, $s$) = cases(
      exc "if" a2 = 0,
      a1 div a2 "if" a1noexc "and" a2noexc,
      excotherwise
    )$
  ]

  The approach is always the same, but this time we are actually returning a valid value even when errors occurs.

  This is the operation that can create the exception in our model, the other guards are there only to propagate it.
]

== Semantics of booleans
#slide[
  #example-block[Semantic function of Boolean Expressions][
    $ cal(B): sBexp -> sState -> TT_exc $
  ]

  Also in this case a total function. The output values are extended to support errors occurring in conditions evaluation.
]

#slide[
=== Truth values
  // tt ff
  #normal-block[True evaluation][#B("true", $s$) =  tt]

  #normal-block[False evaluation][#B("false", $s$) =  ff]
]

#slide[
=== Arithmetic comparison
  // equal and less than 
  #normal-block[Arithmetic equality][
    //#set text(size: 22pt)
    #B($a_1 = a_2$, $s$) = $cases(
      tt "if" a1 = a2 and (a1noexc and a2noexc),
      ff "if" a1 != a2 and (a1noexc and a2noexc),
      excotherwise
    )$
  ]

  #normal-block[Arithmetic less than or equal to][
    //#set text(size: 22pt)
    #B($a_1 <= a_2$, $s$) = $cases(
      tt "if" a1 <= a2 and (a1noexc and a2noexc),
      ff "if" a1 <= not a2 and (a1noexc and a2noexc),
      excotherwise
    )$
  ]

  Those evaluation can proceed only if both subexpressions returns a valid value.
]

#slide[
=== Recursive cases
  // not & and
  #normal-block[Negation][
    #B($not b$, $s$) = $cases(
      tt "if" generalBexp = ff,
      ff "if" generalBexp = tt,
      excotherwise
    )$
  ]

  #normal-block[Logical conjunction][
  #set text(size: 22pt)
  #B($b_1 and b_2$, $s$) = $cases(
    tt "if" (b1 = tt and b2 = tt), // and (b1noexc and b2noexc),
    ff "if" (b1 = ff or b2 = ff) and (b1noexc and b2noexc),
    excotherwise
  )$
  ]

  These are the same from the previous approach, but instead of left some cases undefined, returns the exception value. 
]

== What didn't change
#slide[
  We follow the definitions given in the previous approach, but again, nothing changed for:

  - free variables
  - substitutions in states and expressions

  We have to modify the transition systems a bit to support exceptions.
]

== Exceptions transition systems
#slide[
  #alert-block[Extended transition system: $(Gamma, Tau, arrow.double.r)$][
    - $Gamma : {(S,s) | S in sWhile, s in sState} union sState union {exc}$

    - $Tau : sState union {exc}$
    
    - $=> subset.eq {(S,s) | S in sWhile, s in sState} times Gamma$
  ]

  We added #exc to both $Gamma$ and $Tau$. 
  
  The first is needed to make the exception a *valid* state for the system, while the second is needed to make it a *final* state.
]

== Characteristics of the system
#slide[
  In this new extension we have the same definitions for *derivation sequence*, *determinism* and *stuck configurations*.

  We still *have a deterministic* system.

  The only "non-termination" is caused by infinite loops, so in this approach we return to a *system without stuck configurations* as in the basic one.
]


== Semantics of programs
#slide[
  #alert-block[Semantic functions for Statements][
    $#S(S, "s") = display(cases(s' "if" singleStm(S, s )scripts(=>)^* s', underline("undef") "otherwise" ))$
  ]

  Undefined computation can emerge from $cal(S)$ because only for an infinite loop, because an error will return a value and so the evaluation will reach a final state.
]

== Rules
#slide[
  //=== Skip and assignment
  #normal-block[Skip][
    #grid(
      // name, rule, conditions
      columns: (3em, auto),
      column-gutter: 1em,
      align: (right, auto),
      row-gutter: 1em,
      [ [skip] ], [#skip],
    )
  ]

  The skip rule is standard.
  
  #alert-block[Assignments][
    #grid(
      // name, rule, conditions
      columns: (3em, auto),
      column-gutter: 1em,
      align: (right, auto),
      row-gutter: 1em,
      [ [$"ass"^"ok"$] ], [#ass_ok #ass_ok_side],
      [ [$"ass"^"err"$] ], [#ass_err #ass_err_side],
    )
  ]

  We split the assignment rules to follow the standard behaviour if the arithmetic expression returns a numeral.

  If when evaluating $a$ we get an exception, then we propagate it.
]

#slide[
  //=== Composition 
  #alert-block[Composition][
    #set align(horizon)
    #grid(
      // name, rule, conditions
      columns: (auto, auto, auto),
      column-gutter: 1em,
      align: (right, auto),
      row-gutter: 1em,
      [ [$"comp"^1$] ], [#comp1], [],
      [ [$"comp"^2$] ], [#comp2], [#comp2_side],
      [ [$"comp"^"err"$] ], [#comperr], [],
    )
  ]

  Here, we follow the standard behaviour only when no exceptions are involved in the first component $S_1$.

  If the computation of #singleStm($S_1$, "s") raise an exception, then we make the whole composition return it.
]

#slide[
  //=== Conditional 
  #alert-block[Conditional][
    #set align(horizon)
    #grid(
      // name, rule, conditions
      columns: (auto, auto, auto),
      column-gutter: 1em,
      align: (right, auto),
      row-gutter: 1em,
      [ [$"if"^" tt"$] ], [#if_tt, #if_tt_side], [],
      [ [$"if"^" ff"$] ], [#if_ff, #if_ff_side], [],
      [ [$"if"^" err"$] ], [#if_err, #if_err_side], [],
    )
  ]

  The pattern is the same, when exceptions are involved we add a rule that propagates it.
]

#slide[
  //=== Loop
    #normal-block[Loop unfolding rule][
    #set align(horizon)
    #grid(
      // name, rule, conditions
      columns: (auto, auto),
      column-gutter: 1em,
      align: (right, auto),
      row-gutter: 1em,
      [ [while] ], [#while_full],
    )
  ]

  If the condition raise an exception, the program will be stopped by the rule [$"if"^" err"$], so we need the extra steps of the unfolding phase.
]

== Lazy evaluators
#slide[
  #grammarLazyBexp
  
  #B($b_1 \& b_2$, $s$) = $display(cases(
    ff "if" b1 = ff,
    b2 "otherwise"
  ))$

  #B($b_1 || b_2$, $s$) = $display(cases(
    tt "if" b1 = tt,
    b2 "if" b1 = ff,
    exc "if" b1exc
  ))$

  In this approach, with lazy operators we can define guards to avoid exception propagation in the computation.
]

== Possible extensions
#slide[
  Because exceptions in this model are just special symbols, we can define an encoding and then insert everything we need.

  With the basic structure of While, a interesting addition could be defining rules in a way such that we can understand from which expression the error is generated.

  Another extension can be actually implementing a exception recovery strategy like the `try-catch`.
]

== Try-catch sketch
#slide[
  Assume that we extend the grammar of While
  #grammarStmTryCatch

  This construct starts by computing $S_1$ and uses $S_2$ as a recovery procedure when an error occurs.

  For this sketch, we assume just a single type of exception.
]

== Try-catch rules sketch
#slide[
  We follow the model of the composition rules:
    #set align(horizon)
    #grid(
      // name, rule, conditions
      columns: (auto, auto),
      column-gutter: 1em,
      align: (right, auto),
      row-gutter: 1em,
      [ [$"try-catch"^1$] ], [#try_catch_1],
      [ [$"try-catch"^2$] ], [#try_catch_2],
      [ [$"try-catch"^"err"$] ], [#try_catch_err],
    )
  
  The [$"try-catch"^"err"$] rule is the *recovery* rule: when an operation inside the `try` raise an exception, it takes the last valid state $s$ and restart the computation using the `catch` block to proceed.
]

== Conclusions
#slide[
  The approach based on *partial functions* needs little to none modification to support division, but it is less extensible. It also introduces *stuck* configurations and cannot distinguish them from infinite looping from the outside.

  Modelling *exceptions*, on the other side, gives as a more flexible system, at the cost of introducing more rules to handle error cases. The absence of stuck configurations and the explicit errors let us analyze the status of computation with more information.
]

#filled-slide[
  Thank you for your attention!
]
