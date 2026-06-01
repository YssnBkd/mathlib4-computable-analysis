## Chapter 5 <br> Proof of the Second Main Theorem

## Introduction

Here, as promised, we give the proof of the Second Main Theorem. (Cf. Chapter 4. The theorem is also restated at the end of this introduction.) For purposes of discussion, we recall two of the consequences of that theorem: The eigenvalues of an effectively determined self adjoint operator are computable, but the sequence of eigenvalues need not be.

How do we prove this? As might be expected, the proof is based on the spectral theorem. However, it does not involve an effectivization of that theorem. Nor does it involve an effectivization of some weaker version of that theorem. Rather we use certain consequences of the spectral theorem to develop an effective algorithm. This algorithm, in fact, embodies a viewpoint directly opposed to that of the spectral theorem-at least in its most standard form.

The standard form of the spectral theorem gives a decomposition of the Hilbert space $H$ into mutually orthogonal subspaces $H_{\left(a_{i-1}, a_{i}\right]}$ corresponding to an arbitrary partition of the real line into intervals $\left(a_{i-1}, a_{i}\right]$. On these subspaces $H_{\left(a_{i-1}, a_{i}\right]}$ the operator $T$ is "approximately well behaved". More precisely, (i) these subspaces are invariant under $T$-i.e. if $x$ lies in the subspace, so does $T x$, and (ii) the vectors $x$ in the subspace are "approximate eigenvectors"-i.e. if $\left(a_{i-1}, a_{i}\right] \subseteq[\lambda-\varepsilon, \lambda+\varepsilon]$ then $\|T x-\lambda x\| \leqslant \varepsilon\|x\|$.

It turns out that effective computations involving the spectral measure require the uniform norm, i.e. computability in the sense of Chapter 0. Thus the above decomposition-involving disjoint intervals-cannot be made effective. What we have is a classical analytic fact, the existence of such a decomposition, from which we must attempt to derive effective consequences. To do this we alter the standard spectral-theoretic decomposition in two ways.

First, we replace the disjoint intervals by intervals which overlap, after the manner of $\ldots[-2,0],[-1,1],[0,2],[1,3], \ldots$. Second, we replace the characteristic functions of these intervals by "triangle functions" supported on them (cf. Pre-step B in Section 2). The overlapping intervals are necessary to account for the fact that a computable real number cannot be known exactly, and the triangle functions, being continuous, allow effective computations to be made. It is the necessity of using overlapping intervals and continuous functions which is at variance with the
standard viewpoint of the spectral theorem-a viewpoint which stresses disjoint interval decompositions and orthogonal subspaces.

Returning to our original assertion: that the individual eigenvalues are computable but the sequence of eigenvalues need not be. Our overlapping triangles allow us to compute the individual eigenvalues. Essentially this depends on the fact that the eigenvalues occur at points where the spectral measure is "especially dense". By contrast, the sequence of eigenvalues need not be computable: this hinges on the fact that there is no effective way to distinguish between an eigenvalue and a very thin band of continuous spectrum.

The remarks given above are, of necessity, extremely brief. The same points will occur, more fully developed, at appropriate places throughout the proof. Cf. especially Section 3 (Heuristics).

We turn now to an outline of this chapter. In Sections 1-5 we will prove the Second Main Theorem for bounded self-adjoint operators. More precisely, we will prove the positive parts (i) and (ii) of that theorem. The extensions to normal and unbounded self-adjoint operators are given in Sections 6 and 7. Finally, in Section 8, we give the counterexamples required for the negative parts (iii) and (iv).

Remarks. Of course, it is the unbounded self-adjoint operators which-because of their applications in quantum mechanics and elsewhere-are the most interesting. However, the bounded case has to be done first, and it is there that the main difficulties lie. As we shall see, the extension to unbounded self-adjoint operators is rather straightforward once the bounded case has been proved.

As noted in Chapter 4, the proof of this theorem is long and arduous. For that reason, we have included a section on Heuristics (Section 3). The reader is advised to skim Sections 1 and 2, which give preliminary facts and definitions, and turn to Section 3 as soon as possible. Sections 4 and 5 spell out in rigorous detail the ideas sketched in Section 3.

Now for convenience, we restate the theorem. First we recall:
An unbounded operator $T: H \rightarrow H$ is called effectively determined if there is a sequence $\left\{e_{n}\right\}$ in $H$ such that the pairs $\left\{\left(e_{n}, T e_{n}\right)\right\}$ form an effective generating set for the graph of $T$. In the case where $T$ is bounded, this definition can be simplifieda fact that will prove useful. A bounded operator $T$ is effectively determined if there is an effective generating set $\left\{e_{n}\right\}$ for $H$ such that $\left\{T e_{n}\right\}$ is computable.

Second Main Theorem. Let $T: H \rightarrow H$ be an effectively determined (bounded or unbounded) self-adjoint operator. Then there exists a computable sequence of real numbers $\left\{\lambda_{n}\right\}$ and a recursively enumerable set $A$ of natural numbers such that:
i) Each $\lambda_{n} \in \operatorname{spectrum}(T)$, and the spectrum of $T$ coincides with the closure of $\left\{\lambda_{n}\right\}$.
ii) The set of eigenvalues of $T$ coincides with the set $\left\{\lambda_{n}: n \in \mathbb{N}-A\right\}$. In particular, each eigenvalue of $T$ is computable.
iii) Conversely, every set which is the closure of $\left\{\lambda_{n}\right\}$ as in (i) above occurs as the spectrum of an effectively determined self-adjoint operator.
iv) Likewise, every set $\left\{\lambda_{n}: n \in \mathbb{N}-A\right\}$ as in (ii) above occurs as the set of eigenvalues of some effectively determined self-adjoint operator $T$. If the set $\left\{\lambda_{n}\right\}$ is bounded, then $T$ can be chosen to be bounded.

## 1. Review of the Spectral Theorem

This section presents those facts about the spectral theorem which are needed in this chapter. Nothing in it is new, nor has it anything to do with computability. The reader is advised to skim this section and return to it when necessary.

The basic results from spectral theory, which can be found in virtually any text on functional analysis, will be stated without proof. Any results that are not absolutely standard we derive. As references we mention Riesz, Sz.-Nagy [1955], Halmos [1951], Loomis [1953].

Such a survey, if it is to serve its purpose, cannot be too terse. Consequently we shall give a detailed review of the spectral theorem for bounded self-adjoint operators. Then we shall make a quick tour through the corresponding theories for normal and unbounded self-adjoint operators.

Let $T: H \rightarrow H$ be a bounded self-adjoint operator. Corresponding to $T$ there is a "spectral measure" $E$, which is a mapping from Borel sets $I$ in the line to operators $E_{I}$ defined on $H$. More precisely: for each Borel subset $I$ of the real line, $E_{I}$ is the orthogonal projection onto a closed subspace $H_{I}$ of $H$.

These subspaces $H_{I}$ give a decomposition of the Hilbert space $H$ which is a natural extension of the "eigenvector decomposition" for compact operators. (Compact self-adjoint operators, of course, form a special case-for which, as is well known, the eigenvectors are plentiful. On the other hand, we recall that a bounded selfadjoint operator may have no eigenvectors whatsoever. That is why the more complicated "spectral measure decomposition" is necessary.) The properties of the $H_{I}$, which generalize the elementary eigenvector situation, are:
(i) The subspaces $H_{I}$ are invariant under $T$, i.e. $x \in H_{I}$ implies $T(x) \in H_{I}$.
(ii) For disjoint sets $I, J$ in $R$, the spaces $H_{I}$ and $H_{J}$ are orthogonal.
(iii) If $I \subseteq[\lambda-\varepsilon, \lambda+\varepsilon]$ (in words, if $I$ lies in a "thin" interval), then the $x \in H_{I}$ are "approximate eigenvectors"-more precisely, $\|T x-\lambda x\| \leqslant \varepsilon\|x\|$.

The properties of the mapping $I \rightarrow H_{I}$ which justify the name "measure" are:
A. $H_{I \cap J}=H_{I} \cap H_{J}$
B. $H_{I \cup J}=H_{I}+H_{J} \quad$ (direct sum)
C. (Countable additivity). If $I_{1} \supseteq I_{2} \supseteq \cdots$, and $\bigcap I_{n}=\emptyset$, then $\bigcap H_{I_{n}}=\{0\}$.

We recall that, in addition, the spectral measure is entirely supported on the spectrum of $T$, i.e. if $I \supseteq \operatorname{spectrum}(T)$, then $H_{I}=H$.

We have already mentioned above that our construction in this chapter will require "triangle functions". For this reason we need to recall the "operational calculus" associated with the spectral theorem. We recall that, corresponding to any bounded real-valued Borel function $f$ on $\mathbb{R}$, there is a bounded self-adjoint operator $f(T)$ represented by the "spectral integral"

$$
f(T)=\int_{-\infty}^{\infty} f(t) d E(t)
$$

where $d E(t)$ denotes integration with respect to the spectral measure. The use of the
letter $t,-\infty<t<\infty$, reminds us that the domain of the spectral measure is the set of Borel subsets of $\mathbb{R}$.

As a special case, if we take the function $f(t)=t$, we obtain $f(T)=T$. That is, we obtain a representation for the operator $T$ itself. Explicitly:

$$
T=\int_{-\infty}^{\infty} t d E(t)
$$

[Of course, the integration is really over spectrum( $T$ ), a compact set which supports the spectral measure. The function $f(t)=t$ is bounded on this set. We have written the integral as $\int_{-\infty}^{\infty}$ for simplicity.]

The following considerations, which are important in their own right, also shed light on the process of spectral integration. More importantly for our purposes, these results will be needed in this chapter.

## The measure $d \mu_{x y}$

Let $x, y$ be two vectors in $H$. It can be proved that, corresponding to $x$ and $y$, there is a bounded complex measure $d \mu_{x y}$ with the following property. For all bounded real-valued Borel functions $f$ :

$$
(f(T)(x), y)=\int_{-\infty}^{\infty} f(t) d \mu_{x y}(t)
$$

Here again, the use of the variable $t, t \in \mathbb{R}$, expresses the fact that the measure $d \mu_{x y}$ lies on the real line. We emphasize that $d \mu_{x y}$ (unlike $d E$ ) is an ordinary scalar-valued measure. Furthermore:
D. For $x=y$, the corresponding measure $d \mu_{x y}$ is positive (Sometimes we write $d \mu(x)$ for $d \mu_{x x}$.)

## The operational calculus

The operational calculus-i.e. the mapping from functions $f$ to operators $f(T)$ described above-will play a key role in the proof of our Second Main Theorem. In fact, as an algorithmic tool, the operational calculus is very powerful. Its power resides in the fact that it gives a natural isomorphism between the "arithmetic" of functions and the "arithmetic" of operators.

In what follows, we assume that $f$ and $g$ are bounded real-valued Borel functions; $\alpha$ and $\beta$ are real scalars; and $I$ denotes a Borel subset of $\mathbb{R}$.
E. (Linearity). $(\alpha f+\beta g)(T)=\alpha f(T)+\beta g(T)$.
F. (Multiplication). $(f g)(T)=f(T) \cdot g(T)$.
G. (Boundedness). $\|f(T)\| \leqslant \sup \{|f(\lambda)|: \lambda \in \operatorname{spectrum}(T)\}$.
H. (Pointwise convergence). Let $\left\{f_{n}\right\}$ be a uniformly bounded sequence of Borel functions such that, as $n \rightarrow \infty, f_{n}(t) \rightarrow 0$ for all $t$. Then, for any vector $x$ in $H$,

$$
f_{n}(T)(x) \rightarrow 0 \quad \text { in the norm of } H .
$$

I. (Projections). Let $\chi=\chi_{I}$ be the characteristic function of $I$. Then $\chi(T)$ coincides with the projection $E_{I}$ given by the spectral measure.

This completes our list of standard results. We remind the reader that proofs can be found e.g. in Riesz, Sz.-Nagy [1955], Halmos [1951], Loomis [1953].

## Technical Corollaries

We now reach a transitional stage in this introductory section. The above results are standard, but they are not in the form that we need. The following list contains precisely those consequences of the spectral theorem that we will use in proving the Second Main Theorem. There are seven of them.

Remarks. Of course, all of the results in this section are known to specialists. The results A-I above are absolutely standard, and we refer the reader to the literature for their proofs. However, some of the results below are harder to locate in the textbook literature. They are necessary for our proof, and so, for the convenience of the reader, we shall work them out.

To aid the reader in skimming through the derivations which follow, it is useful to stress that two results, taken from the list A-I above, will be used repeatedly.

1) The operational calculus is multiplicative: $(f g)(T)=f(T) g(T)$.
2) Characteristic function correspond to projections: if $\chi=\chi_{I}$ is the characteristic function of a Borel set $I \subseteq \mathbb{R}$, then $\chi(T)$ is the associated projection $E_{I}$ on the subspace $H_{I}$.

We turn now to the seven corollaries of the Spectral Theorem that we need for our proof. These fall into four categories, wich we have put under appropriate headings.

## Criteria for nullity

SpThm 1. Let $I$ be a Borel set in $\mathbb{R}$, and let $x$ be a vector in $H_{I}$. Let $f$ be a bounded Borel function such that support $(f) \cap I=\emptyset$. Then $f(T)(x)=0$.

Proof. Let $\chi=\chi_{I}$ be the characteristic function of $I$. Then $\chi(T)$ is the projection on $H_{I}$. Since $x \in H_{I}, \chi(T)(x)=x$. Now $f$ and $\chi$ have disjoint supports, so that $f \chi=0$. Hence $0=(f \chi)(T)(x)=f(T) \chi(T)(x)=f(T)(x)$.

SpThm 2 (Pointwise convergence almost everywhere). Let I be a Borel set for which $H_{I}$ is the zero subspace. Let $\left\{f_{n}\right\}$ be a uniformly bounded sequence of Borel functions which is pointwise convergent to zero except on I: i.e. $f_{n}(t) \rightarrow 0$ as $n \rightarrow \infty$ for all $t \notin I$. Then, for any vector $x, f_{n}(T)(x) \rightarrow 0$.

Proof. Let $\chi=\chi_{I}$ be the characteristic function of $I$, so that $\chi(T)$ is the projection on $H_{I}$. Since $H_{I}$ is null, $\chi(T)=0$. Hence $(1-\chi)(T)=$ identity operator. Now for all real $t$ :

$$
f_{n}(t)(1-\chi(t)) \rightarrow 0 \quad \text { as } \quad n \rightarrow \infty,
$$

since $f_{n}(t) \rightarrow 0$ for $t \notin I$, and $1-\chi(t)=0$ for $t \in I$. Hence by H. above,

$$
\left[f_{n}(1-\chi)\right](T)(x) \rightarrow 0 \quad \text { as } \quad n \rightarrow \infty .
$$

By the multiplicative property of the operational calculus, we deduce:

$$
f_{n}(T)(1-\chi)(T)(x) \rightarrow 0 \quad \text { as } \quad n \rightarrow \infty .
$$

But since $(1-\chi)(T)=$ identity, this means that $f_{n}(T)(x) \rightarrow 0$.

The question of whether or not certain subspaces $H_{I}$ are null will play an important role in the proof of the Second Main Theorem. For example, even if a point $\lambda \in \operatorname{spectrum}(T)$, the corresponding subspace $H_{\{\lambda\}}$ may be null. However, this cannot happen for a neighborhood $(\lambda-\varepsilon, \lambda+\varepsilon)$ of $\lambda$. Furthermore, we will show that $H_{\{\lambda\}}$ itself is non-null if and only if $\lambda$ is an eigenvalue of $T$. The key results here are SpThm 3 and SpThm 5 below.

SpThm 3. Let $\lambda \in \operatorname{spectrum}(T)$. Then, for any $\varepsilon>0$, the subspace $H_{(\lambda-\varepsilon, \lambda+\varepsilon)}$ is nonzero.

Proof. Suppose otherwise. Let $\chi$ be the characteristic function of $(\lambda-\varepsilon, \lambda+\varepsilon)$, so that $\chi(T)$ is the corresponding projection. By assumption, $\chi(T)=0$, so that $(1-\chi)(T)=$ identity operator. Let

$$
g(t)= \begin{cases}(t-\lambda)^{-1} & \text { for } t \notin(\lambda-\varepsilon, \lambda+\varepsilon), \\ 0 & \text { otherwise } .\end{cases}
$$

Since $(\lambda-\varepsilon, \lambda+\varepsilon)$ is a neighborhood of $\lambda$, the function $g$ is bounded. Hence $g(T)$ is a bounded operator.

We now show that $g(T)=(T-\lambda)^{-1}$. Consider the corresponding functions of a real variable. We have:

$$
(t-\lambda) g(t)(1-\chi(t))=1-\chi(t)
$$

