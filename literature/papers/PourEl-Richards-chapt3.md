## Chapter 3 <br> The First Main Theorem and Its Applications

## Introduction

In this chapter we present the First Main Theorem. This theorem gives a criterion for determining which processes in analysis and physics preserve computability and which do not. A major portion of this chapter is devoted to applications.

Here by the term "process" we mean a linear operator on a Banach space. The Banach space is endowed with a computability structure, as defined axiomatically in Chapter 2. Roughly speaking, the First Main Theorem asserts:
> bounded operators preserve computability, and unbounded operators do not.

Although this already conveys the basic idea, it is useful to state the theorem with a bit more precision. The theorem involves a closed operator $T$ from a Banach space $X$ into a Banach space $Y$. We assume that $T$ acts effectively on an effective generating set $\left\{e_{n}\right\}$ for $X$. Then the conclusion is: $T$ maps every computable element of its domain onto a computable element of $Y$ if and only if $T$ is bounded.

We observe that there are three assumptions made in the above theorem: that $T$ be closed, bounded or unbounded as the case may be, and that $T$ acts effectively on an effective generating set. We now examine each of these assumptions in turn.

Consider first the assumption that $T$ be bounded/unbounded. This assumption is viewed classically; it has no recursion-theoretic content. In this respect, the approach given here represents a generalization and unification of that followed in Chapters 0 and 1 . In Chapters 0 and 1, we gave explicit recursion-theoretic codings -a different one for each theorem. The First Main Theorem also involves a coding, but this coding is embedded once and for all in the proof. In the applications of the First Main Theorem, no such coding is necessary. Thus, in these applications, we are free to regard the boundedness or unboundedness of the operator as a classical fact, and the effective content of this fact becomes irrelevant.

Consider next the assumption that $T$ be closed. The notion of a closed operator is standard in classical analysis. It is spelled out, with examples, in Section 1. However, if the reader is willing to assume the standard fact-that all of the basic operators of analysis and physics are closed-he or she could simply skip Section 1.

We turn now to the final assumption: that $T$ acts effectively on an effective generating set. This is the only assumption of effectiveness made in the First Main Theorem. We recall from Chapter 2 that an effective generating set is a computable sequence $\left\{e_{n}\right\}$ whose linear span is dense in $X$. Thus the notion of an effective generating set effectivizes the notion of separability. However, it does more than that. Associated with many of the basic processes of analysis and physics, there is a special class of functions which is intrinsically identified with the process being studied. For example, if the process is Fourier series on $[0,2 \pi]$, then the special class of functions is the sequence $\left\{e^{i n x}\right\}, n=0, \pm 1, \pm 2, \ldots$. If the process is differentiation, then it is natural to take as our special class of functions the monomials $1, x$, $x^{2}, x^{3}, \ldots$. Of course these are effective generating sets. Now, in applying the First Main Theorem, we have complete freedom in our choice of the effective generating set. So naturally we choose the set $\left\{e_{n}\right\}$ to be the special set of functions which are tailor-made for the problem at hand.

In summary, each of the three assumptions made in the First Main Theorem is generally easy to verify in applications. As we have noted, two of these assumptions -boundedness/unboundedness and closure-are considered classically, and here the results are usually well known. The effectiveness assumption-that $T$ act effectively on an effective generating set-is also easy to verify. In fact, at times it is so easy that it is almost comical. For example, consider the case of Fourier series. Here the effective generating set is the sequence $\left\{e^{i n x}\right\}, n=0, \pm 1, \pm 2, \ldots$. What must we verify? Simply that the Fourier series of the functions $e^{\text {inx }}$ can be computed effectively!

We turn now to a summary of the sections in this chapter.
Section 1 contains a discussion of closed operators. This section has no recursiontheoretic content. As noted above, a reader could skip this section without loss of continuity. However, there is one point which may be worth remarking. An unbounded closed operator is not everywhere defined. In all cases, its domain is a proper subset of the underlying Banach space.

Section 2 contains the statement and proof of the First Main Theorem.
In Section 3 we begin our discussion of applications. These are of two types. First we treat the computability theory of continuous functions, i.e. Chapter- 0 computability. We begin by rederiving some results about integration and differentiation which were proved by direct methods in Chapters 0 and 1 . The new proofs, based on the First Main Theorem, are very easy (cf. Theorem 1). A more instructive example is Theorem 2, about the convergence of Fourier series. Its proof requires the introduction of a Banach space slightly more complicated than most of those considered up to now. Nevertheless, this proof is also quite easy-much easier than a direct proof in the style of Chapter 0. (Such a direct proof appears in Pour-El, Richards [1983a].)

The second type of application in Section 3 concerns the relation between $L^{p}$ and $L^{r}$-computability for $p \neq r$. For example, there exist functions in $L^{p} \cap L^{r}$ which are $L^{p}$-computable, but not $L^{r}$-computable. Perhaps more striking is the existence of a Chapter-0-computable function $f$ on $\mathbb{R}$, such that $f \in L^{r}(\mathbb{R})$, but $f$ is not computable in $L^{r}(\mathbb{R})$. Similar results are given for $l^{p}$ and $l^{r}$. All of these results are spelled out in Theorem 3.

Section 4 deals with applications which are a bit more sophisticated than those given in Section 3. It begins with a complete treatment of the computability theory of Fourier series and transforms. As special cases we derive effective versions of the Plancherel Theorem and the Riemann-Lebesgue Lemma. However it is not always true that the Fourier operations effectivize. There are situations where the Fourier series/transform of a computable function is not computable. Theorem 4 lays out the complete details for Fourier series and transforms. One could find many similar applications, involving operators other than the Fourier transform. We have chosen the case of Fourier series and transforms as a prototype. The same method would apply to any linear operator for which we know the cases of boundedness and unboundedness.

Section 4 continues with a discussion of "well understood functions". Let us recall that the $L^{p}$-computable functions on $[a, b]$ are simply the effective closure in $L^{p}$-norm of the Chapter- 0 -computable functions. It turns out that certain step functions are $L^{p}$-computable. We emphasize that the computability of these step functions is not obtained by an ad-hoc addition of them to the list of Chapter-0computable functions; it is an automatic consequence of the classical definition of computability once we relax the norm. Suppose we investigate this phenomenon from a broader viewpoint-that of "well understood functions". By this we mean continuous functions, piecewise linear functions, and step functions. We ask, for each of these classes of functions, precisely which ones are $L^{p}$-computable. For step functions it turns out to be just the ones we would expect-those with computable values and jump points (Theorem 5). A similar result holds for piecewise linear functions. However, for continuous functions, the result is different. There are continuous functions which are $L^{p}$-computable, but not Chapter- 0 -computable. The same question is asked for sequences of functions. Here the results turn out to be different.

Section 5 deals with applications to mathematical physics. There are many possible applications, of which we have selected three. We consider in turn the wave equation, the heat equation, and the potential equation. The wave equation is dealt with in two different contexts: Chapter- 0 -computability and computability in the energy norm. For the classical Chapter 0 notion of computability, we obtain an example of the wave equation with computable initial data such that its unique solution at time $t=1$ is not computable (Theorem 6). This was done by direct methods in Pour-El/Richards [1981]. By contrast, when we use a norm which is more closely associated with the wave operator-the so called energy norm-then we obtain opposite results. In terms of the energy norm, solutions of the wave equation are computable (Theorem 7). Thus as already illustrated in several previous instances, the question of whether or not an operator preserves computability depends on the norm-and hence the Banach space-being considered.

By contrast, for the heat equation and potential equation, Chapter-0-computability is preserved. This is proved in Theorems 8 and 9.

Remark on the Dirichlet norm and Sobolev spaces. The energy norm treated in Section 5 is an example of a mixed norm- $L^{\infty}$ in the time variable, and $L^{2}$ is the space variables. Moreover, the $L^{2}$-norm in the space variables is on the first derivatives,
and not on the function itself. Such a norm, which is $L^{2}$ on the first derivatives, is called a Dirichlet norm. An important generalization of the Dirichlet norm is the Sobolev norm, associated with the Sobolev space $W^{k, p}$. This is a generalization in two respects. First, it involves all mixed partial derivatives of order $\leqslant k$. Second, the $L^{p}$-norm replaces the $L^{2}$-norm. The intrinsic computability structure for Sobolev spaces is defined in a manner exactly analogous to that which we use for the Dirichlet norm in Section 5.

## 1. Bounded Operators, Closed Unbounded Operators

Since this book is written for a mixed audience-i.e. logicians and analysts-we begin by reviewing some basic definitions and facts.

Let $X$ and $Y$ be Banach spaces and $T: X \rightarrow Y$ a linear operator from $X$ into $Y$. The notions " $T$ is bounded" and " $T$ is closed" will play a key role in everything which follows. Consequently we review these notions in some detail.

Definition. A linear operator $T: X \rightarrow Y$ is called bounded if there is a constant $M \geqslant 0$ such that

$$
\|T x\| \leqslant M \cdot\|x\| \quad \text { for all } x \in X .
$$

(The smallest such $M$ is, of course, called the norm of the operator $T$.)
In many cases, the following equivalent formulation is useful: $T$ is bounded if and only if

$$
x_{n} \rightarrow x \text { in } X \quad \text { implies } \quad T x_{n} \rightarrow T x \text { in } Y .
$$

[Here and throughout, " $x_{n} \rightarrow x$ " means that the norm $\left\|x_{n}-x\right\| \rightarrow 0$.]
We observe that the conclusion $T x_{n} \rightarrow T x$ can be broken into two halves:
i) $T x_{n}$ converges (to some limit $y$ ),
ii) the limit $y=T x$.

Now we come to closed operators. Here the domain of $T$ is usually not $X$ but a subspace $\mathscr{D}(T)$ which is dense in $X$. (More on this below.)

Definition. A linear operator $T: \mathscr{D}(T) \rightarrow Y$ is called closed if, for $x_{n} \in \mathscr{D}(T)$ :

$$
x_{n} \rightarrow x \text { in } X \text { and } T x_{n} \rightarrow y \text { in } Y \quad \text { implies } \quad x \in \mathscr{D}(T) \text { and } T x=y .
$$

Thus the contrast between "closed" and "bounded" operators lies in the placement of condition (i) above ( $T x_{n}$ converges). With bounded operators, (i) is a conclusion of the assumption that $x_{n} \rightarrow x$. By contrast, with closed operators, (i) is part of the hypotheses.

