#import "@preview/simplebnf:0.1.1": *
#import "variables.typ": sStm, sAexp, sBexp

#let grammarStm = bnf(
  Prod(
    $S$,
    annot: $sStm$,
    {
      Or[$x := a$][variable assignment]
      Or[$sans("skip")$][no operation]
      Or[$S_1$;$S_2$][sequencing]
      Or[if $b$ then $S_1$ else $S_2$ end][conditional]
      Or[while $b$ do $S$][while loop]
    },
  ),
)


#let grammarAexp = bnf(
  Prod(
    $a$,
    annot: $sAexp$,
    {
      Or[$n$][number]
      Or[$x$][variable lookup]
      Or[$a_1 + a_2$][addition]
      Or[$a_1 - a_2$][subtraction]
      Or[$a_1 times a_2$][multiplication]
      Or[#text(red)[$a_1 div a_2$]][#text(red)[division]]
    },
  ),
)

#let grammarBexp = bnf(
  Prod(
    $b$,
    annot: $sBexp$,
    {
      Or[true][boolean true]
      Or[false][boolean false]
      Or[$a_1 = a_2$][equality]
      Or[$a_1 <= a_2$][less than or equal]
      Or[$not b$][negation]
      Or[$b_1 and b_2$][conjunction]
    },
  ),
)

#let grammarLazyBexp = bnf(
  Prod(
    $b$,
    annot: $sBexp$,
    {
      Or[...][]
      Or[$b_1 \& b_2$][lazy conjunction]
      Or[$b_1 || b_2$][lazy disjunction]
    }
  )
)

#let grammarStmTryCatch = bnf(
  Prod(
    $S$,
    annot: $sStm$,
    {
      Or[...][]
      Or[try ($S_1$) catch ($S_2$)][]
    },
  ),
)