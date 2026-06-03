# Bound proof plan (round l4-cmap-axiom-linearity-bound)

Goal at CMap.lean:809 (2nd `?_` after `refine ⟨aS, dS, ?_, hd_S, ?_⟩`):
```
∀ n m, ‖(s n) - polyApproxCMap aS dS n m‖ ≤ 1 / 2 ^ m
```
where `s n = ∑ k ∈ Finset.range (d n + 1), (coefα (n,k) • x k + coefβ (n,k) • y k)`
(a `C(Set.Icc α β, ℝ)`), `𝕜 = ℝ`.

## In-scope hypotheses (names from the proof body)
- `x y : ℕ → C(Set.Icc α β, ℝ)`; `coefα coefβ : ℕ × ℕ → ℝ`; `d : ℕ → ℕ`.
- `hbnd_X : ∀ n k, ‖x n - polyApproxCMap aX dX n k‖ ≤ 1/2^k`   (fn approx; order f - poly)
- `hbnd_Y : ∀ n k, ‖y n - polyApproxCMap aY dY n k‖ ≤ 1/2^k`
- `hbnd_αR : ∀ p k, |(αR (p,k):ℝ) - coefα (Nat.unpair p)| ≤ 1/2^k`  (order: approx - val)
- `hbnd_βR : ∀ p k, |(βR (p,k):ℝ) - coefβ (Nat.unpair p)| ≤ 1/2^k`
- `hα_le : |α| ≤ (B:ℝ)`, `hβ_le : |β| ≤ (B:ℝ)`
- witness inner: `αR_a αR_b αR_s : ℕ → ℕ`, `h_αR_bne : ∀k, αR_b k ≠ 0`,
  `h_αR_eq : ∀ k, αR(Nat.unpair k) = (-1)^(αR_s k)*(αR_a k / αR_b k)`. (same for βR, and
  aX_a/b/s with h_aX_eq for the flattened triple aX.)
- lets: `M (n,m) = m + (d n + 1) + bound_max n + 2`;
  `dS (n,m) = Nat.rec 0 (fun k acc => max acc (max (dX(k,M)) (dY(k,M)))) ((d n).succ)`;
  `bound_max n = Nat.rec 0 (fun k acc => max acc (stuff_per_k (n,k))) ((d n).succ)`;
  `stuff_per_k (n,k) = bound_x_k k + bound_y_k k + bound_αR_at_0(n,k)+bound_βR_at_0(n,k)+6`;
  `bound_x_k k = Nat.rec 1 (fun j acc => acc + bound_aX_at_0(k,j)*B^j) ((dX(k,0)).succ)`;
  `bound_aX_at_0 (k,j) = aX_a (Nat.pair k (Nat.pair 0 j))`;
  `bound_αR_at_0 (n,k) = αR_a (Nat.pair (Nat.pair n k) 0)`;
  `pad_X (k,M) j = bif decide (j ≤ dX (k,M)) then aX(k,M,j) else 0`.

## Math (verified on paper; factor-4 slack)
Set MM := M(n,m). For k ≤ d n: dS(n,m) ≥ dX(k,MM) and ≥ dY(k,MM).

1. polyApproxCMap aS dS n m x_ = Σ_{k≤dn} (αR(nk,MM)·pXk(x_) + βR(nk,MM)·pYk(x_))
   where pXk = polyApproxCMap aX dX k MM, pYk = polyApproxCMap aY dY k MM.
   [Rat.cast_sum, sum_mul, sum_comm, mul distribute, padcoeff identity via sum_subset.]
2. s n x_ = Σ_{k≤dn} (coefα(n,k)·(x k) x_ + coefβ(n,k)·(y k) x_).  [coe_sum/sum_apply,
   add_apply, smul_apply, smul_eq_mul.]
3. diff = Σ_k [(coefα·xk - αR·pXk) + (coefβ·yk - βR·pYk)](x_).  [sum_sub_distrib + regroup.]
4. |diff| ≤ Σ_k (|coefα·xk(x_) - αR·pXk(x_)| + |coefβ·yk(x_) - βR·pYk(x_)|). [abs_sum_le_sum_abs
   then split add.]