As we shall see, all of the usual operators of analysis and physics are closed, although the most interesting ones are unbounded.

The above definition of a closed operator is easily seen to be equivalent to the following.

A linear operator $T: \mathscr{D}(T) \rightarrow Y$ is closed if and only if the domain $\mathscr{D}(T)$ is dense in $X$, and the graph of $T[=$ the set of ordered pairs $(x, T x), x \in \mathscr{D}(T)]$ is a closed subset of the cartesian product $X \times Y$.

Now we return to a discussion of the domain $\mathscr{D}(T)$. The most striking fact about unbounded operators is that their domains are not the whole Banach space $X$ but a proper dense subspace $\mathscr{D}(T)$ of $X$. Why is such a weird notion important in analysis and physics? The reason, simply, is that many important operators such as $d / d x$ are only defined for a limited class of functions (differentiable functions). One might ask, why not take the differentiable functions as our Banach space? The difficulty here is that the differentiable functions are not complete in the most useful Banach space norms (e.g. the $L^{2}$-norm or the $L^{\infty}$-norm). When one takes the completion (e.g. in $L^{2}$ or $L^{\infty}$ ), one obtains the spaces $X=L^{2}[]$ or $X=C[$ ] respectively. Then the domain $\mathscr{D}(T)$ of differentiable functions is a proper dense subset of the completed space $L^{2}[]$ or $C[]$.

In summary: the consideration of domains $\mathscr{D}(T) \neq X$ is forced on us by the desire to treat unbounded operators such as $d / d x$ which are important in analysis and physics.

Our assumptions require that, even if $\mathscr{D}(T)$ is a proper subspace of $X$, at least $\mathscr{D}(T)$ is dense in $X$. This is easily achieved in all practical cases. Ignoring details, which vary slightly from case to case, the general idea is this. In the standard Banach spaces, such as $X=L^{2}[]$ or $X=C[]$, there are subspaces consisting of "very nice" functions which are dense in $X$. Depending on the situation, these "very nice" functions might be $C^{\infty}$ functions, polynomials, trigonometric polynomials, etc. The standard unbounded operators of analysis and physics operate on these "very nice" functions. So in practice, there is no difficulty in making the domain $\mathscr{D}(T)$ dense in $X$.

Of course, if $\mathscr{D}(T) \neq X$ but $\mathscr{D}(T)$ is dense in $X$, then $\mathscr{D}(T)$ cannot be closed. Consider now an unbounded closed operator whose domain $\mathscr{D}(T) \neq X$. Then the graph of $T$ is closed, but the domain of $T$ is not. This is no contradiction. For, since $T$ is unbounded, we can have $x_{n} \rightarrow x$ in $X$ (with $x_{n} \in \mathscr{D}(T)$ ) but $\left\{T x_{n}\right\}$ not convergent in $Y$. Then the points $\left(x_{n}, T x_{n}\right)$ on the graph of $T$ approach no limit, and so the hypothesis of a closed graph implies nothing about this sequence. By contrast, if $T$ is bounded (so that $x_{n} \rightarrow x$ does imply $T x_{n} \rightarrow T x$ ), then the hypothesis of a closed graph implies a closed domain. As noted above, since $\mathscr{D}(T)$ is dense in $X$, this means that $\mathscr{D}(T)=X$.

When, in general, does $\mathscr{D}(T)=X$ ? We have seen that this holds when $T$ is bounded. In fact, for closed operators, the converse is true: If $\mathscr{D}(T)=X$ and $T$ has a closed graph, then $T$ is bounded. This is the well known Closed Graph Theorem. Thus, in summary: For a closed operator $T, \mathscr{D}(T)=X$ if and only if $T$ is bounded.

Remark on notation. For an operator $T: X \rightarrow Y$ whose domain $\mathscr{D}(T) \neq X$ we should, if we were properly pedantic, write $T: \mathscr{D}(T) \rightarrow Y$. However, it is conventional to
write $T: X \rightarrow Y$ (with the domain $\mathscr{D}(T)$ being understood), and we shall follow this convention.

It is perhaps time to give an example illustrating these concepts. The following gives two closed operators $T_{1}, T_{2}$, the second a proper extension of the first, and yet both of them having domains which are dense in $X=L^{2}[0,1]$. Of course, as we have seen, such behavior can occur only when the operators are unbounded.

Example. Let $X=Y=L^{2}[0,1]$, and let $T_{1}, T_{2}$ be the operators given formally by $d / d x$, with the domains $\mathscr{D}\left(T_{i}\right), i=1,2$, defined as follows:

We begin with the class of functions $f(x)$ on $[0,1]$ such that $f$ is absolutely continuous (whence $f^{\prime}(x)$ exists almost everywhere) and $f^{\prime}(x)$ belongs to $L^{2}[0,1]$. In addition, we impose the conditions:

$$
\begin{aligned}
& \text { for } \mathscr{D}\left(T_{1}\right): f(0)=f(1)=0 \text {; } \\
& \text { for } \mathscr{D}\left(T_{2}\right): f(0)=0 \text {. }
\end{aligned}
$$

Both of these domains are dense in $L^{2}[0,1]$. Furthermore, the operators $T_{i}$ are closed.

Proof. To show that $T=T_{i}$ is closed, $i=1$, 2, we reason as follows. For functions with $f(0)=0$, the inverse of $T=d / d x$ is the bounded operator

$$
T^{-1} f(x)=\int_{0}^{x} f(t) d t
$$

Now $T^{-1}$, being bounded, has a closed graph. But the graph of $T=d / d x$ is just the graph of $T^{-1}$ with the coordinate axes (i.e. the domain and range) reversed.

Strictly speaking, the above argument is incomplete, since it leaves out the boundary conditions $f(0)=f(1)=0$ etc. This point is handled in the following way. The integral operator $T^{-1}$ above is actually bounded from $L^{2}[0,1]$ into $C[0,1]$ (with the uniform norm on $C[]$ !). For, by the Schwarz inequality, the $L^{2}$-norm of $f \geqslant L^{1}$-norm of $f$, and then in turn, the $L^{1}$-norm of $f \geqslant\left|\int_{0}^{x} f(t) d t\right|$. Thus convergence in $L^{2}$ of $\left\{T f_{n}\right\}=\left\{f_{n}^{\prime}(x)\right\}(n \rightarrow \infty)$ implies uniform convergence of the original functions $f_{n}$.

This proves that the operators $T_{1}$ and $T_{2}$ are both closed.
The above example convinces us that it would be useful to have some general criteria for showing that various operators are closed. We give here two such criteria.

Proposition (First closure criterion). Let $T: X \rightarrow Y$ have dense domain $\mathscr{D}(T)$, and suppose that $T$ is one to one and maps $\mathscr{D}(T)$ onto $Y$. Suppose further that $T^{-1}$ is bounded. Then T is closed.

Proof. Since $T^{-1}: Y \rightarrow X$ is bounded, $T^{-1}$ has a closed graph. But the graph of $T$ is just the graph of $T^{-1}$ with the coordinate axes reversed.

This simple proposition applies in many elementary situations. We saw above how it could be used to treat $d / d x$. Other applications will be given in due course.

Note. We mention one obvious but useful generalization of the first closure criterion. Instead of assuming that $T$ maps $\mathscr{D}(T)$ onto $Y$, it suffices to assume that $T$ maps $\mathscr{D}(T)$ onto a closed subspace $Z$ of $Y$. For then we can apply the same result, with the Banach space $Z$ replacing $Y$.

We turn now to the second closure criterion. This requires a bit of preface.
Sometimes an operator which is not closed has a closed extension. That is, the operator $T$ has a graph which is not closed; by taking the closure of its graph, we define a closed operator $\bar{T}$ which is an extension of $T$. (This should not be confused with the example above, where we had $T_{1}, T_{2}=d / d x$ with varying boundary conditions. There both of the operators were closed, and the extension was from one closed operator to another.)

This suggests a uniform procedure for finding the closure of an arbitrary unbounded operator $T$. Namely, consider the graph $G$ of $T$, take its closure $\bar{G}$, and let $\bar{G}$ determine a new operator $\bar{T}$. If this would work in every case then the problem of finding closures would largely vanish. Where is the difficulty?

The difficulty is that $\bar{G}$ might not be the graph of a single-valued function. In fact, that is the only difficulty. A realization of this fact leads to a very general criterion for closure. This will be our second closure criterion.

As a preface for this, we must say a word about weak topologies. By a "weak topology", in this context, we simply mean a topology which is weaker than the norm topology on the Banach space in question. The point is that an operator $T: X \rightarrow Y$ which is not continuous in terms of the norm topologies on $X$ and $Y$ may be continuous in terms of some weaker topologies.

Remarks. The most generally useful weak topologies are those associated with Schwartz distributions. In terms of these topologies, most of the standard operators of analysis and physics are continuous. However, we should emphasize that this book leans in no essential way on distribution theory. Distributions can be used to show that certain classical operators are closed. It is for this purpose-and for this purpose only-that we use them. Thus a knowledge of distribution theory is in no way essential for an understanding of this book.

Proposition (Second closure criterion). Let $T: X \rightarrow Y$ be an unbounded operator with dense domain $\mathscr{D}(T)$ in $X$. Suppose there exist Hausdorff topologies $\tau_{1}$ and $\tau_{2}$ on $X$ and $Y$ respectively, which are weaker than the norm topologies, and such that $T$ is continuous in terms of $\tau_{1}$ and $\tau_{2}$. Then $T$ has an extension to a closed operator $\bar{T}$ from X to Y.

Proof. Let $G$ be the graph of $T$ in $X \times Y$, and let $\bar{G}$ be its closure. We want to define $\bar{T}$ as the operator with graph $\bar{G}$. The problem is that $\bar{G}$ might not be the graph of a single-valued function: i.e. we might have $x_{n} \rightarrow 0$ in the norm of $X$ and $T x_{n} \rightarrow y \neq 0$ in $Y$. But under the above assumptions, this does not happen. For $x_{n} \rightarrow 0$ in $X$ implies
$x_{n} \rightarrow 0$ in the weaker topology $\tau_{1}$; similarly, $T x_{n} \rightarrow y$ in $Y$ implies $T x_{n} \rightarrow y$ in the topology $\tau_{2}$. If $y \neq 0$, this contradicts the continuity of $T$ in terms of $\tau_{1}$ and $\tau_{2}$.