since $g(t)=(t-\lambda)^{-1}$ for $t \notin(\lambda-\varepsilon, \lambda+\varepsilon)$, and $1-\chi(t)=0$ for $t \in(\lambda-\varepsilon, \lambda+\varepsilon)$. Hence, again by the multiplicative property of the operational calculus,

$$
(T-\lambda) g(T)(1-\chi(T))=1-\chi(T) .
$$

But we have seen that $1-\chi(T)=$ identity operator. Thus $(T-\lambda) g(T)=$ identity. Similarly one shows that $g(T)(T-\lambda)=$ identity. Hence $g(T)$ is an inverse to $(T-\lambda)$, contradicting the fact that $\lambda \in \operatorname{spectrum}(T)$.

## Eigenvalues

Recall that, by definition, $\lambda$ is an "eigenvalue" of $T$ if there is some "eigenvector" $x \neq 0$ with $T x=\lambda x$. The eigenvalues form a subset of the spectrum.

SpThm 4. Let $\lambda$ be an eigenvalue of $T$ with eigenvector $x$. Then, for any continuous function $f$,

$$
f(T)(x)=f(\lambda) \cdot x
$$

[Actually, the same thing holds for bounded Borel functions $f$. This more difficult result is an easy consequence of SpThm 5 below, but we have no need of it.]

Proof. Since $x$ is an eigenvector for $\lambda, T x=\lambda x$, whence $T^{n} x=\lambda^{n} x$, whence $p(T)(x)=p(\lambda) \cdot x$ for any polynomial $p$. Now the result extends to continuous functions $f$ by the Weierstrass Approximation Theorem, combined with G. above.

SpThm 5. A vector $x$ is an eigenvector for $\lambda$ if and only if $x \in H_{\{\lambda\}}$, where $H_{\{\lambda\}}$ is the subspace corresponding to the point-set $\{\lambda\}$. In particular, $\lambda$ is an eigenvalue if and only if $H_{\{\lambda\}}$ is nonzero.

Proof. The "if" part is trivial. If $x \in H_{\{\lambda\}}$, then in the spectral measure $d E(t), x$ belongs exclusively to the part where $t=\lambda$. Thus in the integral representation for $T x$.

$$
T x=\int t \cdot d E(t)(x)
$$

only the value $t=\lambda$ is relevant, and $x$ is multiplied by $\lambda$.
The converse is a little harder. Let $x$ be an eigenvector for $\lambda$. Without loss of generality, we can asume that $\lambda=0$. We use the "triangle functions" $\tau_{n}$ (see Figure 0 ) defined by the equations:

$$
\tau_{n}(t)= \begin{cases}1-n t & \text { for } 0 \leqslant t \leqslant 1 / n \\ 1+n t & \text { for }-1 / n \leqslant t \leqslant 0 \\ 0 & \text { for }|t| \geqslant 1 / n\end{cases}
$$

Let $\delta$ be the characteristic function of $\{0\}$ (i.e. $\delta(t)=1$ if $t=0, \delta(t)=0$ otherwise).

![](https://cdn.mathpix.com/cropped/afa54d18-0165-4a9b-9969-7a907958f214-07.jpg?height=456&width=460&top_left_y=1664&top_left_x=588)
Figure 0

Then as $n \rightarrow \infty$, the functions $\tau_{n}(t)$ converge pointwise to $\delta(t)$. Hence by H. above:

$$
\tau_{n}(T)(x) \rightarrow \delta(T)(x)
$$

Since $x$ is an eigenvector for $\lambda=0$, and since the functions $\tau_{n}$ are continuous, $\tau_{n}(T)(x)=\tau_{n}(0) \cdot x=x$ by SpThm 4. Hence, since $\tau_{n}(T)(x) \rightarrow \delta(T)(x), \delta(T)(x)=x$. But $\delta(T)$ is just the projection onto the subspace $H_{\{0\}}$. Hence $x \in H_{\{0\}}$.

The measure $d \mu(x)$
Recall the complex measure $d \mu_{x y}$ discussed above. If we set $x=y$, then we obtain a positive measure $d \mu_{x x}=d \mu(x)$, determined by the vector $x$.

In integration formulas, we may want to display the real variable $t$ : then we write $d \mu(x)=d \mu(x, t)$. As we saw above for $d \mu_{x y}$, the defining equation for $d \mu_{x x}=d \mu(x)$ is:

$$
(f(T)(x), x)=\int_{-\infty}^{\infty} f(t) d \mu(x, t)
$$

where $f$ is any bounded Borel function, and $f(T)$ is the corresponding operator.

SpThm 6. Let $I$ be any Borel set in $\mathbb{R}$. Let $x$ be any vector in $H$, and let $x_{0}$ be the projection of $x$ on $H_{I}$. Then:

$$
\left\|x_{0}\right\|^{2}=\text { the } d \mu(x) \text {-measure of } I .
$$

(In particular, $\|x\|^{2}=$ the $d \mu(x)$-measure of $\mathbb{R}$.)

Proof. Let $\chi=\chi_{I}$ be the characteristic function of $I$, so that $\chi(T)$ is the projection on the subspace $H_{I}$. Then:

$$
\begin{aligned}
\left\|x_{0}\right\|^{2} & =\|\chi(T)(x)\|^{2}=(\chi(T)(x), \chi(T)(x)) \\
& =\left(\chi(T)^{2}(x), x\right)=\left(\chi^{2}(T)(x), x\right)=(\chi(T)(x), x),
\end{aligned}
$$

since $\chi^{2}=\chi$. Now by the defining equation for $d \mu(x)$, this becomes:

$$
\int_{-\infty}^{\infty} \chi(t) d \mu(x, t)=\int_{I} d \mu(x, t)=\text { the } d \mu(x) \text {-measure of } I
$$

## Uniform approximation

SpThm 7. For any bounded Borel function $f$,

$$
\|f(T)\| \leqslant \sup \{|f(\lambda)|: \lambda \in \operatorname{spectrum}(T)\}
$$

Proof. This is just the standard fact G. above. We have restated it here because we promised to list (in the SpThm $N$ category) every spectral theoretic result needed for the proof of the Second Main Theorem. This result is the last on our list. $\square$

## Bounded Normal and Unbounded Self-adjoint Operators

Here, as promised above, we shall be brief. We recall that a bounded operator $T: H \rightarrow H$ is said to be normal if $T T^{*}=T^{*} T$. All of the above results extend to bounded normal operators, once the following trivial modifications are made:
a) Whereas the spectrum of a self-adjoint operator is real, the spectrum of a bounded normal operator is a compact subset of the complex plane. Hence, for our Borel sets $I$, we take Borel subsets of the complex plane.
b) Similarly, in the operational calculus, we consider complex-valued (as opposed to real-valued) functions. We continue to assume that these functions are bounded and Borel. Then all of the identities A-I above continue to hold, and there is one new entry on the list. If $\bar{f}$ denotes the complex conjugate of the function $f$, and "*" denotes adjoint, then:
J.

$$
\overline{\mathrm{f}}(T)=[f(T)]^{*} .
$$

It follows that if $f$ is real-valued, then the operator $f(T)$ is self-adjoint. In particular, the projections $\chi(T)$ are self-adjoint (since the values of the characteristic function $\chi=\chi_{I}$ are real, whether or not the set $I$ lies within the real line). Of course, the operator $T$ itself need not be self-adjoint, because the function $f(z)=z$ (corresponding to $f(T)=T$ ) is not real-valued in the complex plane.

The proofs of $\mathbf{A}-\mathbf{J}$ for bounded normal operators can be found in standard references (e.g. Riesz, Sz.-Nagy [1955], Halmos [1951]). The corresponding extensions of SpThm 1-SpThm 7 are then obvious: Again, complex Borel sets $I$ and functions $f$ replace the real sets/functions discussed above. In SpThm 3, a disk $\{z:|\mathrm{z}-\lambda|<\varepsilon\}$ in the complex plane replaces the real interval $(\lambda-\varepsilon, \lambda+\varepsilon)$. Otherwise, the statements of SpThm 1-SpThm 7 for normal operators are identical to those given above for self-adjoint operators. The proofs are so similar to those already given that we leave them to the reader.

## Unbounded self-adjoint operators

We recall from the introduction to Chapter 4 that the adjoint of an unbounded closed operator is defined via its graph, and an unbounded operator $T$ is said to be self-adjoint if it coincides with its graph-theoretic adjoint.

Only one result concerning unbounded self-adjoint operators will be needed in this book. Most textbook presentations of operator theory give this result as a lemma (see e.g. Riesz, Sz.-Nagy [1955]). The result is:

Proposition. Let T be a (bounded or unbounded) self-adjoint operator. Then the inverse $(T-i)^{-1}$ exists and is a bounded normal operator.

## 2. Preliminaries

This section presents a number of technical definitions and results which are needed before we can come to the core of the Second Main Theorem. The reader who prefers a broad overview may wish to skim this section and then turn directly to Section 3 (Heuristics). The topics in this section are presented in the order in which they occur in the proofs. However, for skimming purposes, the most important subsection is Pre-step $B$ (the triangle functions). We begin with:

Lemma (Uniformity in the exponent). Let $X$ be a Banach space with a computability structure, and suppose that $X$ has an effective generating set $\left\{e_{n}\right\}$. Let $T: X \rightarrow X$ be an effectively determined bounded linear operator. (Since $T$ is bounded, the hypothesis "effectively determined" means simply that $\left\{T e_{n}\right\}$ is computable.) Then the double sequence $\left\{T^{N} e_{n}\right\}$ is computable in both variables $N$ and $n$.

Proof. At first glance, this would appear to be a simple induction. The difficulty is to give a proof which stays within the axioms for computability on a Banach space (cf. Chapter 2, Section 1). This difficulty is resolved by extending the Effective Density Lemma of Chapter 2, Section 5, in a manner which reduces the problem to multilinear algebra. By hypothesis, $\left\{T e_{n}\right\}$ is computable. Hence, by the Effective Density Lemma, there is a computable triple sequence $\left\{\alpha_{n k j}\right\}$ of real/complex rationals and a recursive function $d(n, k)$ such that: If we write

$$
p_{n k}=\sum_{j=0}^{d(n, k)} \alpha_{n k j} e_{j}
$$

then

$$
\left\|p_{n k}-T e_{n}\right\| \leqslant 2^{-k} \quad \text { for all } n, k .
$$

We also observe that since $T$ is bounded, there is an integer $C$ such that $\|T\| \leqslant C$. Without loss of generality, we can replace $T$ by $T / 2 C$, and thus assume that $\|T\| \leqslant 1 / 2$.

To prove the lemma, we shall construct a computable 4-fold sequence $\left\{\beta_{N n k j}\right\}$ of (real/complex) rationals and a recursive function $e(N, n, k)$ such that: If we write

$$
q_{N n k}=\sum_{j=0}^{e(N, n, k)} \beta_{N n k j} e_{j}
$$

then

$$
\left\|q_{N n k}-T^{N} e_{n}\right\| \leqslant 2^{-k} \quad \text { for all } N, n, k
$$

This is done by an induction on the (real/complex) rational coefficients $\beta_{N n k j}$, using the sequence $\left\{\alpha_{n k j}\right\}$ which we already have. The process operates strictly within the domain of integers and their quotients.

We define $\beta_{N n k j}$ by induction on $N$.
For $N=0$, we set $\beta_{0 n k j}=1$ if $j=n, 0$ otherwise. (This gives $q_{0 n k}=e_{n}$ for all $k$.) Assume that $\beta_{N n k j}$ is defined for a fixed $N$, and all $n, k, j$. We now define $\beta_{N+1, n k j}$.
[Recall that $\|T\|<1 / 2$. Thus from the inductive assumption that $\left\|q_{N n k}-T^{N} e_{n}\right\|< 2^{-k}$, we deduce that $\left\|T q_{N n k}-T^{N+1} e_{n}\right\|<2^{-k} / 2$. Now we examine $q_{N n k}$ with a view towards approximating $T q_{N n k}$.]

Consider

$$
q_{N n k}=\sum_{j=0}^{e(N, n, k)} \beta_{N n k j} e_{j}
$$

Each $\beta_{N n k j}$ is a real or complex rational; let $D_{N n k j}$ be the least integer greater than $\left|\beta_{N n k j}\right|$. Let

$$
E_{N n k}=\sum_{j=0}^{e(N, n, k)} D_{N n k j}
$$

Let $s=s(N, n, k)$ be the least integer such that $2^{-s} \leqslant 2^{-k} / 2 E_{N n k}$.
Now we define $q_{N+1, n k}$ by substituting $p_{j s}$ for $e_{j}$ in the formula for $q_{N n k}$ :

$$
q_{N+1, n k}=\sum_{j=0}^{e(N, n, k)} \beta_{N n k j} p_{j s}
$$

[By the manner in which $p_{j s}$ approximates $T e_{j}$, we have $\left\|p_{j s}-T e_{j}\right\|<2^{-s}$. Hence by the definition of $D_{N n k j}, E_{N n k}$, and $s$, we have $\left\|q_{N+1, n k}-T q_{N n k}\right\|<2^{-k} / 2$.]

Now in the above sum, we replace the index $j$ by $i$, and then put in the definition of $p_{i s}$ :

$$
q_{N+1, n k}=\sum_{i=0}^{e(N, n, k)} \beta_{N n k i} \sum_{j=0}^{d(i, s)} \alpha_{i s j} e_{j}
$$

Thus we define:

$$
\beta_{N+1, n k j}=\sum_{i=0}^{e(N, n, k)} \beta_{N n k i} \cdot \alpha_{i s j}, \quad s=s(N, n, k)
$$

The new limit of summation $e(N+1, n, k)$ is the maximum $j$ for which the above double sum is nonempty, i.e.

$$
e(N+1, n, k)=\max \{d(i, s): 0 \leqslant i \leqslant e(N, n, k)\}
$$

This completes the definition of the multi-sequence $\left\{\beta_{N n k j}\right\}$.
Now we return to the Banach space $X$. We must show that the desired inequality,

$$
\left\|q_{N n k}-T^{N} e_{n}\right\|<2^{-k}
$$

extends by induction on $N$ to all $N, n, k$. For $N=0$ it is trivial. Assume that it holds for $N$. On this assumption, we have already seen (in the bracketed remarks above) that $\left\|T q_{N n k}-T^{N+1} e_{n}\right\|<2^{-k} / 2$, and $\left\|q_{N+1, n k}-T q_{N n k}\right\|<2^{-k} / 2$. Combining these two inequalities gives the desired result.

Now that we have constructed $\left\{\beta_{N n k j}\right\}$ and $\left\{q_{N n k}\right\}$ with the desired properties, the rest is easy. The Linear Forms Axiom implies that $\left\{q_{N n k}\right\}$ is computable in $X$, and the Limit Axiom implies that $\left\{T^{N} e_{n}\right\}$ is computable.

Corollary. Let $T: X \rightarrow X$ be bounded and effectively determined, and let $\left\{y_{n}\right\}$ be a computable sequence in $X$. Then $\left\{T^{N} y_{n}\right\}$ is computable, effectively in $N$ and $n$.

Proof. Since $\left\{y_{n}\right\}$ is computable, the Effective Density Lemma asserts that there is a computable double sequence $r_{n k}=\sum \alpha_{n k j} e_{j}$ such that $\left\|r_{n k}-y_{n}\right\| \rightarrow 0$ as $k \rightarrow \infty$, effectively in $k$ and $n$. Since $T$ is bounded and effectively determined, the preceding lemma tells us that $\left\{T^{N} e_{n}\right\}$ is computable, effectively in $N$ and $n$. Now the Linear Forms Axiom implies that $\left\{T^{N} r_{n k}\right\}$ is computable, effectively in all variables. Finally, since $T$ is bounded, $\left\|T^{N} r_{n k}-T^{N} y_{n}\right\| \rightarrow 0$ as $k \rightarrow \infty$, effectively in all variables. Hence by the Limit Axiom, $\left\{T^{N} y_{n}\right\}$ is computable.

The interval $[-M, M]$
Since $T$ is a bounded self-adjoint operator, $\operatorname{spectrum}(T)$ is a compact subset of the real line. We take an integer $M$ such that

$$
\operatorname{spectrum}(T) \subseteq[-(M-1), M-1]
$$

and then work within the interval $[-M, M]$ in order to give ourselves "room around the edges". Throughout the remainder of this proof, $M$ designates the fixed integer defined above.

The sequence $\left\{x_{n}\right\}$
We recall that $H$ is an effectively separable Hilbert space with an effective generating set $\left\{e_{n}\right\}$. In this proof we will use a computable sequence of vectors $\left\{x_{n}\right\}$ such that:

