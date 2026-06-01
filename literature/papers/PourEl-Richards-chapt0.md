## Part I

Computability in Classical Analysis

## Chapter 0 <br> An Introduction to Computable Analysis

## Introduction

This chapter is, in a sense, a primer of computable real analysis. We present here most of the basic methods needed to decide standard questions about the computability of real valued functions. Thus the chapter deals in a systematic way with the computability theory of real numbers, real sequences, continuous functions, uniform convergence, integration, maxima and minima, the intermediate value theorem, and several other topics. In fact, most of the usual topics from the standard undergraduate real variables course are treated within the context of computability.

There is one conspicuous omission. We postpone the treatment of derivatives until Chapter 1. This is because the computability theory of derivatives is a bit more complicated.

Section 1 deals with computable real numbers. A real number is computable if it is the effective limit of a computable sequence of rationals. All of these terms are defined at the beginning of the section. Surprisingly enough, many of the questions concerning individual computable reals require the consideration of computable sequences of reals. This topic is postponed until Section 2. However, a few questions can be answered at this preliminary stage. For example, the definition of "computable real" involves the notion of effective convergence for rational sequences. We show that the hypothesis of effective convergence is not redundant, by showing that there exist computable sequences of rationals which converge, but not effectively (Rice [1954], Specker [1949]). This is done by means of the Waiting Lemma, a standard recursion-theoretic result, which for the sake of completeness we prove. The Waiting Lemma is used repeatedly throughout the book. The section concludes with a brief discussion of some alternative definitions of "computable real number".

Section 2 deals with computable sequences of real numbers. This notion is essential for the entire book. To do work in computable analysis, one has to be totally fluent with all of the nuances related to computable sequences.
[The importance of sequences, rather than individual elements, reappears in Part II of this book. Thus in Chapter 2, where we lay down axioms for computability on a Banach space, the concept which is axiomatized is "computable sequence of vectors" in the Banach space.]

Section 2 begins with a careful discussion of the two notions: "computable sequence of reals" and "effective convergence of a double sequence $\left\{x_{n k}\right\}$ to a limit sequence $\left\{x_{n}\right\}$ ". The second of these has subtleties of its own. In particular, we must make the distinction between effective convergence (a notion from logic) and uniform convergence (a notion from analysis). In general neither implies the other. This is illustrated by Examples 1 and 2.

The section also contains two results, Propositions 1 and 2, dealing with effective convergence. As a corollary of these we obtain a noncomputable real which is the noneffective limit of a computable sequence of rationals (Rice [1954], Specker [1949]). The section concludes with two further examples, Examples 3 and 4, which serve several purposes. Firstly, these examples illustrate techniques which are echoed many times throughout the book. Secondly, the examples have corollaries which are of independent interest. For instance, there exists a sequence of rational numbers which is computable as a sequence of reals, but not as a sequence of rationals.

Section 3 gives the definition of a computable function of one or several real variables. In fact, it gives two equivalent definitions. Definition A is based on the pioneering work of Grzegorczyk [1955, 1957] and Lacombe [1955a, 1955b]. This definition involves a natural effectivization of basic constructs in analysis, and it is readily applicable to work in analysis. Definition B, due to Caldwell and Pour-El [1975], is based on an effectivization of the Weierstrass Approximation Theorem. For certain purposes-e.g. the treatment of integration over irregular domainsDefinition B is more efficient than Definition A. Finally Definitions A and B, given for a single function defined on a bounded rectangle, are extended to sequences of functions and to unbounded domains (Definitions $\mathbf{A}^{\prime}, \mathbf{B}^{\prime}, \mathbf{A}^{\prime \prime}, \mathbf{B}^{\prime \prime}$ ). It should be added that, over the years, a variety of definitions all equivalent to Definitions A and B have been given. These include definitions based on recursive functionals-cf. Grzegorczyk [1955, 1957] and Lacombe [1955a, 1955b] for details.

Here we reach a transition point. The basic definitions of this chapter have all been given, and now we begin to investigate systematically their consequences.

Section 4 deals with three elementary topics-composition of functions, patching, and extension of functions. The proofs in this section are worked out in great detail. Later on in the chapter we adopt a lighter style.

Section 5 treats two basic constructs in analysis-uniform convergence and integration. We first prove that the computable functions are closed under effective uniform convergence. The treatment of integration is, of necessity, more complicated. The reason is this. In order to handle the deeper problems concerned with integration, we need Definition B. However, in order to prove the equivalence of Definitions A and B, we need a preliminary result about integration (Theorem 5). From this we can deduce the equivalence of Definitions $\mathbf{A}$ and $\mathbf{B}$ (Theorem 6). Then follows a detailed discussion of the types of integrals which occur routinely in analysis. These include indefinite integrals, integrals depending on a parameter, a variety of line and surface integrals, and integrals over irregular domains. Such integrals appear at several places throughout this book. For instance, in later chapters we deal with the Cauchy integral formula, Kirchhoff's solution formula
for the wave equation, the corresponding formula for the heat equation, and others. A general result which encompasses all integrals of this type is given in Corollary 6c.
[Part of the proof of Theorem 6 is deferred until Section 7-see below. Of course, this proof uses only results proved prior to the statement of Theorem 6.]

Section 6 deals with the max-min theorem, the intermediate value theorem, and certain other topics. Both the max-min theorem and the intermediate value theorem effectivize for a single computable function. However, when we consider computable sequences of functions we see a divergence: the max-min theorem effectivizes for sequences, whereas the intermediate value theorem does not. There is a further subtlety associated with the max-min theorem. Although the maximum value taken by a computable function is computable, the point where this maximum occurs need not be (Kreisel [1958], Lacombe [1957b], Specker [1959]). We omit the proof of this theorem, since we do not need it. Two further topics are treated. As a corollary of the intermediate value theorem, we prove that the computable reals form a real closed field. The section concludes with a brief discussion of the Mean Value Theorem.

Section 7 completes the proof of Theorem 6 (equivalence of Definitions A and B). This is done by giving an effective version of the Weierstrass Approximation Theorem. The proof is rather complicated, and is included partly as an illustration of technique. A much easier proof is given in Chapter 2, Section 5.

## 1. Computable Real Numbers

While every rational number is computable, it is clear that not every real number is. For the set of all computer programs is countable, whereas the set of real numbers is not. Roughly speaking, a computable real is one which can be effectively approximated to any desired degree of precision by a computer program given in advance. Thus the number $\pi$ is computable, since there exist finite recipes for computing it. When more precision is desired the computation may take longer, but the recipe itself does not change.

In this section, we define "computable real" and prove some simple results about effective and noneffective convergence. As remarked in the introduction to the chapter, further results on individual computable reals require a knowledge of "computable sequences of reals", and hence are postponed until Section 2.

We begin with the fact that a real number is the limit of a Cauchy sequence of rationals. There are two aspects to the effectivization of this concept: 1) the sequence of rationals must be computable, and 2) the convergence of this sequence to its limit must be effective. We now examine each of these requirements in turn.

For 1) we mean-as already suggested above-that the entire sequence of rationals is computed by a finite set of instructions given in advance. For 2) we mean that there is a second set of instructions, also given in advance, which will tell us, for any $\varepsilon>0$, a point where an error less than $\varepsilon$ has been achieved. The precise definitions are:

Definition 1. A sequence $\left\{r_{k}\right\}$ of rational numbers is computable if there exist three recursive functions $a, b, s$ from $\mathbb{N}$ to $\mathbb{N}$ such that $b(k) \neq 0$ for all $k$ and

$$
r_{k}=(-1)^{s(k)} \frac{a(k)}{b(k)} \quad \text { for all } k
$$

Definition 2. A sequence $\left\{r_{k}\right\}$ of rational numbers converges effectively to a real number $x$ if there exists a recursive function $e: \mathbb{N} \rightarrow \mathbb{N}$ such that for all $N$ :

$$
k \geqslant e(N) \quad \text { implies } \quad\left|r_{k}-x\right| \leqslant 2^{-N} .
$$

Definition 3. A real number $x$ is computable if there exists a computable sequence $\left\{r_{k}\right\}$ of rationals which converges effectively to $x$.

A complex number is called computable if its real and imaginary parts are computable. Similarly, a $q$-vector $\left(x_{1}, \ldots, x_{q}\right)$ is computable if each of its components is computable.

Obviously, the notion of a computable real is central to recursive analysis. Eventually, in order to obtain far-reaching results, we shall have to generalize this notion to sequences of reals, continuous functions, and beyond. Nevertheless, certain basic questions already appear at this stage.

Proposition 0. Let $x$ be a computable real number. If $x>0$, then there is an effective procedure which shows this. Likewise for $x<0$. If $x=0$, there is in general no effective way of proving this.

Proof. Since $x$ is a computable real, $x$ is the limit of a computable sequence $\left\{r_{k}\right\}$ of rationals, with an effective modulus of convergence $e(N)$ as above. Suppose that $x>0$. Then the following procedure will eventually terminate and provide an effective proof that $x>0$ :

For $N=0,1,2, \ldots$, compute $e(N)$ and $r_{e(N)}$, and wait until an $r_{e(N)}$ turns up with

$$
r_{e(N)}>2^{-N}
$$

If $x>0$, such an $N$ must eventually occur. For suppose $2^{-N}<x / 2$. Then, since $\left|r_{e(N)}-x\right| \leqslant 2^{-N}<x / 2, r_{e(N)}>x / 2>2^{-N}$.

In the reverse direction, since $\left|r_{e(N)}-x\right| \leqslant 2^{-N}$, the condition $r_{e(N)}>2^{-N}$ implies $x>0$.

Similarly for $x<0$.
However, such a simple test will not work for the case where $x=0$. In fact, there is no effective test for this case. A counterexample demonstrating this is given in the next section (Fact 3 following Example 4).

Remark. The processes of analysis frequently require that comparisons be made between real numbers. Yet, as we have just seen, such comparisons cannot always
be made effectively. Often we can obtain an effective substitute by using rational approximations. Thus the following simple fact will be used constantly.

Consider a computable sequence $\left\{r_{n}\right\}$ of rationals: $r_{n}=(-1)^{s(n)}[a(n) / b(n)]$ as in Definition 1. Then $r_{n}=0$ if and only if $a(n)=0 ; r_{n}>0$ if and only if $a(n)>0$ and $s(n)$ is even; and $r_{n}<0$ if and only if $a(n)>0$ and $s(n)$ is odd. This gives an effective test for picking out the sequences $\left\{n: r_{n}=0\right\},\left\{n: r_{n}>0\right\}$, and $\left\{n: r_{n}<0\right\}$.

In a word: exact comparisons are possible for computable sequences of rationals, although not necessarily for computable reals.

We turn now to the question of effective convergence. Generally, when a computable sequence of rationals $\left\{r_{k}\right\}$ converges to a real number $x$, the convergence may or may not be effective. There is one important case where effectiveness of convergence is guaranteed; it corresponds to the nested intervals approach for the definition of a real number.

Let $\left\{a_{k}\right\}$ and $\left\{b_{k}\right\}$ be computable sequences of rationals which are monotone upwards and downwards respectively and converge to $x$ : i.e. $a_{0} \leqslant a_{1} \leqslant \cdots, b_{0} \geqslant b_{1} \geqslant \cdots$, and $a_{k} \leqslant x \leqslant b_{k}$ for all $k$. Then these sequences converge effectively to $x$, as we now show.

The differences $\left(b_{k}-a_{k}\right)$ decrease monotonically to zero. Hence, to define an effective modulus of convergence $e(N)$, we simply wait, for each $N$, until an index $e(N)$ with $\left(b_{e(N)}-a_{e(N)}\right) \leqslant 2^{-N}$ turns up.

In the above situation, we had two monotone sequences, converging upwards and downwards respectively to the limit $x$. Suppose we merely have one computable sequence $\left\{s_{k}\right\}$ which converges upwards monotonically to $x$. Then the convergence need not be effective.

To show this-our first example of noneffective convergence-we need some preliminary results. These results will be used several times throughout this book.

Lemma (Waiting Lemma). Let $a: \mathbb{N} \rightarrow \mathbb{N}$ be a one to one recursive function generating a recursively enumerable nonrecursive set $A$. Let $w(n)$ denote the "waiting time"

$$
w(n)=\max \{m: a(m) \leqslant n\} .
$$

Then there is no recursive function $c$ such that $w(n) \leqslant c(n)$ for all $n$.

Proof. The term "waiting time" contains the essential idea of the proof. If we could effectively bound the waiting time, then we would have a decision procedure for telling whether or not $n \in A$. Namely, wait until the waiting time for $n$ has elapsed. If the value $n$ has not turned up by this time then it never will. Now more formally:

Suppose, on the contrary, that $w(n) \leqslant c(n)$ with $c$ recursive. Then the set $A$ is recursive. Here is a decision procedure for $A$.

For any $n$, compute $a(m)$ for all $m \leqslant c(n)$. If one of these values $a(m)=n$, then $n \in A$; otherwise $n \notin A$.

To see this, we reason as follows. Obviously if $a(m)=n$ for some $m \leqslant c(n)$, then $n \in A$. Otherwise, since $c(n) \geqslant w(n)$, we have $a(m) \neq n$ for all $m \leqslant w(n)$. But $w(n)$ gives the last value of $m$ for which $a(m) \leqslant n$, and hence the last value (if any) for which
$a(m)=n$. Thus if $n$ has not turned up as a value of $a(m)$ by this time, then it never will.

There is a close connection between the waiting time defined above and the modulus of convergence for certain series.

Lemma (Optimal Modulus of Convergence). Let $a: \mathbb{N} \rightarrow \mathbb{N}$ be $a$ one to one recursive function generating a recursively enumerable nonrecursive set $A$, and let $w$ be the waiting time, as in the preceding lemma. Consider the series:

