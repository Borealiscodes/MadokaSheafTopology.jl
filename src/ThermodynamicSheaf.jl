module ThermodynamicSheaf

using LinearAlgebra
using StaticArrays

export StalkState, SheafEdge, MadokaSheaf
export coboundary, sheaf_laplacian, dirichlet_energy
export verify_thermodynamic_law, apply_law_of_cycles, rebellion_isolation_surgery

"""
    StalkState
4D static state vector on each 0-cell (Magical Girl / Witch / Incubator node):
  1. H     : Hope / Karmic potential
  2. D     : Despair / Curse accumulation
  3. R     : Soul Gem structural purity / Resolve
  4. S_ent : Thermodynamic entropy exported to universe
"""
const StalkState = SVector{4, Float64}

struct SheafEdge
    src::Int
    dst::Int
    F_src::SMatrix{4, 4, Float64, 16}   # Restriction map F_{src ◁ e}
    F_dst::SMatrix{4, 4, Float64, 16}   # Restriction map F_{dst ◁ e}
    loop_weight::Float64                # Karmic amplification across Homura timeline resets
end

struct MadokaSheaf
    n_vertices::Int
    edges::Vector{SheafEdge}
    d_break::Float64                    # Witch transformation threshold (from Spectral Labyrinth)
    tikhonov_lambda::Float64            # A7.2 CollapseSurfaceRepairPipeline clamping (0.0015)
end

"""
    coboundary(sheaf::MadokaSheaf, x::Vector{StalkState}) -> Vector{StalkState}
Computes the 0-coboundary (δ⁰x)_e = F_{src◁e}(x_src) - F_{dst◁e}(x_dst).
Global sections H⁰(X; F) satisfy δ⁰x = 0.
"""
function coboundary(sheaf::MadokaSheaf, x::Vector{StalkState})::Vector{StalkState}
    out = Vector{StalkState}(undef, length(sheaf.edges))
    @inbounds for (i, e) in enumerate(sheaf.edges)
        out[i] = e.loop_weight * (e.F_src * x[e.src] - e.F_dst * x[e.dst])
    end
    return out
end

"""
    dirichlet_energy(sheaf::MadokaSheaf, x::Vector{StalkState}) -> Float64
Measures total sheaf frustration / topological obstruction energy E(x) = 1/2 ||δ⁰x||².
Non-zero minimum energy on a closed loop indicates non-trivial cohomology H¹(X; F) != 0.
"""
function dirichlet_energy(sheaf::MadokaSheaf, x::Vector{StalkState})::Float64
    dx = coboundary(sheaf, x)
    acc = 0.0
    @inbounds for v in dx
        acc += dot(v, v)
    end
    return 0.5 * acc
end

"""
    verify_thermodynamic_law(before::Vector{StalkState}, after::Vector{StalkState}, harvested_work::Float64) -> Bool
Enforces First & Second Laws of Thermodynamics across a Magical Girl -> Witch phase transition:
  - Total energy (H - D - harvested_work) is conserved within machine tolerance.
  - Total universe entropy ∑ S_ent is monotonically non-decreasing (ΔS_total >= 0).
"""
function verify_thermodynamic_law(
    before::Vector{StalkState},
    after::Vector{StalkState},
    harvested_work::Float64;
    atol::Float64 = 1e-10
)::Bool
    E_before = sum(s[1] - s[2] for s in before)
    E_after  = sum(s[1] - s[2] for s in after) + harvested_work

    S_before = sum(s[4] for s in before)
    S_after  = sum(s[4] for s in after)

    first_law_ok  = isapprox(E_before, E_after; atol=atol)
    second_law_ok = (S_after - S_before) >= -atol
    return first_law_ok && second_law_ok
end