Incidentally, when an operator $T$ has a closed extension, it is conventional to assume that this extension has been made and to say that $T$ is closed. We shall follow this convention.

We conclude this section with two examples which illustrate the two closure criteria.

Example. Let $p, r$ be computable reals with $1 \leqslant p<r<\infty$. We recall that then $L^{r}[0,1] \varsubsetneqq L^{p}[0,1]$ and $\|f\|_{p} \leqslant\left\|f_{r}\right\|$ for any $f \in L^{r}$. Thus (with $p<r$ ) the natural injection from $L^{r}[0,1]$ to $L^{p}[0,1]$ is bounded of norm 1 .

Now let $T$ be the inverse mapping $T: L^{p}[0,1] \rightarrow L^{r}[0,1]$ defined by $T f=f$ for $f \in L^{r}$. This, of course, is not an identity mapping; it is not even bounded. Its domain $\mathscr{D}(T)$ is the proper subspace $L^{r}[0,1] \varsubsetneqq L^{p}[0,1]$.

However, the injection operator $T$ is closed. This follows from the first closure criterion, since $T^{-1}$ is bounded.

Example. Let $p, r$ be computable reals with $1 \leqslant p, r<\infty$. (Here we could have $p=r$.) Let $T$ be the Fourier transform operator from $L^{p}(-\infty, \infty)$ to $L^{r}(-\infty, \infty)$. This is defined formally by

$$
(T f)(t)=\int_{-\infty}^{\infty} e^{-i t x} f(x) d x
$$

Now, in general, neither $T$ nor $T^{-1}$ is bounded from $L^{p}$ to $L^{r}$ or vice-versa. Furthermore, a correct definition of $T$ requires weak topologies. For the above integral makes sense only if $f$ is integrable, i.e. if $f \in L^{1}$-and we have not assumed that $p=1$.

The way out of this dilemma is to use a suitable weak topology-e.g. the topology of tempered distributions-in which the Fourier transform is well defined and continuous.

We observe, however, that it is not necessary to be fluent in the theory of tempered distributions, in order to grasp the essential features of this example. It is enough to know that such a theory exists, that it gives a well defined meaning to $T f$ for any $f \in L^{p}(-\infty, \infty)$, and that it allows us to answer the question: Does $T f$ belong to $L^{r}(-\infty, \infty)$ ?

We now define the domain $\mathscr{D}(T)$ to be the set of functions $f \in L^{p}(-\infty, \infty)$ for which $T f \in L^{r}(-\infty, \infty)$. On this domain-generally a proper subset of $L^{p}(-\infty, \infty) -T$ gives a well defined mapping into $L^{r}(-\infty, \infty)$.

The fact that $T$ is closed follows immediately from the second closure criterion.

## 2. The First Main Theorem

The preceding section had nothing per-se to do with computability. The notions of a closed or bounded operator are standard concepts of functional analysis. However, as we shall see, the question of whether or not a closed linear operator $T$ is bounded largely determines the behavior of $T$ with respect to computability.

The notion of a computability structure on a Banach space was developed axiomatically in the last chapter. We recall that there are three axioms: Linear Forms, Limits, and Norms. Two immediate consequences of these axioms are also essential: the Composition Property, which allows us to pass to a computable subsequence $\left\{x_{a(n)}\right\}$ of a computable sequence $\left\{x_{n}\right\}$, and the Insertion Property, which allows us to combine two computable sequences $\left\{x_{n}\right\}$ and $\left\{y_{n}\right\}$ into one.

Let $X$ be a Banach space with a computability structure. We recall that an effective generating set for $X$ is a computable sequence $\left\{e_{n}\right\}$ whose linear span is dense in $X$. In this definition, there is no requirement of "effective density"-merely that the linear span of $\left\{e_{n}\right\}$ be dense. However, the Effective Density Lemma from Section 5 of Chapter 2 gives:

A sequence of vectors $\left\{x_{n}\right\}$ is computable in $X$ if and only if there is a computable double sequence $\left\{p_{n k}\right\}$ of (rational/complex rational) linear combinations of the $e_{n}$ such that $\left\|p_{n k}-x_{n}\right\| \rightarrow 0$ as $k \rightarrow \infty$, effectively in $k$ and $n$. Thus we do, in fact, have effective density for computable sequences $\left\{x_{n}\right\}$.

The following is the key theorem of this chapter.

First Main Theorem. Let $X$ and $Y$ be Banach spaces with computability structures. Let $\left\{e_{n}\right\}$ be a computable sequence in $X$ whose linear span is dense in $X$ (i.e. an effective generating set). Let $T: X \rightarrow Y$ be a closed linear operator whose domain $\mathscr{D}(T)$ contains $\left\{e_{n}\right\}$ and such that the sequence $\left\{T e_{n}\right\}$ is computable in $Y$. Then $T$ maps every computable element of its domain onto a computable element of $Y$ if and only if $T$ is bounded.

Complement. Under the same assumptions, if $T$ is bounded then more can be said. The domain of $T$ coincides with $X$, and $T$ maps every computable sequence in $X$ into a computable sequence in Y.

Remark. We have not assumed that $\left\{T e_{n}\right\}$ is an effective generating set for $Y$.
Proof. We first assume that $T$ is bounded and prove the stronger statement given in the Complement. Let $\left\{x_{n}\right\}$ be computable in $X$. By the Effective Density Lemma (recalled at the beginning of this section), there is a computable double sequence $p_{n k} \in X$, consisting of computable linear combinations of the $e_{n}$, such that $\left\|p_{n k}-x_{n}\right\| \rightarrow 0$ as $k \rightarrow \infty$, effectively in $k$ and $n$.

Now $\left\{T e_{n}\right\}$ is computable by hypothesis, and hence by the Linear Forms Axiom, $\left\{T p_{n k}\right\}$ is computable. Since $p_{n k} \rightarrow x_{n}$ as $k \rightarrow \infty$, effectively in $k$ and $n$, and since $T$ is
bounded, $T p_{n k} \rightarrow T x_{n}$ as $k \rightarrow \infty$, effectively in both variables. Hence by the Limit Axiom, $\left\{T x_{n}\right\}$ is computable, as desired.

Now we come to the case where $T$ is not bounded. We need to find a computable element $x \in \mathscr{D}(T)$ such that $T x$ is not computable in $Y$. The proof is based on two lemmas. The first of these asserts, roughly speaking, that $T$ is "effectively unbounded". The second lemma contains the key idea of the proof.

Lemma 1. Take the assumptions of the theorem, with $T$ unbounded. Then there exists a computable sequence $\left\{p_{n}\right\}$ of finite linear combinations of the $e_{n}$ such that $\left\{T p_{n}\right\}$ is computable in $Y$ and

$$
\left\|T p_{n}\right\|>10^{n}\left\|p_{n}\right\| \quad \text { for all } n .
$$

Proof of Lemma 1. By hypothesis, the linear span of $\left\{e_{n}\right\}$ is dense in $X$. Since the operator $T$ is closed, $T$ cannot be bounded on the span of $\left\{e_{n}\right\}$; else $T$ would be bounded on $X$. Now we sweep out the set of all finite (rational/complex rational) linear combinations of the $e_{n}$; this is easily done in an effective way by using any of the standard recursive enumerations of all finite sequences of integers. The result, by the Linear Form Axiom, is a computable sequence $\left\{p_{n}^{\prime}\right\}$ in $X$ which runs through all finite (rational/complex rational) linear combinations of the $e_{n}$.

By hypothesis, the sequence $\left\{T e_{n}\right\}$ is computable in $Y$. Since $T p_{n}^{\prime}$ can be computed from the $T e_{n}$ via linearity, it again follows from the Linear Forms Axiom that $\left\{T p_{n}^{\prime}\right\}$ is computable in $Y$.

We now construct a computable subsequence $\left\{p_{n}\right\}$ of $\left\{p_{n}^{\prime}\right\}$ such that $\left\|T p_{n}\right\|> 10^{n}\left\|p_{n}\right\|$ for all $n$. By the Composition Property, any recursive process for selecting a subsequence of indices automatically generates computable subsequences $\left\{p_{n}\right\}$ and $\left\{T p_{n}\right\}$ in the Banach spaces $X$ and $Y$ respectively.

Since $T$ is unbounded on the linear span of $\left\{e_{n}\right\}$, the set of ratios $\left\{\left\|T p_{n}^{\prime}\right\| /\left\|p_{n}^{\prime}\right\|\right.$, $\left.p_{n}^{\prime} \neq 0\right\}$ is unbounded. By the Norm Axiom, the sequences $\left\{\left\|T p_{n}^{\prime}\right\|\right\}$ and $\left\{\left\|p_{n}^{\prime}\right\|\right\}$ are computable. So we can effectively select the desired subsequence $\left\{p_{n}\right\}$ of $\left\{p_{n}^{\prime}\right\}$, with $\left\|T p_{n}\right\|>10^{n}\left\|p_{n}\right\|$, merely by waiting, for each $n$, until a suitable $p_{n}^{\prime}$ turns up.

Lemma 2. Let $r>2$ be a computable real. Let $\left\{z_{n}\right\}$ be a computable sequence in $Y$ with $\left\|z_{n}\right\|=1$ for all $n$. Let $a: \mathbb{N} \rightarrow \mathbb{N}$ be a one to one recursive function which enumerates a set $A \subseteq N$. (Thus the set $A$ is recursively enumerable; it may or may not be recursive.) Then the element

$$
y=\sum_{k=0}^{\infty} r^{-a(k)} z_{k}
$$

is computable in $Y$ if and only if the set $A$ is recursive.
Proof of Lemma 2. The "if" part is trivial. If $A$ is recursive, then the series converges effectively and the Limit Axiom implies that $y$ is computable.

For the "only if" part: We will assume that $y$ is computable and deduce that $A$ is recursive. Let $y_{n}$ denote the $n$-th partial sum of the above series. Then $\left\{y_{n}\right\}$ is
computable (Linear Forms Axiom), and $y$ is computable (by assumption); hence $\left\{y-y_{n}\right\}$ is computable. By the Norm Axiom, the sequence of norms $\left\{\left\|y-y_{n}\right\|\right\}$ is also computable.

