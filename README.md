# Division in Small Steps Operational semantics

First homework for the course _Software Verification_ at Unipd, MSc in Computer Science @ Unipd (A.Y. 2025/2026).

## Homework task

Extend `Aexp` to include integer division `a1÷a2`, introducing the possibility of a run-time error (“division by zero”). Modify the operational semantics of `Aexp`, `Bexp` and `Stm` accordingly.

## Known problems

Some definitions of the exception-based model are not completely formally correct, but it is mostly sound (**pun intended**).

## 1/0 = 0
A little math rant by Hillel Wayne on division by zero found while doing this presentation. [https://www.hillelwayne.com/post/divide-by-zero/](https://www.hillelwayne.com/post/divide-by-zero/) 