5. per-k X: add/sub coefα·pXk(x_):
   |coefα·(xk-pXk)(x_)| + |(coefα-αR)·pXk(x_)|
   = |coefα|·|xk(x_)-pXk(x_)| + |coefα-αR|·|pXk(x_)|
   ≤ |coefα|·2^-MM       (|xk(x_)-pXk(x_)| ≤ ‖xk-pXk‖ ≤ 2^-MM via norm_coe_le_norm + hbnd_X)
     + 2^-MM·|pXk(x_)|    (hbnd_αR at MM; note order |αR-coefα|, abs_sub_comm)
   |coefα(n,k)| ≤ bound_αR_at_0(n,k)+1   (hbnd_αR at 0: |αR(nk,0)-coefα|≤1, |αR(nk,0)|≤a)
   |pXk(x_)| ≤ bound_x_k k + 1            (≤ ‖xk‖ + 2^-MM, and ‖xk‖ ≤ bound_x_k k ... see NOTE)
   ⇒ X-term ≤ 2^-MM·(bound_αR_at_0(n,k)+1) + 2^-MM·(bound_x_k k + 1)
            = 2^-MM·(bound_x_k k + bound_αR_at_0(n,k) + 2).
   Y similarly ≤ 2^-MM·(bound_y_k k + bound_βR_at_0(n,k) + 2).
   sum ≤ 2^-MM·stuff_per_k(n,k)   (since +4 ≤ +6).
6. Σ_k ≤ (d n+1)·2^-MM·bound_max(n)   (stuff_per_k(n,k) ≤ bound_max(n) for k≤dn, rec_max_ge;
   sum_le_sum; sum_const = card·c).
7. close: 2^-MM = 2^-m·2^-(dn+1)·2^-bound_max·2^-2;
   (dn+1)·2^-(dn+1) ≤ 1, bound_max·2^-bound_max ≤ 1, 2^-2=1/4 ⇒ ≤ 2^-m·(1/4) ≤ 2^-m.

NOTE on |pXk(x_)| ≤ bound_x_k k + 1:
  pXk = polyApproxCMap aX dX k MM. We DON'T bound its coeffs directly (they're at precision
  MM, but bound_x_k uses precision 0). Instead:
  |pXk(x_)| ≤ |(x k) x_| + |(x k) x_ - pXk(x_)| ≤ ‖x k‖ + 2^-MM.
  And ‖x k‖ ≤ ‖polyApproxCMap aX dX k 0‖ + ‖x k - poly..0‖ ≤ ‖poly..0‖ + 1 (hbnd_X k 0).
  ‖polyApproxCMap aX dX k 0‖ = sup_x |Σ_{j≤dX(k,0)} aX(k,0,j)·x^j| ≤ Σ_j |aX(k,0,j)|·|x|^j
    ≤ Σ_j |aX(k,0,j)|·B^j  (|x.val|≤max(|α|,|β|)≤B via Set.Icc + hα_le,hβ_le; need B≥0... B:ℕ ok)
    ≤ Σ_j bound_aX_at_0(k,j)·B^j  (abs_q_le)  ≤ bound_x_k k - 1.
  So ‖x k‖ ≤ (bound_x_k k - 1) + 1 = bound_x_k k. Then |pXk(x_)| ≤ bound_x_k k + 2^-MM
    ≤ bound_x_k k + 1.
  ⇒ this is the most involved sub-bound. Needs: sup over Set.Icc, |x.val|≤B, abs_q_le per j.

## Helpers (top-level, before the def; pure)
- `rec_max_ge (f:ℕ→ℕ) (N k:ℕ) : k < N → f k ≤ Nat.rec 0 (fun j a => max a (f j)) N`  [ind N]
- `abs_q_cast_le (a b s : ℕ) : b ≠ 0 → |((-1:ℚ)^s*(a/b) : ℝ)| ≤ (a:ℝ)` (or ℚ-level then cast)
- `mul_two_pow_neg_le_one`? Actually want: (t:ℝ)/2^t ≤ 1, i.e. (t:ℝ) ≤ 2^t. Mathlib:
  `Nat.lt_two_pow : n < 2^n` ⇒ (n:ℝ) ≤ 2^n. Use cast.

## Implementation order (sorry-stub skeleton first, then fill)
1. Add top-level helpers.
2. After 2nd bullet `· intro n m`: set MM, prove `hdS_ge`, `hstuff_le` (rec_max_ge instances).
3. `have hpoly_expand`, `have hs_eval`, then reduce-to-pointwise, then per-k bound `have`,
   then Σ_k + close. Stub each big `have` with sorry; confirm skeleton type-checks; fill.
```