$$
1<\left\|x_{n}\right\|<1001 / 1000 \quad \text { for all } n
$$

and

$$
\left\{x_{n}\right\} \text { is dense on the annulus }\{x: 1 \leqslant\|x\| \leqslant 1001 / 1000\} .
$$

It is important to stress that, by these hypotheses, $\left\|x_{n}\right\|>1$. Furthermore, the closure of $\left\{x_{n}\right\}$ in $H$ contains the unit sphere $\{x:\|x\|=1\}$.

The construction of $\left\{x_{n}\right\}$ is very simple. We begin by taking the sequence $\left\{x_{n}^{\prime}\right\}$ of all (real/complex) rational linear combinations of the elements $e_{n}$ in the effective generating set. Then $\left\{x_{n}^{\prime}\right\}$ is computable by the Linear Forms Axiom. Next we effectively list (not necessarily in their original order) all of the elements of $\left\{x_{n}^{\prime}\right\}$ which
satisfy $1<\left\|x_{n}^{\prime}\right\|<1001 / 1000$. For the sake of completeness, we indicate precisely how this is done.

By the Norm Axiom, since $\left\{x_{n}^{\prime}\right\}$ is computable, the norms $\left\{\left\|x_{n}^{\prime}\right\|\right\}$ form a computable sequence of real numbers. Hence there is a computable double sequence of rational approximations $R_{n k}$ with $\left|R_{n k}-\left\|x_{n}^{\prime}\right\|\right| \leqslant 1 / 2^{k}$ for all $n, k$. Now we effectively scan the double sequence $\left\{R_{n k}\right\}$, using a procedure which returns to each $n$ infinitely often. Whenever an $R_{n k}$ shows up with $1+\left(1 / 2^{k}\right)<R_{n k}<(1001 / 1000)-\left(1 / 2^{k}\right)$, we add the corresponding vector $x_{n}^{\prime}$ to our list. In this way we eventually find all of those $x_{n}^{\prime}$, and only those $x_{n}^{\prime}$, which satisfy $1<\left\|x_{n}^{\prime}\right\|<1001 / 1000$.

The resulting list is the desired computable sequence $\left\{x_{n}\right\}$.
The constructions of the interval $[-M, M]$ and the sequence $\left\{x_{n}\right\}$, while essential, were rather elementary. The three "Pre-steps" which follow are somewhat more elaborate.

## Pre-step A (the effective operational calculus)

Here we must find the effective content of the operational calculus, as laid out (noneffectively) in Section 1. More precisely, we must develop-as corollaries of the spectral theorem-operations which can be made effective and which will allow us to proceed with our construction.

We begin with the assumption, made in the Second Main Theorem, that $T$ is an effectively determined self-adjoint operator. Here and until the end of Section 5, we also assume that $T$ is bounded. Then from the above lemma (Uniformity in the exponents) and its corollary, we have:

Let $\left\{y_{n}\right\}$ be a computable sequence of vectors in $H$. Then the double sequence $\left\{T^{N} y_{n}\right\}$ is computable in $H$, effectively in $N$ and $n$.

Now, in terms of the operational calculus, $T^{N}$ is just the action of the function $f(t)=t^{N}$ on the operator $T$; i.e. if $f(t)=t^{N}$, then $f(T)=T^{N}$.
[For completeness we give the proof. Since $T=\int_{-\infty}^{\infty} t d E(t), T$ itself corresponds to the function $f(t)=t$. Then the extension to powers of $t$ (or $T$ ) follows from the multiplicative law: $(f g)(T)=f(T) g(T)$.]

Now by the Linear Forms Axiom (cf. Chapter 2) the above extends immediately to any computable sequence of polynomials. Thus we have:

Let $\left\{y_{n}\right\}$ be a computable sequence of vectors in $H$, and let $\left\{p_{m}\right\}$ be a computable sequence of polynomials. Then the double sequence $\left\{p_{m}(T)\left(y_{n}\right)\right\}$ is computable in $H$.

Lemma. Let $[-M, M], M=$ integer, be an interval containing spectrum $(T)$. Let $\left\{f_{m}\right\}$ be a sequence of continuous functions on $[-M, M]$ which is computable in the sense of Chapter 0 . Let $\left\{y_{n}\right\}$ be a computable sequence of vectors in $H$. Then $\left\{f_{m}(T)\left(y_{n}\right)\right\}$ is a computable double sequence of vectors in $H$.

Proof. We use the result from spectral theory (SpThm 7) that, for any bounded Borel function $f$, the operator norm

$$
\|f(T)\| \leqslant \sup \{|f(\lambda)|: \lambda \in \operatorname{spectrum}(T)\} .
$$

We also use the "Weierstrass approximation" variant of the notion of a computable sequence of continuous functions $\left\{f_{m}\right\}$. (Cf. Section 3 in Chapter 0). By this definition, there is a computable double sequence of polynomials $\left\{p_{m k}\right\}$ which converges uniformly to $f_{m}$ as $k \rightarrow \infty$, effectively in $k$ and $m$.

The rest is easy. A uniform bound on $\left|f_{m}(t)-p_{m k}(t)\right|$ gives (by SpThm 7) the same bound on the uniform operator norm $\left\|f_{m}(T)-p_{m k}(T)\right\|$. We already know that we can compute $\left\{p_{m k}(T)\left(y_{n}\right)\right\}$, effectively in $m, k$, and $n$. Now we apply the Limit Axiom (Chapter 2): the uniform convergence in operator norm implies the computability of $\left\{f_{m}(T)\left(y_{n}\right)\right\}$, as desired.

Corollary. With $\left\{f_{m}\right\}$ and $\left\{y_{n}\right\}$ as above, the sequence of norms

$$
\left\|f_{m}(T)\left(y_{n}\right)\right\|
$$

is computable, effectively in both $m$ and $n$.

Proof. This follows immediately from the above lemma, together with the Norm Axiom of Chapter 2.

Notes. These arguments break down if we attempt to deal with $f(T)$ for discontinuous functions $f$. For then we would have to deal with pointwise rather than uniform convergence, a notion that is frequently not effective.

Pre-step A involves a triple transition from continuous functions $f_{m}$ to operators $f_{m}(T)$ to vectors $f_{m}(T)\left(y_{n}\right)$ to norms $\left\|f_{m}(T)\left(y_{n}\right)\right\|$. This is quite natural, since to compute an operator means to compute its action on vectors, and the easiest thing to compute about a vector is its norm.

## Pre-step B (the triangle functions)

As stated above, in order to obtain computability in our application of the spectral theorem, we must work with continuous functions. On the other hand, we want to preserve-so far as is possible-the idea of a decomposition of the interval $[-M, M]$ into subintervals. This is achieved by using triangle functions (definitions to follow). The supports of these triangle functions overlap, in the manner of

$$
\ldots[-2,0],[-1,1],[0,2],[1,3], \ldots
$$

Our construction will proceed in stages, indexed by $q=0,1,2, \ldots$. At the 0 -th stage, we pave the interval $[-M, M]$ with overlapping intervals of length 2 , as displayed above. Then we subdivide these intervals, reducing the mesh by a factor of $1 / 8$ at each stage. At the $q$-th stage, we have overlapping intervals of length $2 \cdot 8^{-q}$, the $i$-th such interval being

$$
I_{q i}=\left[(i-1) 8^{-q},(i+1) 8^{-q}\right], \quad \text { where }-M \cdot 8^{q}<i<M \cdot 8^{q} \text {. }
$$

Now the corresponding triangle function $\tau_{q i}$, whose support is $I_{q i}$, is given by:

$$
\tau_{q i}=\tau\left(8^{q} x-i\right), \quad-M \cdot 8^{q}<i<M \cdot 8^{q}
$$

where

$$
\tau(x)= \begin{cases}1-|x| & \text { for }|x| \leqslant 1 \\ 0 & \text { elsewhere. }\end{cases}
$$

We observe that the triangle functions $\tau_{q i}$ are symmetrical and rise to a peak at the midpoints of the intervals $I_{q i}$. (Cf. Figures 1 and 2.)

At the initial stage in our construction, which we call the -1 -st stage, we do not use triangle functions. Instead we use a trapezoidal function $\sigma$ such that $\sigma(x)=1$ on $[-(M-1), M-1]$, and $\sigma(x)$ drops linearly to zero at $\pm M$. (See Figure 2.) We observe that, since spectrum $(T) \subseteq[-(M-1), M-1], \sigma(x)$ is identically equal to 1 on the spectrum of $T$.

We shall need an identity which shows how each $\tau_{q-1, j}$ decomposes into triangle functions $\tau_{q i}$ of the next generation. Consider a fixed $\tau_{q-1, j}$. To conform with later notations, we shall denote this fixed $\tau_{q-1, j}$ by $\tau_{q-1}^{*}$. Similarly the interval $I_{q-1, j}$ will be written $I_{q-1}^{*}$. Finally we set $h=8 j$.

Note. In the body of the proof, $\tau_{q-1}^{*}$ will be a particular one of the $\tau_{q-1, j}$, chosen via an inductive process. The identities of this subsection hold for any $j$, and hence they hold for the particular $j$ which we eventually select.

As a preface to the first identity, we make some geometric observations. Contained within the interval $\tau_{q-1}^{*}$, there are precisely fifteen subintervals of the $q$-th generation, namely

$$
I_{q, h-7}, \ldots, I_{q, h+7} \quad(h=8 j) .
$$

We shall decompose the triangle function $\tau_{q-1}^{*}$ into a linear combination of the triangle functions $\tau_{q i}, h-7 \leqslant i \leqslant h+7$. This is done as follows:

$$
\begin{aligned}
\tau_{q-1}^{*}(x)= & \frac{1}{8}\left[\tau_{q, h-7}(x)+2 \cdot \tau_{q, h-6}(x)+\cdots+7 \cdot \tau_{q, h-1}(x)+8 \cdot \tau_{q, h}(x)\right. \\
& \left.+7 \cdot \tau_{q, h+1}(x)+\cdots+2 \cdot \tau_{q, h+6}(x)+\tau_{q, h+7}(x)\right]
\end{aligned}
$$

(See Figure 1.)
Proof. For the sake of completeness, we prove the above identity. The easiest proof is via slopes. Firstly, all of the functions in the above identity are continuous. Therefore is suffices to show that both sides of the equation have the same slope at all non-partition points $x \neq i \cdot 8^{-q}$ (i.e. at all points which are not vertices of the triangles $\tau_{q i}$ ).

Without loss of generality, we can consider the left hand side of the "big" triangle $\tau_{q-1}^{*}$, i.e. the region where $\tau_{q-1}^{*}$ has positive slope. On this region, the slope of $\tau_{q-1}^{*}$