Now $\left\|y-y_{n}\right\| \rightarrow 0$, but the convergence is not monotone, and we cannot immediately deduce that the convergence is effective. We shall use the fact that $r>2$ to establish a decision procedure for the set $A$ (and incidentally show that $\left\|y-y_{n}\right\| \rightarrow 0$ effectively).

Since $r>2$, each term in the series $\sum_{a=0}^{\infty} r^{-a}$ is strictly larger than the sum of all the following terms; the $a$-th term is $r^{-a}$, whereas $\sum_{b=a+1}^{\infty} r^{-b}=r^{-a} /(r-1)$.

Here is the decision procedure for the set $A$. To test whether an integer $a$ belongs to $A$, we wait until we find an $n$ for which

$$
\left\|y-y_{n}\right\|<r^{-a}-\left[r^{-a} /(r-1)\right] .
$$

If $a$ has occurred as some value $a(k), 0 \leqslant k \leqslant n$, then $a \in A$; otherwise $a \notin A$.
To justify this test, we will show that, for $k>n, a(k)$ takes no value $c \leqslant a$ (and hence in particular does not take the value $a$ ). Suppose otherwise. Let $c=a(m)$ be the least value taken by $a(k), k>n$. Then $r^{-c}$ exceeds the sum of all other terms $r^{-a(k)}$, $k>n$, by at least $r^{-c}\left[1-(r-1)^{-1}\right] \geqslant r^{-a}\left[1-(r-1)^{-1}\right]$. Now consider the series

$$
y-y_{n}=\sum_{k>n} r^{-a(k)} z_{k}
$$

The term $r^{-c} z_{m}$ has norm $r^{-c}$ (since $\left\|z_{m}\right\|=1$ ). However, by the triangle inequality, the sum of the other terms has norm

$$
\leqslant \sum_{a>c} r^{-a}=r^{-c} /(r-1) .
$$

Hence

$$
\left\|y-y_{n}\right\| \geqslant r^{-c}-\left[r^{-c} /(r-1)\right],
$$

and since $c \leqslant a$, this contradicts the defining inequality for $n$ given in the decision procedure above.

Proof of theorem, concluded. Following Lemma 1, we take a computable sequence $\left\{p_{n}\right\}$ in $X$ such that $\left\{T p_{n}\right\}$ is computable in $Y$ and $\left\|T p_{n}\right\|>10^{n}\left\|p_{n}\right\|$. By the Norm Axiom, $\left\{\left\|T p_{n}\right\|\right\}$ is computable, and we define the computable sequences

$$
\begin{aligned}
& z_{n}=T p_{n} /\left\|T p_{n}\right\| \quad \text { in } Y, \\
& u_{n}=p_{n} /\left\|T p_{n}\right\| \quad \text { in } X .
\end{aligned}
$$

Then $z_{n}=T u_{n},\left\|u_{n}\right\|<10^{-n}$, and $\left\|z_{n}\right\|=1$.

Let $a: \mathbb{N} \rightarrow \mathbb{N}$ be a one to one recursive function which enumerates a recursively enumerable non recursive set $A$. Let

$$
\begin{aligned}
& x=\sum_{k=0}^{\infty} 10^{-a(k)} u_{k}, \\
& y=\sum_{k=0}^{\infty} 10^{-a(k)} z_{k} .
\end{aligned}
$$

Then by Lemma 2, the element $y$ is not computable in $Y$. On the other hand, since $\left\|u_{k}\right\|<10^{-k}$, the series for $x$ converges effectively, so that by the Limit Axiom $x$ is computable in $X$.

Finally, $T u_{n}=z_{n}$, and the series for $x$ and $y$ converge (although not necessarily effectively). Since $T$ is a closed operator, it follows that $x$ belongs to the domain of $T$, and $T x=y$.

## 3. Simple Applications to Real Analysis

Before proceeding to these applications, a few comments seem in order. In the First Main Theorem above, there is only one recursion theoretic assumption on the operator $T$ : that $T$ map the effective generating set $\left\{e_{n}\right\}$ onto a computable sequence $\left\{T e_{n}\right\}$ in $Y$. All of the other assumptions on $T$-that it be closed, bounded or unbounded-are within the domain of standard analysis and have nothing per-se to do with computability.

As for the one recursion theoretic assumption-that $T$ acts effectively on $\left\{e_{n}\right\}$ this is trivial to verify in most cases. For the effective generating sets $\left\{e_{n}\right\}$ are usually chosen to consist of very simple functions: e.g. the monomials $\left\{x^{n}\right\}$ or the trigonometric functions $\left\{e^{i n x}\right\}$. For these functions, the computability of $\left\{T e_{n}\right\}$ is often so obvious that it seems slightly pedantic to mention it. (Example: let $T=d / d x$ and $\left\{e_{n}\right\}=\left\{x^{n}\right\}$; then we must "verify" that the sequence $\left\{(d / d x) x^{n}\right\}$ is computable.)

The following applications illustrate these points.
A standing convention. In each of the theorems below, "computability" will be in the standard intrinsic sense for the Banach space considered. Thus e.g. computability in $C[a, b]$ means the classical Grzegorczyk/Lacombe computability defined in Chapter 0. Henceforth we shall refer to this as "Chapter-0-computability". Computability in $L^{p}[a, b], 1 \leqslant p<\infty$, means the intrinsic $L^{p}$-computability defined in Chapter 2. Similarly for $l^{p}, l_{0}^{\infty}, C_{0}(\mathbb{R})$ and other spaces-see Chapter 2 for details. Of course, $a, b$, and $p$ are computable reals.

Theorem 1 (Integrals and Derivatives). (a) The indefinite integral of a computable function $f \in C[a, b]$ is computable.
(b) There exist computable functions in $C[a, b]$ which have continuous derivatives, but whose derivatives are not computable.
[The result (b) is due to Myhill [1971]. It was proved by an explicit construction in Chapter 1.]

Proof. In the First Main Theorem, we let $X=Y=C[a, b]$. As an effective generating set for $X$, we take the sequence of monomials $\left\{e_{n}\right\}=\left\{x^{n}\right\}$. For parts (a) and (b), we let $T$ be the indefinite integral/derivative operator, respectively. In case (a) $T$ is bounded; in case (b) it is not. Both operators are closed. The indefinite integral, being bounded, is automatically closed. For $T=d / d x$, we obtain a closed operator if we take the domain $\mathscr{D}(T)=C^{1}[a, b]$ : this follows easily from either of the Closure Criteria in Section 1 above. Finally, in both cases (a) and (b), the verification of computability for $\left\{T\left(x^{n}\right)\right\}$ is trivial.

Remark. In Chapter 1 we also proved that if $f$ is computable in $C[a, b]$ and if $f \in C^{2}[a, b]$, then $f^{\prime}$ is computable. This involves no contradiction, even though we have an unbounded operator $T=d / d x$ which maps computable functions onto computable functions. For the operator $d / d x$, when restricted to $C^{2}[a, b]$, is not closed.

Our next example is more recondite. Although the theorem applies to $C[0,2 \pi]$, its proof requires the use of a more complicated Banach space. This theorem was proved by classical methods in Pour-El, Richards [1983a]. That classical construction was distinctly more complicated than the entire proof of the First Main Theorem.

Theorem 2 (Convergence of Fourier series). There exists a computable function $f \in C[0,2 \pi]$ with $f(0)=f(2 \pi)$ which has the following properties. The Fourier series of $f$ is computable (i.e. the sequence of partial sums is computable), the Fourier series converges uniformly, but the series is not effectively uniformly convergent.

Proof. Again with reference to the First Main Theorem: For $X$ we take the space $C[0,2 \pi]$ with the points 0 and $2 \pi$ identified, so that our functions must satisfy $f(0)=f(2 \pi)$. We use the standard notion of Chapter- 0 -computability for these functions. As an effective generating set $\left\{e_{n}\right\}$ we take the sequence $\left\{e^{i n x}\right\}, n=0, \pm 1$, $\pm 2, \ldots$.

For $Y$, we take the Banach space of uniformly convergent sequences of continuous functions on $[0,2 \pi]$ :

$$
\left\{s_{0}(x), s_{1}(x), s_{2}(x), \ldots\right\} .
$$

(Again, of course, we require $s_{k}(0)=s_{k}(2 \pi)$.) The norm on $Y$ is the obvious sup norm:

$$
\left\|\left\{S_{k}(x)\right\}\right\|=\sup _{k, x}\left|S_{k}(x)\right| .
$$

Now we must put a computability structure on $Y$. We say that an element $\left\{s_{k}\right\}$ in $Y$ is computable if the sequence $\left\{s_{k}(x)\right\}$ is Chapter- 0 -computable and is effectively uniformly convergent. Similarly, a sequence $\left\{y_{n}\right\}$ in $Y$ (which is a double sequence
$\left\{s_{n k}\right\}$ of functions) is computable if $\left\{s_{n k}(x)\right\}$ is Chapter-0-computable and, as $k \rightarrow \infty$, $s_{n k}(x)$ converges uniformly in $x$ and effectively in $k$ and $n$.

The axioms for a computability structure are easily verified for $Y$. Only the Norm Axiom requires a moment's thought: it holds because the double sequence $\left\{s_{n k}\right\}$ is effectively uniformly convergent as $k \rightarrow \infty$.

It would be fairly easy, although a trifle cumbersome, to describe an effective generating set for $Y$. We have no need of it. For, in the First Main Theorem, an effective generating set is needed in the domain $X$ but not in the range $Y$.

Now that we have our range space $Y$, it remains only to define an appropriate operator $T$ and verify its properties. For $T$, of course, we take the operator which maps each function $f \in C[0,2 \pi]$ onto its Fourier series. More precisely,

$$
T f=\left\{s_{k}\right\}, \quad \text { where } s_{k}(x)=\sum_{m=-k}^{k} c_{m} e^{i m x}
$$

and $c_{m}$ is the $m$-th Fourier coefficient of $f$.
It is well known that $T$ is not everywhere defined (there exist continuous functions whose Fourier series do not converge); hence $T$ is an unbounded operator. One readily verifies, however, that $T$ is closed. Finally, as usual, the fact that $\left\{T e_{n}\right\}$ is computable (i.e. that we can compute the Fourier series for the functions $\left\{e^{i n x}\right\}$ ) is trivial almost to the point of being a joke.

