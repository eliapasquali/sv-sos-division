#import "@preview/curryst:0.6.0": rule, prooftree, rule-set
#import "/common/variables.typ": exc, tt, ff, generalAexp, generalBexp, singleStm, composeStm

// Rules for the exception approach

// Basic rules

#let ass_ok = [ $chevron.l x := a, s chevron.r => s[x mapsto generalAexp]$ ]
#let ass_ok_side = [ $"if" generalAexp != exc$ ]
#let ass_err = [ $chevron.l x := a, s chevron.r => exc$ ]
#let ass_err_side = [ $"if" generalAexp = exc$ ]

#let skip = [ $chevron.l "skip", s chevron.r => s$ ]

// Compositions
#let comp1 = [
  #prooftree(
    rule(
      [$singleStm(S_1, s) => singleStm(S'_1', s')$],
      [$composeStm(S_1,S_2,s) => composeStm(S'_1, S_2, s') $],
    )
  )
]

#let comp2 = [
  #prooftree(
    rule(
      [$singleStm(S_1, s) => s'$],
      [$composeStm(S_1,S_2,s) => singleStm(S_2, s') $],
    )
  )
]

#let comperr = [
  #prooftree(
    rule(
      [$singleStm(S_1, s) => exc$],
      [$composeStm(S_1,S_2,s) => exc $],
    )
  )
]

// Conditionals

#let ifbase(condition, then_branch, else_branch, state) = [
  $chevron.l "if" condition "then" #then_branch "else" #else_branch, state chevron.r$
]

#let if_tt = [ $ifbase(b, S_1, S_2, s) => singleStm(S_1, s)$ ]
#let if_tt_side = [ $"if" generalBexp = tt $ ]

#let if_ff = [ $ifbase(b, S_1, S_2, s) => singleStm(S_2, s)$ ]
#let if_ff_side = [ if $generalBexp = ff$ ]

#let if_err = [ $ifbase(b, S_1, S_2, s) => exc$ ]
#let if_err_side = [ if $generalBexp = exc$ ]

// While rule with unfolding
#let while_full = [  
  $chevron.l "while" b "do" S, s chevron.r => ifbase(b, (S, "while" b "do" S), "skip", s)$
]