$$
s_{k}=\sum_{m=0}^{k} 2^{-a(m)}
$$

and let $x=\lim _{k \rightarrow \infty} s_{k}$. Define the "optimal modulus of convergence" $e^{*}(N)$ to be the smallest integer such that

$$
k \geqslant e^{*}(N) \quad \text { implies } \quad\left(x-s_{k}\right) \leqslant 2^{-N} .
$$

Then $w(N)=e^{*}(N)$.

Proof. For any $k$,

$$
x-s_{k}=\sum_{m=k+1}^{\infty} 2^{-a(m)}
$$

We will show that the waiting time $w(N)$ satisfies the conditions defining $e^{*}(N)$.
By definition of $w(N)$ as the last value $m$ with $a(m) \leqslant N$, we have in particular that $a[w(N)] \leqslant N$.

Suppose $k<w(N)$. Then the series for $x-s_{k}$ contains the term with $m=w(N)$, and the value of this term is $2^{-a[w(N)]} \geqslant 2^{-N}$. Since the series also contains other positive terms, $x-s_{k}>2^{-N}$.

Suppose $k \geqslant w(N)$. Then the series for $x-s_{k}$ (which begins with $m=k+1$ ) contains no term $2^{-a(m)}$ with $a(m) \leqslant N$. Hence the series is dominated by $\sum_{a=N+1}^{\infty} 2^{-a}= 2^{-N}$, and $x-s_{k} \leqslant 2^{-N}$.

Hence $w(N)$ fulfills precisely the condition by which we defined $e^{*}(N)$.
By combining the two previous lemmas, we have an example of a computable monotone sequence of rationals which converges, but does not converge effectively.

Example (Noneffective convergence, cf. Rice [1954], Specker [1949]). Let $a: \mathbb{N} \rightarrow \mathbb{N}$ be as in the two preceding lemmas, and let $\left\{s_{k}\right\}$ be the computable sequence given by:

$$
s_{k}=\sum_{m=0}^{k} 2^{-a(m)}
$$

Then $\left\{s_{k}\right\}$ converges noneffectively to its limit $x$.

Proof. Since the function $a$ is one to one, obviously the series converges. If the convergence were effective, there would be a recursive function $e(N)$ such that

$$
k \geqslant e(N) \quad \text { implies } \quad\left(x-s_{k}\right) \leqslant 2^{-N} .
$$

Comparing this with the "optimal" modulus of convergence in the previous lemma, we see that $e(N) \geqslant e^{*}(N)$.

By the previous lemma $e^{*}(N)=w(N)$, so that the recursive function $e(N) \geqslant w(N)$. By the Waiting Lemma, this is impossible.

Note. Although the sequence $s_{k}$ is computable, we cannot say that the limit $x$ is computable, since the convergence is noneffective. However, $x$ might still be computable, as there could be another computable sequence $\left\{r_{k}\right\}$ which converges effectively to $x$. In fact, as we shall show in the next section (Corollary 2b), this cannot happen: $x$ is not computable.

Alternative definitions of "computable real number". All of the standard definitions of real number (in the classical, noncomputable sense) effectivize to give the same definition of "computable real". Specifically, we list the following four well known methods for constructing the reals from the rationals:

1) Cauchy sequences (the method effectivized in this section).
2) Dedekind cuts.
3) Nested intervals.
4) Decimals to the base $b$, an integer $>1$.

The fact that the effective versions of $1-4$ are equivalent was first proved by R.M. Robinson [1951]. Robinson observed that the key step is to show that, for any computable real $\alpha$, the function $a(n)=[n \alpha]$ (where []$=$ greatest integer) is recursive. The equivalence of $1-4$ follows easily from this observation. In this regard we cite another important early paper of Rice [1954]. See also Mazur [1963].

In this book we shall work exclusively with definition 1 (Cauchy sequences). The equivalence of the other definitions is not needed. For that reason we do not spell out any further details.

## 2. Computable Sequences of Real Numbers

A sequence of real numbers may not be computable, even though each of its individual elements is. With a finite sequence, of course, there is no problem, since finitely many programs can be combined into one. But for an infinite sequence $\left\{x_{n}\right\}$, we might have a program for each $n$, but no way to combine these infinitely many programs into one.

To say that a sequence is computable means that there is a master program which, upon the input of the number $n$, computes $x_{n}$.

The idea of sequential computability plays a key role in this book. Consequently, in this section, we give a thorough treatment of the points at issue. First, we lay down the basic definitions. These definitions involve the notion of effective convergence of a double sequence $\left\{x_{n k}\right\}$ to a sequence $\left\{x_{n}\right\}$. We include a discussion of the similarities and contrasts between this and the analyst's notion of "uniform convergence". Two examples (Examples 1 and 2) illustrate these points. Then follow two propositions-Proposition 1 (closure under effective convergence) and Proposition 2 (dealing with monotone convergence)-which are used so often in this book that eventually we stop referring to them by name and simply regard them as "well known facts". Proposition 2, incidentally, leads us for the first time to noncomputable reals (Corollary 2b). The section closes with two more counterexamples (Examples 3 and 4) and several "facts" which follow from them. We suggest that the techniques used in constructing the examples may be of interest in their own right. These techniques, refined and extended, recur at many points throughout the book.

We turn now to the basic definitions.
As with the case of computable reals in Section 1, there are two aspects to the definition of a "computable sequence of reals" $\left.\left\{x_{n}\right\}: 1\right)$ we require computable double sequence of rationals $\left\{r_{n k}\right\}$ which converges to $\left\{x_{n}\right\}$ as $k \rightarrow \infty$, and 2 ) this convergence must be "effective". We now make these notions precise.

First a technicality. A double sequence will be called computable if it is mapped onto a computable sequence by one of the standard recursive pairing functions from $\mathbb{N} \times \mathbb{N}$ onto $\mathbb{N}$. Similarly for triple or $q$-fold sequences.

Definition 4. Let $\left\{x_{n k}\right\}$ be a double sequence of reals and $\left\{x_{n}\right\}$ a sequence of reals such that, as $k \rightarrow \infty, x_{n k} \rightarrow x_{n}$ for each $n$. We say that $x_{n k} \rightarrow x_{n}$ effectively in $k$ and $n$ if there is a recursive function $e: \mathbb{N} \times \mathbb{N} \rightarrow \mathbb{N}$ such that for all $n, N$ :

$$
k \geqslant e(n, N) \quad \text { implies } \quad\left|x_{n k}-x_{n}\right| \leqslant 2^{-N} .
$$

(In words, the variable $N$ corresponds to the error $2^{-N}$, and the function $e(n, N)$ gives a bound on $k$ sufficient to attain this error. Without loss of generality, we can assume that $e(n, N)$ is an increasing function of both variables.)

Combining Definition 4 with Definition 1 of the previous section, we obtain:
Definition 5. A sequence of real numbers $\left\{x_{n}\right\}$ is computable (as a sequence) if there is a computable double sequence of rationals $\left\{r_{n k}\right\}$ such that $r_{n k} \rightarrow x_{n}$ as $k \rightarrow \infty$, effectively in $k$ and $n$.

The following variant is often useful.
Definition 5a. A sequence of real numbers $\left\{x_{n}\right\}$ is computable (as a sequence) if there is a computable double sequence of rationals $\left\{r_{n k}\right\}$ such that

$$
\left|r_{n k}-x_{n}\right| \leqslant 2^{-k} \quad \text { for all } k \text { and } n .
$$

Obviously, the condition in Definition 5a implies that in Definition 5. For the converse, we reason as follows. From Definitions 4 and 5, there is a computable sequence of rationals $\left\{r_{n k}\right\}$, and a recursive function $e(n, N)$, such that $k \geqslant e(n, N)$ implies $\left|r_{n k}-x_{n}\right| \leqslant 2^{-N}$. Then we simply replace $\left\{r_{n k}\right\}$ by the computable subsequence,

$$
r_{n k}^{\prime}=r_{n, e(n, k)},
$$

to obtain $\left|r_{n k}^{\prime}-x_{n}\right| \leqslant 2^{-k}$, as desired.
The above definitions extend in the obvious way to complex numbers and to $q$-vectors. Thus a sequence of complex numbers is called computable if its real and imaginary parts are computable sequences. A sequence of $q$-vectors is called computable if each of its components is a computable sequence of real or complex numbers.

There are subleties associated with the idea of effective convergence which will come up repeatedly throughout this work. Many of these will be dealt with as they appear. However, the following discussion clarifies one simple point.

There is a possible confusion, which comes to the forefront in this book, between the notion of "uniformity" as used in logic and in analysis. When an analyst says " $x_{n k} \rightarrow x_{n}$ as $k \rightarrow \infty$, uniformly in $n$ " he or she means that the rate of convergence can be made independent of $n$. In logic, the same phrase would often mean dependent on $n$, but in a computable way. To avoid confusion, in this book we shall set the following conventions:
"uniformly in $n$ " means independent of $n$;
"effectively in $n$ " means governed by a recursive function of $n$.
Thus we use the word "uniformly" in the sense of analysis, and describe logical uniformities by the term "effective".

The following examples illustrate these distinctions.
Example 1. The double sequence

$$
x_{n k}=\frac{k}{k+n+1}
$$

converges as $k \rightarrow \infty$ to the sequence $\left\{x_{n}\right\}=\{1,1,1, \ldots\}$. The convergence is not uniform in $n$. However, the convergence is effective in both $k$ and $n$ : an effective modulus of convergence (for the error $2^{-N}$ ) is given by $e(n, N)=(n+1) \cdot 2^{N}$.

Example 2. In the previous section, we gave an example of a sequence $\left\{s_{k}\right\}$ which converges noneffectively to its limit $x$. Suppose we set

$$
x_{n k}=s_{k} \quad \text { for all } n .
$$

Then $\left\{x_{n k}\right\}$ converges uniformly in $n$ (since it does not depend on $n$ ), but noneffectively in $k$.

It is more difficult to give an example of a double sequence $\left\{x_{n k}\right\}$ which converges as $k \rightarrow \infty$, effectively in $k$ but noneffectively in $n$. We shall give such an example later in this section.

We now give two propositions concerning computable sequences. These will be used repeatedly throughout the book.

Proposition 1 (Closure under effective convergence). Let $\left\{x_{n k}\right\}$ be a computable double sequence of real numbers which converges as $k \rightarrow \infty$ to a sequence $\left\{x_{n}\right\}$, effectively in $k$ and $n$. Then $\left\{x_{n}\right\}$ is computable.

Proof. Since $\left\{x_{n k}\right\}$ is computable, we have by Definition 5a a computable triple sequence of rationals $\left\{\boldsymbol{r}_{\boldsymbol{n} \boldsymbol{k} \boldsymbol{N}}\right\}$ such that

$$
\left|r_{n k N}-x_{n k}\right| \leqslant 2^{-N} \quad \text { for all } n, k, N .
$$

Since $x_{n k} \rightarrow x_{n}$ effectively in $k$ and $n$, there is a recursive function $e(n, N)$ such that

$$
k \geqslant e(n, N) \quad \text { implies } \quad\left|x_{n k}-x_{n}\right| \leqslant 2^{-N} .
$$

Then the computable double sequence of rationals,

$$
r_{n N}^{\prime}=r_{n, e(n, N), N}
$$

satisfies

$$
\left|r_{n N}^{\prime}-x_{n}\right| \leqslant 2 \cdot 2^{-N},
$$

whence $\left\{x_{n}\right\}$ is computable, as desired.
Proposition 2 (Monotone convergence). Let $\left\{x_{n k}\right\}$ be a computable double sequence of real numbers which converges monotonically upwards to a sequence $\left\{x_{n}\right\}$ as $k \rightarrow \infty$ : i.e. $x_{n 0} \leqslant x_{n 1} \leqslant x_{n 2} \leqslant \cdots$ and $x_{n k} \rightarrow x_{n}$ for each $n$. Then $\left\{x_{n}\right\}$ is computable if and only if the convergence is effective in both $k$ and $n$.

Corollary 2a. If a computable sequence $\left\{x_{k}\right\}$ converges monotonically upwards to a limit $x$, then the number $x$ is computable if and only if the convergence is effective.

Corollary 2b. There exists a computable sequence of rationals which converges to a noncomputable real.
[In particular, this shows that the effective analog of the Bolzano-Weierstrass Theorem dos not hold.]

Proof of corollaries (assuming the proposition). Corollary 2a follows immediately by holding $n$ fixed.

For Corollary 2b. In Section 1 we gave an example of a computable sequence $\left\{s_{k}\right\}$ of rational numbers which converges monotonically upwards to a limit $x$, but
for which the convergence is not effective. Hence by Corollary 2a, the limit $x$ is not computable.

Proof of Proposition 2. The "if" part follows (without any assumption of monotonicity) from Proposition 1 above.

It is for the "only if" part that we need monotonicity. Suppose $\left\{x_{n}\right\}$ is computable. Since $\left\{x_{n k}\right\}$ is also computable, there exists a computable double sequence of rationals $\left\{r_{n N}\right\}$ and a computable triple sequence of rationals $\left\{r_{n k N}\right\}$ such that:

$$
\begin{aligned}
\left|r_{n N}-x_{n}\right| \leqslant 2^{-N} / 6 & \text { for all } n, N ; \\
\left|r_{n k N}-x_{n k}\right| \leqslant 2^{-N} / 6 & \text { for all } n, k, N .
\end{aligned}
$$

Now define the recursive function $e(n, N)$ to be the first index $k$ such that

$$
\left|r_{n k N}-r_{n N}\right| \leqslant 2^{-N} / 2
$$

Such a $k$ must exist, since $x_{n k} \rightarrow x_{n}$, and the sum of the two errors above is $2^{-N} / 3$. Furthermore,

$$
k=e(n, N) \quad \text { implies } \quad\left|x_{n k}-x_{n}\right| \leqslant \frac{5}{6} \cdot 2^{-N} .
$$

