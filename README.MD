# 🌌 MadokaSheafTopology.jl

**Thermodynamically Consistent, Entropy-Accurate Cellular Sheaf & Algebraic Topology of the *Puella Magi Madoka Magica* Universe (with *Rebellion* as Universal Edge Case)**

[![License: MIT](https://shields.io)](LICENSE)
[![Julia 1.10+](https://shields.io)](https://julialang.org)
[![Altitude: A3–A7.2](https://shields.io)](#altitude-map)

---

## ⚠️ Epistemic Statement, Scope & Non-Activation Clause

1. **Closed-World Fictional Corpus Benchmark:** This repository models the internal narrative physics of *Puella Magi Madoka Magica* and *The Rebellion Story* as a closed-world topological stress test for cellular sheaf cohomology, thermodynamic accounting, and rank-deficient collapse repair.
2. **Pure Systems & Mathematical Scope:** All stalks (`Hope`, `Despair`, `Purity`, `Entropy`), coboundary operators (δ⁰), and Tikhonov regularizers (λ = 0.0015) operate strictly as formal real-vector and algebraic-topological objects (`StaticArrays`). They carry zero clinical, diagnostic, or autonomous runtime activation authority.
3. **Mathematical Honesty Constraint:** When an Incubator Isolation Field severs global restriction maps (\(\sigma_{\min} \to 0^+\)), A7.2 Tikhonov clamping and \(\operatorname{atanh}\) contraction restore numerical invertibility and prevent singular pole blowup—they do not erase historical karmic holonomy (H¹ ≠ 0).

---

## 1. Overview & Cross-Repository Integration

`MadokaSheafTopology.jl` unifies five diagnostic and geometric primitives from the `Borealiscodes` ecosystem into a zero-allocation native Julia package:

* **CW-Complex & Phenomenological Tiles (`NDH-Core/engine/madoka-tests`):** Maps entities (`Madoka`, `Homura`, `Sayaka`, `Mami`, `Kyoko`, `Kyubey`) to 0-cells, causal transitions and timeline resets to 1-cells, and Witch Labyrinths to 2-cells.
* **Labyrinth Curvature Substrate (`Spectral_Labyrinth_Engine_v1_0.md`):** Parameterizes spatial distortion \(d_{\text{eff}}\), despair accumulation \(\Delta D_i\), hope dampening \(k_{\text{eff}}\), and the Witch phase-transition threshold \(D_{\text{break}}\).
* **Exact-Rational Wiki Ingestion (`mediawiki-audit-mcp`):** Ingests canonical timeline graphs via `BigInt` fractions (p/q) with SHA-256 provenance receipts (`berne-provenance-v2.0`) before projecting into stack-allocated `SVector{4, Float64}` stalks.
* **Zero-Allocation Differential Geometry (`ManifoldPerturbationInstruments.jl`):** Uses `StaticArrays` (`SVector{4}`, `SMatrix{4,4}`) to compute cellular sheaf coboundaries (δ⁰), Dirichlet frustration energy \(\frac{1}{2}\Vert{}\delta^0 \mathbf{x}\Vert{}^2\), and path-ordered timeline loop holonomy (\(\mathcal{P}\exp \oint_\gamma \Gamma\,dx\)).
* **Collapse-Surface Surgery (`A7.2-CollapseSurfaceRepairPipeline`):** Handles the *Rebellion* universal edge case via λ = 0.0015 Tikhonov regularization and \(\operatorname{atanh}\) spectral contraction across rank-deficient isolation boundaries.

---

## 2. Altitude Map (A3–A7.2 Operational Scope)

| Altitude | Domain | Mathematical State | Module / Operation |
| :--- | :--- | :--- | :--- |
| **A0** | Provenance | 64-char SHA-256 receipts & exact p/q `BigInt` fractions | `WikiIngestionBridge.jl` |
| **A3–A4** | Cellular Sheaf & Thermodynamics | Stack-allocated stalks \(\mathcal{F}(v) \in \mathbb{R}^4\), coboundary δ⁰, First & Second Law checks | `ThermodynamicSheaf.jl` |
| **A6** | Global Sheafification | Law of Cycles quotient functor (\(\mathcal{F} \to \mathcal{F}^+\)) clearing \(D_v \ge D_{\text{break}}\) | `apply_law_of_cycles` |
| **A7** | Collapse Surface (Σ) | Incubator Isolation Field severs restriction maps (\(\sigma_{\min} \to 0^+\)) | `rebellion_isolation_surgery` |
| **A7.2** | Twisted Holonomy Equilibrium | Tikhonov clamping (λ = 0.0015), \(\operatorname{atanh}\) contraction, & *Akuma Homura* \(\mathbb{Z}_2\) twist (H¹ ≠ 0) | `rebellion_isolation_surgery` |

---

## 3. Repository Structure

```text
MadokaSheafTopology.jl/
├── Project.toml                         # Package manifest (StaticArrays, LinearAlgebra, SparseArrays, Test)
├── src/
│   ├── MadokaSheafTopology.jl           # Top-level module exports & Mitakihara CW-complex builder
│   ├── ThermodynamicSheaf.jl            # 4D stalks, coboundary δ⁰, Dirichlet energy, Law of Cycles & Rebellion surgery
│   └── WikiIngestionBridge.jl           # Exact p/q rational parser & NDH madoka-tests markdown tile loader
├── test/
│   └── runtests.jl                      # Automated @test verification suite (H¹ energy, 1st/2nd Law, Rebellion)
├── docs/
│   └── tex/                             # Modular LaTeX mathematical specifications (Phase 3)
│       ├── 01-CellComplex-And-Loop-Holonomy.tex
│       ├── 02-Thermodynamic-Sheaf-Conservation.tex
│       └── 03-Rebellion-Collapse-Surface-Surgery.tex
├── LICENSE                              # MIT License
└── README.md                            # System specification & epistemic charter
```

---

## 4. Quickstart & Verification

Run the zero-allocation verification suite locally with Julia 1.10+:

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.test()'
```

### Example Usage

```julia
using MadokaSheafTopology

# 1. Construct the 6-node Mitakihara complex after 100 timeline resets
sheaf, states = build_mitakihara_complex(loops = 100, d_break = 10.0)

# 2. Measure topological frustration energy (H¹ loop holonomy)
println("Initial Dirichlet Energy: ", dirichlet_energy(sheaf, states))

# 3. Apply Global Sheafification (Law of Cycles)
purified_states = apply_law_of_cycles(sheaf, states)

# 4. Execute the Rebellion Universal Edge Case (Incubator Isolation + Akuma Homura Z₂ Twist)
twisted_sheaf, stabilized_states, min_sigma = rebellion_isolation_surgery(
    sheaf, states, 2, 1
)
println("Post-Surgery Minimum Singular Value (σ_min >= 0.0015): ", min_sigma)
println("Twisted Bundle Dirichlet Energy (H¹ != 0): ", dirichlet_energy(twisted_sheaf, stabilized_states))
```

---

## 5. Provenance & Licensing

* **Author & Maintainer:** Borealis Serenity Hedling (`NDH-RESEARCH-PILOT` · Dublin, Ireland)
* **License:** MIT License