So now, by the First Main Theorem, there exists a computable function $f \in C[0,2 \pi]$, with $f \in \mathscr{D}(T)$, whose Fourier series $T f=\left\{s_{k}\right\}$ is not computable in $Y$. What does this imply? Firstly, since $f$ is in the domain of $T$, the Fourier series of $f$ is uniformly convergent. Secondly since $T f$ is not computable in $Y$, we have either:
i) the sequence of partial sums $\left\{s_{k}(x)\right\}$ is not Chapter-0-computable, or ii) the sequence $\left\{s_{k}(x)\right\}$ is not effectively uniformly convergent.

Now (i) is false: the standard method for computing Fourier coefficients gives an effective method for computing $\left\{s_{k}\right\}$. So we must have (ii) which proves the theorem!

We mention in passing Fejer's Theorem, which asserts that, for any $f \in C[0,2 \pi]$, the averages

$$
\sigma_{k}=\left(s_{0}+s_{1}+\cdots+s_{k}\right) /(k+1)
$$

converge uniformly to $f$. Since this holds for all $f \in C[0,2 \pi]$, we know that the corresponding operator (from $f$ to $\left\{\sigma_{k}\right\}$ ) must be bounded. Thus here one obtains a result in the opposite sense to that in Theorem 2:

Effective Fejer Theorem. If $f \in C[0,2 \pi]$ is computable, with $f(0)=f(2 \pi)$, then the sequence $\left\{\sigma_{k}(x)\right\}$ is effectively uniformly convergent to $f(x)$.
(For more details, see Pour-El, Richards [1983a].)

## $L^{p}$ and $l^{p}$ spaces

We turn now to the intrinsic $L^{p}$ and $l^{p}$ computability theories defined in Chapter 2. Our first result deals with the question: If a function $f$ belongs to both $L^{p}[a, b]$ and $L^{r}[a, b]$, and if $f$ is computable in $L^{p}$, is $f$ necessarily computable in $L^{r}$ ? The answer, depending on $p$ and $r$, is sometimes yes, sometimes no. The proof involves the First Main Theorem applied to the injection operator $T f=f$ from $L^{p}$ to $L^{r}$.

For convenience, we combine the corresponding results for $L^{p}[a, b], L^{p}(\mathbb{R})$, and $l^{p}$. We remark that these results also hold for $p=\infty$ or $r=\infty$, where the corresponding spaces-as defined in Chapter 2-are:
$L^{p}[a, b]$ : for $p=\infty$ the corresponding space is $C[a, b]$.
$L^{p}(\mathbb{R})$ : for $p=\infty$ the corresponding space is $C_{0}(\mathbb{R})$.
$l^{p}$ : for $p=\infty$ the corresponding space is $l_{0}^{\infty}$.
Throughout this discussion, when $p$ is finite, we assume that $p$ is a computable real, $p \geqslant 1$. The case $p=\infty$ is as explained above. For $L^{p}[a, b]$, we assume the endpoints $a, b$ are computable reals.

Theorem 3 ( $L^{p}$-Computability for varying $p$ ). (a) If $r \leqslant p$, then every function computable in $L^{p}[a, b]$ is also computable in $L^{r}[a, b]$. If $r>p$, then there exists a function $f$ computable in $L^{p}[a, b]$, such that $f$ belongs to $L^{r}[a, b]$ but is not computable in $L^{r}[a, b]$.
(b) If $r \neq p$, then there exists a function $f$ belonging to both $L^{p}(\mathbb{R})$ and $L^{r}(\mathbb{R})$, such that $f$ is computable in $L^{p}(\mathbb{R})$ but not in $L^{r}(\mathbb{R})$.
(c) If $p \leqslant r$, then every sequence computable in $l^{p}$ is computable in $l^{r}$. If $p>r$, then there exist sequences which are computable in $l^{p}$, belong to $l^{r}$, but are not computable in $l^{r}$.

The proof will follow. First we give some specific cases which are of independent interest.

Let us focus our attention on part (a) above, and on the case where $r=\infty$ and $p$ is finite. Thus we are comparing computability in $L^{p}[a, b]$ to that in $C[a, b]$. Now $C[a, b]$ is a proper subset of $L^{p}[a, b]$, and it is trivial to verify that there exist computable (i.e. $L^{p}$-computable) functions in $L^{p}[a, b]$ which do not belong to $C[a, b]$. (Example: any discontinuous function which is $L^{p}$-computable, such as a step function with computable values and jump-points.) The following is more subtle.

Example 1. There is a continuous function which is computable in $L^{p}[a, b]$ but not in $C[a, b]$-i.e. a continuous function which is $L^{p}$-computable but not Chapter- 0 computable.

Now, since the $L^{p}$-topology is so weak, it may not seem surprising that there are $L^{p}$-computable functions which are not Chapter- 0 -computable. If so, the following example may seem more striking. It is based on part (b) above with $p=\infty$ and $r$ finite.

Example 2. There exists a function $f \in C_{0}(\mathbb{R}) \cap L^{r}(\mathbb{R})$ which is computable in $C_{0}$ but not in $L^{r}$. Spelling this out: There exists a Chapter-0-computable function $f$ on $\mathbb{R}$, such that $f(x) \rightarrow 0$ effectively as $|x| \rightarrow \infty$, and such that $f \in L^{r}(\mathbb{R})$, but such that $f$ is not computable in $L^{r}(\mathbb{R})$.

Proof of Theorem 3. To avoid repeating ourselves three times, we shall use the term " $L^{p}$ " as a generic expression for either $L^{p}[a, b], L^{p}(\mathbb{R})$, or $l^{p}$. Similarly for " $L^{r}$ ".

Let $T$ be the injection operator $T f=f$ from $L^{p}$ to $L^{r}$. What is the domain of $T$ ? Since $T: L^{p} \rightarrow L^{r}$ and $T f=f$, we need $f \in L^{p}$ and $f \in L^{r}$ : thus the domain $\mathscr{D}(T)=L^{p} \cap L^{r}$.

We pause now to verify that $T$ is closed. Since this is our first theorem dealing with $L^{p}$-spaces, we shall proceed with some care. This also provides a good opportunity to illustrate the closure criteria developed at the end of Section 1.

Begin with $L^{p}[a, b]$ and $L^{p}(\mathbb{R})$. We use the Second Closure Criterion, applied to a topology which is weaker than any of the $L^{p}$-topologies-e.g. the distribution topology. Obviously the operator $T f=f$ is continuous in this weak topology.

For $l^{p}$, instead of distributions, we use the topology of pointwise convergence (viewing sequences in $l^{p}$ as functions defined on the natural numbers).

Remark. For $L^{p}[a, b]$ and $l^{p}$, it turns out that $T^{-1}$ is bounded whenever $T$ is not. Thus we could also use the First Closure Criterion. However, this would not work for $L^{p}(\mathbb{R})$.

Now that we know that $T$ is closed, we also know that $T$ is bounded if and only if its domain $\mathscr{D}(T)=L^{p}$ (Closed Graph Theorem). Since, as we have seen, $\mathscr{D}(T)=L^{p} \cap L^{r}$, we conclude that $T$ is bounded if and only if $L^{p} \subseteq L^{r}$. When does this happen? One readily verifies that:
$L^{p}[a, b] \subseteq L^{r}[a, b]$ if and only if $r \leqslant p$.
$L^{p}(\mathbb{R}) \subseteq L^{r}(\mathbb{R})$ if and only if $r=p$.
$l^{p} \subseteq l^{r}$ if and only if $p \leqslant r$.
These, the necessary and sufficient conditions for $T$ to be bounded, are precisely the conditions given in Theorem 3-parts (a), (b), and (c), respectively-for $T$ to preserve computability. Thus we now have almost everything we need to apply the First Main Theorem: $T$ is closed, and we know the conditions on $p$ and $r$ under which $T$ is bounded. There is one last point. We must show that $T$ maps the effective generating set $\left\{e_{n}\right\}$ (for $L^{p}[a, b]$ or $L^{p}(\mathbb{R})$ or $l^{p}$ as the case may be) onto a computable sequence. Well, since $T f=f, T$ maps the effective generating set onto itself.

## 4. Further Applications to Real Analysis

Here we present several topics which are a bit more sophisticated than those given in Section 3. Our first and main result (Theorem 4) delineates the computability relations which hold between functions and their Fourier series and transforms.

This theorem is a prototype for many similar theorems. Indeed, in a virtually identical manner, we could deal with any of the standard linear transforms of real analysis (e.g. the Hilbert transform). We mention in passing that Theorem 4 leads to an effective Plancherel Theorem and an effective Riemann-Lebesgue Lemma (Corollaries 4d and 4e).

Our second result concerns an alternative characterization of $L^{p}$-computability in terms of the Fourier coefficients and the norm. For $p=2$, this result is a corollary of the effective Plancherel Theorem mentioned above.

Our third result also involves the properties of $L^{p}$-computability, but in a different setting. We focus on whether taking the effective $L^{p}$-closure of the "starting functions" (step functions, continuous functions, etc.) adds to the collection of computable starting functions. For continuous functions the answer is "yes", as we saw in Theorem 3 of the last section. For step functions the answer is "no", as we shall show in Theorem 5 below.

## Fourier series and transforms

As a consequence of the First Main Theorem, we can easily determine the cases in which the process of taking Fourier series, Fourier coefficients, or Fourier transforms preserves computability, and also tell when it does not. First we fix some notation. For Fourier series we shall use the interval $[0,2 \pi]$, and thus define the Fourier coefficients $c_{k}$ of a function $f(x)$ by:

$$
c_{k}=(2 \pi)^{-1} \int_{0}^{2 \pi} e^{-i k x} f(x) d x
$$

We consider the (possibly unbounded) operator $T$ which maps functions $f \in L^{p}[0,2 \pi]$ onto their sequence of Fourier coefficients $\left\{c_{k}\right\} \in l^{r}$; the domain $\mathscr{D}(T)$ is the set of such $f$ for which $\left\{c_{k}\right\}$ has finite $l^{r}$-norm. Similarly we define the inverse operator $T^{-1}$ mapping coefficient sequences $\left\{c_{k}\right\}$ in $l^{p}$ to the corresponding functions $f(x)=\sum_{k=-\infty}^{\infty} c_{k} e^{i k x}$ in $L^{r}[0,2 \pi]$. (Note that we keep the $p$-norm on the domain, the $r$-norm on the range.) For the Fourier transform, which we denote by $F T$, we use:

