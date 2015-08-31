function kl = PointKL(p,q)
% pointwise kl divergence
kl = p.*log2(p./q);