Now the fact that this holds for all $k \geqslant e(n, N)$, and not merely for $k=e(n, N)$, follows from the monotonicity of $\left\{x_{n k}\right\}$ as a function of $k$. Thus $e(n, N)$ provides an effective modulus of convergence for the limit process $x_{n k} \rightarrow x_{n}$.

The following remark is included for the sake of completeness.
Remark (Elementary functions). Let $\left\{x_{n}\right\}$ and $\left\{y_{n}\right\}$ be computable sequences of real numbers. Then the following sequences are computable:

$$
\begin{aligned}
& x_{n} \pm y_{n}, \\
& x_{n} y_{n}, \\
& x_{n} / y_{n} \quad\left(y_{n} \neq 0 \text { for all } n\right), \\
& \max \left(x_{n}, y_{n}\right) \text { and } \min \left(x_{n}, y_{n}\right), \\
& \exp x_{n}, \\
& \sin x_{n} \quad \text { and } \cos x_{n}, \\
& \log x_{n} \quad\left(x_{n}>0 \text { for all } n\right), \\
& \sqrt[m]{x_{n}} \quad\left(x_{n} \geqslant 0 \text { for all } n\right), \\
& \operatorname{arc} \sin x_{n} \quad \text { and arc } \cos x_{n} \quad\left(\left|x_{n}\right| \leqslant 1 \text { for all } n\right), \\
& \operatorname{arc} \tan x_{n} .
\end{aligned}
$$

Thus, in particular, the computable reals form a field. We will show in Section 6 that they also form a real closed field.

Proof. Algorithms for doing these computations are so well known that we need not set them down here. We give one example-not even the most complicated onebecause it illustrates the use of the "effective convergence proposition", Proposition 1 above.

First, the proofs of computability for addition, subtraction, and multiplication are routine. Then to prove the computability of $\left\{\exp x_{n}\right\}$, we use Taylor series. Let

$$
s_{n k}=\sum_{j=0}^{k}\left(x_{n}^{j} / j!\right)
$$

The double sequence $\left\{s_{n k}\right\}$ is computable and converges to $\left\{\exp x_{n}\right\}$ as $k \rightarrow \infty$, effectively in $k$ and $n$. Hence by Proposition 1, $\left\{\exp x_{n}\right\}$ is computable.

The functions $\sin x, \cos x, \operatorname{arc} \sin x$, and $\operatorname{arc} \cos x$ can all be handled similarly, by Taylor series which converge effectively over the entire domain of definition of the function. For $\operatorname{arc} \tan x$, we use the identity $\operatorname{arc} \tan x=\operatorname{arc} \sin \left[x /\left(1+x^{2}\right)^{1 / 2}\right]$. Now $\log x$ and $\sqrt[m]{x}$ require a little more work, since their Taylor series have limited domains of convergence. However, the detailed treatment of these functions is mundane, and we shall not spell it out.

Incidentally, the computability of $\operatorname{arc} \tan x_{n}$ implies the computability of $\pi$.
The last two examples in this section serve two purposes. First, they introduce techniques which will be used repeatedly throughout the book. Second, they have the merit of answering, at the same time, four different questions concerning the topics in this section. These results will appear as "facts" at the end.

In each of these examples, $a: \mathbb{N} \rightarrow \mathbb{N}$ is a one to one recursive function generating a recursively enumerable nonrecursive set $A$.

Example 3. Consider the computable double sequence $\left\{x_{n k}\right\}$ defined by:

$$
x_{n k}= \begin{cases}1 & \text { if } n=a(m) \text { for some } m \leqslant k \\ 0 & \text { otherwise }\end{cases}
$$

Then as $k \rightarrow \infty, x_{n k} \rightarrow x_{n}$ where:

$$
x_{n}=1 \quad \text { if } n \in A, \quad 0 \quad \text { if } n \notin A .
$$

Thus $\left\{x_{n}\right\}$ is the characteristic function of the set $A$.
Now $\left\{x_{n}\right\}$ is not a computable sequence of reals. For it if were, then by approximating the $x_{n}$ effectively to within an error of $1 / 3$, we would have an effective procedure to determine the integers $n \in A$ and also $n \notin A$. Thus the set $A$ would be recursive, a contradiction.

We mention in passing that, although $\left\{x_{n}\right\}$ is not a computable sequence of real numbers, its individual elements are computable reals-in fact, they are either 0 or 1.

Our last example is a modification of the preceding one,
Example 4. Consider the computable double sequence $\left\{x_{n k}\right\}$ defined by:

$$
x_{n k}= \begin{cases}2^{-m} & \text { if } n=a(m) \text { for some } m \leqslant k \\ 0 & \text { otherwise }\end{cases}
$$

Then as $k \rightarrow \infty, x_{n k} \rightarrow x_{n}$ where:

$$
x_{n}= \begin{cases}2^{-m} & \text { if } n=a(m) \text { for some } m \\ 0 & \text { if } n \notin A\end{cases}
$$

The case description of $\left\{x_{n}\right\}$ above is not effective, since it requires knowledge of $a(m)$ for infinitely many $m$. Nevertheless, $\left\{x_{n}\right\}$ is a computable sequence of reals. For the convergence of $x_{n k}$ to $x_{n}$ is effective in $k$ and $n$. To see this, we observe that the only case where $x_{n k} \neq x_{n}$ occurs when $n=a(m)$ for some $m>k$. Then $x_{n k}=0$, and $x_{n}=2^{-m}<2^{-k}$. Hence:

$$
\left|x_{n k}-x_{n}\right|<2^{-k} \quad \text { for all } k, n .
$$

Hence by Proposition 1, $\left\{x_{n}\right\}$ is computable.
The following facts are consequences of Examples 3 and 4 above.
Fact 1. Let $A$ be a recursively enumerable non recursive set, and let $\chi(n)$ be the characteristic function of $A$. Then there exists a computable double sequence $\left\{x_{n k}\right\}$ which converges (noneffectively) to $\chi(n)$ as $k \rightarrow \infty$.

This follows from Example 3, with $\chi(n)$ in place of $x_{n}$.
In Example 2 we gave an instance of a computable double sequence $\left\{x_{n k}\right\}$ which converges to a sequence $\left\{x_{n}\right\}$ as $k \rightarrow \infty$, effectively in $n$ but noneffectively in $k$. Now we reverse the situation:

Fact 2. There exists a computable double sequence $\left\{x_{n k}\right\}$ which converges to a sequence $\left\{x_{n}\right\}$ as $k \rightarrow \infty$, effectively in $k$ but noneffectively in $n$.

Again this follows from Example 3. Consider the $\left\{x_{n k}\right\}$ and $\left\{x_{n}\right\}$ given there. Fix $n$. Then the convergence of $x_{n k} \rightarrow x_{n}$ as $k \rightarrow \infty$ is effective in $k$; indeed, $x_{n k}=x_{n}$ for all but finitely many $k$. But the convergence is not effective in $n$. For if it were, then by Proposition 1 above, the limit sequence $\left\{x_{n}\right\}$ would be computable.

The next result substantiates an assertion made in Proposition 0 of Section 1.
Fact 3. The condition $x=0$ for computable real numbers cannot be decided effectively.

Here we use Example 4. The sequence $\left\{x_{n}\right\}$ given there is a computable sequence of real numbers. Yet the set $\left\{n: x_{n}=0\right\}$, which equals the set $\{n: n \notin A\}$, cannot be effectively listed.

Fact 4. There exists a sequence $\left\{x_{n}\right\}$ of rational numbers which is computable as a sequence of reals, but not computable as a sequence of rationals.

Again the sequence $\left\{x_{n}\right\}$ from Example 4 suffices. We have seen that $\left\{x_{n}\right\}$ is a computable sequence of reals. But $\left\{x_{n}\right\}$ is not a computable sequence of rationalsi.e. $x_{n}$ cannot be expressed in the form $x_{n}=(-1)^{s(n)}[p(n) / q(n)]$ with recursive functions $p, q, s$. For if it could, then the condition $x_{n}=0$ would be effectively decidable. As we saw in the discussion following Fact 3, this is not so.

Alternative definitions of "computable sequence of real numbers". This discussion parallels a corresponding discussion at the end of Section 1. However, there are striking differences in the results, as we shall see. In Section 1 we noted that, for a single computable real, there are numerous equivalent definitions. Thus the definitions via 1. Cauchy sequences (as in this book), 2. Dedekind cuts, 3. nested intervals, and 4. decimals to the base $b$, all effectivize to give equivalent definitions of "computable real number". However, Mostowski [1957] showed by counterexamples that the corresponding definitions for sequences of real numbers are not equivalent. He observed that the Cauchy definition is presumably the correct one.

There are several reasons for preferring the Cauchy definition. We mention the following in passing. Suppose we took any of the other above-mentioned definitions (e.g. via Dedekind cuts) for "computable sequence of reals". Then we would obtain some rather bizarre results, such as: There exist "computable" sequences $\left\{x_{n}\right\}$ and $\left\{y_{n}\right\}$ whose sum $\left\{x_{n}+y_{n}\right\}$ is not "computable". Of course, this does not happen with the Cauchy definition.
[The above-mentioned counterexample will be used nowhere in this book. Nevertheless, we give a brief explanation of it. Consider e.g. the Dedekind definition. It is possible to give an example of a Cauchy computable sequence $\left\{z_{n}\right\}$ which is not Dedekind computable, and in which the elements $z_{n}$ are rational numbers. On the other hand, it can be shown that if $\left\{x_{n}\right\}$ is Cauchy computable, and the values $x_{n}$ are irrational, then $\left\{x_{n}\right\}$ is Dedekind computable. Now, starting with the above example $\left\{z_{n}\right\}$, set $x_{n}=z_{n}+\sqrt{2}, y_{n}=-\sqrt{2}$. Then $\left\{x_{n}\right\}$ and $\left\{y_{n}\right\}$ are Cauchy computable, and they take irrational values. Hence $\left\{x_{n}\right\}$ and $\left\{y_{n}\right\}$ are Dedekind computable, but $\left\{x_{n}+y_{n}\right\}=\left\{z_{n}\right\}$ is not.]

## 3. Computable Functions of One or Several Real Variables

We begin with a bit of historical background. In recursion-theoretic practice, a real number $x$ is usually viewed as a function $a: \mathbb{N} \rightarrow \mathbb{N}$. Then a function of a real variable $f(x)$ is viewed as a functional, i.e. a mapping $\Phi$ from functions $a$ as above into similar functions $b$. Within this theory, there is a standard and well explored notion of a
recursive functional, investigated by Kleene and others. We shall not define these terms here, since we will not need them. Suffice it to say that these notions gave the original definition of "computable function of a real variable": the real-valued function $f$ is called computable if the corresponding functional $\Phi$ is recursive (Lacombe [1955a, 1955b], Grzegorczyk [1955, 1957]).

From a recursion-theoretic viewpoint, this definition appears to capture the notion of "computability" for real-valued functions very well. However, this approach is not readily amenable to work in analysis. For an analyst does not view a real number as a function $a: \mathbb{N} \rightarrow \mathbb{N}$, nor a function of a real variable as a functional from such functions $a$ into other functions $b$. Accordingly, much of the intuition of the analyst is lost. Clearly it is desirable to have a definition of "computable function of a real variable" equivalent to the recursion-theoretic one, but couched in the traditional notions of analysis.

Such a definition was provided by Grzegorczyk [1955, 1957]. It is equivalent, as Grzegorczyk proved, to the recursion-theoretic definition, but expressed in analytic terms. This is definition A below.

From the point of view of the analyst, Definition A is quite natural. For a real function $f$ is determined if we know (a) the values of $f$ on a dense set of points, and (b) that $f$ is continuous. Definition A simply effectivizes these notions. Condition (i) in Definition A effectivizes (a), and condition (ii) effectivizes (b).

In this book, we give another equivalent definition based on an effective version of the Weierstrass Approximation Theorem (Definition B). This definition is useful in many applications. The equivalence of Definitions A and B is proved in Sections 5 and 7.

One final note. The equivalent Definitions A and B below are the natural ones for continuous functions. However, there are other definitions which apply to more general classes of functions-e.g. $L^{p}$ functions. In fact, they apply to arbitrary Banach spaces. These definitions will be introduced in Chapter 2. They will play a major role in later chapters of the book. We will see, however, that when the general definitions of Chapter 2 are applied to the special case of continuous functions, they reduce to Definitions A and B.

We turn now to the definitions themselves.
For simplicity, we first consider the case where the function $f$ is defined on a closed bounded rectangle $I^{q}$ in $\mathbb{R}^{q}$. Specifically, $I^{q}=\left\{a_{i} \leqslant x_{i} \leqslant b_{i}, 1 \leqslant i \leqslant q\right\}$, where the endpoints $a_{i}, b_{i}$ are computable reals.

As noted above, the following definition is due to Grzegorczyk/Lacombe.
Definition $\mathbf{A}$ (Effective evaluation). Let $I^{q} \subseteq \mathbb{R}^{q}$ be a computable rectangle, as described above. A function $f: I^{q} \rightarrow \mathbb{R}$ is computable if:
(i) $f$ is sequentially computable, i.e. $f$ maps every computable sequence of points $x_{k} \in I^{q}$ into a computable sequence $\left\{f\left(x_{k}\right)\right\}$ of real numbers;
(ii) $f$ is effectively uniformly continuous, i.e. there is a recursive function $d: \mathbb{N} \rightarrow \mathbb{N}$ such that for all $x, y \in I^{q}$ and all $N$ :

$$
|x-y| \leqslant 1 / d(N) \text { implies }|f(x)-f(y)| \leqslant 2^{-N},
$$

where $\mid$ | denotes the euclidean norm.

Our second equivalent definition involves the notion of a computable sequence of polynomials. In the real case, which we are here considering, these polynomials can have rational coefficients.