$$
F T(f)(t)=(2 \pi)^{-1 / 2} \int_{-\infty}^{\infty} e^{-i t x} f(x) d x
$$

Then, as is well known, the inverse transform is $F T(f)(-t)$. That is, if $g(t)=F T(f)(t)$, then $f(t)=F T(g)(-t)$.

Of course we assume that $p, r$ are computable reals. The values $p=\infty$ and $r=\infty$ are also allowed, with the interpretation given in the preceding subsection on $L^{p}$-spaces (and also spelled out in Chapter 2). Here it is convenient to let $q$ denote the dual variable to $p$, given by

$$
\frac{1}{p}+\frac{1}{q}=1
$$

Theorem 4 (Fourier series and transforms). (a) Let $f$ be computable in $L^{p}[0,2 \pi]$, and let $\left\{c_{k}\right\}$ be its sequence of Fourier coefficients. If $r \geqslant \max (q, 2)$, then $\left\{c_{k}\right\}$ is computable in $l^{r}$. Otherwise, there exist examples where $f$ is computable in $L^{p}[0,2 \pi]$, $\left\{c_{k}\right\}$ belongs to $l^{r}$, but $\left\{c_{k}\right\}$ is not computable in $l^{r}$.
(b) The inverse mapping $T^{-1}$ from sequences $\left\{c_{k}\right\} \in l^{p}$ to functions $f \in L^{r}[0,2 \pi]$ preserves computability (i.e. maps computable sequences onto computable functions) if $r \leqslant q$ and $p \leqslant 2$. Otherwise, there exist examples where $\left\{c_{k}\right\}$ is computable in $l^{p}$, $f$ belongs to $L^{r}[0,2 \pi]$, but $f$ is not computable in $L^{r}[0,2 \pi]$.
(c) The Fourier transform $F T: L^{p}(\mathbb{R}) \rightarrow L^{r}(\mathbb{R})$ preserves computability when $r=q$, $p \leqslant 2$, and maps some computable $L^{p}$ function onto a noncomputable $L^{r}$ function otherwise.

Proof. To apply the First Main Theorem, we must go through the usual steps: (i) verify that $T, T^{-1}$, and $F T$ are closed; (ii) determine the conditions under which they are or are not bounded, and (iii) verify that they act effectively on an effective generating set.

Begin with closedness. In the last Example in Section 1, we showed that $F T$ is closed. The proofs for $T$ and $T^{-1}$ are similar (and easier).

The problem of deciding for which $p$ and $r$ the operators $T, T^{-1}$, and $F T$ are bounded is by no means trivial; but it is a standard problem in classical analysis whose answer is well known. We list the results and then give some comments and literature references. The necessary and sufficient conditions for boundedness are:
for $T$ : that $r \geqslant \max (q, 2)$;
for $T^{-1}$ : that $r \leqslant q$ and $p \leqslant 2$;
for $F T$ : that $r=q$ and $p \leqslant 2$.
Of course, these match precisely the cases-in (a), (b), and (c) respectively-under which the operators $T, T^{-1}$, and $F T$ preserve computability.

Although these results are "folklore", we know of no source where all of them are collected in one place. However, they are easily obtainable from standard results. All of the cases of boundedness follow from the Riesz Convexity Theorem (cf. Dunford, Schwartz [1958]). For the unbounded cases, two key counterexamples are given in Zygmund [1959, Vol. 2, pp. 101-102], and all of the other examples can be derived by combining Zygmund's examples with standard arguments from Fourier analysis.

This brings us to the action of $T, T^{-1}$, or $F T$ on the effective generating sets. First we must specify the effective generating sets themselves.

For $L^{p}[0,2 \pi]$, the domain of $T$, we use the effective generating set $\left\{e^{i n x}\right\}$, $n=0, \pm 1, \pm 2, \ldots$.

For $l^{p}$, the domain of $T^{-1}$, we take as our effective generating set the sequence $\left\{e_{n}\right\}, n=0, \pm 1, \pm 2, \ldots$, consisting of "unit vectors" $e_{n}(m)$ (where $e_{n}(m)=1$ for $m=n, 0$ for $m \neq n$ ).

For $L^{p}(\mathbb{R})$, the domain of the Fourier transform, we take as our effective generating set the continuous piecewise linear functions with compact support (and with rational [complex rational] coordinates for the vertices-cf. Chapter 2, Section 3).

Routine computations show that $T, T^{-1}$, and $F T$ act effectively on these effective generating sets. This completes the proof of Theorem 4.

The following two corollaries are so useful that we state them separately.
Corollary 4d (Effective Plancherel Theorem). A function $f \in L^{2}[0,2 \pi]$ is computable in $L^{2}$ if and only if its sequence of Fourier coefficients $\left\{c_{k}\right\}$ is computable in $l^{2}$. A function $f \in L^{2}(\mathbb{R})$ is computable if and only if its Fourier transform is.

Corollary 4e (Effective Riemann-Lebesgue Lemma). If $f$ is computable in $L^{1}(\mathbb{R})$, then its Fourier transform $F T(f)$ is computable in $C_{0}(\mathbb{R})$. In particular, $F T(f)(t) \rightarrow 0$ effectively as $|t| \rightarrow \infty$.

Proofs. Corollary 4d is just the case $p=r=2$ in parts (a), (b), (c) of Theorem 4. Corollary 4e is the case $p=1, r=\infty$ of Theorem 4, part (c).

## An alternative characterization of $L^{p}$-computability

Corollary 4d above suggests that there is another characterization of intrinsic $L^{p}$-computability, in which the Fourier coefficients play a major role. The next theorem shows that this is the case. For $1<p<\infty$, the Fourier coefficients together with the norm provide such a characterization.

Theorem* ( $L^{p}$-computability in terms of the Fourier coefficients and the norm). Let $p$ be a computable real, $1<p<\infty$. Then a function $f \in L^{p}[0,2 \pi]$ is intrinsically $L^{p}$-computable if and only if:
(a) the sequence $\left\{c_{k}\right\}$ of Fourier coefficients of $f$ is computable, and
(b) the $L^{p}$-norm of $f$ is computable.

The proof will not be given here, as it is quite intricate. The details can be found in Pour-El, Richards [1984]. We mention that the result fails for $p=1$.

For the case $p=2$, there is a much easier proof. Since this proof is short, we give it here.

Proof for $p=2$. Suppose $f$ is computable in $L^{2}$. Then by the Effective Plancherel Theorem (Corollary 4d above) the sequence of Fourier coefficients $\left\{c_{k}\right\}$ is computable in $l^{2}$. Furthermore, by the Norm Axiom, $\|f\|$ is computable.

Conversely, suppose that $\left\{c_{k}\right\}$ is a computable sequence of reals, and $\|f\|$ is computable. Then, since $\|f\|=\left\|\left\{c_{k}\right\}\right\|,\left\|\left\{c_{k}\right\}\right\|$ is computable. Hence $\left(\sum_{k=-\infty}^{\infty}\left|c_{k}\right|^{2}\right)^{1 / 2}$ is a computable real. Now the sequence $\left\{\sum_{k=-N}^{N}\left|c_{k}\right|^{2}\right\}$ is a computable sequence which converges monotonically to a computable limit. Hence (cf. Section 2 in Chapter 0) the convergence is effective. Thus we conclude that the sequence of partial sums $\sum_{k=-N}^{N} c_{k} e^{i k x}$ is a computable sequence which converges effectively to $f$. Hence $f$ is computable.

## Well understood functions

Recall that, for $p<\infty$, the set of $L^{p}$-computable functions is the effective closure in $L^{p}$-norm of various classes of "well understood" functions (e.g. continuous functions/step functions/piecewise linear functions, etc.). Here we ask a different question: what does the process of taking the effective $L^{p}$-closure do to the well understood functions themselves?

Let us begin with step functions-the most natural starting point for measure theoretic applications. We ask: does the process of taking the effective $L^{p}$-closure produce any new "computable" step functions? That is, are there any step functions which are $L^{p}$-computable, even though they are not computable in the "elementary" sense of having computable values and jump points? The answer turns out to be "no" (Theorem 5 below).

This result is not quite so obvious as might be supposed. To illustrate the point, suppose we ask the same question for continuous functions. That is, do there exist continuous functions which are $L^{p}$-computable, although they are not computable in the "elementary" sense of Chapter 0? The answer is "yes": cf. Example 1 following Theorem 3 in the last section.

Where does the difference lie? Presumably it is connected with the fact that step functions are determined by a finite set of real parameters, whereas continuous functions are not. Further evidence for this is obtained if we consider sequences of step functions.

Definition. A sequence $\left\{s_{n}(x)\right\}$ of step functions on $[a, b]$ is computable in the elementary sense if

$$
s_{n}(x)=c_{n i} \quad \text { for } a_{n, i-1} \leqslant x<a_{n i},
$$

where $a=a_{n 0}<a_{n 1}<\cdots<a_{n m}=b$, the number of "steps" $m=m(n)$ is a recursive function of $n,\left\{a_{n i}\right\}$ is a computable double sequence of real numbers, and $\left\{c_{n i}\right\}$ is a computable double sequence of real/complex numbers.

As previously, we ask: does the process of taking the effective $L^{p}$-closure produce any new computable sequences of step functions? The answer turns out to be "yes".

To summarize, we now have three cases: 1) step functions, 2) continuous functions 3) sequences of step functions, where we ask: does taking the effective $L^{p}$-closure increase the stock of computable starting functions? As we have seen, the answers are 1 ) no, 2 ) yes, and 3 ) yes.

We shall now prove these results. As already noted, 2) follows from Theorem 3. This leaves 1) (step functions) and 3) (sequences of step functions) to be dealt with. We will begin with 3 ).

Note. For piecewise linear functions and sequences of piecewise linear functions, the results are the same as for 1) and 3) respectively. These results could be established by the same methods.

Example. We now show that a sequence of step functions can be $L^{p}$-computable without being computable in the elementary sense.

Proof. Let $a: \mathbb{N} \rightarrow \mathbb{N}$ be a one to one recursive function generating a recursively enumerable non recursive set $A$. For convenience, we assume $0 \notin A$, and also, in studying $a(k)$, we ignore the value $k=0$.

Operating, for the moment, without reference to computability, suppose that $n \in A, n=a(k)$ with $k>0$. Then we define a corresponding step function $\sigma_{n k}$ on [0,1] by