"""
    apply_law_of_cycles(sheaf::MadokaSheaf, x::Vector{StalkState}) -> Vector{StalkState}
Global Sheafification Functor (Madoka's Ascension):
Intercepts any node reaching D >= d_break, annihilates despair (D -> 0), converts
karmic potential into exported entropy, and prevents Witch 2-cell formation.
"""
function apply_law_of_cycles(sheaf::MadokaSheaf, x::Vector{StalkState})::Vector{StalkState}
    y = similar(x)
    @inbounds for i in eachindex(x)
        H, D, R, S_ent = x[i]
        if D >= sheaf.d_break
            # Despair is absorbed by the Law of Cycles; entropy is discharged cleanly
            y[i] = StalkState(0.0, 0.0, 1.0, S_ent + D)
        else
            y[i] = x[i]
        end
    end
    return y
end

"""
    rebellion_isolation_surgery(
        sheaf::MadokaSheaf,
        x::Vector{StalkState},
        homura_idx::Int,
        madoka_idx::Int
    ) -> Tuple{MadokaSheaf, Vector{StalkState}, Float64}

Universal Edge Case (Madoka Magica: Rebellion):
  1. Incubator Isolation Field severs restriction maps to the Law of Cycles (F -> 0),
     creating a rank-deficient collapse surface (σ_min -> 0+).
  2. Applies A7.2 Tikhonov clamping (λ = 0.0015) + atanh contraction to prevent pole blowup.
  3. Executes Akuma Homura sheaf-splitting: pins a twisted holonomy edge (sign flip on H/D
     coupling) between Homura and Madoka so H¹ != 0 holds in metastable equilibrium without
     Witch 2-cell collapse.
Returns (twisted_sheaf, stabilized_states, min_singular_value).
"""
function rebellion_isolation_surgery(
    sheaf::MadokaSheaf,
    x::Vector{StalkState},
    homura_idx::Int,
    madoka_idx::Int
)
    λ = sheaf.tikhonov_lambda
    ϵ = 1e-7

    # Step 1: Sever edges touching the Law of Cycles (simulate Incubator Isolation Field)
    # and apply A7.2 Tikhonov regularization + atanh contraction to prevent singular poles
    new_edges = SheafEdge[]
    min_sigma = Inf

    for e in sheaf.edges
        if e.src == madoka_idx || e.dst == madoka_idx
            # Severed restriction map -> rank-deficient collapse surface (σ_min -> 0+)
            # Regularize via A7.2 Tikhonov shift (λ = 0.0015)
            F_reg = Matrix{Float64}(λ * I, 4, 4)
            sv = svdvals(F_reg)
            min_sigma = min(min_sigma, minimum(sv))

            # Construct Akuma Homura twisted restriction map (preserves human Madoka stalk
            # while trapping curse energy inside Homura's Dark Orb containment)
            twist = SMatrix{4, 4, Float64, 16}(
                1.0,  0.0, 0.0, 0.0,
                0.0, -1.0, 0.0, 0.0,   # Inversion of Despair flow (Horizon Inversion)
                0.0,  0.0, 1.0, 0.0,
                0.0,  0.0, 0.0, 1.0
            )
            push!(new_edges, SheafEdge(e.src, e.dst, SMatrix{4,4,Float64,16}(F_reg), twist, e.loop_weight))
        else
            # Stabilize interior labyrinth restriction maps via atanh spectral contraction
            U, S, Vt = svd(Matrix(e.F_src))
            S_clamped = clamp.(S, λ, 1.0 - ϵ)
            min_sigma = min(min_sigma, minimum(S_clamped))
            F_contracted = SMatrix{4, 4, Float64, 16}(U * Diagonal(atanh.(S_clamped)) * Vt)
            push!(new_edges, SheafEdge(e.src, e.dst, F_contracted, e.F_dst, e.loop_weight))
        end
    end

    # Step 2: Update Homura's stalk to contain the Dark Orb curse load while keeping R > 0
    y = copy(x)
    H_h, D_h, R_h, S_h = y[homura_idx]
    y[homura_idx] = StalkState(H_h, D_h, max(R_h, λ), S_h)

    twisted_sheaf = MadokaSheaf(sheaf.n_vertices, new_edges, sheaf.d_break, λ)
    return twisted_sheaf, y, min_sigma
end

end # module