By a computable sequence of rational polynomials, we mean a sequence

$$
p_{n}(x)=\sum_{i=0}^{D(n)} r_{n i} x^{i}
$$

where $D: \mathbb{N} \rightarrow \mathbb{N}$ is a recursive function, and $\left\{r_{n i}\right\}$ is a computable double sequence of rationals.

The following definition is due to Caldwell and Pour-El [1975].
Definition $\mathbf{B}$ (Effective Weierstrass). Let $I^{q} \subseteq \mathbb{R}^{q}$ be as above. A function $f: I^{q} \rightarrow \mathbb{R}$ is computable if there is a computable sequence of rational polynomials $\left\{p_{m}(x)\right\}$ which converges effectively to $f$ in uniform norm: this means there is a recursive function $e: \mathbb{N} \rightarrow \mathbb{N}$ such that for all $x \in I^{q}$ and all $N$ :

$$
m \geqslant e(N) \quad \text { implies } \quad\left|f(x)-p_{m}(x)\right| \leqslant 2^{-N} .
$$

The equivalence of Definitions A and B will be proved in Sections 5 and 7.

We must now extend these definitions to sequences of functions $\left\{f_{n}(x)\right\}$ and also to unbounded domains. These extensions follow very closely the pattern laid out in passing from Section 1 (computable real numbers) to Section 2 (computable sequences of real numbers). This extension process is routine: whenever a new parameter enters into a definition, the dependence on this parameter must be recursive. Now for the details.

We begin with the case of a sequence of functions, still restricted to a compact domain. The corresponding extensions of Definitions A and B above are:

