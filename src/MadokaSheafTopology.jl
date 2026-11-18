module MadokaSheafTopology

using LinearAlgebra
using SparseArrays
using StaticArrays

include("ThermodynamicSheaf.jl")
using .ThermodynamicSheaf

export StalkState, SheafEdge, MadokaSheaf
export coboundary, dirichlet_energy
export verify_thermodynamic_law, apply_law_of_cycles, rebellion_isolation_surgery
export build_mitakihara_complex

"""
    build_mitakihara_complex(; loops::Int = 100, d_break::Float64 = 10.0) -> Tuple{MadokaSheaf, Vector{StalkState}}

Constructs the canonical 5-node Mitakihara CW-complex + Incubator sink:
  1: Madoka Kaname (Karmic focal node / Law of Cycles anchor)
  2: Homura Akemi  (Time-loop holonomy carrier across `loops` resets)
  3: Sayaka Miki   (High-sensitivity despair gradient node -> Oktavia)
  4: Mami Tomoe    (Structural mentor / baseline stability node)
  5: Kyoko Sakura  (Independent conservation / damping node)
  6: Kyubey        (Incubator thermodynamic entropy sink)
"""
function build_mitakihara_complex(; loops::Int = 100, d_break::Float64 = 10.0)
    id4 = SMatrix{4, 4, Float64, 16}(1.0I)

    # Karmic amplification scales logarithmically with Homura's timeline resets
    karmic_gain = 1.0 + log(Float64(max(1, loops)))

    edges = SheafEdge[
        # Homura -> Madoka causal loop edge (carries accumulated karmic holonomy)
        SheafEdge(2, 1, id4, id4, karmic_gain),
        # Madoka <-> Sayaka resonance edge
        SheafEdge(1, 3, id4, id4, 1.0),
        # Mami <-> Madoka mentorship edge
        SheafEdge(4, 1, id4, id4, 1.0),
        # Kyoko <-> Sayaka counterweight edge
        SheafEdge(5, 3, id4, id4, 1.0),
        # Sayaka -> Kyubey entropy export edge
        SheafEdge(3, 6, id4, id4, 1.0),
    ]

    # Initial StalkStates: (H: Hope, D: Despair, R: Soul Gem Purity, S_ent: Entropy)
    states = StalkState[
        StalkState(5.0 * karmic_gain, 0.5, 0.95, 0.0),  # 1: Madoka
        StalkState(4.0,               6.5, 0.60, 0.0),  # 2: Homura
        StalkState(3.0,               9.8, 0.15, 0.0),  # 3: Sayaka (near D_break = 10.0)
        StalkState(3.5,               2.0, 0.85, 0.0),  # 4: Mami
        StalkState(3.2,               3.0, 0.80, 0.0),  # 5: Kyoko
        StalkState(0.0,               0.0, 1.00, 1.0),  # 6: Kyubey
    ]

    sheaf = MadokaSheaf(6, edges, d_break, 0.0015)
    return sheaf, states
end

end # module