$$
\sigma_{n k}(x)= \begin{cases}1 & \text { if } \frac{j}{k} \leqslant x \leqslant \frac{j}{k}+\frac{1}{k^{2}} \text { for some } j, 0 \leqslant j<k \\ 0 & \text { otherwise. }\end{cases}
$$

Thus $\sigma_{n k}$ consists of $k$ "steps", each of height 1 and width $1 / k^{2}$. The measure of the set $\left\{x: \sigma_{n k}(x)=1\right\}$ is $1 / k$. Hence the $L^{p}$-norm of $\sigma_{n k}$ is $(1 / k)^{1 / p}$.

Returning now to an effective presentation, we define the double sequence of step functions $s_{n k}$ effectively by:

$$
s_{n k}= \begin{cases}\sigma_{n j} & \text { if } n=a(j) \text { for some } j \leqslant k \\ 0 & \text { otherwise } .\end{cases}
$$

Then as $k \rightarrow \infty$, the computable double sequence $\left\{s_{n k}\right\}$ converges effectively in $L^{p}$-norm to the sequence $\left\{s_{n}\right\}$ given by:

$$
s_{n}= \begin{cases}\sigma_{n j} & \text { if } n=a(j) \text { for some } j \\ 0 & \text { otherwise }\end{cases}
$$

To see that the convergence is effective, we argue as follows: If $s_{n k} \neq s_{n}$, then $s_{n k}=0$, whereas $s_{n}=\sigma_{n j}$ for some $j>k$. Thus the $L^{p}$-norm $\left\|s_{n k}-s_{n}\right\|=\left\|\sigma_{n j}\right\|$, and as we saw above, $\left\|\sigma_{n j}\right\|=(1 / j)^{1 / p}<(1 / k)^{1 / p}$. Here, of course, $p$ is fixed, and $(1 / k)^{1 / p} \rightarrow 0$ effectively as $k \rightarrow \infty$.

Since $\left\{s_{n}\right\}$ is the effective limit in $L^{p}$-norm of the computable double sequence $\left\{s_{n k}\right\}$, the sequence $\left\{s_{n}\right\}$ is $L^{p}$-computable.

Yet $\left\{s_{n}\right\}$ is not computable in the elementary sense defined above. For, if $\left\{s_{n}\right\}$ were computable in the elementary sense, then by definition we would have formulas for the $s_{n}$ which would give a decision procedure for $A$. Since $A$ is not recursive, this is impossible. In addition, the "number of steps" in the $n$-th step function $s_{n}$ grows more rapidly than any recursive function of $n$. For, if $n=a(k)$, the "number of steps" in $s_{n}(x)=\sigma_{n k}(x)$ is just $k$. Now consider the "maximum number of steps" in any $s_{m}(x), m \leqslant n$ : it is

$$
w(n)=\max \{k: a(k) \leqslant n\} .
$$

This is just the "waiting time" defined in the first section of Chapter 0. By the Waiting Lemma, proved there, $w(n)$ is not bounded by any recursive function.

We turn now to the case of a single step function. We work over $L^{p}[a, b]$, where $p, a, b$ are computable reals, and consider an arbitrary step function $s(x)$ defined by:

$$
s(x)=c_{i} \quad \text { for } a_{i-1} \leqslant x<a_{i},
$$

where $a=a_{0}<a_{1}<\cdots<a_{m}=b$. We call $a_{i}$ an essential transition point if $c_{i+1} \neq c_{i}$, i.e. if the function really jumps at $a_{i}$.
[Note: we have not assumed $a$-priori that the jump-points $a_{i}$ or the values $c_{i}$ are computable.]

Theorem 5 (step functions). A step function $s(x)$ is computable in $L^{p}[a, b]$ for $p<\infty$ if and only if all of the values $c_{i}$ and all of the essential transition points $a_{i}$ are computable (i.e. if and only if $s(x)$ is computable in the elementary sense).

Proof. The "if" part is trivial.
For the "only if" part, assume that $s(x)$ is $L^{p}$-computable. This means, by definition, that there is a sequence $\left\{s_{k}\right\}$ of step functions, computable in the elementary sense, which converges effectively to $s$ in $L^{p}$-norm. We have to show that $s$ itself is computable in the elementary sense (i.e. has computable $c_{i}$ and $a_{i}$ ).

A direct proof along these lines is not entirely trivial. A much easier proof can be given based on the First Main Theorem.

We apply the First Main Theorem to the transformation

$$
T(f)(x)=\int_{a}^{x} f(u) d u
$$

Then $T$ is a bounded linear operator form $L^{p}[a, b]$ into $C[a, b]$. Clearly $T$ maps the effective generating set $x^{0}, x^{1}, x^{2}, \ldots$ onto a computable sequence. Therefore $T$ maps any function computable in $L^{p}[a, b]$ onto a function computable in $C[a, b]$.

Hence, since $s(x)$ is computable in $L^{p}[a, b], T[s(x)]$ is computable in $C[a, b]$-i.e. $T[s(x)]$ is Chapter-0-computable. Since $s(x)$ is a step function, $T[s(x)]$ is a "piecewise linear" function, whose linear portions have slopes $c_{i}$, and whose transition points are the $a_{i}$. Now the Chapter 0 definition allows the effective evaluation of computable functions at computable points. Thus we can compute the slopes $c_{i}$ by evaluating $T[s(x)]$ at two rational points within the same subinterval of the partition; and once the slopes are found, we can compute the $a_{i}$ by solving two linear equations in two unknowns.

Remark. Of course, pointwise evaluation makes no sense for $L^{p}$-functions, since an $L^{p}$-function is only determined up to sets of measure zero. This limitation already exists in classical analysis, without any notions of logical "effectiveness" being required. By its very nature, an $L^{p}$-function is known only on the average.

The point of the above proof is to map $L^{p}[a, b]$ into $C[a, b]$, where pointwise evaluation makes sense.

## 5. Applications to Physical Theory

We now discuss, from the viewpoint of computability theory, the three well-known partial differential equations of classical physics: the wave equation, the heat equation, and Laplace's equation. A similar discussion could be given for other linear differential and integral equations which occur regularly in analysis and in physical theory.

## The Wave Equation

We consider the equation:

$$
\begin{gather*}
\frac{\partial^{2} u}{\partial x^{2}}+\frac{\partial^{2} u}{\partial y^{2}}+\frac{\partial^{2} u}{\partial z^{2}}-\frac{\partial^{2} u}{\partial t^{2}}=0 \\
u(x, y, z, 0)=f(x, y, z)  \tag{1}\\
\frac{\partial u}{\partial t}(x, y, z, 0)=0
\end{gather*}
$$

As solutions to this equation travel with finite velocity (here made equal to 1 ), it is natural to consider the wave equation on compact domains. We just make the domain large enough so that "light rays" from outside the domain cannot reach any point in the domain in the time considered. Thus we define $D_{1}$ and $D_{2}$ by:

$$
\begin{aligned}
& D_{1}=\{(x, y, z):|x| \leqslant 1,|y| \leqslant 1,|z| \leqslant 1\}, \\
& D_{2}=\{(x, y, z):|x| \leqslant 3,|y| \leqslant 3,|z| \leqslant 3\} .
\end{aligned}
$$

Then if $0<t<2$, the solution of the wave equation on $D_{1}$ does not depend on the initial values $u(x, y, z, 0)$ outside $D_{2}$. So we may as well assume that $f$ has domain $D_{2}$.

Consider the definitions of computability on $D_{1}$ and $D_{2}$ given in Chapter 0 . Recall that they correspond respectively to the Banach spaces of continuous functions $C\left(D_{1}\right)$ and $C\left(D_{2}\right)$ with the uniform norm. Now the monomials $x^{a} y^{b} z^{c}, a, b, c \in \mathbb{N}$ provide an effective generating set both for $C\left(D_{1}\right)$ and for $C\left(D_{2}\right)$. Thus finite linear combinations of the monomials (i.e. polynomials in three variables) are dense in $C\left(D_{i}\right)(i=1,2)$, and a function $f \in C\left(D_{i}\right)$ is computable if and only if the Weierstrass approximation can be made effective (Theorem 6, Chapter 0).

The solution of the wave equation (1) is given by Kirchhoff's formula (Petrovskii [1967]).

$$
\begin{equation*}
u(\vec{x}, t)=\iint_{\text {unit sphere }}[f(\vec{x}+t \vec{n})+t(\operatorname{grad} f)(\vec{x}+t \vec{n}) \cdot \vec{n}] d \sigma(\vec{n}) \tag{2}
\end{equation*}
$$

where $\vec{x}=(x, y, z), \vec{n}$ ranges over the sphere of radius 1 in $\mathbb{R}^{3}$, and $d \sigma(\vec{n})$ is the area measure on this sphere normalized so that the total area is 1 .