Definition $\mathbf{A}^{\prime}$ (Effective evaluation). Let $I^{q} \subseteq \mathbb{R}^{q}$ be a computable rectangle. A sequence of functions $f_{n}: I^{q} \rightarrow \mathbb{R}$ is computable (as a sequence) if:
(i') for any computable sequence of points $x_{k} \in I^{q}$, the double sequence of reals $\left\{f_{n}\left(x_{k}\right)\right\}$ is computable;
(ii') there exists a recursive function $d: \mathbb{N} \times \mathbb{N} \rightarrow \mathbb{N}$ such that for all $x, y \in I^{q}$ and all $n, N$ :

$$
|x-y| \leqslant 1 / d(n, N) \quad \text { implies } \quad\left|f_{n}(x)-f_{n}(y)\right| \leqslant 2^{-N} .
$$

Definition $\mathbf{B}^{\prime}$ (Effective Weierstrass). Let $I^{q} \subseteq \mathbb{R}^{q}$ be a above. A sequence of functions $f_{n}: I^{q} \rightarrow \mathbb{R}$ is computable (as a sequence) if there is a computable double sequence of rational polynomials $\left\{p_{n m}(x)\right\}$ with the following property. There is a recursive function $e: \mathbb{N} \times \mathbb{N} \rightarrow \mathbb{N}$ such that for all $x \in I^{q}$ and all $n, N$ :

$$
m \geqslant e(n, N) \quad \text { implies } \quad\left|f_{n}(x)-p_{n m}(x)\right| \leqslant 2^{-N} .
$$

We now pass from the compact rectangle $I^{q}$ to the unbounded domain $\mathbb{R}^{q}$. This is done via a sequence of rectangles

$$
I_{M}^{q}=\left\{-M \leqslant x_{i} \leqslant M, 1 \leqslant i \leqslant q\right\},
$$

where $M=0,1,2, \ldots$ The idea is to require uniform continuity or convergence on each rectangle $I_{M}^{q}$, effectively in $M$. Then the definitions parallel Definitions $\mathrm{A}^{\prime}$ and $\mathbf{B}^{\prime}$ above, except that we have one new parameter, $M$.

Definition A" (Effective evaluation). A sequence of functions $f_{n}: \mathbb{R}^{q} \rightarrow \mathbb{R}$ is computable (as a sequence) if:
( $\mathrm{i}^{\prime \prime}$ ) for any computable sequence of points $x_{k} \in \mathbb{R}^{q}$, the double sequence of reals $\left\{f_{n}\left(x_{k}\right)\right\}$ is computable;
(ii") there exists a recursive function $d: \mathbb{N} \times \mathbb{N} \times \mathbb{N} \rightarrow \mathbb{N}$ such that for all $M, n, N$ :

$$
|x-y| \leqslant 1 / d(M, n, N) \text { implies } \quad\left|f_{n}(x)-f_{n}(y)\right| \leqslant 2^{-N} \quad \text { for all } x, y \in I_{M}^{q},
$$

where $I_{M}^{q}=\left\{-M \leqslant x_{i} \leqslant M, 1 \leqslant i \leqslant q\right\}$.
Definition $\mathbf{B}^{\prime \prime}$ (Effective Weierstrass). A sequence of functions $f_{n}: \mathbb{R}^{q} \rightarrow \mathbb{R}$ is computable (as a sequence) if there is a computable triple sequence of rational polynomials $\left\{p_{M n m}\right\}$ with the following property. There is a recursive function $e: \mathbb{N} \times \mathbb{N} \times \mathbb{N} \rightarrow \mathbb{N}$ such that for all $M, n, N$ :

$$
m \geqslant e(M, n, N) \text { implies }\left|f_{n}(x)-p_{M n m}(x)\right| \leqslant 2^{-N} \text { for all } x \in I_{M}^{q},
$$

where $I_{M}^{q}=\left\{-M \leqslant x_{i} \leqslant M, 1 \leqslant i \leqslant q\right\}$.
Remark. Without loss of generality, we can assume that the functions $d()$ and $e()$ are increasing in all variables. We shall frequently make this assumption.

Of course, Definitions $\mathrm{A}^{\prime \prime}$ and $\mathrm{B}^{\prime \prime}$ contain Definitions $\mathrm{A}^{\prime}$ and $\mathrm{B}^{\prime}$ (when we hold $M$ constant); and these in turn contain Definitions A and B (when we hold $n$ constant).

A complex-valued function is called computable if its real and imaginary parts are computable. Similarly for sequences of complex functions.

Standard functions. It is trivial to verify that most of the specific continuous functions encountered in analysis-e.g. $e^{x}, \sin x, \cos x, \log x, J_{0}(x)$ and $\Gamma(x)$, as well as $x \pm y$, $x y$ and $x / y$-are computable over any computable rectangle on which they are continuous. Those without singularities are computable over $\mathbb{R}^{q}(q=1,2, \ldots)$ as well.

To consider whether functions like $1 / x$ or $\log x$ are computable on the open interval $(0, \infty)$, we need a slight extension of our previous definitions. This we now give.

Computability on $(0, \infty)$. To define this, we simply mimic Definition $\mathrm{A}^{\prime \prime}$. In fact, to define the notion " $\left\{f_{n}\right\}$ is computable on $(0, \infty)$ ", we make precisely three changes
in Definition $\mathrm{A}^{\prime \prime}$. First we set the dimension $q=1$. Second, in condition ( $\mathrm{i}^{\prime \prime}$ ) we replace $x_{k} \in \mathbb{R}$ by $x_{k}>0$. Third, in condition (ii"), we replace the domain $I_{M}= [-M, M]$ by the interval $[1 / M, M]$. Otherwise, the definition reads exactly as before.

It is easy to verify that $1 / x$ is computable on $(0, \infty)$-and also in a like manner on ( $-\infty, 0$ ). Also $\log x$ is computable on ( $0, \infty$ ).

A similar definition would apply to any open interval $(a, b)$ with computable endpoints.

Definition B" could also be extended in a similar manner.
A technical remark. In Definitions $\mathbf{B}, \mathbf{B}^{\prime}$, and $\mathbf{B}^{\prime \prime}$ above, we have used computable sequences of rational polynomials. In an analogous way we could define a computable sequence of real polynomials. The Definitions $\mathbf{B}, \mathbf{B}^{\prime}, \mathbf{B}^{\prime \prime}$ could have been given in terms of real polynomials. For, by the methods of Sections 1 and 2, the real coefficients of the real polynomials can be effectively approximated by rationals. Henceforth, in applying Definitions B, $\mathbf{B}^{\prime}, \mathbf{B}^{\prime \prime}$, the versions based on real polynomials and rational polynomials will be used interchangeably.

Besides the definitions of Lacombe [1955a, 1955b] and Grzegorczyk [1955, 1957] cited above, we mention that Grzegorczyk in the same papers gave several equivalent definitions. Another equivalent definition has recently been suggested by Mycielski (cf. Pour-El, Richards [1983a]).

Finally, if we isolate condition (i) from Definition A (sequential computability), we obtain the Banach-Mazur definition. This is strictly broader than the definitions given above. An example of a sequentially computable continuous function which is not computable will be given in Chapter 1, Section 3.

## 4. Preliminary Constructs in Analysis

We turn now to the computable theory of functions of a real variable.
In this section we deal with composition, patching of functions, and extension of functions (Theorems 1-3 respectively). These are preliminary theorems which the usual practice of analysis takes for granted.

In Theorems 1, 1a, 1b we begin with a single computable function on a compact rectangle, and then gradually extend first to a noncompact domain, and then to a sequence of functions. These extensions are routine. Often in similar situations this is the case. However not always. In fact, sometimes the extensions do not hold at all. See, for example, Section 6 in this chapter and Sections 1 and 2 in Chapter 1.

In this section we give the proofs in all of their boring detail. Beginning in Section 5 , we adopt a more compressed style.

Finally a technical note. Until the equivalence of Definitions A and B is established, we will use Definition A (or its extensions $\mathrm{A}^{\prime}$ and $\mathrm{A}^{\prime \prime}$ ). Thus Theorems 1-5 in this and the next section are all based on Definition A.

Theorem 1 (Composition). Let $g_{1}, \ldots, g_{p}$ be computable functions from $I^{q} \rightarrow \mathbb{R}$, and suppose that the range of the vector ( $g_{1}, \ldots, g_{p}$ ) is contained in a computable rectangle
$I^{p}$. Let $f: I^{p} \rightarrow \mathbb{R}$ be computable. Then the composition $f\left(g_{1}, \ldots, g_{p}\right)$ is a computable function from $I^{q}$ into $\mathbb{R}$.

Proof. By Definition A, we must prove (i) sequential computability, and (ii) effective uniform continuity. For convenience, we write $\vec{g}=\left(g_{1}, \ldots, g_{p}\right)$.

Proof of (i). Let $\left\{x_{n}\right\}$ be a computable sequence of points in $I^{q}$. Since the functions $g_{i}$ are sequentially computable, $\left\{\vec{g}\left(x_{n}\right)\right\}$ is a computable sequence of points in $I^{q}$. Then, since $f$ is sequentially computable $\left\{f\left(\vec{g}\left(x_{n}\right)\right)\right\}$ is a computable sequence of reals, as desired.

Proof of (ii). Since this is our first proof dealing with effective uniform continuity, we shall give it in great detail.

From the effective uniform continuity of $g_{1}, \ldots, g_{p}$ and $f$, we have recursive functions $d_{1}, \ldots, d_{p}$ and $d^{*}$ such that, for all $x, y$ in $I^{q}$ or $I^{p}$, and for all $N$ :

$$
\begin{array}{lll}
|x-y| \leqslant 1 / d_{i}(N) & \text { implies } & \left|g_{i}(x)-g_{i}(y)\right| \leqslant 2^{-N}, \\
|x-y| \leqslant 1 / d^{*}(N) & \text { implies } & |f(x)-f(y)| \leqslant 2^{-N},
\end{array}
$$

where | | denotes the euclidean norm. We need to construct a recursive function $d^{* *}$ such that:

$$
|x-y| \leqslant 1 / d^{* *}(N) \quad \text { implies } \quad|f(\vec{g}(x))-f(\vec{g}(y))| \leqslant 2^{-N} .
$$

We begin with a heuristic approach. Starting with the desired inequality

$$
\begin{equation*}
|f(\vec{g}(x))-f(\vec{g}(y))| \leqslant 2^{-N} \tag{*}
\end{equation*}
$$

we will work backwards to find a suitable $d^{* *}(N)$. Then we will show that $d^{* *}$ is recursive, and that it does what is required.

By definition of $d^{*},(*)$ will hold provided that

$$
|\vec{g}(x)-\vec{g}(y)| \leqslant 1 / d^{*}(N)
$$

Since the vector $\vec{g}$ is $p$-dimensional, it suffices that for each component $g_{i}$,

$$
\left|g_{i}(x)-g_{i}(y)\right| \leqslant(1 / p)\left(1 / d^{*}(N)\right)
$$

A stronger (and therefore sufficient) condition is

$$
\left|g_{i}(x)-g_{i}(y)\right| \leqslant 2^{-Q} \quad \text { where } \quad 2^{Q} \geqslant p \cdot d^{*}(N) .
$$

Now by definition of the $d_{i}$,

$$
|x-y| \leqslant 1 / d_{i}(Q) \text { implies }\left|g_{i}(x)-g_{i}(y)\right| \leqslant 2^{-Q} .
$$

Comparing the last two displayed formulas, we are led to the following definition.

Define the recursive function $Q=Q(N)$ to be the least integer such that

$$
2^{Q} \geqslant p \cdot d^{*}(N)
$$

Then define the recursive function $d^{* *}$ by

$$
d^{* *}(N)=\max _{1 \leqslant i \leqslant p} d_{i}(Q(N))
$$

Now we verify that $d^{* *}$ serves as a modulus of continuity for $f(\vec{g})$. For, retracing our previous steps:

If $|x-y| \leqslant 1 / d^{* *}(N)$, then $|x-y| \leqslant 1 / d_{i}(Q(N))$ for all $i$, whence $\left|g_{i}(x)-g_{i}(y)\right| \leqslant 2^{-Q(N)} \leqslant(1 / p)\left(1 / d^{*}(N)\right)$ for all $i$, whence $|\vec{g}(x)-\vec{g}(y)| \leqslant 1 / d^{*}(N)$, whence $\mid f(\vec{g}(x))- f(\vec{g}(y)) \mid \leqslant 2^{-N}$, as desired.

We turn now to the extension of Theorem 1 to unbounded domains. The proof has one amusing twist. Although the definition of computability involves sequential computability and effective uniform continuity, the key issue in the proof below turns out to be the rate of growth of the $g_{i}(x)$ as $|x| \rightarrow \infty$.

Theorem la (Composition on unbounded domains). Let $g_{1}, \ldots, g_{p}$ be computable functions from $\mathbb{R}^{q} \rightarrow \mathbb{R}$, and let $f: \mathbb{R}^{p} \rightarrow \mathbb{R}$ be computable. Then $f\left(g_{1}, \ldots, g_{p}\right)$ is computable.

Proof. The proof of (i) sequential computability is the same as in Theorem 1 above.
Before proving (ii), we need the following. Recall that $I_{M}^{q}$ denotes the cube in $\mathbb{R}^{q}$ given by $\left|x_{i}\right| \leqslant M, 1 \leqslant i \leqslant q$.

Lemma (Rate of growth). Let $g: \mathbb{R}^{q} \rightarrow \mathbb{R}$ be a computable function. Then there exists a recursive function $a: \mathbb{N} \rightarrow \mathbb{N}$ such that for all natural numbers $M$ :

$$
x \in I_{M}^{q} \quad \text { implies } \quad|g(x)| \leqslant a(M)
$$

Proof of lemma. We use the fact that $g$ is effectively uniformly continuous on each $I_{M}^{q}$, in a manner which varies effectively in $M$. More precisely, there is a recursive function $d: \mathbb{N} \times \mathbb{N} \rightarrow \mathbb{N}$ such that

$$
|x-y| \leqslant 1 / d(M, N) \quad \text { implies } \quad|g(x)-g(y)| \leqslant 2^{-N} \quad \text { for all } x, y \in I_{M}^{q} .
$$

In particular, setting $N=0$

$$
|x-y| \leqslant 1 / d(M, 0) \quad \text { implies } \quad|g(x)-g(y)| \leqslant 1 .
$$

Now any point $x \in I_{M}^{q}$ can be connected to 0 by a straight line of length $\leqslant q M$. Suppose we break this line into $q \cdot M \cdot d(M, 0)$ equal segments, of length $\leqslant 1 / d(M, 0)$. Then on each segment, $|g(u)-g(v)| \leqslant 1$. Since there are $q \cdot M \cdot d(M, 0)$ segments
between the points $x$ and 0 , we have

$$
|g(x)-g(0)| \leqslant q \cdot M \cdot d(M, 0) \quad \text { for all } x \in I_{M}^{q}
$$

Let $C$ be an integer with $|g(0)| \leqslant C$. Define the recursive function $a$ by

$$
a(M)=q \cdot M \cdot d(M, 0)+C .
$$

Then $|g(x)| \leqslant a(M)$ for all $x \in I_{M}^{q}$, as desired.

Proof of (ii). Here the moduli of uniform continuity depend on the domain $I_{M}^{q}$, this dependence being effectively given by the recursive functions $d_{i}(M, N)$ and $d^{*}(M, N)$ (where $d_{1}, \ldots, d_{p}$ and $d^{*}$ correspond to $g_{1}, \ldots, g_{p}$ and $f$ as in Theorem 1 above). Without loss of generality, we can assume that $d_{1}, \ldots, d_{p}$ and $d^{*}$ are increasing functions. The point of the Lemma is that the function $\vec{g}=\left(g_{1}, \ldots, g_{p}\right)$ maps $I_{M}^{q}$ into a cube $I_{a(M)} \stackrel{p}{(M)}$ whose size is a recursive function of $M$. From here on, the proof is almost identical with that of Theorem 1.

Let $a_{i}(M)$ be the function corresponding to $g_{i}$ via the Lemma, and let $a(M)= \max \left\{a_{i}(M): 1 \leqslant i \leqslant p\right\}$.

Let $Q=Q(M, N)$ be the least integer such that

$$
2^{Q} \geqslant p \cdot d^{*}(a(M), N)
$$

Define $d^{* *}$ by

$$
d^{* *}(M, N)=\max _{1 \leqslant i \leqslant p} d_{i}(M, Q(M, N))
$$

Clearly $d^{* *}$ is recursive. The fact that, for $x, y \in I_{M}^{q},|x-y| \leqslant 1 / d^{* *}(M, N)$ implies $|f(\vec{g}(x))-f(\vec{g}(y))| \leqslant 2^{-N}$, is proved exactly as in Theorem 1 above.

Now we move on to sequences of functions. We continue to use the vector notation $\vec{g}=\left(g_{1}, \ldots, g_{p}\right)$ for mappings into $\mathbb{R}^{p}$.

Theorem 1b. Let $\vec{g}_{n}: \mathbb{R}^{q} \rightarrow \mathbb{R}^{p}$ be a computable sequence of vector-valued functions, and let $f_{m}: \mathbb{R}^{p} \rightarrow \mathbb{R}$ be a computable sequence of real functions. Then the compositions $f_{m}\left(\vec{g}_{n}\right)$ form a computable double sequence of real-valued functions.

Proof. The construction is identical to that in Theorem 1a, except that, where appropriate, we insert the parameters $m$ and $n$. Thus the functions $d_{1}, \ldots, d_{p}$ for $\vec{g}_{n}$ become $d_{i}(M, n, N)$. The function $d^{*}$ for $f_{m}$ becomes $d^{*}(M, m, N)$. The function $a$ in the Lemma becomes $a(M, n)$. Again we can assume that these functions are increasing. Finally the $d^{* *}$ for $f_{m}\left(\vec{g}_{n}\right)$ becomes

$$
d^{* *}(M, m, n, N)=\max _{1 \leqslant i \leqslant p} d_{i}(M, n, Q(M, m, n, N))
$$

where $Q$ is the least integer such that

$$
2^{Q} \geqslant p \cdot d^{*}(a(M, n), m, N)
$$

In the preceding proofs, effective uniform continuity played the key role. In the next result, we will find that sequential computability is the key issue. This result also suggests one reason why we require our intervals to have computable endpoints.

Theorem 2 (Patching theorem). Let $[a, b]$ and $[b, c]$ be intervals with computable endpoints, and let $f$ and $g$ be computable functions defined on $[a, b]$ and $[b, c]$ respectively, with $f(b)=g(b)$. Then the common extension of $f$ and $g$ is a computable function on $[a, c]$.

Proof. Write the common extension as $f \cup g$. Since $f$ and $g$ are effectively uniformly continuous, clearly $f \cup g$ is also effectively uniformly continuous. The sequential computability of $f \cup g$ is a little harder to prove.

Take any computable sequence $x_{n} \in[a, c]$; we need to show that the sequence $(f \cup g)\left(x_{n}\right)$ is computable. The difficulty is that there is no effective method for deciding in general whether $x_{n}<b, x_{n}=b$, or $x_{n}>b$. Thus we have no effective method for deciding which of the functions, $f$ or $g$, should be applied to $x_{n}$.

To remedy this, we shall construct a computable double sequence $\left\{x_{n N}\right\}$ as follows. Since $\left\{x_{n}\right\}$ is computable, there is a computable double sequence of rationals $r_{n N}$ such that $\left|x_{n}-r_{n N}\right| \leqslant 2^{-N}$ for all $n, N$. Since $b$ is computable, there is a computable sequence of rationals $s_{N}$ such that $\left|b-s_{N}\right| \leqslant 2^{-N}$ for all $N$.

Now computations with rational numbers can be performed exactly, so the following is an effective procedure. Define:

$$
x_{n N}= \begin{cases}x_{n} & \left|r_{n N}-s_{N}\right|>3 \cdot 2^{-N} \\ x_{n}-6 \cdot 2^{-N} & \text { otherwise }\end{cases}
$$

[By deleting finitely many $N$, we can assume that $12 \cdot 2^{-N}<(b-a)$, so that $x_{n N} \in$ [ $a, c$ ] in all cases.]

Now $x_{n N} \neq b$ for all $n, N$, and the above inequalities furnish an effective method for deciding whether $x_{n N}<b$ or $x_{n N}>b$. Namely: $x_{n N}>b$ if $r_{n N}-s_{N}>3 \cdot 2^{-N}$, and $x_{n N}<b$ otherwise.

Hence the double sequence $(f \cup g)\left(x_{n N}\right)$ is computable, since we have a method which is effective in $n$ and $N$ for deciding whether to apply $f$ to $x_{n N}$ (if $x_{n N}<b$ ), or to apply $g$ to $x_{n N}$ (if $x_{n N}>b$ ).

Now $\left|x_{n}-x_{n N}\right| \leqslant 6 \cdot 2^{-N}$, so $x_{n N} \rightarrow x_{n}$ as $N \rightarrow \infty$, effectively in $N$ and $n$. Since $f \cup g$ is effectively uniformly continuous, $(f \cup g)\left(x_{n N}\right) \rightarrow(f \cup g)\left(x_{n}\right)$ as $N \rightarrow \infty$, effectively in $N$ and $n$.

We apply Proposition 1 of Section 2:
Since $(f \cup g)\left(x_{n N}\right)$ is computable and converges to $(f \cup g)\left(x_{n}\right)$ as $N \rightarrow \infty$, effectively in all variables, $(f \cup g)\left(x_{n}\right)$ is computable, as desired.

The patching theorem has an obvious extension to $q$ dimensions.
Frequently in analytic arguments, one needs to extend the domain of definition of a function from a rectangle $I^{q}$ to a larger rectangle $I_{M}^{q}$. This is done, so to speak, to give us "room around the edges". The following theorem justifies this procedure.

Theorem 3 (Expansion theorem). Let $I^{q}=\left\{a_{i} \leqslant x_{i} \leqslant b_{i}, 1 \leqslant i \leqslant q\right\}$ be a computable rectangle in $\mathbb{R}^{q}$, let $M$ be an integer, and let $I_{M}^{q}=\left\{-M \leqslant x_{i} \leqslant M\right.$, all $\left.i\right\}$. Suppose that the rectangle $I_{M}^{q}$ contains $I^{q}$ in its interior. Then any computable function $f$ on $I^{q}$ can be extended to a computable function on $I_{M}^{q}$.

Proof. We prove this as a corollary of Theorems 1 and 2 . For $1 \leqslant i \leqslant q$, let

$$
y_{i}\left(x_{i}\right)= \begin{cases}a_{i} & \text { for }-M \leqslant x_{i} \leqslant a_{i} \\ x_{i} & \text { for } a_{i} \leqslant x_{i} \leqslant b_{i} \\ b_{i} & \text { for } b_{i} \leqslant x_{i} \leqslant M\end{cases}
$$

Then by the patching theorem, Theorem 2, the functions $y_{i}$ are computable. Furthermore, the vector $\vec{y}=\left(y_{1}, \ldots, y_{q}\right)$ maps $I_{M}^{q}$ into the smaller rectangle $I^{q}$.

Finally, by the composition theorem, Theorem 1, the function

$$
f\left(y_{1}\left(x_{1}\right), \ldots, y_{q}\left(x_{q}\right)\right)
$$

is computable on $I_{M}^{q}$. This gives the desired extension of $f$.

## 5. Basic Constructs of Analysis

This section contains three main topics. The first is closure under effective uniform convergence (Theorem 4). The second is the equivalence of Definitions A and B (Theorem 6). The third is integration.

A preliminary result about integration (Theorem 5) is given because it is needed for the proof of Theorem 6. Once we have Theorem 6, a variety of more difficult integration theorems can be proved (Corollaries 6a, b, c). A thoroughgoing treatment of integration has been included because several types of integrals-integrals depending on a parameter, line integrals, surface integrals, etc.-occur routinely in analysis and its applications to physics. For example, in this book we use Kirchhoff's solution formula for the wave equation, which depends on integration over a sphere (cf. Chapter 3, Section 5).
[Differentiation is treated in Chapter 1; cf. the remark at the end of this section.]
We recall that, until we have the equivalence of Definitions A and B, our working definition of "computable function of a real variable" is Definition A.

We turn now to closure under effective uniform convergence. First we must define what it means for a sequence of functions to be effectively uniformly conver-
gent. Although the definition of this term is implicit in Sections 2 and 3, we set it down:

Definition. Let $\left\{f_{n k}\right\}$ and $\left\{f_{n}\right\}$ be respectively a double sequence and sequence of functions from $I^{q}$ into $\mathbb{R}$. We say that $f_{n k} \rightarrow f_{n}$ as $k \rightarrow \infty$, uniformly in $x$, effectively in $k$ and $n$, if there is a recursive function $e: \mathbb{N} \times \mathbb{N} \rightarrow \mathbb{N}$ such that for all $n$ and $N$ :

$$
k \geqslant e(n, N) \quad \text { implies } \quad\left|f_{n k}(x)-f_{n}(x)\right| \leqslant 2^{-N} \quad \text { for all } x \in I^{q} .
$$

Theorem 4 (Closure under effective uniform convergence). Let $f_{n k}: I^{q} \rightarrow \mathbb{R}$ be a computable double sequence of functions such that $f_{n k} \rightarrow f_{n}$ as $k \rightarrow \infty$, uniformly in $x$, effectively in $k$ and $n$. Then $\left\{f_{n}\right\}$ is a computable sequence of functions.

Proof. For simplicity, we suppress the index $n$, and consider a sequence of functions $f_{k}$ which is effectively uniformly convergent to a limit $f$. The extension to $f_{n k} \rightarrow f_{n}$ is left to the reader. We begin by proving (ii) that $f$ is effectively uniformly continuous.

By hypothesis, there is a recursive function $e: \mathbb{N} \rightarrow \mathbb{N}$ such that

$$
k \geqslant e(N) \text { imples }\left|f_{k}(x)-f(x)\right| \leqslant 2^{-N} \quad \text { for all } x \in I^{q} .
$$

Since the sequence $\left\{f_{k}\right\}$ is uniformly continuous, effectively in $k$, there is a recursive function $d: \mathbb{N} \times \mathbb{N} \rightarrow \mathbb{N}$ such that for all $x, y \in I^{q}$ and all $k$ and $N$ :

$$
|x-y| \leqslant 1 / d(k, N) \quad \text { implies } \quad\left|f_{k}(x)-f_{k}(y)\right| \leqslant 2^{-N}
$$

Replacing $N$ by $N+2$ throughout, the error $2^{-N}$ becomes $2^{-N-2}=(1 / 4) \cdot 2^{-N}< (1 / 3) \cdot 2^{-N}$. Then to bound $|f(x)-f(y)|$, we compare $f(x)$ to $f_{k}(x)$ to $f_{k}(y)$ to $f(y)$ in the standard way. Thus we define the recursive function $d^{*}$ by:

$$
d^{*}(N)=d(e(N+2), N+2)
$$

We now show that $d^{*}$ serves as an effective modulus of continuity for $f$. Take any $x, y \in I^{q}$ with $|x-y| \leqslant 1 / d^{*}(N)$. Set $k=e(N+2)$. Then $\left|f(x)-f_{k}(x)\right|< (1 / 3) \cdot 2^{-N}$ (by definition of $e$ ); $\left|f_{k}(x)-f_{k}(y)\right|<(1 / 3) \cdot 2^{-N}$ (by definition of $d$ ); and $\left|f_{k}(y)-f(y)\right|<(1 / 3) \cdot 2^{-N}$ (by definition of $e$ ). Hence $|f(x)-f(y)| \leqslant 2^{-N}$, as desired.

Proof of (i) (sequential computability). There is one amusing point in this otherwise routine proof. Take any computable sequence $\left\{x_{m}\right\}$ in $I^{q}$; we need to show that $\left\{f\left(x_{m}\right)\right\}$ is computable. Since $f_{k}\left(x_{m}\right) \rightarrow f\left(x_{m}\right)$ as $k \rightarrow \infty$, it would suffice, in view of Proposition 1 in Section 2, if the convergence were effective in $k$ and $m$. But in fact we have more: since $f_{k}(x) \rightarrow f(x)$ as $k \rightarrow \infty$, effectively in $k$ and uniformly in $x$, the convergence of $f_{k}\left(x_{m}\right)$ to $f\left(x_{m}\right)$ is actually effective in $k$ and uniform in $m$.
(Thus the weaker condition of effectiveness = "logical uniformity" is here deduced from uniformity in the analytic sense-a circumstance which is rather rare.)

We turn now to a preliminary result on the computability of integrals. This is needed to prove the equivalence of Definitions A and B (Theorem 6 below). Once we have Theorem 6, we shall find that the result on integration can easily be extended to a much more general setting.

Theorem 5 (Definite Integrals). Let $I^{q}$ be a computable rectangle in $\mathbb{R}^{q}$, and let $f_{n}: I^{q} \rightarrow \mathbb{R}$ be a computable sequence of functions. Then the definite integrals

$$
v_{n}=\int \cdots \int_{I^{q}} f_{n}\left(x_{1}, \ldots, x_{q}\right) d x_{1} \ldots d x_{q}
$$

form a computable sequence of real numbers.
Proof. We effectivize the Riemann sum definition of the integral. For simplicity, we take $q=1$, leaving the general case to the reader. Thus the integration is over a 1-dimensional interval $[a, b]$, and

$$
v_{n}=\int_{a}^{b} f_{n}(x) d x
$$

For any $k \geqslant 1$, let $v_{n k}$ be the $k$-th Riemann sum approximation

$$
v_{n k}=\frac{b-a}{k} \cdot \sum_{j=1}^{k} f_{n}\left(a+\frac{j}{k}(b-a)\right) .
$$

Since $a, b$ are computable reals, and since $\left\{f_{n}\right\}$ is sequentially computable, the double sequence $\left\{v_{n k}\right\}$ is computable.

To show that $v_{n k}$ converges to $v_{n}$, effectively in $k$ and $n$, we use the effective uniform continuity of the $f_{n}$. Thus there is a recursive function $d(n, N)$ such that

$$
|x-y| \leqslant 1 / d(n, N) \quad \text { implies } \quad\left|f_{n}(x)-f_{n}(y)\right| \leqslant 2^{-N}
$$

Let $M$ be an integer $>(b-a)$, and let

$$
e(n, N)=M \cdot d(n, N)
$$

We will show that

$$
\begin{equation*}
k \geqslant e(n, N) \quad \text { implies } \quad\left|v_{n k}-v_{n}\right| \leqslant(b-a) \cdot 2^{-N} . \tag{*}
\end{equation*}
$$

To prove (*), let $I_{j}$ be the $j$-th subinterval corresponding to the above Riemann sum, that is

$$
I_{j}=\left[a+\frac{j-1}{k}(b-a), a+\frac{j}{k}(b-a)\right]
$$

Suppose $k \geqslant e(n, N)$. Then each subinterval $I_{j}$ has length equal to $(b-a) / k$ where

$$
(b-a) / k<M / k \leqslant M / e(n, N)=1 / d(n, N) .
$$

By definition of $d(n, N)$, this means that the function $f_{n}$ varies by $\leqslant 2^{-N}$ over each interval $I_{j}$. Hence the difference $\left(v_{n k}-v_{n}\right)$ between the Riemann sum and the integral satisfies:

$$
\begin{aligned}
\left|v_{n k}-v_{n}\right| & \leqslant \sum_{j=1}^{k}\left(\text { maximum variation of } f_{n} \text { over } I_{j}\right) \cdot\left(\text { length of } I_{j}\right) \\
& \leqslant k \cdot 2^{-N} \cdot \frac{(b-a)}{k} \\
& \leqslant(b-a) \cdot 2^{-N}
\end{aligned}
$$

proving (*).
Since the function $e(n, N)$ is recursive, (*) implies that $v_{n k} \rightarrow v_{n}$ as $k \rightarrow \infty$, effectively in $k$ and $n$. Since $\left\{v_{n k}\right\}$ is computable and approaches $v_{n}$ as $k \rightarrow \infty$, effectively in both variables, $\left\{v_{n}\right\}$ is computable (cf. Proposition 1 in Section 2).

## Equivalence of Definitions $A$ and $B$

Up to now, all of our work has been based on Definition A and its extensions A' and $\mathrm{A}^{\prime \prime}$. We now consider the equivalence of Definitions A and B . This is the content of Theorem 6 below. Since Definition B is based on polynomial approximation, this amounts to giving an effective treatment of the Weierstrass Approximation Theorem.

Actually, the proof of the Effective Weierstrass Theorem is quite complicated. We postpone it until Section 7. The reason for stating Theorem 6 here is that its corollaries (Corollaries 6a, b, c) properly belong in this section. On the other hand, the proof in Section 7 uses only Theorems 1-5.

We remark, however, that part of the proof of Theorem 6 below-the easy part-is given right here in this section. This is done so as not to clutter up the Effective Weierstrass proof in Section 7.

We recall that Definitions $\mathbf{A}$ and $\mathbf{B}$ apply to a single real-valued function $f$ defined on a computable rectangle $I^{q}$. Definitions $\mathrm{A}^{\prime}$ and $\mathrm{B}^{\prime}$ apply to a sequence of functions $f_{n}$ on $I^{q}$, and $\mathrm{A}^{\prime \prime} / \mathrm{B}^{\prime \prime}$ apply to a sequence of functions on $\mathbb{R}^{q}$.

Theorem 6 (Equivalence of Definitions A and B). Definitions A and B are equivalent. Similarly for Definitions $A^{\prime}$ and $B^{\prime}$, and for Definitions $A^{\prime \prime}$ and $B^{\prime \prime}$.

Proof. We shall give the proof for Definitions $\mathbf{A}$ and $\mathbf{B}$. The extension to $\mathbf{A}^{\prime} / \mathbf{B}^{\prime}$ and $\mathrm{A}^{\prime \prime} / \mathrm{B}^{\prime \prime}$ is routine, involving only a proliferation of indices.

Furthermore, we consider only the case of dimension $q=1$. The extension to $q$ dimensions is also routine.

Definition B implies Definition A. Let $f$ satisfy Definition B. Then there exists a computable sequence of polynomials $\left\{p_{m}\right\}$ which converges effectively and uniformly to $f$. By Theorem 4 above (closure under effective uniform convergence), $f$ is computable in the sense of Definition A.

Definition A implies Definition B. The proof will be given in Section 7. $\square$

## Integration

Here the preliminary Theorem 5 above is extended to cover a variety of integration processes. These extensions depend on Theorem 6, which allows us to use Definition B in place of Definition A. In fact, the powerful and general Corollary 6c could hardly be proved in any other way.

Corollary 6c combines in one statement: (1) integrals depending on a parameter $t$; (2) integration over a general class of regions in $\mathbb{R}^{3}$ (i.e. regions-like the interior of a sphere-which are not rectangles); and (3) line integrals and surface integrals.
[Of course, instead of $\mathbb{R}^{3}$ we could have stated Corollary 6c for $\mathbb{R}^{n}$; we used $\mathbb{R}^{3}$ for convenience.]

In order to achieve this generality, Corollary 6c requires a bit of preface. The conditions involve compact regions $K$ in $\mathbb{R}^{3}$ and measures $\mu$ on $K$. At first glance, these considerations may appear a trifle ponderous. In fact, however, they ae entirely natural. Consider, for example, a compact surface $K$ in $\mathbb{R}^{3}$. Then $K$ has Lebesgue measure zero. But the very notion of surface integration implies that there is some measure $\mu$ (e.g. the area measure) with respect to which we are integrating. Hence we have the pair $\langle K, \mu\rangle=\langle$ compact set, measure $\rangle$. This is absolutely standard, and we have merely put the situation into a general format in order to cover a wide variety of applications.

The main hypothesis in Corollary 6 c is that the monomials $x^{a} y^{b} z^{c}$ have computable integrals with respect to $K$ and $\mu$, effectively in $a, b$, and $c$. This is easily verified in most applications. Then the Effective Weierstrass condition of Definition B permits an immediate extension from the monomials to arbitrary computable functions.
[By contrast, a proof based on Definition A would be pretty ugly, even for such a simple domain as the surface of the unit sphere in $\mathbb{R}^{3}$.]

Corollaries 6a and 6b involve elementary results which seem important enough to be displayed separately.

Corollary $6 \mathbf{a}$ (Indefinite integrals). Let $f$ be a computable function on a computable interval $[a, b]$. Then the indefinite integral

$$
\int_{a}^{x} f(u) d u
$$

is computable on $[a, b]$.

Corollary $\mathbf{6 b}$ (Definite integrals depending on a parameter). Let $f(x, t)$ be a computable function on the rectangle $[a, b] \times[c, d]$. Then the function

$$
F(t)=\int_{a}^{b} f(x, t) d x
$$

is computable on $[c, d]$.
Proofs. See the proof of Corollary 6c.
As a preparation for Corollary 6 c we need:

Definition. Let $K$ be a compact set in $R^{q}$. We say that a real-valued function $f$ on $K$ is computable if $f$ has an extension to a computable function on a computable rectangle $I^{q} \supseteq K$.

For notational convenience, we give the next definition for 3-dimensional space, and write a typical point in $\mathbb{R}^{3}$ as $(x, y, z)$.

Definition. Let $K$ be a compact set in $\mathbb{R}^{3}$, and let $\mu$ be a finite measure on $K$. We say that the pair $\langle K, \mu\rangle$ is computably integrable if for $a, b, c \in \mathbb{N}$,

$$
v_{a b c}=\int_{K} x^{a} y^{b} z^{c} d \mu
$$

is a computable triple sequence of real numbers.

Notes. We have not defined either a "computable compact set" or a "computable measure". The above definition expresses a property of the pair $\langle K, \mu\rangle$. Moreover, this definition does not require that the integrals be computed by some "constructive method"; merely that the results of the integration yield a computable sequence.

Examples. First, let $\mu$ be Lebesgue measure. Practically every specific region $K$ encountered in elementary analysis is computably integrable. For all that is required is that the integrals of $x^{a} y^{b} z^{c}$ over $K$ yield a computable sequence of values. In particular, the following are computably integrable with respect to Lebesgue measure:

A disk with computable center and radius,
An ellipsoid with computable center and axes,
A computable rectangle,
A polyhedron given by computable parameters,
A cylinder or cone given by computable parameters.
A second class of example involves line or surface integrals. One instance which is important in physical applications is:

The unit sphere $K=\left\{x^{2}+y^{2}+z^{2}=1\right\}$, with the area measure $\mu=d \sigma$ normalized so that the total area equals 1 .

The next result covers all of these cases, and also allows integrals depending on a parameter.

Corollary 6c (Integration over regions). Let $K$ be a compact set in $\mathbb{R}^{3}$, and let $\mu$ be a finite measure on $K$. Suppose that the pair $\langle K, \mu\rangle$ is computably integrable. Let $I^{q}$ be a computable rectangle in $\mathbb{R}^{q}$. Let $f(x, y, z, t), t \in I^{q}$, be computable on $K \times I^{q}$. Then

$$
F(t)=\iiint_{K} f(x, y, z, t) d \mu(x, y, z)
$$

is computable on $I^{q}$.
Proof. We use Definition B. Since $f(x, y, z, t)$ is computable, there is a computable sequence of polynomials $\left\{p_{m}(x, y, z, t)\right\}$ which converges to $f(x, y, z, t)$ as $m \rightarrow \infty$, uniformly in ( $x, y, z, t$ ) and effectively in $m$.

These polynomials are computable finite linear combinations of the monomials

$$
x^{a} y^{b} z^{c} t^{d}
$$

where

$$
t^{d}=t_{1}^{d_{1}} t_{2}^{d_{2}} \ldots t_{q}^{d_{q}} .
$$

[Actually, since the integration involves only $x, y, z$, the $t^{d}$ terms behave like constants and can be taken outside of the integral.]

Now since the pair $\langle K, \mu\rangle$ is computably integrable,

$$
\iiint_{K} x^{a} y^{b} z^{c} d \mu(x, y, z)
$$

is a computable triple sequence of real numbers.
Hence the sequence of polynomials

$$
P_{m}(t)=\iiint p_{m}(x, y, z, t) d \mu(x, y, z)
$$

is computable.
Finally, since $p_{m} \rightarrow f$, uniformly in ( $x, y, z, t$ ) and effectively in $m$, and since the set $K$ has finite $\mu$-measure,

$$
P_{m}(t) \rightarrow F(t) \quad \text { as } m \rightarrow \infty
$$

uniformly in $t$ and effectively in $m$. Hence by Theorem 4, $F(t)$ is computable as desired.

After such an extended study of integration, the reader may wonder why we do not consider differentiation. The reason is that the computable theory of differentiation is more difficult. It is dealt with in Chapter 1.

## 6. The Max-Min Theorem and the Intermediate Value Theorem

This is the first section in which the distinction between computable elements and computable sequences finds illustration in a natural setting.

The maximum value of a computable function is computable (Theorem 7). This result extends to computable sequences of functions. By contrast, the Effective Intermediate Value Theorem (Theorem 8) holds for individual computable functionsbut it does not hold for computable sequences of functions (Example 8a).

In addition, this section includes the following. Theorem 9 asserts that the computable reals form a real closed field. The section closes with a few remarks about the Mean Value Theorem.

Theorem 7 (Maximum Values). Let $I^{q}$ be a computable rectangle in $\mathbb{R}^{q}$, and let $f_{n}: I^{q} \rightarrow \mathbb{R}$ be a computable sequence of functions. Then the maximum values

$$
s_{n}=\max \left\{f_{n}(x): x \in I^{q}\right\}
$$

form a computable sequence of real numbers.
Proof. As previously, we shall treat the 1 -dimensional case, where the $f_{n}$ are defined on a computable interval $[a, b]$, and leave the $q$-dimensional case to the reader.

We use Definition A. The proof, like that of Theorem 5 above (definite integrals), is based on a partitioning of the interval $[a, b]$. For any $k \geqslant 1$, let $s_{n k}$ be the "partial maximum"

$$
s_{n k}=\max \left\{f_{n}\left[a+\frac{j}{k}(b-a)\right]: 1 \leqslant j \leqslant k\right\} .
$$

Since $a, b$ are computable reals, and since $\left\{f_{n}\right\}$ is sequentially computable, the double sequence $\left\{s_{n k}\right\}$ is computable.

By the effective uniform continuity of $\left\{f_{n}\right\}$, there is a recursive function $d(n, N)$ such that

$$
|x-y| \leqslant 1 / d(n, N) \quad \text { implies } \quad\left|f_{n}(x)-f_{n}(y)\right| \leqslant 2^{-N} .
$$

Let $M$ be an integer $>(b-a)$, and let

$$
e(n, N)=M \cdot d(n, N)
$$

Then, as in Theorem 5 above, it follows that

$$
k \geqslant e(n, N) \quad \text { implies } \quad\left|s_{n k}-s_{n}\right| \leqslant 2^{-N}
$$

Thus $s_{s k} \rightarrow s_{n}$ as $k \rightarrow \infty$, effectively in $k$ and $n$. Since $\left\{s_{n k}\right\}$ is computable, this implies, by Proposition 1 in Section 2, that $\left\{s_{n}\right\}$ is computable.

Remark. Although the maximum value of a computable function $f(x)$ is computable, the point(s) $x$ where this maximum occurs need not be. Specker [1959] has given an example of a computable function $f$ on $[0,1]$ which does not attain its maximum at any computable point. (For alternative constructions, see Kreisel [1958] and Lacombe [1957b].) In these examples, there are infinitely many maximum points. This is inevitable, for it can be shown:

If a computable function $f$ takes a local maximum at an isolated point $x$ (i.e. if $f(y)<f(x)$ for all $y$ sufficiently close to $x$ with $y \neq x)$, then $x$ is computable.

We do not need this result and shall not prove it.
Our next result is interesting in that it holds for single functions $f$ and does not hold for sequences of functions.

Theorem 8 (Intermediate Value Theorem). Let $[a, b]$ be an interval with computable endpoints, and let $f$ be a computable function on $[a, b]$ such that $f(a)<f(b)$. Let $s$ be a computable real with $f(a)<s<f(b)$. Then there exists a computable point $c$ in $(a, b)$ such that $f(c)=\mathrm{s}$.

Proof. We can assume without loss of generality that the domain of $f$ is $[0,1]$ and that $s=0$.

Now the proof breaks into two cases:
Case 1. There is some rational number $c$ such that $f(c)=0$. Then $c$ is computable, and we are finished.

Case 2. $f(c) \neq 0$ for all rational $c$.

Now this assumption allows us to effectivize a procedure which would otherwise not be effective. Namely:

Consider $f(1 / 2)$. Since $f(1 / 2) \neq 0$, a sufficiently good approximation to $f(1 / 2)$ will allow us to decide-effectively-whether $f(1 / 2)>0$ or $f(1 / 2)<0$ (cf. Proposition 0 in Section 1). In the former case we replace the interval [ 0,1 ] by [ $0,1 / 2$ ]; in the latter case, we replace $[0,1]$ by $[1 / 2,1]$.

We continue in this manner. After the $m^{\text {th }}$ stage, we have an interval $\left[a_{m}, b_{m}\right]$ of length $1 / 2^{m}$, with rational endpoints, and with $f\left(a_{m}\right)<0$ and $f\left(b_{m}\right)>0$. We take the midpoint $d_{m}=\left(a_{m}+b_{m}\right) / 2$, and compute $f\left(d_{m}\right)$ with sufficient accuracy to determine whether $f\left(d_{m}\right)>0$ or $f\left(d_{m}\right)<0$ (again using the fact that, since $d_{m}$ is rational, $f\left(d_{m}\right) \neq 0$ ).

$$
\begin{aligned}
& \text { If } f\left(d_{m}\right)>0 \text {, we set } a_{m+1}=a_{m}, b_{m+1}=d_{m} \text {. } \\
& \text { If } f\left(d_{m}\right)<0 \text {, we set } a_{m+1}=d_{m}, b_{m+1}=b_{m} \text {. }
\end{aligned}
$$

The sequences $\left\{a_{m}\right\}$ and $\left\{b_{m}\right\}$ converge from below, and from above respectively, to a point $c$ such that $f(c)=0$. Since $b_{m}-a_{m}=2^{-m}$, the convergence is effective. Hence $c$ is computable.

Now we give a counterexample for sequences of functions.
Example 8a (Failure of the Intermediate Value Theorem for sequences). There exists a computable sequence of functions $f_{n}$ on $[0,1]$ such that $f_{n}(0)=-1$ for all $n$, $f_{n}(1)=1$ for all $n$, but there is no computable sequence of points $c_{n}$ in $[0,1]$ with $f_{n}\left(c_{n}\right)=0$ for all $n$.

Proof. We use a recursively inseparable pair of sets $A$ and $B$, i.e. disjoint subsets $A$ and $B$ of $\mathbb{N}$ which are recursively enumerable, but such that there is no recursive set $C$ with $A \subseteq C$ and $B \cap C=\emptyset$.

Let $a: \mathbb{N} \rightarrow \mathbb{N}$ and $b: \mathbb{N} \rightarrow \mathbb{N}$ be recursive functions giving one-to-one listings of the sets $A$ and $B$ respectively.
[A rough summary of the following construction is given in the Notes at the end. We put these comments at the end since, without the details, they might be found more vague than helpful.]

Each function $f_{n}(x)$ will be piecewise linear and continuous, with the breaks in its derivative occurring at the points $1 / 3$ and $2 / 3$. Thus each $f_{n}$ is determined by the four values $f_{n}(0), f_{n}(1 / 3), f_{n}(2 / 3), f_{n}(1)$. We set

$$
\begin{array}{ll}
f_{n}(0)=-1 & \text { for all } n \\
f_{n}(1)=1 & \text { for all } n
\end{array}
$$

The interesting points are $1 / 3$ and $2 / 3$. Hence we set:

$$
\begin{aligned}
& f_{n}(1 / 3)= \begin{cases}-1 / 2^{m} & \text { if } n \in A, n=a(m), \\
0 & \text { if } n \notin A .\end{cases} \\
& f_{n}(2 / 3)= \begin{cases}1 / 2^{m} & \text { if } n \in B, n=b(m), \\
0 & \text { if } n \notin B .\end{cases}
\end{aligned}
$$

It is by no means clear from this description that $\left\{f_{n}\right\}$ is computable-for we have no effective test to determine whether $n \in A, n \in B$, or $n \in \mathbb{N}-(A \cup B)$. However, $\left\{f_{n}\right\}$ actually is computable as we now show.

We define a double sequence $\left\{f_{n k}\right\}$ of piecewise linear functions by:

$$
\begin{aligned}
f_{n k}(0) & =-1, \quad f_{n k}(1)=1 \quad \text { for all } n, k . \\
f_{n k}(1 / 3) & = \begin{cases}-1 / 2^{m} & \text { if } n=a(m) \text { for some } m \leqslant k, \\
0 & \text { otherwise } .\end{cases} \\
f_{n k}(2 / 3) & = \begin{cases}1 / 2^{m} & \text { if } n=b(m) \text { for some } m \leqslant k, \\
0 & \text { otherwise } .\end{cases}
\end{aligned}
$$

Now the double sequence $\left\{f_{n k}\right\}$ is computable. For, given any $k$, we have only to test the $2(k+1)$ values $a(0), \ldots, a(k)$ and $b(0), \ldots, b(k)$ in order to determine $f_{n k}(1 / 3)$ and $f_{n k}(2 / 3)$.

We shall show that $\left|f_{n k}(x)-f_{n}(x)\right| \leqslant 2^{-k}$ for all $n, k$, and $x$. To see this, we first verify that

$$
\begin{aligned}
\left|f_{n k}(1 / 3)-f_{n}(1 / 3)\right| & \leqslant 2^{-k} \\
\left|f_{n k}(2 / 3)-f_{n}(2 / 3)\right| & \leqslant 2^{-k}
\end{aligned}
$$

Namely, consider the point $1 / 3$. There are three cases:

1. $n \notin A$. Then $f_{n k}(1 / 3)=f_{n}(1 / 3)$ for all $k$.
2. $n \in A$, and $n=a(m)$ for some $m \leqslant k$. Then $f_{n k}(1 / 3)=f_{n}(1 / 3)$ for this $k$.
3. $n \in A$, and $n=a(m)$ with $m>k$. Then $\left|f_{n k}(1 / 3)-f_{n}(1 / 3)\right|=\left|0-\left(-2^{-m}\right)\right|= 2^{-m}<2^{-k}$.

The point $2 / 3$ is handled similarly.
Finally, since all of the functions $f_{n k}$ and $f_{n}$ are piecewise linear, and determined by their values at $x=1 / 3$ and $x=2 / 3$, the inequalities which we have established for $x=1 / 3$ or $2 / 3$ extend to all $x$.

Since $\left\{f_{n k}(x)\right\}$ is computable and converges to $\left\{f_{n}(x)\right\}$ as $k \rightarrow \infty$, uniformly in $x$ and effectively in $k$ and $n,\left\{f_{n}\right\}$ is computable (Theorem 4).

We still have to verify that there is no computable sequence $\left\{c_{n}\right\}$ with $f_{n}\left(c_{n}\right)=0$ for all $n$.

Suppose otherwise. Since $\left\{c_{n}\right\}$ is computable, there is a computable sequence of rationals $\left\{r_{n}\right\}$ with

$$
\left|r_{n}-c_{n}\right| \leqslant 1 / 12 \quad \text { for all } n
$$

Since exact comparisons are effective for rational numbers, we can define a recursive set $C$ by:

$$
n \in C \quad \text { if and only if } r_{n} \geqslant 1 / 2 \text {. }
$$

Now if $n \in A$, the only zero of $f_{n}(x)$ occurs at $x=2 / 3$ (since $f_{n}(1 / 3)$ was depressed to a value slightly below zero). Similarly, if $n \in B$, the only zero of $f_{n}(x)$ occurs at $x=1 / 3$. Since the distance from $1 / 3$ (or $2 / 3$ ) to $1 / 2$ is $1 / 6$, and since $1 / 6>1 / 12$, we have:

$$
\begin{array}{ll}
r_{n}>1 / 2 & \text { if } n \in A, \\
r_{n}<1 / 2 & \text { if } n \in B,
\end{array}
$$

whence

$$
\begin{aligned}
A & \subseteq C, \\
B \cap C & =\emptyset .
\end{aligned}
$$

Hence the recursive set $C$ separates $A$ and $B$, a contradiction.

Notes. Of course, in this construction, the interesting action takes place on the interval $[1 / 3,2 / 3]$. For $n \notin A \cup B$, the function $f_{n}(x)$ is identically zero on this subinterval. But if $n \in A, n=a(m)$, we depress the value $f_{n}(1 / 3)$ slightly-the amount of decrease, $2^{-m}$, becoming less and less the longer we have to wait for $m$ to occur.

Similarly if $n \in B, n=b(m)$, we increase $f_{n}(2 / 3)$ by $2^{-m}$.
Since $2^{-m} \rightarrow 0$ effectively as $m \rightarrow \infty$, we can approximate $f_{n}(x)$, to any desired degree of precision, by checking only finitely many values of $m$. That is why the sequence $\left\{f_{n}(x)\right\}$ is computable.

On the other hand, by this "see-saw" construction, we can send the zeros of $f_{n}(x)$ shooting off in either direction-to $2 / 3$ or $1 / 3$-by an arbitrarily small perturbation in $f_{n}(x)$.

These ideas, in various guises, form the basis for many counterexamples.
One final note. In the proof of Theorem 8 above, there was a case analysis which began-Case 1: if $c$ is rational, then we are done. Any single rational number is ipso-facto computable. But a sequence of rationals need not be.

Theorem 9 (Real closed field). The computable reals form a real closed field. That is, if a polynomial has computable real coefficients, then all of its real roots are computable.

Proof. For simple roots, this is an immediate consequence of the Intermediate Value Theorem, Theorem 8 above. For multiple roots we reason as follows. Let $p(x)$ be a polynomial with computable real coefficients, and let $c$ be a root of order $n$ of $p(x)$. Then the $(n-1)$ st derivative $p^{(n-1)}(x)$ has computable real coefficients, and $c$ is a simple root of $p^{(n-1)}(x)$. Hence the previous argument applies.

Remark (The Mean Value Theorem). In connection with the topics of this section, the reader may wonder why we do not deal with the Mean Value Theorem. The facts are these. The Mean Value Theorem effectivizes for an individual computable function with a continuous derivative (computable or not). But the theorem does not effectivize for computable sequences of functions, even if the sequence of derivatives is computable.

We have omitted this theorem for two reasons. First, we have no need for it. Second, it is hard to see how an effective version of the Mean Value Theorem could be useful. Consider the situation in classical (noncomputable) analysis. When one uses the Mean Value Theorem- $f(b)-f(a)=(b-a) f^{\prime}(\xi)$ for some $\xi$-it is only the existence of $\xi$ which is relevant, and not its actual value. In fact, in almost all applications, the Mean Value Theorem is used to establish inequalities involving $f(b)-f(a)$, and the location of the point $\xi$ is immaterial.

## 7. Proof of the Effective Weierstrass Theorem

With this result, we prove the difficult half of Theorem 6 (equivalence of Definitions A and B). Namely, we proved in Section 5 that, if a function $f$ satisfies the conditions of Definition B (Effective Weierstrass), then it satisfies Definition A(Effective evalua-
tion). This proof was quite easy. However, the converse, which involves an effectivization of the classical Weierstrass Approximation Theorem, is considerably more complicated. We now prove that converse.

Here is where we get our hands dirty. This is the only effectivization of a major classical proof given in this book. It seems worthwhile to do such a thing once, if only to show what such "effectivization proofs" look like. As stated earlier, we prefer to develop general theorems (which are usually theorems with no classical analog), and deduce results like the Weierstrass theorem as corollaries.

A much simpler proof of the Effective Weierstrass Theorem is given in Chapter 2, Section 5. That proof is based on the "axioms for computability on a Banach space" developed there. Naturally one must ask-what elementary results are needed to validate the axioms-in order to make sure that no circularity has crept in. As we shall see in Chaper 2, the verification of the axioms requires Theorems 1,4, and 7 of this chapter-none of which depend on the Effective Weierstrass Theorem.

For convenience we restate the theorem. This theorem has no number, since it is really a part of Theorem 6.

Theorem (Effective Weierstrass Theorem). Let $[a, b]$ be an interval with computable end points, and let $f$ be a function on $[a, b]$ which is computable in the sense of Definition A. Then there exists a computable sequence of polynomials $\left\{p_{m}\right\}$ which converges effectively and uniformly to $f$ on $[a, b]$-i.e. $f$ is computable in the sense of Definition B.

Technical preliminaries for the effective Weierstrass proof. We select an integer $M$ such that:

$$
[a, b] \subseteq[-M / 4, M / 4]
$$

Then we use the Expansion Theorem (Theorem 3) to extend $f$ from $[a, b]$ to $[-M, M]$. We define a polynomial pulse function $P_{m}(x)$ on $[-M, M]$ by:

$$
P_{m}(x)=\left[1-\left(\frac{x}{M}\right)^{2}\right]^{m}
$$

We must investigate the behavior of this pulse as $m \rightarrow \infty$.
Fix a small interval $[-1 / d, 1 / d]$ about 0 . Here $d$ is a positive integer with $1 / d<M / 4$. Let $J$ be the complementary domain

$$
J=[-M, M]-[-1 / d, 1 / d]
$$

It seems apparent that, for large $m$, most of the mass of the pulse $P_{m}(x)$ should be concentrated on $[-1 / d, 1 / d]$. Equivalently, only a negligible portion of the mass should lie on the complementary domain $J$. To make this effective, we need some explicit inequalities.

For the domain $J$ we have:

$$
|x| \geqslant 1 / d \quad \text { implies } \quad P_{m}(x) \leqslant\left[1-(1 / d M)^{2}\right]^{m} .
$$

Now consider the smaller interval $[-1 / 2 d, 1 / 2 d]$. On this interval:

$$
|x| \leqslant 1 / 2 d \quad \text { implies } \quad P_{m}(x) \geqslant\left[1-(1 / 2 d M)^{2}\right]^{m} .
$$

Thus we are led to consider the ratio:

$$
\left[1-(1 / 2 d M)^{2}\right]^{m} /\left[1-(1 / d M)^{2}\right]^{m}
$$

It is obvious that, since $d$ and $M$ are fixed, this ratio grows without bound as $m \rightarrow \infty$. Specifically:

$$
\begin{equation*}
\left[\frac{1-(1 / 2 d M)^{2}}{1-(1 / d M)^{2}}\right]^{m} \geqslant \frac{3 m}{4 d^{2} M^{2}} \tag{*}
\end{equation*}
$$

For completeness we give the elementary proof. The left side of $(*)$ is just $[(1-u) / (1-4 u)]^{m}$, where $u=(1 / 2 d M)^{2}$.

By induction on $k,(1+u)^{k} \geqslant 1+k u$ and $(1-u)^{k} \geqslant 1-k u$ for $k=0,1,2, \ldots$. We simply apply these facts several times:

Since $(1-u)^{4} \geqslant 1-4 u$, we have $(1-u) /(1-4 u) \geqslant 1 /(1-u)^{3}$. Also $1 /(1-u)^{3} \geqslant (1+u)^{3}($ since $(1-u)(1+u) \leqslant 1)$, and $(1+u)^{3} \geqslant 1+3 u$. Finally, $(1+3 u)^{m} \geqslant 1+3 m u \geqslant 3 m u$. Thus $[(1-u) /(1-4 u)]^{m} \geqslant 3 m u$, which is $(*)$.

The main point of this subsection is contained in the following:
Technical Lemma. Let $J$ denote the complement of the interval $[-1 / d, 1 / d]$ in $[-M, M]$. Then

$$
\frac{\int_{J} P_{m}(x) d x}{\int_{-M}^{M} P_{m}(x) d x} \leqslant \frac{8 d^{3} M^{3}}{3 m}
$$

Proof. Since $P_{m}(x)>0$ on $(-M, M)$, the integral of $P_{m}$ over $[-M, M]$ exceeds the integral over $[-1 / 2 d, 1 / 2 d]$. Therefore it suffices to estimate the larger ratio

$$
\left(\int_{J} P_{m}\right) /\left(\int_{-1 / 2 d}^{1 / 2 d} P_{m}\right)
$$

Now we use (*) above. Thus the ratio

$$
\frac{\max \text { of } P_{m}(x) \text { on } J}{\min \text { of } P_{m}(x) \text { on }[-1 / 2 d, 1 / 2 d]} \leqslant \frac{4 d^{2} M^{2}}{3 m} .
$$

On the other hand, the ratio

$$
\frac{\text { length of } J}{\text { length of }[-1 / 2 d, 1 / 2 d]} \leqslant 2 d M
$$

Multiplying the last two displayed inequalities gives the lemma.

Proof of the Effective Weierstrass Theorem, completed. Let $P_{m}(x)$ be the polynomial pulse function as above, and define

$$
p_{m}(x)=\frac{1}{C_{m}} \int_{-M / 2}^{M / 2} P_{m}(t-x) f(t) d t,-M / 4 \leqslant x \leqslant M / 4
$$

where

$$
C_{m}=\int_{-M}^{M} P_{m}(x) d x
$$

Recall that the interval $[-M / 4, M / 4]$ contains $[a, b]$.
We now show that $\left\{p_{m}\right\}$ is a computable sequence of polynomials.
Clearly the sequence $P_{m}(x)=\left[1-(x / M)^{2}\right]^{m}$ is computable, and by the Binomial Theorem,

$$
P_{m}(t-x)=\sum_{k=0}^{2 m} \sum_{j=0}^{k} b_{m k j} x^{j} t^{k-j}
$$

where the triple sequence $\left\{b_{m k j}\right\}$ is computable. Then

$$
p_{m}(x)=\frac{1}{C_{m}} \sum_{k=0}^{2 m} \sum_{j=0}^{k} b_{m k j}\left(\int_{-M / 2}^{M / 2} t^{k-j} f(t) d t\right) \cdot x^{j}
$$

is a computable sequence of polynomials:
For we already have that $\left\{b_{m k j}\right\}$ is computable, and the computability of $C_{m}$ and of the other definite integrals above, effectively over $m, k, j$, follows from Theorem 5.

Now, to complete the proof, we must show that $p_{m}(x) \rightarrow f(x)$, uniformly in $x$ and effectively in $m$, as $m \rightarrow \infty$.

Since $f$ is effectively uniformly continuous, there is a recursive function $d(N)$ such that

$$
|x-y| \leqslant 1 / d(N) \quad \text { implies } \quad|f(x)-f(y)| \leqslant \frac{2^{-N}}{3}
$$

Also, since $f$ is continuous on $[-M, M]$, there exists an integer $S$ with

$$
\sup _{|x| \leqslant M}|f(x)| \leqslant S
$$

FIX a point $x \in[-M / 4, M / 4]$. We have to bound $\left|p_{m}(x)-f(x)\right|$ in a manner uniform in $x$ and effective in $m$. Since $f(x)$ is held constant, and $C_{m}=\int_{-M}^{M} P_{m}(t) d t$,

$$
f(x)=\frac{1}{C_{m}} \int_{x-M}^{x+M} P_{m}(t-x) f(x) d t
$$

On the other hand,

$$
p_{m}(x)=\frac{1}{C_{m}} \int_{-M / 2}^{M / 2} P_{m}(t-x) f(t) d t
$$

For simplicity, we write $d$ for $d(N)$. We break the difference $p_{m}(x)-f(x)$ into three parts:

$$
p_{m}(x)-f(x)=(A)+(B)+(C)
$$

where

$$
\begin{aligned}
& (A)=\frac{1}{C_{m}}\left[\int_{-M / 2}^{M / 2} P_{m}(t-x) f(t) d t-\int_{x-1 / d}^{x+1 / d} P_{m}(t-x) f(t) d t\right] \\
& (B)=\frac{1}{C_{m}}\left[\int_{x-1 / d}^{x+1 / d} P_{m}(t-x)[f(t)-f(x)] d t\right] \\
& (C)=\frac{1}{C_{m}}\left[\int_{x-1 / d}^{x+1 / d} P_{m}(t-x) f(x) d t-\int_{x-M}^{x+M} P_{m}(t-x) f(x) d t\right]
\end{aligned}
$$

Concerning the various domains of integration: Of course, $t \in[x-M, x+M]$ puts $(t-x) \in[-M, M]$, so that the pulse $P_{m}(t-x)$ is integrated over the correct set. Since $|x| \leqslant M / 4$, the interval $[x-M, x+M]$ contains $[-M / 2, M / 2]$. Also, the small interval $[x-1 / d, x+1 / d]$ lies inside $[-M / 2, M / 2]$. Finally, and most importantly:

In both $(A)$ and $(C)$, the domain of integration satisfies $(t-x) \in J$, where $J= [-M, M]-[-1 / d, 1 / d]$ as in the Technical Lemma above.

We recall that $C_{m}=\int_{-M}^{M} P_{m}$, and that $S$ dominates the sup of $|f(x)|$. Hence by the Technical Lemma:

$$
\begin{aligned}
& |(A)| \leqslant S \cdot \frac{8 d^{3} M^{3}}{3 m} \\
& |(C)| \leqslant S \cdot \frac{8 d^{3} M^{3}}{3 m}
\end{aligned}
$$

To estimate $(B)$, we use the definition of $d=d(N)$. Since $|f(t)-f(x)| \leqslant 2^{-N} / 3$ for $t \in[x-1 / d, x+1 / d]$, and since $C_{m}$ dominates the integral of $P_{m}(t-x)$,

$$
|(B)| \leqslant \frac{1}{3} \cdot 2^{-N}
$$

Now to effectivize the bounds on $(A),(B)$, and $(C)$, we define the recursive function

$$
m(N)=8 S M^{3} \cdot d(N)^{3} \cdot 2^{N}
$$

so that

$$
S \cdot \frac{8 M^{3} \cdot d(N)^{3}}{3 \cdot m(N)}=\frac{1}{3} \cdot 2^{-N}
$$

Then $m \geqslant m(N)$ gives

$$
|(A)| \leqslant \frac{1}{3} \cdot 2^{-N} \quad \text { and } \quad|(C)| \leqslant \frac{1}{3} \cdot 2^{-N},
$$

whence

$$
\left|p_{m}(x)-f(x)\right| \leqslant|(A)+(B)+(C)| \leqslant 2^{-N}
$$

Since $m(N)$ is a recursive function, the last inequality above shows $p_{m}(x) \rightarrow f(x)$ effectively in $m$. None of the above inequalities depend on $x$, so the convergence is uniform in $x$ as well. This proves the Effective Weierstrass Theorem.