![](https://cdn.mathpix.com/cropped/afa54d18-0165-4a9b-9969-7a907958f214-16.jpg?height=445&width=945&top_left_y=274&top_left_x=332)
Figure 1

is $8^{q-1}$. By contrast, the triangles $\tau_{q i}$ have slopes $8^{q}$ on their left sides and slopes $-8^{q}$ on their right sides.

In the sum in the above identity: The right side of $\tau_{q, h-7}$ ( slope $=-8^{q}$ ) is superimposed on the left side of $2 \cdot \tau_{q, h-6}$ (slope $=2 \cdot 8^{q}$ ), giving a resultant slope of $8^{q}$. Similarly, the right side of $2 \cdot \tau_{q, h-6}$ (slope $=\cdot-2 \cdot 8^{q}$ ) is superimposed on the left side of $3 \cdot \tau_{q, h-5}$ (slope $=3 \cdot 8^{q}$ ), giving the same resultant slope $8^{q}$. And so on.

Finally, the sum is multiplied by $1 / 8$, giving a resultant slope of $8^{q-1}$ : exactly as for the "big" triangle function $\tau_{q-1}^{*}$. This proves the identity. $\square$

For the trapezoidal function $\sigma$ we have the identity:

$$
\sigma(x)=\sum_{i=-M+1}^{M-1} \tau_{0 i}(x)
$$

## (See Figure 2.)

The proof of this identity is similar to the previous proof (and easier), and we leave it to the reader. $\square$

We conclude this subsection with two inequalities derived from the above identities. To set the stage, we recall that, for $q \geqslant 1, \tau_{q-1}^{*}=\tau_{q-1, j}$ decomposes into a linear combination of the fifteen functions $\tau_{q i}, h-7 \leqslant i \leqslant h+7(h=8 j)$.

Now fix a vector $x_{n}$ from the sequence $\left\{x_{n}\right\}$ constructed above. Following the operational calculus of Pre-step $A$, we are interested in the norms $\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|$.

![](https://cdn.mathpix.com/cropped/afa54d18-0165-4a9b-9969-7a907958f214-16.jpg?height=182&width=945&top_left_y=1919&top_left_x=327)
Figure 2

We define:

$$
\begin{aligned}
& u \text { is the first index, } h-7 \leqslant u \leqslant h+7 \quad(h=8 j) \text {, } \\
& \text { which maximizes }\left\|\tau_{q u}(T)\left(x_{n}\right)\right\| .
\end{aligned}
$$

Then for this $u$ we have:

$$
\begin{aligned}
& \left\|\tau_{q u}(T)\left(x_{n}\right)\right\| \geqslant(1 / 8)\left\|\tau_{q-1}^{*}(T)\left(x_{n}\right)\right\| \quad(q \geqslant 1), \\
& \left\|\tau_{0 u}(T)\left(x_{n}\right)\right\| \geqslant 1 /(2 M-1) .
\end{aligned}
$$

Proofs. For the first inequality. This follows immediately from the first identity, $\tau_{q-1}^{*}=(1 / 8)\left[\tau_{q, h-7}+2 \cdot \tau_{q, h-6}+\cdots\right]$, upon observing that the sum of the coefficients $(1 / 8)[1+2+3+\cdots+7+8+7+\cdots+3+2+1]$ is equal to 8 .

For the second inequality. First we recall that $\left\|x_{n}\right\| \geqslant 1$, and that since $\sigma(x)=1$ on $\operatorname{spectrum}(T), \sigma(T)=$ identity operator. Hence $\left\|\sigma(T)\left(x_{n}\right)\right\|=\left\|x_{n}\right\|_{M-1} \geqslant 1$. Now the second inequality follows at once from the second identity, $\sigma=\sum_{-M+1}^{M-1} \tau_{0 i}$, upon observing that the sum has $(2 M-1)$ terms.

Note. We do not claim that the maximizing index $u$ can be found effectively. In the formal proof in Section 5, the index $u$ will be replaced by a slightly inferior index $v$ which is computed effectively.

## Pre-step C (the computed norms)

To compute norms, we have to compute real numbers. Of course, a computable real number is the effective limit of a computable sequence of rationals. Thus when we "compute" a real number, the things which we actually compute are rational approximations.

We begin with the final corollary in Pre-step A, which tells us that $\left\{\left\|f_{m}(T)\left(y_{n}\right)\right\|\right\}$ is computable for any computable sequence of continuous functions $\left\{f_{m}\right\}$ and any computable sequence of vectors $\left\{y_{n}\right\}$. For $\left\{y_{n}\right\}$, we take the sequence of vectors $\left\{x_{n}\right\}$ constructed prior to Pre-step A. For $\left\{f_{m}\right\}$ we take the double sequence of triangle functions $\left\{\tau_{q i}\right\}$ constructed in Pre-step B. Hence we have:

$$
\left\{\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|\right\}
$$

is a computable triple sequence of real numbers. We emphasize that this "computability" is simultaneously effective in all three variables, $q, i$ and $n$.

Thus there exists a computable triple sequence of rational approximations, which we denote by $\operatorname{CompNorm}_{q i}(n)$ such that:

$$
\begin{aligned}
& \left|\operatorname{CompNorm}_{q i}(n)-\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|\right| \leqslant(1 / 1000)(1 / 2 M)\left(1 / 16^{q}\right) \quad(q \geqslant 1), \\
& \left|\operatorname{CompNorm}_{0 i}(n)-\left\|\tau_{0 i}(T)\left(x_{n}\right)\right\|\right| \leqslant \frac{1}{1000}\left[\frac{1}{2 M-1}-\frac{1}{2 M}\right] .
\end{aligned}
$$

Note. Sometimes, in situations where the variable $n$ is being temporarily held fixed, we shall write $\operatorname{CompNorm}_{q i}$ in place of $\operatorname{CompNorm}_{q i}(n)$.

## 3. Heuristics

The two subsections Heuristics I and II below treat respectively: I. the construction itself and II. the proof of its properties.

In this heuristic section, we shall make one simplification. As a result, the "construction" described here is not effective: it contains one non-effective step. (We will flag the place where this occurs.) Later, in Section 4, we give an effective construction, followed in Section 5 by detailed proofs.

## Heuristics I. A simplified version of the procedure

We now expand upon some comments made in the Introduction.
In order to motivate the steps which follow, it is useful to return momentarily to the spectral theorem in its traditional (noneffective) setting. We recall that, associated with any bounded self-adjoint operator $T$, there is a "spectral measure". (For details, cf. Section 1.) The spectral measure gives a decomposition of the Hilbert space $H$ into orthogonal subspaces $H_{I}$.

Let us now make this decomposition explicit in the most obvious (albeit noneffective) way. We begin by taking an interval ( $-M, M$ ] containing the spectrum of $T$. Next we partition ( $-M, M$ ] into "thin" subintervals $I_{i}=\left(a_{i-1}, a_{i}\right]$ in the usual fashion

$$
\begin{gathered}
-M=a_{0}<a_{1}<\cdots<a_{N}=M, \\
a_{i}-a_{i-1}<\varepsilon \quad \text { for all } i .
\end{gathered}
$$

Then the corresponding subspaces,

$$
H_{i}=H_{\left(a_{i-1}, a_{i}\right]}
$$

are orthogonal and invariant under $T$, and the elements of $H_{i}$ are "approximate eigenvectors" (i.e. $\left\|T x-a_{i} x\right\| \leqslant \varepsilon\|x\|$ for $x \in H_{i}$ ). Thus we obtain a rough "picture" of the operator $T$, a picture that becomes more precise as we let $\varepsilon \rightarrow 0$.

Of course, these steps are wildly nonconstructive. Indeed, even ignoring the Hilbert space aspects, the question of whether a real number $t$ belongs to an interval ( $a_{i-1}, a_{i}$ ] cannot be decided effectively. Thus we must find an analog of this procedure-one which has some chance of being effective. To achieve this, we shall have to abandon the "natural" decomposition of the real line into disjoint subintervals.

Our modification of the "disjoint interval" procedure involves two main steps. Firstly, we replace the disjoint intervals by intervals which overlap. Secondly, we eliminate the intervals altogether! More precisely, instead of considering the
characteristic functions of these intervals (step functions) we use triangle functions. The necessary triangle functions were introduced in Pre-step $B$ above. Their advantage over step functions lies in the fact that they are continuous. This, as we shall see, is what makes effective computation of the spectrum possible.

Now we turn to the details of the "construction". This "construction" is (if we ignore its one noneffective step) a universal procedure which begins with any computable vector $x$ and produces a computable real number $\lambda$. Likewise, if we input a computable sequence of vectors $\left\{x_{n}\right\}$, it produces a computable sequence of reals $\left\{\lambda_{n}\right\}$. In fact we shall input the computable sequence $\left\{x_{n}\right\}$ defined in Section 2. The resulting sequence $\left\{\lambda_{n}\right\}$ will be the computable sequence of reals whose existence was asserted in the Second Main Theorem.

We shall describe the procedure for a single vector $x_{n}$, but in a manner which is clearly effective in $n$. Then to deal with the entire sequence $\left\{x_{n}\right\}$, we merely use an effective process which returns to each $x_{n}$ infinitely often.

Thus we $f i x$ a vector $x_{n}$ from the computable sequence $\left\{x_{n}\right\}$ given in Section 2. The following procedure will lead to the corresponding real number $\lambda_{n}$.

Step 1. We recall the computable double sequence of triangle functions $\tau_{q i}$ defined in Pre-step B of Section 2. The function $\tau_{q i}$ is supported on the interval

$$
I_{q i}=\left[(i-1) 8^{-q},(i+1) 8^{-q}\right]
$$

which has half-width $=8^{-q}$. These intervals overlap in the manner

$$
\ldots[-2,0],[-1,1],[0,2],[1,3], \ldots
$$

Step 2. We now have, by Pre-step A, that the double sequence of vectors $\left\{\tau_{q i}(T)\left(x_{n}\right)\right\}$ (recall that $x_{n}$ is fixed) and the double sequence of norms $\left\{\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|\right\}$ are computable. The norms, of course, are a computable double sequence of nonnegative real numbers.

Step 3. For each $q=0,1,2, \ldots$, we shall choose an index $i=i(q)$ in a manner to be described below. This will yield a nested sequence of intervals

$$
I_{q}^{*}=I_{q, i(q)}
$$

where

$$
I_{0}^{*} \supseteq I_{1}^{*} \supseteq I_{2}^{*} \supseteq \cdots
$$

Of course, the sequence $\left\{I_{q}^{*}\right\}$ is defined by induction. To obtain the nested intervals we do the following. At any stage $q \geqslant 1$, we consider only those $i$ such that $I_{q i} \subseteq I_{q-1}^{*}$.

We recall from Pre-step $B$ that, if we write $j=i(q-1)$ so that $I_{q-1}^{*}=I_{q-1, j}$, then the allowed values for $i=i(q)$ must come from the finite list:

$$
i=8 j-7, \ldots, 8 j+7 .
$$

Finally, we observe that, corresponding to the intervals $I_{q}^{*} I_{q, i(q)}$, there is a sequence of triangle functions $\tau_{q}^{*}=\tau_{q, i(q)}$.

Step 4. We now define the sequence of intervals $\left\{I_{q}^{*}\right\}$ and triangle functions $\left\{\tau_{q}^{*}\right\}$ by induction on $q$. We begin with the vacuous case $q=-1$ (for which there are no triangle functions and no interval $I_{q}^{*}$ ). Then, subject to the restriction from Step 3,

$$
I_{q i} \subseteq I_{q-1}^{*} \quad(\text { vacuous when } q-1=-1)
$$

we choose the value $i=i(q)$ which

$$
\text { maximizes }\left\|\tau_{q i}(T)\left(x_{n}\right)\right\| \text {. }
$$

In case of ties, we choose the smallest tying $i$.
[This, of course, is the noneffective step! For the norms $\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|$ are computable real numbers, and exact comparisons between computable reals cannot be made effectively.]

Step 5 (Definition of $\lambda_{n}$ ). We define the real number $\lambda_{n}$ as the common intersection point of the intervals $I_{q}^{*}\left(=I_{q}^{*}(n)\right.$, where we have suppressed the variable $\left.n\right)$. Since the $q$-th interval $I_{q}^{*}$ has half-width $8^{-q}$, the convergence of these intervals as $q \rightarrow \infty$ is effective in both $q$ and $n$.

Notes. Later, in Section 4, we shall obtain an effective procedure by replacing the norms $\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|$ in Step 4 by the approximations CompNorm ${ }_{q i}$ from Pre-step $C$. Since the values $\left\{\right.$ CompNorm $\left._{q i}\right\}$ form a computable double sequence of rationals, exact comparisons of the CompNorm ${ }_{q i}$ can be made effectively.

On the other hand, the use of approximate values complexifies the proof to a substantial degree. Furthermore, the key ideas of the proof lie elsewhere. That is why, in this heuristic section, we ignore this painful but necessary step.

## Not an eigenvalue!

Now we must define the set $A$ of indices such that the set of eigenvalues coincides with $\left\{\lambda_{n}: n \notin A\right\}$. Thus $A$ is to be a recursively enumerable set of natural numbers, whose significance is the following: when an integer $n$ appears on the list $A$, then $\lambda_{n}$ will not be counted as an eigenvalue. Thus the statement that $n \in A$ corresponds to the declaration "Not an eigenvalue!" for $\lambda_{n}$.
[We remark, however, that the sequence $\left\{\lambda_{n}\right\}$ need not be one to one. The same real number $\lambda$ may appear as the value $\lambda_{n}$ for several $n$. In fact, we can have $\lambda=\lambda_{n}=\lambda_{m}$ with $m \neq n$ and the declaration "Not an eigenvalue!" could be made for $n$ but not for $m$. More on this below.]

The idea behind our definition of the set $A$ is embodied in the following two facts:
(i) If $\lambda_{n}$ is not an eigenvalue for $T$, then the norms $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\| \rightarrow 0$ as $q \rightarrow \infty$.
(ii) If $\lambda_{n}$ is an eigenvalue, AND if $x_{n}$ is "sufficiently close" to the corresponding eigenvector, then the norms $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\|$ remain bounded away from zero as $q \rightarrow \infty$. In fact, $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\| \geqslant 1 / 8$ for all $q$.

We shall prove these statements in subsequent sections. Accepting their truth for now, we can see at once what the criterion for "Not an eigenvalue!" should be.

Definition of set $A$ ("Not an eigenvalue!"). We say that $n \in A$ if, for some $q$, the norm $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\|<1 / 8$.

We conclude this descriptive section with several remarks.
First, it is clear that the set $A$ defined above is recursively enumerable. For we can compute $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\|$ for $q=0,1,2, \ldots$, and if a value of $q$ with $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\|<1 / 8$ ever occurs, we will eventually find it. However, there may be no effective procedure for listing the complement of $A$. For it is, of course, impossible to scan the entire sequence $\left\{\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\|\right\}$ in a finite number of steps.

What does this mean from the viewpoint of spectral theory? In a deliberately vague but suggestive fashion, we can describe the situation as follows. We recall from Section 1 that $\lambda$ is an eigenvalue if and only if there is a nonzero spectral measure concentrated in the point-set $\{\lambda\}$. Now the sequence of triangle functions $\left\{\tau_{q i}\right\}$ gives us a kind of "microscope" which allows us to examine intervals on the real line, locating those intervals where the spectral measure is most heavily concentrated. However, for each fixed $q$, the microscope has only a limited amount of resolving power. This power increases towards infinity as $q \rightarrow \infty$. Nevertheless, at any finite stage, our imperfect microscope is incapable of distinguishing between a single spectral line and a thin band of continuous spectrum. And, since in any effective process we are always at some finite stage, this difficulty can never by resolved. This explains heuristically why, in the case where $\lambda_{n}$ actually is an eigenvalue, we may never possess an effective verification of that fact.

Remark. We have noted that the sequence $\left\{\lambda_{n}\right\}$ need not be one to one. This has the consequence that, even if $\lambda_{n}$ is an eigenvalue, the declaration "Not an eigenvalue!" might be made for $n$. This is because (ii), on which the definition of $A$ was based, requires that $\lambda_{n}$ be an eigenvalue and that $x_{n}$ be an approximate eigenvector. Even if $\lambda_{n}$ satisfies this, $x_{n}$ might not. However, if $x_{n}$ fails, then a suitable vector $x_{m}$ will eventually turn up. The new vector will give the same value $\lambda=\lambda_{n}=\lambda_{m}$, but this time the pair ( $\lambda_{m}, x_{m}$ ) will pass the "eigenvalue/eigenvector test". For a proof of these statements, see proposition 4, whose proof is sketched in Heuristics II and then done carefully in Section 5.

Finally, we repeat that the "almost effective procedure" in this section is only an approximation to the effective (but more complicated) algorithm given in Section 4.

## Heuristics II. Why the Procedure Works

In order to satisfy the conditions of the Second Main Theorem, there are four things that we must show about the sequence $\left\{\lambda_{n}\right\}$ and the set $A$ "constructed" in Heuristics I. These are:

1. Every $\lambda_{n} \in \operatorname{spectrum}(T)$.
2. The sequence $\left\{\lambda_{n}\right\}$ is dense in spectrum( $T$ ).
3. If $\lambda_{n}$ is not an eigenvalue of $T$, then $n \in A$ (i.e. the declaration "Not an eigenvalue!" is made for $n$ ).
4. If $\lambda$ is an eigenvalue of $T$, then there exists some $n \notin A$ such that $\lambda=\lambda_{n}$.
[Propositions 1. and 2. are virtually identical to the statements about $\left\{\lambda_{n}\right\}$ and spectrum( $T$ ) made in (i) of the Second Main Theorem. Propositions 3. and 4. combine to give the result: The set of eigenvalues of $T$ coincides with the set $\left\{\lambda_{n}: n \notin A\right\}$-exactly as in (ii) of the Second Main Theorem. As stated earlier, (iii) and (iv) will be proved in Section 8.]

Precise proofs of 1., 2., 3., and 4. will be given in Section 5. Here, instead of trying to be semi-precise, we shall be rather casual. Yet the sketchy "proofs" which we outline here already contain the key ideas of the detailed proofs which are to come.

Consider the "construction" in Heuristics I. Recall that it begins with a vector $x_{n}$ and ends with a corresponding real number $\lambda_{n}$. As a first step, we must unravel the meaning of this construction in terms of the Spectral Theorem.
[This will require a rather lengthy discussion. We cannot avoid it. The Spectral Theorem involves three different structures: projections/subspaces/measures, and it is the interplay between these that is vital to our construction.]

Recall that in the Spectral Theorem there are two types of spectral measures. Firstly, there is the spectral measure associated with the operator $T$. It consists of projections onto subspaces of the Hilbert space. Secondly, there are the measures $d \mu_{x x}=d \mu(x)$ associated with a vector $x$. These are ordinary positive real-valued measures.

Here we recall some notation from Section 1: $d \mu(x)$ is a measure on the real line, determined by the vector $x$. In integration formulas, we may want to display the real variable $t$ (for example, as in $\left(T^{2}(x), x\right)=\int_{\mathbb{R}} t^{2} d \mu(x, t)$ ). So we sometimes add the variable $t$ and write $d \mu(x)=d \mu(x, t)$.

The measure $d \mu(x)=d \mu(x, t)$ is governed by the defining equation:

$$
(f(T)(x), x)=\int_{-\infty}^{\infty} f(t) d \mu(x, t)
$$

where $f$ is any bounded Borel function, and $f(T)$ is the corresponding operator.
Now we must recall the connection between the spectral measure of $T$ and that of $x$. Begin with $T$. For each interval $(a, b]$ in the real line, the spectral measure of $T$ gives a projection $E_{(a, b]}$ onto a subspace $H_{[a, b]}$ of the Hilbert space $H$.

As we showed in Section 1 (SpThm 6), the connection between these projections and the measure $d \mu(x)=d \mu(x, t)$ is:

Let $x_{0}=E_{(a, b]}(x)$ be the projection of $x$ on the subspace $H_{[a, b]}$. Then

$$
\left\|x_{0}\right\|^{2}=\text { the } d \mu(x) \text {-measure of }(a, b]
$$

In particular,

$$
\|x\|^{2}=\text { the } d \mu(x) \text {-measure of } \mathbb{R} .
$$

As an easy application of SpThm 6, we obtain a continuous analog of the Pythagorean Theorem. Suppose we partition $\mathbb{R}$ into countably many disjoint inter-
vals $\left(a_{i}, b_{i}\right]$. Let

$$
x_{i}=E_{\left(a_{i}, b_{i}\right]}(x),
$$

so that $x_{i}$ is the projection of $x$ onto the subspace $H_{\left(a_{i}, b_{i}\right]}$. Then:

$$
\sum_{i}\left\|x_{i}\right\|^{2}=\|x\|^{2} .
$$

Here is the proof. The intervals $\left(a_{i}, b_{i}\right]$ are disjoint and their union is $\mathbb{R}$. Then the fact that $d \mu(x)$ is a measure (i.e. countably additive) means that the $d \mu(x)$-measures of the $\left(a_{i}, b_{i}\right]$ add up to the $d \mu(x)$-measure of $\mathbb{R}$. But the $d \mu(x)$-measure of $\left(a_{i}, b_{i}\right]$ is $\left\|x_{i}\right\|^{2}$, and the $d \mu(x)$-measure of $\mathbb{R}$ is $\|x\|^{2}$. q.e.d.

Thus we reach a conclusion which can be put into words as follows:
The measure $d \mu(x)$ shows the way the vector $x$ breaks down into its orthogonal components $x_{i}$-while in a parallel fashion the Hilbert space is being broken down into orthogonal subspaces by the action of the projection-valued measure $d E$. More precisely, $d \mu(x)$ records the way that the square-norms $\left\|x_{i}\right\|^{2}$ add up via the "Pythagorean Theorem" to give the square-norm of $x$.

This completes our review of spectral measures.
We apply this now to the vector $x_{n}$ with which we began the construction in Heuristics I. The spectral measure of $x_{n}$ would seem to be a difficult thing to get our hands on computationally. Let us worry about that later. For now, let us suppose that we can somehow "see" the spectral measure, as though it were displayed on a screen like a computer-graphic.

We know that the spectral measure of $x_{n}$ describes the connection between intervals on the real line and the orthogonal decomposition of the vector $x_{n}$. ("The Pythagorean Theorem"). Thus, for example, consider the interval $(a, b]$ and its associated subspace $H_{(a, b]}$ : if $x_{n} \in H_{(a, b]}$, then all of the spectral measure of $x_{n}$ is contained in $(a, b]$. If $x_{n}$ deviates only slightly from a vector in $H_{(a, b]}$, then most of the spectral measure of $x_{n}$ will lie within $(a, b]$. Of course, for most vectors $x_{n}$, the spectral measure of $x_{n}$ is spread out all over the place. But, even for such $x_{n}$ as these, there should be parts of the real line where the spectral measure of $x_{n}$ is "more heavily concentrated". We should be able to find these regions of "heavy concentration" by partitioning the real line and choosing the subintervals which have the "heaviest concentration".

All of this, we recall, was under the assumption that we could somehow "see" the spectral measure of $x_{n}$. But the triangle functions $\tau_{q i}$ allow us to do precisely that. Our procedure in Heuristics I, of choosing the $i$ which maximizes $\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|$, allows us to pick out a nested sequence of subintervals of "heavy concentration" converging down to a point $\lambda_{n}$ of "heavy concentration".

Perhaps it is not clear at a glance that the triangle functions do what we have just claimed for them. What connection is there between the norms $\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|$ and the spectral measure $d \mu\left(x_{n}, t\right)$ of $x_{n}$ ? Well,

$$
\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|^{2}=\left(\tau_{q i}(T)\left(x_{n}\right), \tau_{q i}(T)\left(x_{n}\right)\right)=\left(\left(\tau_{q i}\right)^{2}(T)\left(x_{n}\right), x_{n}\right),
$$

and by the defining equation of the spectral measure $d \mu(x, t)$ (see above), this becomes

$$
\int_{-\infty}^{\infty}\left(\tau_{q i}\right)^{2}(t) d \mu\left(x_{n}, t\right)
$$

Thus the value $\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|^{2}$ is equal to that gotten by integrating the square of the triangle function, $\left(\tau_{q i}\right)^{2}$, against the spectral measure $d \mu\left(x_{n}, t\right)$.
[The fact that the square-norm $\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|^{2}$ is the integral of the square $\left(\tau_{q i}\right)^{2}$ is, of course, another variant of the "Pythagorean Theorem".]

Now we return to the procedure in Heuristics I. Recall that, at stage $q$, it involves letting $i$ vary and choosing the $i$ which maximizes $\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|$. We observe that, for fixed $q$ and varying $i$, the functions $\tau_{q i}$ all have the same shape-they are merely translates of one another. So the integral of $\left(\tau_{q i}\right)^{2}$ against $d \mu\left(x_{n}, t\right)$ will be maximal only when the support of the function $\tau_{q i}$ contains "its fair share" of the measure $d \mu\left(x_{n}, t\right)$. The procedure is pushing us towards a place $\lambda_{n}$ on the real line where the spectral measure of $x_{n}$ is "heavily concentrated".

The results of the discussion-which we state in a deliberately vague but intuitively suggestive fashion-are:

The norms $\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|$ give us a computationally effective way to get our hands on the spectral measure of $x_{n}$. Using these norms as in Heuristics I, we have a procedure which passes from an input vector $x_{n}$ to an output number $\lambda_{n}$. This procedure is designed so that $\lambda_{n}$ lies at a place on the real line where the spectral measure of $x_{n}$ is "heavily concentrated".

Now we ask: what does this say about the propositions 1., 2., 3., 4., listed above. Let us go through them in order. For convenience, each proposition has been restated (in parentheses) at the beginning of its paragraph.
[Incidentally, the fact that in the above sentence, the phrase "in parentheses" is in parentheses, does not lead to a new type of self-referential formula in logic.]

This is a good place to pause. We have reached a turning point. The heuristic descriptions have come to an end, and the time to apply them has begun. We reemphasize that the arguments given below are intended as proof sketches, and not as formal proofs. For that reason we have omitted the usual symbol □ which marks the end of a proof. The formal proofs will be given in Section 5.

Remark concerning SpThm N. In Section 1 we gave seven results, SpThm 1 to SpThm 7, on which this proof would be based. SpThm 6 and 7 have already been used. The other five results are used in the arguments below.

1. ( $\lambda_{n} \in \operatorname{spectrum}(T)$.) Obviously, if $\lambda_{n}$ lies at a point where the spectral measure is "heavily concentrated", it must lie in the spectrum. For the complement of spectrum( $T$ ) is an open set containing no spectral measure whatsoever.
2. ( $\left\{\lambda_{n}\right\}$ is dense in spectrum( $T$ ).) Take any $\lambda \in \operatorname{spectrum}(T)$. We have to show that there exist $\lambda_{n}$ lying arbitrarily close to $\lambda$. Now the position of $\lambda_{n}$ on the real line depends on the initial vector $x_{n}$. Obviously we must pick $x_{n}$ correctly. Well, suppose we take a closed $\varepsilon$-neighborhood $[\lambda-\varepsilon, \lambda+\varepsilon]$ of $\lambda$. By SpThm 3 in Section 1, this neighborhood has nonzero spectral measure. Choose a vector $x_{n}$ whose spectral
measure lies entirely within $[\lambda-\varepsilon, \lambda+\varepsilon]$. (This can only be done approximatelya difficulty we ignore for now.)

Let $\lambda_{n}$ be the number corresponding to $x_{n}$. We want to show that $\lambda_{n} \in[\lambda-\varepsilon, \lambda+\varepsilon]$. Suppose otherwise. We recall that the point $\lambda_{n}$ is the intersection, as $q \rightarrow \infty$, of $\operatorname{support}\left(\tau_{q}^{*}\right)$. Then as $q \rightarrow \infty$, $\operatorname{support}\left(\tau_{q}^{*}\right)$ approaches $\lambda_{n}$, and hence becomes disjoint from $[\lambda-\varepsilon, \lambda+\varepsilon]$. But $[\lambda-\varepsilon, \lambda+\varepsilon]$ contains the entire spectral measure of $x_{n}$. So by SpThm 1, for all sufficiently large $q,\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\|=0$.

However, our construction guarantees that the triangle functions $\tau_{q}^{*}$ are supported on an interval where the spectral measure of $x_{n}$ is "heavily concentrated". Hence, in particular, the vector $\tau_{q}^{*}(T)\left(x_{n}\right) \neq 0$, and the norm $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\|>0$. This contradicts the conclusion of the preceding paragraph.
3. (If $\lambda_{n}$ is not an eigenvalue, then $n \in A$ : that is, the declaration "Not an eigenvalue!" will be made for $n$.) Here it turns out that the spectral measure of $T$-involving projections onto subspaces-is easier to use than the spectral measure of $x_{n}$. We saw in Section 1 that a number $\lambda$ is an eigenvalue of $T$ if and only if the point-set $\{\lambda\}$ has nonzero spectral measure: i.e. if and only if the subspace $H_{\{\lambda\}}$ is nonzero (SpThm 5).

Suppose that $\lambda_{n}$ is not an eigenvalue. Then the point-set $\left\{\lambda_{n}\right\}$ has zero spectral measure. Hence, by the countable additivity of spectral measure, the spectral measure of the interval ( $\lambda_{n}-\varepsilon, \lambda_{n}+\varepsilon$ ) shrinks to zero as $\varepsilon \rightarrow 0$. Now the triangle functions $\tau_{q}^{*}$ are uniformly bounded $\left(0 \leqslant \tau_{q}^{*}(t) \leqslant 1\right)$ and their supports shrink to the point-set $\left\{\lambda_{n}\right\}$ as $q \rightarrow \infty$. Hence for any vector $x_{n}$, the vectors $\tau_{q}^{*}(T)\left(x_{n}\right) \rightarrow 0$, and thus the norms $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\| \rightarrow 0$ (SpThm 2). Since these norms approach zero as $q \rightarrow \infty$, they must eventually drop below the cut-off value of $1 / 8$. When that happens, the declaration "Not an eigenvalue!" will be made. This finishes proposition 3.

Before coming to 4 ., there is a caution which we must stress. The converse of 3 . is false. That is, even if the declaration "Not an eigenvalue!" is made, it could still happen that the value $\lambda=\lambda_{n}$ is an eigenvalue. This was discussed in the Remark at the end of Heuristics I. Here we merely recall that the sequence $\left\{\lambda_{n}\right\}$ need not be one to one. Therefore if $\lambda_{n}=\lambda_{m}=\lambda$ with $m \neq n$, we might have the "Not an eigenvalue!" declaration for $n$ but not for $m$.
4. (If $\lambda$ is an eigenvalue of $T$, then there exists an $n \notin A$ with $\lambda=\lambda_{n}$.) As in 2 . above, the trick is to choose $x_{n}$ correctly. We begin with an $x_{n}$ which is an eigenvector of $T$ with eigenvalue $\lambda$. (Again this can only be done approximately, a difficulty we ignore for now.) Since $x_{n}$ is an eigenvector for $\lambda$, spectral theory (SpThm 4) tells us that, for any continuous function $f$,

$$
f(T)\left(x_{n}\right)=f(\lambda) \cdot x_{n}
$$

In particular,this holds for the triangle functions $\tau_{q i}$ :

$$
\tau_{q i}(T)\left(x_{n}\right)=\tau_{q i}(\lambda) \cdot x_{n}
$$

Assume, for convenience, that $x_{n}$ is a unit vector (again only approximately true). Then:

$$
\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|=\tau_{q i}(\lambda) .
$$

Now $\tau_{q i}(\lambda)$ is a much more tractable thing to deal with than $\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|$. We can simply look at the graphs of the triangle functions $\tau_{q i}$ and see the way they overlap (see Figures 1 and 2 in Section 2 above). We see from the graphs of the $\tau_{q i}$ that:

$$
\text { For any } q \text {, there exists an } i \text {, such that } \tau_{q i}(\lambda) \geqslant 1 / 2 \text {. }
$$

Recall that $\tau_{q}^{*}$ denotes the function $\tau_{q i}$ which maximizes $\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|=\tau_{q i}(\lambda)$. Thus we have:

$$
\tau_{q}^{*}(\lambda) \geqslant 1 / 2 \quad \text { for all } q .
$$

Recall further that, by definition, $\lambda_{n}$ is the common intersection of the intervals $I_{q}^{*}=\operatorname{support}\left(\tau_{q}^{*}\right)$.

The results which we need to show are (i) $\lambda=\lambda_{n}$, and (ii) $n \notin A$.
(i) $\lambda=\lambda_{n}$. Well, $\tau_{q}^{*}(\lambda) \geqslant 1 / 2$ for all $q$, which puts $\lambda$ within the support of $\tau_{q}^{*}$ for all $q$. Hence $\lambda \in I_{q}^{*}$ for all $q, \lambda_{n} \in I_{q}^{*}$ for all $q$ (by definition), and since the widths of the intervals $I_{q}^{*}$ shrink to zero, $\lambda=\lambda_{n}$.
(ii) $n \notin A$ (i.e. the declaration "Not an eigenvalue!" is never made). Well, this declaration will be made if, for some $q,\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\|=\tau_{q}^{*}(\lambda)<1 / 8$. But we have seen that $\tau_{q}^{*}(\lambda)$ remains always $\geqslant 1 / 2$.

Note. The reader may wonder why we chose the value $1 / 8$ as our cut-off for the "Not an eigenvalue!" declaration. Actually, any value strictly less than $1 / 2$ would do. However, for normal operators (c.f. Section 6), we need a value $<1 / 4$ We wanted a uniform procedure, so we simply took the next power of two below $1 / 4$.

This completes our discussion of proposition 4.
We make one final comment. Throughout this section, we have been rather cavalier about "approximations". A computable real number can only be known approximately. For the most part, this is a mere nuisance. However, there is one place in our construction where the need to approximate plays a pivotal role. This is the fact that our triangle functions have overlapping supports, after the manner of

$$
\ldots[-2,0],[-1,1],[0,2] \ldots
$$

Why do we do this? Suppose instead that we used intervals which abut, like

$$
\ldots[-1,0],[0,1],[1,2] \ldots .
$$

What would go wrong? The trouble is that something like the following might happen:

There might be an eigenvalue $\lambda$ which is slighty greater than 1 , but which due to errors in computation we reckon as being slightly less than 1 . Consequently we select the interval $[0,1]$ instead of $[1,2]$. Well $\ldots$ ? The eigenvalue $\lambda$ has been lost forever. For our method requires us to remain within the interval $[0,1]$. No amount of partitioning of $[0,1]$ can bring us back to $\lambda$, which lies outside of $[0,1]$.

By using overlapping intervals we avoid these difficulties.

## 4. The Algorithm

In this section we give the algorithm and prove that it is effective.
We recall that there are two constructions which we must carry out. We must construct the sequence $\left\{\lambda_{n}\right\}$ of real numbers, and list the set $A$ of indices for which the declaration "Not an eigenvalue!" is made. We repeat that the algorithm below is NOT the same as the "construction" given in Heuristics I. The procedure in Heuristics I was a simplified (noneffective) preview of what we do here.

We shall give this algorithm in the form of a "recipe", simply listing its steps. Any explanations we include will be of a descriptive nature (to clarify what the recipe is). As already noted, the properties of this algorithm are proved in Section 5.

Construction of the $\lambda_{n}$. The number $\lambda_{n}$ will be constructed via a universal effective process applied to the vector $x_{n}$. We shall describe this process for a single fixed value of $n$. The sequence $\left\{\lambda_{n}\right\}$ is then generated by using a recursive procedure which returns to each $n$ infinitely often.

The ingredients for this construction are:
The vector $x_{n}$, which is held fixed.
The operational calculus of Pre-step A.
The triangle functions $\tau_{q i}$ of Pre-step B.
The approximation CompNorm ${ }_{q i}$ of Pre-step C.
We recall that the triangle functions $\tau_{q i}$ are supported on the intervals $I_{q i}= \left[(i-1) 8^{-q},(i+1) 8^{-q}\right]$ of half-width $8^{-q}$. These intervals overlap in the manner:

$$
\ldots[-2,0],[-1,1],[0,2],[1,3] \ldots
$$

[The trapezoidal function $\sigma$ plays no role in the construction, although it will play a role in the proofs which follow.]

We recall further that the values $\operatorname{CompNorm}_{q i}$ are a computable multi-sequence of nonnegative rational numbers which approximate the norms $\left\|\tau_{q i}(T)\left(x_{n}\right)\right\|$ to within an error given by:

$$
\mid \text { CompNorm }_{q i}-\left\|\tau_{q i}(T)\left(x_{n}\right)\right\| \mid \leqslant(1 / 1000)(1 / 2 M)\left(1 / 16^{q}\right)
$$

Now here is the recipe:
We proceed by induction, beginning with the stage $q=-1$, and going forward to the stages $q=0,1,2, \ldots$. At the stage $q=-1$, nothing has been done.

At each stage $q \geqslant 0$ we shall select a single triangle function $\tau_{q}^{*}$ from among the $\tau_{q i},-M \cdot 8^{q}<i<M \cdot 8^{q}$, defined in Pre-step B. If one wants to be very formal, we are really selecting an index $i=i(q)$ from the list of indices $-M \cdot 8^{q}<i<M \cdot 8^{q}$. Then we have the triangle $\tau_{q}^{*}$, the interval $I_{q}^{*}$, and the computed norm CompNorm ${ }_{q}^{*}$ given by:

$$
\begin{aligned}
\tau_{q}^{*} & =\tau_{q i}, & i & =i(q) ; \\
I_{q}^{*} & =I_{q i}, & i & =i(q) ; \\
\operatorname{CompNorm}_{q}^{*} & =\operatorname{CompNorm}_{q i}, & i & =i(q) .
\end{aligned}
$$

Now, at any stage $q \geqslant 1$, we impose the following restriction. In selecting $\tau_{q}^{*}=\tau_{q i}$ [i.e. in choosing $i=i(q)$ ], we consider only those $i$ such that

$$
I_{q i} \subseteq I_{q-1}^{*}
$$

[This guarantees that the selected interval $I_{q}^{*}$ satisfies $I_{q}^{*} \subseteq I_{q-1}^{*}$. Hence $I_{0}, I_{1}, I_{2}, \ldots$ form a nested sequence of intervals.]

It may be useful to recall (cf. Pre-step B) that, if $I_{q-1}^{*}=I_{q-1, j}$, then the allowed values for $i=i(q)$ are

$$
i=8 j-7, \ldots, 8 j+7
$$

It is from this finite list that the actual value $i=i(q)$ will be selected.
Finally, we are ready to describe the selection process for $i=i(q)$. It is this. Subject to the above restrictions on $i$ :

## Choose the $i$ for which CompNorm ${ }_{q i}$ is maximal.

In case of ties, we take the smallest tying $i$.
This is an effective process, since the multi-sequence $\operatorname{CompNorm}_{q i}$ is a computable double sequence of rational numbers.

The number $\lambda_{n}$ is defined as the common intersection of the intervals $I_{q}^{*}\left(=I_{q i}\right.$ for $i=i(q)$ ).

Lemma. The sequence $\left\{\lambda_{n}\right\}$ is computable.
Proof. The $I_{q}^{*}$ form a computable nested sequence of intervals of half-widths $8^{-q}$. Clearly these half-widths approach zero effectively. Hence the above furnishes an effective procedure for computing the real number $\lambda_{n}$.

What about effectiveness in $n$ ? For convenience in description, we have held $n$ fixed. But, clearly, the procedure is effective in $n$ also. For $\left\{x_{n}\right\}$ is a computable sequence of vectors, and the procedures in Pre-steps A and B are canonical and universal. By contrast, the approximation procedure in Pre-step C-giving the rational approximations CompNorm $_{q i}$-is slightly less canonical. But we took pains to insure that the computation was effective in $n$ as well as $q$ and $i$. That is all we need.

This completes the construction of $\left\{\lambda_{n}\right\}$.
Construction of the Set $A$ (Not an eigenvalue!). Recall that $A$ is to be a recursively enumerable set of natural numbers such that the set of eigenvalues of $T$ has the form $\left\{\lambda_{n}: n \notin A\right\}$. Roughly speaking, $A$ gives the set of indices $n$ for which we make the declaration "Not an eigenvalue!" The set $A$, although recursively enumerable, need not be recursive. Thus, from a computational point of view, we will eventually compute the $n \in A$-i.e. those $n$ for which the declaration "Not an eigenvalue!" is made. But the complementary set, listing the sequence of eigenvalues themselves, may never be known to us.

Of course, each individual eigenvalue (as opposed to the sequence of all eigenvalues) is computable. For if we hold $n$ fixed, then the set $A$ becomes irrelevant. We simply fix $n$ and then apply the effective procedure above for computing $\lambda_{n}$.

We turn now to the effective listing of the set $A$. Continuing with the notation used in constructing $\left\{\lambda_{n}\right\}$, we shall add one detail. All of the previous constructions depended on the initial vector $x_{n}$, which we held fixed. Where previously we suppressed the variable $n$, now it will be useful to display it. Thus we write:

$$
\begin{aligned}
i(q) & =i(q, n), \\
\tau_{q}^{*} & =\tau_{q}^{*}(n), \\
I_{q}^{*} & =I_{q}^{*}(n),
\end{aligned}
$$

and in particular,

$$
\operatorname{CompNorm}_{q}^{*}=\operatorname{CompNorm}_{q}^{*}(n) .
$$

Now it is easy to describe the set $A$ :
$n \in A$ if and only if, for some $q=0,1,2, \ldots$,

$$
\operatorname{CompNorm}_{q}^{*}(n)<\frac{1}{8} \text {. }
$$

Lemma. The set $A$ is recursively enumerable.

Proof. Clearly the set $A$ (although not its complement) can be effectively listed. For, firstly, $\left\{\operatorname{CompNorm}_{q}^{*}(n)\right\}$ is a computable double sequence of rational numbers. Thus, to list $A$, we scan the set of pairs ( $n, q$ ) in a recursive manner, returning to each $n$ infinitely often: If $\operatorname{CompNorm}_{q}^{*}(n)<1 / 8$ for some $q$, then we shall eventually find this $q$, and consequently add the integer $n$ to the set $A$.

## 5. Proof That the Algorithm Works

We have now given all of the necessary constructions and proved their effectiveness. But we have not proved that these constructions fulfill the promises made in the Second Main Theorem. This is our final task.

The proof depends on several inequalities, and we shall begin by deriving these. Then we will turn to the propositions 1. to 4. discussed in Heuristics II. For convenience, we will restate each proposition before giving its proof.

There are three inequalities. Analytically, they are not difficult. However, the combinatorial situation which gives rise to them requires a bit of preface.

Suppose that in our construction we have completed stage $(q-1)$ and are looking at stage $q$. The triangle function $\tau_{q-1}^{*}$ with support $I_{q-1}^{*}$ has already been selected. We recall that, if we write $I_{q-1}^{*}=I_{q-1, j}$, then the next value of $i$ must be selected from
the list:

$$
8 j-7 \leqslant i \leqslant 8 j+7
$$

We first consider what we would do if we could achieve perfect accuracy. Let $u$ be an index from the above list which maximizes the norm $\left\|\tau_{q u}(T)\left(x_{n}\right)\right\|$. That is, $u$ is chosen so that, with $i$ restricted as above:

$$
\left\|\tau_{q u}(T)\left(x_{n}\right)\right\| \geqslant\left\|\tau_{q i}(T)\left(x_{n}\right)\right\| \quad \text { for all } i .
$$

(Of course, there is no effective procedure for finding $u$.)
Let $v$ be the least index from the above list which maximizes CompNorm ${ }_{q v}$. That is, $v$ is chosen so that, with $i$ restricted as above:

$$
\text { CompNorm }_{q v} \geqslant \text { CompNorm }_{q i} \quad \text { for all } i .
$$

Here, by contrast, we can compute $v$. In fact, $v$ is just the value $v=i(q)$ which is used in the effective algorithm of Section 4. Hence, by the definitions of $\tau_{q}^{*}$ and CompNorm ${ }_{q}^{*}$ in Section 4:

$$
\begin{aligned}
\tau_{q}^{*} & =\tau_{q v} \\
\operatorname{CompNorm}_{q}^{*} & =\operatorname{CompNorm}_{q v}
\end{aligned}
$$

The use of the index $v$ instead of $u$ can lead to values which are slightly less than maximal. We must compare these "imperfect" values to $\left\|\tau_{q u}(T)\left(x_{n}\right)\right\|$, which is what we would obtain if we could do perfect computations. We repeat that the reason for these considerations is that we can find $v$ effectively, but not $u$.

The key inequalities

$$
\begin{align*}
\left|\operatorname{CompNorm}_{q}^{*}-\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\|\right| & \leqslant(1 / 1000)(1 / 2 M)\left(1 / 16^{q}\right)  \tag{InEq1}\\
& \left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\| \geqslant\left\|\tau_{q u}(T)\left(x_{n}\right)\right\|-(2 / 1000)(1 / 2 M)\left(1 / 16^{q}\right)  \tag{InEq2}\\
& \left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\| \geqslant(1 / 2 M)\left(1 / 16^{q}\right) \tag{InEq3}
\end{align*}
$$

Proof of the inequalities. For $\operatorname{InEq} 1$. The error estimates in Pre-step C give us, for all $q$ and $i$ :

$$
\mid \text { CompNorm }_{q i}-\left\|\tau_{q i}(T)\left(x_{n}\right)\right\| \mid \leqslant(1 / 1000)(1 / 2 M)\left(1 / 16^{q}\right) .
$$

Hence, in particular, this inequality holds for $i=v$. Since $\operatorname{CompNorm}_{q}^{*}= \operatorname{CompNorm}_{q v}$ and $\tau_{q}^{*}=\tau_{q v}$, this gives InEq 1.

For InEq 2, we observe that similarly $\operatorname{CompNorm}_{q u}$ deviates from $\left\|\tau_{q u}(T)\left(x_{n}\right)\right\|$ by less than $(1 / 1000)(1 / 2 M)\left(1 / 16^{q}\right)$. Now by definition of $v=i(q)$, CompNorm ${ }_{q v} \geqslant$ CompNorm $_{q u}$. (With the CompNorms, which are effectively computed rational
numbers, we do, of course, pick the best value.) Hence:

$$
\operatorname{CompNorm}_{q v} \geqslant\left\|\tau_{q u}(T)\left(x_{n}\right)\right\|-(1 / 1000)(1 / 2 M)\left(1 / 16^{q}\right)
$$

Again we recall that $\operatorname{CompNorm}_{q}^{*}=\operatorname{CompNorm}_{q v}$. By $\operatorname{InEq} 1$, the transition back from CompNorm ${ }_{q}^{*}$ to $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\|$ introduces another error of $(1 / 1000)(1 / 2 M)\left(1 / 16^{q}\right)$. This, added to the identical error above, produces the $(2 / 1000)(1 / 2 M)\left(1 / 16^{q}\right)$ of InEq 2.

For InEq 3. We use induction on $q$. Assume that the inequality has been proved for $q-1$. First we will deal with the case $q \geqslant 1$, and then we shall come back to the case $q=0$. Take $q \geqslant 1$. By the induction hypothesis:

$$
\left\|\tau_{q-1}^{*}(T)\left(x_{n}\right)\right\| \geqslant(1 / 2 M)\left(1 / 16^{q-1}\right)
$$

Now we use an inequality which has already been proved in Pre-step B. This inequality was based on the decomposition formulas for triangle functions (see Figures 1 and 2 above). We proved in Pre-step B that:

$$
\left\|\tau_{q u}(T)\left(x_{n}\right)\right\| \geqslant(1 / 8)\left\|\tau_{q-1}^{*}(T)\left(x_{n}\right)\right\| .
$$

For convenience, let us call $(1 / 2 M)\left(1 / 16^{q}\right)$ "the target value". Our objective is to show that $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\| \geqslant$ (the target value).

By combining the two displayed inequalities above, we obtain $\left\|\tau_{q u}(T)\left(x_{n}\right)\right\| \geqslant 2$. (the target value), since $(1 / 8)\left(1 / 16^{q-1}\right)(1 / 2 M)=2 \cdot\left(1 / 16^{q}\right)(1 / 2 M)$. We must make the transition from $\tau_{q u}$ (the true maximum) to $\tau_{q v}\left(=\tau_{q}^{*}\right.$, the function we select). Well, we simply use InEq 2. We have 2 • (the target value), and the "error" in InEq 2 forces us to subtract $(2 / 1000) \cdot$ (the target value). This leaves us with:

$$
\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\| \geqslant[2-(2 / 1000)] \cdot(\text { the target value }) .
$$

The coefficient [ $2-(2 / 1000)$ ] exceeds the required value of 1 , with room to spare.
Now we must do the case $q=0$. This is where the trapezoidal function $\sigma$ from Pre-step B comes in. (See Figure 2.) Actually, we already did most of the work in Pre-step B, where we proved-using $\sigma$-that:

$$
\left\|\tau_{\mathrm{o} u}(T)\left(x_{n}\right)\right\| \geqslant 1 /(2 M-1) .
$$

Again $u$ is the maximizing index, $v$ is the slightly inferior index which we select, and $\tau_{0}^{*}=\tau_{0 v}$. We need $\left\|\tau_{0}^{*}(T)\left(x_{n}\right)\right\| \geqslant 1 / 2 M$. Hence this allows us to use the gap between $1 /(2 M-1)$ and $1 / 2 M$.

Now we go back to Pre-step C. There, at stage $q=0$, we insisted on an error:

$$
\mid \text { CompNorm }_{0 i}-\left\|\tau_{0 i}(T)\left(x_{n}\right)\right\| \left\lvert\, \leqslant \frac{1}{1000}\left[\frac{1}{2 M-1}-\frac{1}{2 M}\right]\right.
$$

Well, how convenient!

Again, our "error" is $1 / 1000$-th of the allowable gap. The rest of the proof is so similar to that given above (for $q \geqslant 1$ ) that we leave any further details to the reader.

This completes our treatment of the inequalities $\operatorname{InEq} 1$ to $\operatorname{InEq} 3$.

## The end of the proof

We now give the proofs of the propositons 1 to 4.
Because we have made the right preparations, these proofs are very short. We recall that "SpThm $N$ " refers to the $N$-th corollary of the spectral theorem, as developed in Section 1. Of course, "InEq $N$ " refers to the $N$-th inequality in the preceding subsection.

1. (Every $\lambda_{n} \in \operatorname{spectrum}(T)$.)

Proof. Suppose not. Since spectrum( $T$ ) is a closed set, $\lambda_{n}$ must lie within an open interval $\left(\lambda_{n}-\varepsilon, \lambda_{n}+\varepsilon\right)$ outside of spectrum( $T$ ). Since the supports of the triangle functions $\tau_{q}^{*}$ shrink to the point $\lambda_{n}$, there must be some $q$ for which support $\left(\tau_{q}^{*}\right) \subseteq \left(\lambda_{n}-\varepsilon, \lambda_{n}+\varepsilon\right)$.

Thus the support of $\tau_{q}^{*}$ lies entirely outside of spectrum $(T)$. Since $\left\|\tau_{q}^{*}(T)\right\| \leqslant \sup \left\{\left|\tau_{q}^{*}(\lambda)\right|: \lambda \in \operatorname{spectrum}(T)\right\}(\operatorname{SpThm} 7), \tau_{q}^{*}(T)=0$. Hence $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\|=0$. This contradicts InEq 3.
2. (The sequence $\left\{\lambda_{n}\right\}$ is dense in spectrum( $T$ ).)

Proof. Let $\lambda \in \operatorname{spectrum}(T)$, and take any $\varepsilon>0$. We must find a $\lambda_{n}$ such that $\left|\lambda_{n}-\lambda\right|<\varepsilon$.

Take an integer $q$ such that the interval $I_{q}^{*}=\operatorname{support}\left(\tau_{q}^{*}\right)$ has length $<\varepsilon / 2$, that is, such that $2 \cdot 8^{-q}<\varepsilon / 2$.

From SpThm 3, the open interval $(\lambda-\varepsilon / 2, \lambda+\varepsilon / 2)$ corresponds to a nonzero subspace $H_{(\lambda-\varepsilon / 2, \lambda+\varepsilon / 2)}$ of $H$.

Let $x$ be any unit vector in $H_{(\lambda-\varepsilon / 2, \lambda+\varepsilon / 2)}$.
Since $\left\{x_{n}\right\}$ is dense on the spherical shell $\{x: 1 \leqslant\|x\| \leqslant 1001 / 1000\}$, there exists some $x_{n}$ with $\left\|x_{n}-x\right\|<(1 / 2 M)\left(1 / 16^{q}\right)$. Thus we may write:

$$
\begin{aligned}
& x_{n}=x+z \\
& \|z\|<(1 / 2 M)\left(1 / 16^{q}\right) \\
& x \in H_{(\lambda-\varepsilon / 2, \lambda+\varepsilon / 2)}
\end{aligned}
$$

We use this vector $x_{n}$ with its associated triangle functions $\tau_{q}^{*}$ and its associated value $\lambda_{n}$. We recall that $\lambda_{n}$ is the common intersection of the intervals $I_{q}^{*}=\operatorname{support}\left(\tau_{q}^{*}\right)$ for $q=0,1,2, \ldots$. On the other hand, in this argument we are using a fixed value of $q$, as defined above. We claim:

$$
\operatorname{support}\left(\tau_{q}^{*}\right) \text { intersects }(\lambda-\varepsilon / 2, \lambda+\varepsilon / 2) \text {. }
$$

Suppose not. Then the support of $\tau_{q}^{*}$ lies entirely outside of ( $\lambda-\varepsilon / 2, \lambda+\varepsilon / 2$ ), whereas the vector $x$ lies entirely within the subspace $H_{(\lambda-\varepsilon / 2, \lambda+\varepsilon / 2)}$. Hence by $\operatorname{SpThm} 1, \tau_{q}^{*}(T)(x)=0$. Hence $\tau_{q}^{*}(T)\left(x_{n}\right)=\tau_{q}^{*}(T)(z)$. Now $\left|\tau_{q}^{*}(t)\right| \leqslant 1$ for all real $t$, whence $\left\|\tau_{q}^{*}(T)\right\| \leqslant 1(\operatorname{SpThm} 7)$, whence

$$
\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\|=\left\|\tau_{q}^{*}(T)(z)\right\| \leqslant\|z\|<(1 / 2 M)\left(1 / 16^{q}\right) .
$$

This contradicts InEq 3.
Consequently $I_{q}^{*}=\operatorname{support}\left(\tau_{q}^{*}\right)$ does intersect $(\lambda-\varepsilon / 2, \lambda+\varepsilon / 2)$. Since $I_{q}^{*}$ has length $<\varepsilon / 2$, and $\lambda_{n} \in I_{q}^{*}$, we obtain $\left|\lambda_{n}-\lambda\right|<\varepsilon$, as desired.

Summary of 1. and 2. (the spectrum). This is a good place to pause and recall what went into the proofs of 1 . and 2 . Begin with 2 . There we used a vector $x_{n}$ which depended on $q$ which in turn depended on $\varepsilon$. We used the inequality $\operatorname{InEq} 3 \left[\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\| \geqslant(1 / 2 M)\left(1 / 16^{q}\right)\right]$, which also depends on $q$, but is independent of $n$. Much of the work in Pre-step B-the careful partitioning of triangles as shown in Figures 1 and 2 above-was aimed at producing this independence. It is essential. For the definition of $x_{n}$ implicitly depended on $\operatorname{InEq} 3$. If $\operatorname{InEq} 3$ also depended on $x_{n}$, then our definition would be circular.

By contrast, the proof of 1. required only $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\|>0$. If this were all we needed, it could be attained much more easily.

We turn now to the "eigenvalue propositions" 3. and 4.
Remarks. Here we shall not need such sharp error estimates as those proved in InEq 1 to InEq 3 above. Instead of the error term $(1 / 1000)(1 / 2 M)\left(1 / 16^{q}\right)$ of InEq 1, we can get by with $1 / 1000$. Similarly for InEq 2. Lastly, InEq 3 has served its purpose (in proving 2.) and will not be seen again.

Of course, in this theoretical account, we are not going to alter our construction. But for the purpose of algorithmic efficiency, it might be well to record the fact: If one cared only about eigenvalues, and not about the spectrum, then a fixed "error" such as 1/1000 would suffice.
3. (If $\lambda_{n}$ is not an eigenvalue, then $n \in A$, that is, the declaration "Not an eigenvalue!" is made for $n$.)

Proof. Since $\lambda_{n}$ is not an eigenvalue, the spectral measure of the point-set $\left\{\lambda_{n}\right\}$ is null (SpThm 5).

The triangle functions are uniformly bounded $\left(0 \leqslant \tau_{q}^{*}(t) \leqslant 1\right)$. Recall that, as $q \rightarrow \infty$, the supports of the $\tau_{q}^{*}$ shrink to the point-set $\left\{\lambda_{n}\right\}$. Hence, as $q \rightarrow \infty$, the functions $\tau_{q}^{*}(t) \rightarrow 0$ pointwise except at the point $t=\lambda_{n}$.

Now, as we have seen, the point-set $\left\{\lambda_{n}\right\}$ has spectral measure zero. Thus, as $q \rightarrow \infty$, the functions $\tau_{q}^{*}(t) \rightarrow 0$ "almost everywhere" in terms of the spectral measure. Hence by SpThm 2, $\tau_{q}^{*}(T)\left(x_{n}\right) \rightarrow 0$, which means by definition that $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\| \rightarrow 0$.

The rest is trivial. Since $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\| \rightarrow 0$ as $q \rightarrow \infty$, eventually $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\|$ becomes less than $(1 / 8)-(1 / 1000)$. Since $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\|$ and $\operatorname{CompNorm}_{q}^{*}$ differ by $\leqslant(1 / 1000)$ (InEq 1), eventually CompNorm ${ }_{q}^{*}$ becomes less than $1 / 8$. When that happens, the declaration "Not an eigenvalue!" is made.
4. (If $\lambda$ is an eigenvalue of $T$, then there exists some $n \notin A$ with $\lambda=\lambda_{n}$.)

Proof. Let $\lambda$ be an eigenvalue of $T$, and let $x$ be a unit eigenvector corresponding to $\lambda$. Since $\left\{x_{n}\right\}$ is dense on the spherical shell $\{x: 1 \leqslant\|x\| \leqslant 1001 / 1000\}$, there exists some $x_{n}$ with $\left\|x_{n}-x\right\|<1 / 1000$. Let $\lambda_{n}$ be the scalar corresponding to $x_{n}$ via our construction. We wish to show that $\lambda=\lambda_{n}$ and $n \notin A$. For this we use:

Lemma. Under the above assumptions on $x_{n}$, we have $\tau_{q}^{*}(\lambda) \geqslant 1 / 7$ and $\operatorname{CompNorm}_{q}^{*} \geqslant$ 1/7 for all $q$.

We first show that the lemma implies 4 . Recall that $\lambda_{n}$ is the common intersection point of the intervals $I_{q}^{*}=\operatorname{support}\left(\tau_{q}^{*}\right)$ for $q=0,1,2, \ldots$. Since, by the lemma, $\lambda \in \operatorname{support}\left(\tau_{q}^{*}\right)$ for all $q, \lambda=\lambda_{n}$. Since CompNorm ${ }_{q}^{*} \geqslant 1 / 7>1 / 8$, the declaration "Not an eigenvalue!" is never made, whence $n \notin A$.

Proof of lemma. We give the essential points first, and save the details of "approximation" for the end. Thus for now we work with the true eigenvector $x$, and ignore its approximation $x_{n}$. From SpThm 4 we have:

$$
\left\|\tau_{q i}(T)(x)\right\|=\tau_{q i}(\lambda) \cdot\|x\|=\tau_{q i}(\lambda) \quad \text { for all } q, i .
$$

Now the proof hinges on the way the triangle functions $\tau_{q i}$ overlap. (Here see Figures 1 and 2 in Section 2 above, and especially Figure 3 below.) Hold $\lambda$ fixed. Then for any $q$, there exists some index $i$ such that $\tau_{q i}(\lambda) \geqslant 1 / 2$. However, this overlooks a crucial point. We are not allowed to pick $i$ with complete freedom. (Here cf. the closing remarks in Heuristics II.) Specifically, the situation is this:

Suppose at stage $q-1$ we have selected the function $\tau_{q-1}^{*}=\tau_{q-1, j}$. Then at stage $q$, the index $i=i(q)$ must come from the list

$$
i=8 j-7, \ldots, 8 j+7 .
$$

We must show that for one of these $i, \tau_{q i}(\lambda) \geqslant 1 / 2$. Here again we refer to the geometry of the triangle functions (Figure 3). One readily verifies:
(ooo) $\tau_{q i}(\lambda) \geqslant 1 / 2$ for some $i=8 j-7, \ldots, 8 j+7$ if and only if $\tau_{q-1}^{*}(\lambda) \geqslant 1 / 16-$ that is, if and only if $\lambda$ lies within the middle 15/16-ths of the support of $\tau_{q-1}^{*}$.

![](https://cdn.mathpix.com/cropped/afa54d18-0165-4a9b-9969-7a907958f214-34.jpg?height=296&width=1067&top_left_y=1820&top_left_x=274)
Figure 3

Now the rest of the argument, while analytically simple, involves an induction on the pair of statements:
(*) For all $q$, there is some $i=8 j-7, \ldots, 8 j+7$ such that $\tau_{q i}(\lambda) \geqslant 1 / 2$.
$(* *) \tau_{q}^{*}(\lambda) \geqslant 1 / 7$.
Assume that both $(*)$ and $(* *)$ hold for $q-1$. Then by $(* *), \tau_{q-1}^{*}(\lambda) \geqslant 1 / 7$, which exceeds $1 / 16$ with room to space. By (ooo) above, this gives (*) [although not yet (**)] for $q$.

We must also verify (*) for $q=0$. (Here see Figure 2 above.) This follows immediately from the fact that $\operatorname{spectrum}(T) \subseteq[-(M-1), M-1]$, whence $\lambda \in [-(M-1), M-1]$.

Now we turn to the derivation of (**). This is a mundane problem of approximation. Let $u$ be the value of $i, 8 j-7 \leqslant i \leqslant 8 j+7$, which maximizes $\tau_{q i}(\lambda)$. [We do not claim that $u$ can be found effectively.] By (*) we know that

$$
\tau_{q u}(\lambda) \geqslant 1 / 2
$$

and since $\tau_{q u}(\lambda)=\left\|\tau_{q u}(T)(x)\right\|$,

$$
\left\|\tau_{q u}(T)(x)\right\| \geqslant 1 / 2
$$

Since $\left\|x_{n}-x\right\|<1 / 1000$ and $\left\|\tau_{q u}(T)\right\| \leqslant 1$ (SpThm 7):

$$
\left|\left\|\tau_{q u}(T)(x)\right\|-\left\|\tau_{q u}(T)\left(x_{n}\right)\right\|\right|<1 / 1000
$$

Since CompNorm ${ }_{q u}$ differs from $\left\|\tau_{q u}(T)\left(x_{n}\right)\right\|$ by less than $1 / 1000$,

$$
\mid\left\|\tau_{q u}(T)(x)\right\|-\text { CompNorm }_{q u} \mid<2 / 1000
$$

Since, by definition, CompNorm* is the maximum of the computed norms, $\operatorname{CompNorm}_{q}^{*} \geqslant \operatorname{CompNorm}_{q u}$, whence

$$
\begin{aligned}
\operatorname{CompNorm}_{q}^{*} & \geqslant\left\|\tau_{q u}(T)(x)\right\|-2 / 1000 \\
& \geqslant(1 / 2)-(2 / 1000)
\end{aligned}
$$

Since CompNorm ${ }_{q}^{*}$ differs from $\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\|$ by less than $1 / 1000$,

$$
\left\|\tau_{q}^{*}(T)\left(x_{n}\right)\right\| \geqslant\left\|\tau_{q u}(T)(x)\right\|-3 / 1000
$$

Finally, since $\left\|x_{n}-x\right\|<1 / 1000$,

$$
\begin{aligned}
\left\|\tau_{q}^{*}(T)(x)\right\| & \geqslant\left\|\tau_{q u}(T)(x)\right\|-4 / 1000 \\
& \geqslant(1 / 2)-(4 / 1000)
\end{aligned}
$$

Now we are back to the true eigenvector $x$, but with the "imperfect" triangle function $\tau_{q}^{*}$ which our approximate construction furnishes. We have (again by SpThm 4):

$$
\left\|\tau_{q}^{*}(T)(x)\right\|=\tau_{q}^{*}(\lambda) \geqslant(1 / 2)-(4 / 1000) .
$$

The value $(1 / 2)-(4 / 1000)$ exceeds the desired target value of $1 / 7$ with room to spare. This proves ( $* *$ ), and completes the induction from $q-1$ to $q$.

Finally, several steps back, we had $\operatorname{CompNorm}_{q}^{*} \geqslant(1 / 2)-(2 / 1000)$, which exceeds $1 / 7$ with slightly more room to space.

This proves the lemma. As we have seen, the lemma implies proposition 4. This, in turn, completes the proof of the Second Main Theorem.

More precisely, we have proved the positive parts (i) and (ii) of the Second Main Theorem for the case of bounded self-adjoint operators. Normal operators, unbounded self-adjoint operators, and the negative parts (iii) and (iv) will be treated in Sections 6, 7, and 8 respectively.

## 6. Normal Operators

We recall that a bounded linear operator $T$ is normal if it commutes with its adjoint, i.e. if $T T^{*}=T^{*} T$. The Second Main Theorem extends mutatis mutadis to bounded normal operators. This extension is needed for the unbounded self-adjoint case.

Theorem 1 (Normal Operators). Let $H$ be an effectively separable Hilbert space. Let $T: H \rightarrow H$ be a bounded normal operator. Suppose that $T$ is effectively determined. Then there exists a computable sequence $\left\{\lambda_{n}\right\}$ of complex numbers, and a recursively enumerable set $A$ of integers such that:

```
each $\lambda_{n} \in \operatorname{spectrum}(T) ;$
```

the spectrum of $T$ is the closure in $\mathbb{C}$ of the set $\left\{\lambda_{n}\right\}$; the set of eigenvalues of $T$ coincides with $\left\{\lambda_{n}: n \in \mathbb{N}-A\right\}$.

Before we come to the proof of Theorem 1, we need the following.
Proposition. Let $T: H \rightarrow H$ be an effectively determined bounded normal operator. Then the adjoint $T^{*}$ is effectively determined.

Proof. We wish to show that $T^{*} x$ is computable if $x$ is. It will be obvious that the procedure is effective, uniformly for computable sequences $\left\{x_{k}\right\}$.

Let $x$ be computable. Now $T$ is bounded and effectively determined. Hence by the First Main Theorem (Chapter 3), $T x$ is computable. Then by the Norm Axiom,
$\|T x\|$ is computable. Since $T$ is normal, $\|T x\|=\left\|T^{*} x\right\|$, for we have $\|T x\|^{2}= \left(T^{*} T x, x\right)=\left(T T^{*} x, x\right)=\left\|T^{*} x\right\|^{2}$. Thus $\left\|T^{*} x\right\|$ is computable.

We recall that by Lemma 7, Section 6, Chapter 4 there exists a computable orthonormal basis $\left\{e_{n}\right\}$ for $H$. Let $\left\{c_{n}\right\}$ be the sequence of "Fourier coefficients" of $T^{*} x$, namely $c_{n}=\left(T^{*} x, e_{n}\right)=\left(x, T e_{n}\right)$. Since $T$ is effectively determined, we see that $\left\{c_{n}\right\}$ is computable. Thus the sequence of vectors $y_{n}=\sum_{i=0}^{n} c_{i} e_{i}$ is computable.

The norms $\left\|y_{n}\right\|=\left(\sum_{i=0}^{n}\left|c_{i}\right|^{2}\right)^{1 / 2}$ form a nondecreasing sequence whose limit is $\left(\sum_{i=0}^{\infty}\left|c_{i}\right|^{2}\right)^{1 / 2}=\left\|T^{*} x\right\|$. As we have seen, $\left\|T^{*} x\right\|$ is computable. Thus the norms $\left\{\left\|y_{n}\right\|\right\}$ form a computable sequence converging monotonically to a computable limit $\left\|T^{*} x\right\|$. Hence the convergence is effective (Chapter 0, Section 2). Finally, $\left\|y_{n}-T^{*} x\right\|^{2}=\sum_{i=n+1}^{\infty}\left|c_{i}\right|^{2}=\left\|T^{*} x\right\|^{2}-\left\|y_{n}\right\|^{2} \rightarrow 0$ effectively-i.e. $y_{n} \rightarrow T^{*} x$ effectively in the norm of $H$. Since $\left\{y_{n}\right\}$ is computable, it follows by the Limit Axiom that $T^{*} x$ is computable. This proves the proposition.

Note. This proposition fails for operators which are not normal. That is, there exists a bounded (non-normal) effectively determined operator $T$ whose adjoint $T^{*}$ is not effectively determined. Since we do not need this counterexample, we shall not digress by presenting it.

## Proof of Theorem 1

The proof follows so closely the proofs in Section 1-5 that it is pointless to give it in detail. Instead we list the few modifications which are necessary in order to pass from the bounded self-adjoint to the normal case.

First, and obviously, we use the spectral theorem for bounded normal rather than bounded self-adjoint operators. Here the spectrum of $T$ is a compact set in the complex plane rather than the real line. All of the (minor) modifications in the proof are consequence of this circumstance. We now list these modifications, with reference to the places in Sections 1-5 where they occur.
(Weierstrass approximation theorem in Section 2, Pre-step A). There we had real polynomials $p(t)$, where the relevant values of $t$ were the points $\lambda$ in the spectrum of $T$. Here we replace polynomials in the real variable $\lambda$ by polynomials in the two complex variables $\lambda$ and $\bar{\lambda}$. We observe that, in the operational calculus, $\lambda$ corresponds to $T$ and $\bar{\lambda}$ corresponds to $T^{*}$. For the Weierstrass theorem, we note that a arbitrary polynomial in $x=\operatorname{Re}(\lambda), y=\operatorname{Im}(\lambda)$ can be expressed in terms of $\lambda$ and $\bar{\lambda}: x=(\lambda+\bar{\lambda}) / 2, y=(\lambda-\bar{\lambda}) / 2 i$.
(The two dimensional grid-cf. Section 2). As before, we partition our intervals into 8 parts at each stage. However, here the spectrum of $T$ is complex. Hence we have a two dimensional grid on which each square is partitioned like a chessboard into 64 squares. As this happens at each stage, after $q$ stages the number of squares is multiplied by $64^{q}$.
(The "triangle functions" $\tau_{q i}(x)$ in Section 2, Pre-step B.) Since the spectrum of $T$ is complex, we need functions of two real variables $x, y$. We set:

$$
\tau_{q i j}(x, y)=\tau_{q i}(x) \tau_{q j}(y), \quad-8^{q} M<i<8^{q} M, \quad-8^{q} M<j<8^{q} M .
$$

In Section 2, Pre-step B we had the decomposition identity:

$$
\tau_{q-1, i}(x)=\frac{1}{8} \sum_{j=-7}^{7}(8-|j|) \cdot \tau_{q, h+j}(x), \quad \text { where } h=8 i
$$

(As we recall, the coefficients go $1,2,3, \ldots, 7,8,7, \ldots, 3,2,1$.) Now by the distributive law, the product $\tau_{q-1, i}(x) \tau_{q-1, j}(y)$ decomposes into a linear combination of terms $\tau_{q r}(x) \tau_{q s}(y)$, where $8 i-7 \leqslant r \leqslant 8 i+7,8 j-7 \leqslant s \leqslant 8 j+7$.

For the sake of thoroughness, we check that the factor $64^{q}$ mentioned above is correct. Consider the passage from $q-1$ to $q$. The function $\tau_{q-1, i j}(x, y)$ is a linear combination of products $\tau_{q r}(x) \tau_{q s}(y)$. The sum of the coefficients is

$$
\left(\frac{1}{8}\right)^{2}[1+2+\cdots+7+8+7+\cdots+2+1]^{2}=\frac{1}{64} \cdot 64^{2}=64 .
$$

Hence the largest of the $\left\|\tau_{q r}(x) \tau_{q s}(y)(T)\left(x_{n}\right)\right\|$ must be $\geqslant 1 / 64$ the size of the corresponding term for $q-1$.
(The "CompNorms" in Section 2, Pre-step C). Previously, at stage $q$, the CompNorms $=$ computed norms approximated the true norms to within an error of

$$
(1 / 1000)(1 / 2 M)\left(1 / 16^{q}\right) \quad \text { for } q \geqslant 1
$$

Here the " $1 / 2 M$ " took care of the length of the interval $[-M, M]$, and the " $1 / 16^{q}$ " was designed to be safely smaller than the natural factor of $1 / 8^{q}$ which results from the partition process.

In the two dimensional case, we replace the " $1 / 2 M$ " by " $1 / 4 M^{2}$ " (area of a square), and replace the " $1 / 16^{q}$ " by " $1 / 256^{q}$ " (again safely smaller than the natural factor of $1 / 64^{q}$ which results from the partition process).

The trivial modifications for the case $q=0$ are left to the reader.
(The algorithm in Section 4). Once the CompNorms have been found-cf. above -there is essentially no change in Section 4, other than the obvious fact that the single index $i$ is replaced by a pair of indices $i, j$.
(Section 5, "Not an eigenvalue!") We examine the crucial lemma in step 4. in Section 5. In the proof of this lemma we had the statement: "There is some index $i$ (which we label $u$ ) such that $\tau_{q u}(\lambda) \geqslant 1 / 2$." Now, because of the two-dimensional picture, the corresponding statement becomes: There is some pair of indices $u, v$ such that $\tau_{q u v}(\lambda) \geqslant 1 / 4$. In the previous proof, we went from $1 / 2$ down to $1 / 7$; the exact size of these constants did not matter: only the fact that the second was strictly less than the first. Here we can go from $1 / 4$ to $1 / 7$, so the constant $1 / 7$ still suffices in the complex case. [Of course, the point of the constant $1 / 7$ is that it is strictly
greater than $1 / 8$-since the "Not an eigenvalue!" declaration uses the cutoff value of $1 / 8$.]

This completes our listing of the modifications. $\square$

## 7. Unbounded Self-Adjoint Operators

Let $T: H \rightarrow H$ be an unbounded self-adjoint operator. It is well known (cf. Section 1) that $N=(T-i)^{-1}$ exists and is a bounded normal operator. Thus, in the classical (non-computable) case, the theory of unbounded self-adjoint operators reduces to that of bounded normal operators. A computable treatment of the spectrum for bounded normal operators was outlined in the preceding section. In this section, we extend this treatment to unbounded self-adjoint operators.

We recall the difinition. Let $X$ be a Banach space with a computability structure. A closed operator $T$ is effectively determined if there is a computable sequence of pairs $\left\{\left(e_{n}, T e_{n}\right)\right\}$ which spans a dense subspace of the graph of $T$. Then we also say that $\left\{e_{n}\right\}$ is an effective generating set for $T$.

The following trivial observation will be used in what follows. If $T$ is effectively determined, if $\left\{e_{n}\right\}$ is an effective generating set for $T$, and if $\alpha$ is a computable real or complex constant, then the operator $T+\alpha$ is effectively determined, and $\left\{e_{n}\right\}$ is an effective generating set for $T+\alpha$. The proof is clear.

The following proposition, which we will use in our proof, may also be of independent interest.

Proposition. Let $T: X \rightarrow X$ be effectively determined, and let $\left\{e_{n}\right\}$ be an effective generating set for $T$. Suppose that $T^{-1}$ exists and is a bounded operator. Then $T^{-1}$ is effectively determined.

Proof. Since $T^{-1}$ is bounded, it suffices to compute $T^{-1} e_{n}$ for any effective generating set $\left\{e_{n}\right\}$. More generally, we show how to compute $\left\{T^{-1} x_{n}\right\}$ for any computable sequence $\left\{x_{n}\right\}$. To do this we show how to compute $T^{-1} x$ for any computable $x$; it will be obvious that our procedure extends effectively to computable sequences $\left\{x_{n}\right\}$.

Since $T^{-1}$ is a bounded operator, the range of $T$ is the whole Banach space $X$. That is, the projection of the graph $\{(u, v): v=T u\}$ onto the $v$-coordinate is $X$. Let $v=x$, so that $u=T^{-1} x$. Now to compute $u$ effectively, we proceed as follows.

Let $M$ be an integer such that $\left\|T^{-1}\right\|<M$. Let $\left\{p_{i}\right\}$ be an effective listing of all (real/complex) rational linear combinations of the $e_{n}$. Since $T$ is effectively determined, the set of pairs ( $p_{i}, T p_{i}$ ) is dense in the graph of $T$. Hence for any $k$ there exists an $i$ such that

$$
\left\|p_{i}-u\right\|+\left\|T p_{i}-v\right\|<2^{-k} / M,
$$

which immediately gives

$$
\left\|T p_{i}-v\right\|<2^{-k} / M .
$$

To compute $u=T^{-1} x$ to within an error $<2^{-k}$, we set $v=x$, and then wait until a $p_{i}$ turns up such that $\left\|T p_{i}-x\right\|<2^{-k} / M$. Then since $\left\|T^{-1}\right\|<M,\left\|p_{i}-T^{-1} x\right\|<2^{-k}$. The $u$-coordinate $p_{i}$ is our desired approximation to $T^{-1} x$.

Now we return to the case of unbounded self-adjoint operators on a Hilbert space $H$. For convenience, we recall the result which we need to show.

Second Main Theorem, unbounded case, parts (i) and (ii). Let $T: H \rightarrow H$ be an effectively determined unbounded self-adjoint operator. Then there exists a computable sequence $\left\{\lambda_{n}\right\}$ of real numbers, and a recursively enumerable set $A$ of integers such that:
each $\lambda_{n} \in \operatorname{spectrum}(T) ;$
the spectrum of $T$ is the closure in $\mathbb{R}$ of the set $\left\{\lambda_{n}\right\}$;
the set of eigenvalues of $T$ coincides with $\left\{\lambda_{n}: n \in \mathbb{N}-A\right\}$.
[Thus the results of Sections 1-5 extend to the case of unbounded self-adjoint operators.]

Proof. We combine the proposition above with Theorem 1, Section 6 (normal operators). Since $T$ is self-adjoint, the operator $N=(T-i)^{-1}$ is bounded and normal. From the proposition above, we see that $N$ is effectively determined. Now we apply Theorem 1 for normal operators. This asserts that there is a computable sequence of complex numbers $\left\{\mu_{n}\right\}$ which is dense in spectrum $(N)$ and such that the eigenvalues of $N$ consist of $\left\{\mu_{n}: n \in \mathbb{N}-A\right\}$ for some recursively enumerable set $A$.

Now the transition from $N$ to $T$ requires three steps.

1. Since $N=(T-i)^{-1}, T=N^{-1}(1+i N)$. The spectrum/eigenvalues of $N$ are mapped onto those of $T$ by the function $\lambda=(1+i \mu) / \mu$.
2. We observe that 0 is not an eigenvalue of $N$ (else $T-i$ would map zero onto a nonzero vector). However, since $T$ is unbounded, $0 \in \operatorname{spectrum}(N)$, and 0 is a limit point of the spectrum of $N$.
3. We have to deal with the possibility that some of the $\mu_{n}=0$. We simply delete these $\mu_{n}$. The set $B$ of $n$ for which $\mu_{n} \neq 0$ is recursively enumerable (although perhaps not recursive). Consequently we keep $\left\{\mu_{n}: n \in B\right\}$, and replace the set $A$ by $A \cap B$. Since 0 is a limit point of the spectrum, the set $\left\{\mu_{n}: \mu_{n} \neq 0\right\}$ is still dense in spectrum $(N)$.

Combining steps 1. to 3 . above, we see that the sequence $\left\{\lambda_{n}=\left(1+i \mu_{n}\right) / \mu_{n}: n \in B\right\}$ fulfills the conditions of the theorem.

## 8. Converses

Here we prove the converse parts (iii) and (iv) of the Second Main Theorem. We recall that (iii) is the converse to part (i), and (iv) is the converse to part (ii): the proof of the "positive" parts (i) and (ii) has occupied most of this chapter-Sections 1 to 7 above. Here, for convenience, we restate all of the parts (i) to (iv).

Consider an effectively determined (bounded or unbounded) self-adjoint operator $T: H \rightarrow H$. Part (i) asserts that there exists a computable real sequence $\left\{\lambda_{n}\right\}$ such that the spectrum of $T$ coincides with the closure of $\left\{\lambda_{n}\right\}$. The converse part (iii) (Example 1 below) asserts that, given a computable real sequence $\left\{\lambda_{n}\right\}$, we can construct an operator $T$ as above such that closure of $\left\{\lambda_{n}\right\}$ coincides with the spectrum of $T$. We recall that, since the spectral norm of $T$ equals its norm, if the set $\left\{\lambda_{n}\right\}$ is bounded then $T$ is bounded.

Now again consider an effectively determined (bounded or unbounded) selfadjoint operator $T: H \rightarrow H$. Part (ii) asserts that there exists a computable real sequence $\left\{\lambda_{n}\right\}$ and a recursively enumerable set $A$ of natural numbers, such that the set of eigenvalues of $T$ coincides with $\left\{\lambda_{n}: n \notin A\right\}$. The converse part (iv) (Example 2 below) asserts that given $\left\{\lambda_{n}\right\}$ and $A$ as above, we can construct an effectively determined self-adjoint operator $T$ such that the set $\left\{\lambda_{n}: n \notin A\right\}$ coincides with the set of eigenvalues of $T$. When the set $\left\{\lambda_{n}\right\}$ is bounded, the operator $T$ can be chosen to be bounded.

Example 1. Let $\left\{\lambda_{n}\right\}$ be a computable sequence of real numbers. There exists an effectively determined, self-adjoint operator $T$ whose spectrum is the closure of $\left\{\lambda_{n}\right\}$ in $\mathbb{R}$.

Proof. Let $\left\{e_{n}\right\}$ be a computable orthonormal basis for the Hilbert space $H$ (cf. Lemma 7, Section 6 in Chapter 4). In terms of this basis, $T$ is the self-adjoint operator defined by the matrix:

$$
T \sim\left(\begin{array}{cccccc}
\lambda_{0} & & & & & \\
& \lambda_{1} & & & & \\
& & \lambda_{2} & & 0 & \\
& & & \ddots & & \\
& & 0 & & \lambda_{n} & \\
& & & & & \ddots
\end{array}\right) .
$$

This means that $T e_{n}=\lambda_{n} e_{n}$, and the domain of $T$ is the set of all vectors $x=\sum c_{n} e_{n}$ for which both of the sums $\|x\|^{2}=\sum\left|c_{n}\right|^{2}$ and $\|T x\|^{2}=\sum\left|\lambda_{n} c_{n}\right|^{2}$ are finite. It is easy to verify (cf. Riesz and Sz-Nagy [1955]) that $T$, as so defined, is self-adjoint. Since $\left\{\lambda_{n}\right\}$ is computable, the sequence of pairs $\left\{\left\langle e_{n}, T e_{n}\right\rangle\right\}=\left\{\left\langle e_{n}, \lambda_{n} e_{n}\right\rangle\right\}$ is computable and forms an effective generating set for the graph of $T$. Hence $T$ is effectively determined.

The eigenvalues $\lambda_{n} \in \operatorname{spectrum}(T)$, and since spectrum $(T)$ is closed, the closure of $\left\{\lambda_{n}\right\}$ is a subset of spectrum $(T)$. To show that closure $\left\{\lambda_{n}\right\}=\operatorname{spectrum}(T)$, consider any real number $\alpha \notin$ closure $\left\{\lambda_{n}\right\}$. Then the sequence of numbers $\left\{1 /\left(\lambda_{n}-\alpha\right)\right\}$ is bounded. These numbers form the elements of the diagonal matrix for $(T-\alpha I)^{-1}$. Thus $(T-\alpha I)^{-1}$ exists and is bounded. Hence $\alpha \notin \operatorname{spectrum}(T)$. $\square$

Example 2. Let $\left\{\lambda_{n}\right\}$ be a computable sequence of real numbers. Let $A$ be a recursively enumerable set of natural numbers. Then there exists an effectively
determined self-adjoint operator $T$ such that the set of eigenvalues of $T$ coincides with the set $\left\{\lambda_{n}: n \notin A\right\}$. When the sequence $\left\{\lambda_{n}\right\}$ is bounded, the operator $T$ is also bounded.

Here we give the construction only for the case where $\left\{\lambda_{n}\right\}$ is bounded-so that the resulting operator $T$ is also bounded. The extension to unbounded $\left\{\lambda_{n}\right\}$ is purely mechanical. In fact, the construction for unbounded $\left\{\lambda_{n}\right\}$ is identical to that given here. However, the verifications (e.g. that $T$ is self-adjoint) require a number of technicalities associated with unbounded self-adjoint operators. These facts about unbounded operators can be found e.g. in Riesz and Nagy [1955], p. 314. We add that, when $\left\{\lambda_{n}\right\}$ is bounded, these technical difficulties disappear. (We also mention in passing that the example in part (iii) above was done for both the bounded and unbounded case.) Now here is the construction.

Proof for bounded $\left\{\lambda_{n}\right\}$. This construction is an extension of the preceding one, but is a little more complicated. We let $H$ be a countable direct sum of spaces $H_{n}$ isomorphic to $L^{2}[-1,1]$. Let $e_{n m}$ be the function on the $n$-th copy of $L^{2}[-1,1]$ given by $e_{n m}(x)=(1 / \sqrt{2}) e^{\pi i m x}, m=0, \pm 1, \pm 2, \ldots$. Then $\left\{e_{n m}\right\}$ is a computable orthonormal basis for $H$.

As a preliminary step, we begin with the operator $T_{0}$ defined by

$$
T_{0} f=\lambda_{n} f \quad \text { for } f \in H_{n}
$$

Thus, $T_{0}$ restricted to the $n$-th copy of $L^{2}[-1,1]$ coincides with multiplication by the constant $\lambda_{n}$. This makes $\lambda_{n}$ an eigenvalue of $T_{0}$.

The idea behind our construction is that, by perturbing $T_{0} \mid H_{n}$ ever so slightly, we can destroy the eigenvalue $\lambda_{n}$ and replace it by a narrow band of continuous spectrum. This perturbation can come at any stage; the later it comes, the smaller it will be.

We now give the details. Let $a(k)$ be a $1-1$ recursive function which enumerates the set $A$. We start with the operator $T_{0}$ defined above. At the $k$-th stage, we introduce the following perturbation. Let $T_{k}$ denote the operator as it is before the $k$-th stage. Then we define $T_{k+1}$ by:

$$
T_{k+1}=T_{k} \text { on the orthocomplement of } H_{a(k)} \text { in } H .
$$

On $H_{a(k)}$, we change

$$
T_{k}=\text { multiplication by the constant } \lambda_{a(k)}
$$

into

$$
T_{k+1}=\text { multiplication by the function } \lambda_{a(k)}+2^{-k} x .
$$

The resulting operator $T_{k+1}$ on $H_{a(k)}$ has the form:

$$
T_{k+1}[f(x)]=(a+b x) \cdot f(x)
$$

where $a=\lambda_{a(k)}, b=2^{-k} \neq 0$. It is well known and easy to verify that such an operator has only continuous spectrum, and no eigenvalues.
(The spectrum of $T_{k+1}$ on $H_{a(k)}$ coincides with the range of $(a+b x)$ on $[-1,1]$, i.e. with the interval between $\lambda_{a(k)} \pm 2^{-k}$. Thus the eigenvalue $\lambda_{a(k)}$ is replaced by a band of continuous spectrum with a band width of $2 \cdot 2^{-k}$.)

Let $T=\lim T_{k}$. We must verify that the operator $T$ is effectively determined. Since $T$ is bounded, it suffices to show that $\left\{T\left(e_{n m}\right)\right\}$ is computable, where $\left\{e_{n m}\right\}$ is the effective generating set given above. Now it is clear that the triple sequence $\left\{T_{k}\left(e_{n m}\right)\right\}$ is computable in $k, n, m$. Since $\left\|T_{k}-T_{k-1}\right\| \leqslant 2^{-k}$, the operators $T_{k}$ converge uniformly and effectively to $T$ as $k \rightarrow \infty$. Hence by the Limit Axiom $\left\{T\left(e_{n m}\right)\right\}$ is computable. Thus $T$ is effectively determined.

Finally, the eigenvalues of $T$ are precisely the set of $\lambda_{n}$ not destroyed, i.e. $\left\{\lambda_{n}: n \notin A\right\}$. This completes the example and finishes the proof of the Second Main Theorem.