Now fix $t_{0}$ so that $0<t_{0}<2$. Let the associated solution operator $T\left(t_{0}\right)$ (given by Kirchhoff's formula above) be denoted by $T$. Since the formula contains a "grad" term, $T$ is an unbounded operator. Furthermore $T$ is closed. This follows because there exist weaker topologies-e.g. that of Schwartz distributions-in which the Kirchhoff operator is continuous (cf. Section 1). Finally, we must verify that $T$ operates effectively on the monomials $x^{a} y^{b} z^{c}$ in the generating set. This is obvious from Kirchhoff's formula. Hence, letting $t_{0}=1$, by the First Main Theorem, we conclude:

Theorem 6 (Wave Propagation, Uniform Norm). Consider the wave equation with the initial conditions $u=f, \partial u / \partial t=0$ at time $t=0$. Let $D_{1}$ and $D_{2}$ be the two cubes in $\mathbb{R}^{3}$ given above. Then there exists a computable, continuous function $f(x, y, z)$ in $C\left(D_{2}\right)$ such that the solution $u(x, y, z, t)$ at time $t=1$ is continuous, but is not a computable function in $C\left(D_{1}\right)$.

We now show that the situation is different if we use the energy norm instead of the uniform norm. This difference occurs even if the wave equation is treated more generally. Recall that the wave equation (1) gives a mapping from an initial function $f(x, y, z)$ on $\mathbb{R}^{3}$ to the solution $u(x, y, z, t)$ on $\mathbb{R}^{4}$. We now replace the initial condition $\partial u / \partial t=0$ at $t=0$ by $\partial u / \partial t=g$. This gives two initial conditions

$$
\begin{aligned}
u(x, y, z, 0) & =f(x, y, z) \\
\frac{\partial u}{\partial t}(x, y, z, 0) & =g(x, y, z)
\end{aligned}
$$

Thus we are led to consider two Banach spaces of functions with the energy norm: one for the range space on $\mathbb{R}^{4}$ and one for the domain on $\mathbb{R}^{3} \times \mathbb{R}^{3}$.

For technical reasons, we will consider a compact time interval $-M \leqslant t \leqslant M$, where $M>0$ is a computable real. Thus the functions in our range space are defined on $\mathbb{R}^{3} \times\{-M \leqslant t \leqslant M\}$.

We consider the range space first. The energy norm is defined by

$$
\|u(x, y, z, t)\|=\sup _{t} E(u, t)
$$

where

$$
\begin{equation*}
E(u, t)^{2}=\iiint_{\mathbb{R}^{3}}\left[|\operatorname{grad} u|^{2}+\left(\frac{\partial u}{\partial t}\right)^{2}\right] d x d y d z \tag{3}
\end{equation*}
$$

(As is usual, $|\operatorname{grad} u|^{2}=(\partial u / \partial x)^{2}+(\partial u / \partial y)^{2}+(\partial u / \partial z)^{2}$.)
$E(u, t)^{2}$ is known as the energy integral. It is well known (Hellwig [1964], p. 24) that for solutions of the wave equation, $E(u, t)$ is independent of $t$ ("conservation
of energy"). However, for an arbitrary function $u, E(u, t)$ will depend on $t$. This is the reason we take the sup over $t$ in (3).

The Banach space consists of those functions $u$ for which the norm $\sup E(u, t)$ is bounded.

Although the above Banach space with the energy norm is being considered for the first time, the notion of computability is not really new. It is closely associated with the notion of "intrinsic computability" discussed in Chapter 2. This can be seen as follows. The Banach space is of mixed type- $L^{2}$ in the partial derivatives with respect to $x, y, z$ and $L^{\infty}$ in $t$. To obtain the computable functions we use the procedure of Chapter 2: we take the effective closure in the energy norm of the computable functions of Chapter 0. There is a small variation, however. Since the norm $E(u, t)$ involves first derivatives, we take Chapter- 0 -computable functions which are computably $C^{1}$-i.e. computable together with their first derivatives. Similar remarks hold for computable sequences of computable functions.

We now turn to the domain of the wave equation. It consists of pairs of functions $f, g$ on $\mathbb{R}^{3}$, where $f$ and $g$ are initial conditions. To restrict the energy norm to $\mathbb{R}^{3}$, we let $t=0$. Then the energy norm becomes the energy integral

$$
\|f, g\|^{2}=\iiint_{\mathbb{R}^{3}}\left[|\operatorname{grad} f|^{2}+g^{2}\right] d x d y d z
$$

The notion of computability on this space is an obvious modification of the notion of computability on the previous space.

In summary, we have defined "computability in energy norm" for solutions $u(x, y, z, t)$ on $\mathbb{R}^{4}$ and for pairs of initial conditions $f(x, y, z)$ and $g(x, y, z)$ on $\mathbb{R}^{3}$.

There are two additional facts which we must verify in order to apply the First Main Theorem. First we must show that there is an effective generating set for the pairs of functions $f, g$ in the domain space, and that the wave operator acts effectively on this set. Second we must show that the wave operator is bounded.

To construct an effective generating set we proceed as follows. We begin with a $C^{\infty}$ function $\varphi(x) \geqslant 0$ which is supported on $[-1,1]$, positive on the interior of this interval and computable together with all of its derivatives. For example, let

$$
\varphi(x)= \begin{cases}e^{-x^{2} /\left(1-x^{2}\right)} & \text { for }|x|<1 \\ 0 & \text { otherwise }\end{cases}
$$

Then take the sequence of functions

$$
x^{a} y^{b} z^{c} \cdot \varphi\left[\left(x^{2}+y^{2}+z^{2}\right) / d^{2}\right], \quad a, b, c, d \in \mathbb{N}, d \geqslant 1
$$

Note that linear combinations of pairs of such functions generate, by effective closure in the energy norm, the set of computable pairs ( $f, g$ ). Furthermore it is easily verified that the wave operator $T$ acts effectively on pairs of functions $f, g$ in the effective generating set on the domain space.

To show that the wave operator is bounded we note the following. The conservation of energy principle mentioned above implies that the mapping $T$ from the initial conditions $f, g$ to the solution $u(x, y, z, t)$ is bounded of norm 1 .

Since the hypotheses of the First Main Theorem are satisfied and the solution operator is bounded we have:

Theorem 7 (Wave Propagation, Energy Norm). Let $(f, g)$ be a pair of initial functions on $\mathbb{R}^{3}$ which is computable in terms of the energy norm. Then the corresponding solution $u(x, y, z, t)$ on $\mathbb{R}^{3} \times\{-M \leqslant t \leqslant M\}$ is computable in the energy norm.

Note. A rather more complicated treatment of the wave equation with energy norm, which however deals with the entire time-interval $-\infty<t<\infty$, is given in Pour-El, Richards [1983b].

## The Heat Equation

This equation is:

$$
\begin{gathered}
\frac{\partial u}{\partial t}=\frac{\partial^{2} u}{\partial x^{2}}+\frac{\partial^{2} u}{\partial y^{2}}+\frac{\partial^{2} u}{\partial z^{2}} \\
u(x, y, z, 0)=f(x, y, z)
\end{gathered}
$$

Its solution is given by

$$
u(x, y, z, t)=\iiint_{\mathbb{R}^{3}} K_{t}\left(x-x^{\prime}, y-y^{\prime}, z-z^{\prime}\right) f\left(x^{\prime}, y^{\prime}, z^{\prime}\right) d x^{\prime} d y^{\prime} d z^{\prime}
$$

where

$$
K_{t}(x, y, z)=\left(\frac{1}{4 \pi t}\right)^{3 / 2} e^{-\left(x^{2}+y^{2}+z^{2}\right) / 4 t}
$$

The appropriate Banach spaces for the heat equation are $C_{0}\left(\mathbb{R}^{3}\right)$ for the domain and $C_{0}\left(\mathbb{R}^{4}\right)$ for the range, both with the uniform norm. Recall that $f(x), x \in \mathbb{R}^{n}$ is computable in $C_{0}\left(\mathbb{R}^{n}\right)$ if it is computable in the sense of Chapter 0 and in addition $f(x) \rightarrow 0$ effectively as $|x| \rightarrow 0$ (see Chapter 2, Section 3).

As our effective generating set for the domain space $C_{0}\left(\mathbb{R}^{3}\right)$ we use the same family of functions as with the wave equation. It is obvious that the solution formula for the heat equation operates effectively on this sequence of functions.

Since the kernel $K_{t}(x, y, z)$ decays rapidly as $\left(x^{2}+y^{2}+z^{2}\right) \rightarrow \infty$, the heat operator is bounded.

Thus the hypotheses of the First Main Theorem are satisfied. Since the heat operator is bounded the following theorem is an immediate corollary of the First Main Theorem.

Theorem 8 (Heat Equation). Let $f(x, y, z)$ be computable in $C_{0}\left(\mathbb{R}^{3}\right)$. Then the solution $u(x, y, z, t)$ of the heat equation is computable in $C_{0}\left(\mathbb{R}^{4}\right)$.

## Laplace's Equation

Here the standard problem is to find a solution $u$ of Laplace's equation

$$
\frac{\partial^{2} u}{\partial x^{2}}+\frac{\partial^{2} u}{\partial y^{2}}+\frac{\partial^{2} u}{\partial z^{2}}=0
$$

on the interior of a compact domain $D$, such that the values of $u$ on the boundary $\partial D$ coincide with a preassigned continuous function $f$. It is well known that solutions of Laplace's equation satisfy the "maximum principle", i.e. the maximum of $|u|$ occurs on the boundary of $D$. Hence the mapping $T$ from $f$ to $u$ is bounded of norm one. This already suggests, by the First Main Theorem, that computable boundary data $f$ should produce computable solutions $u$.

The difficulties in solving this problem are geometric, relating the solution operator $T: f \rightarrow u$ to the shape of the boundary $\partial D$. A detailed examination of this question would lead us into potential theory, which we regard as lying outside our scope. Consequently we shall restrict our attention to a few of the standard regions which occur frequently in applications. Our list is by no means exhaustive, and many other regions could be dealt with by the same method. We consider the following regions.

1. Rectangle with computable coordinates for the "corners".
2. Cylinder with computable parameters.
3. Ball with computable center and radius.
4. Ellipsoid with computable center and axes.

Theorem 9 (Laplace's Equation). Let $D$ be any one of the regions listed above. Let $f$ be a continuous function which is computable in the sense of Chapter 0 . Let $u$ be the solution of Laplace's equation which coincides with $f$ on the boundary of $D$. Then $u$ is also computable in the sense of Chapter 0 .

Proof. We have noted that $T$ is a bounded operator. Thus the only thing that remains is to show that $T$ maps an effective generating set onto a computable sequence. For our effective generating set we take the monomials $\left\{x^{a} y^{b} z^{c}\right\}$ where $a$, $b, c$ are nonnegative integers. The computation of the solutions $u$ corresponding to $f=x^{a} y^{b} z^{c}$ are classical, and the resulting functions are computable, effectively in $a$, $b, c$. Theorem 9 now follows as a corollary of the First Main Theorem.

Clearly the same argument could be applied to many other regions $D$ besides those listed above. A more general approach can also be given, using ideas similar to those in Corollary 6c of Chapter 0 (cf. Pour-El, Richards [1983b]).

## Dimensions other than 3

The results in this section have been proved for the important case of spacedimension 3. All of them extend to other dimensions. Theorems 7, 8 and 9, in which the solution operator is bounded, extend mutatis-mutandis to all space-dimensions $q \geqslant 1$. Theorem 6 (wave equation, uniform norm) extends to space-dimensions $q \geqslant 2$ but not to $q=1$ (cf. Pour-El, Richards [1981]). This is because the solution operator for the wave equation in uniform norm is unbounded for $q \geqslant 2$, but bounded for $q=1$.

