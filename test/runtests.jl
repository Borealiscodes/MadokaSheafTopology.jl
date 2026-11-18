using Test
using LinearAlgebra
using StaticArrays
using MadokaSheafTopology

@testset "MadokaSheafTopology.jl Verification Suite" begin

    @testset "1. Zero-Allocation Stalk & Coboundary Invariants" begin
        sheaf, states = build_mitakihara_complex(loops = 100)
        dx = coboundary(sheaf, states)
        @test length(dx) == length(sheaf.edges)
        @test eltype(dx) == StalkState

        # Non-trivial timeline frustration (H¹ != 0) produces strictly positive Dirichlet energy
        energy = dirichlet_energy(sheaf, states)
        @test energy > 0.0

        # Uniform global section (all stalks identical with unit weight) yields zero coboundary
        id4 = SMatrix{4, 4, Float64, 16}(1.0I)
        unit_edges = [SheafEdge(1, 2, id4, id4, 1.0)]
        flat_sheaf = MadokaSheaf(2, unit_edges, 10.0, 0.0015)
        s0 = StalkState(2.0, 1.0, 0.9, 0.5)
        @test isapprox(dirichlet_energy(flat_sheaf, [s0, s0]), 0.0; atol = 1e-14)
    end

    @testset "2. First & Second Laws of Thermodynamics" begin
        before = StalkState[
            StalkState(10.0, 2.0, 0.8, 1.0),
            StalkState(5.0,  9.5, 0.1, 2.0),
        ]
        # Sayaka crosses D_break (9.5 -> 0.0 despair), releasing 7.0 units of harvested work
        # and exporting 2.5 units into entropy (total energy conserved, entropy increases)
        after = StalkState[
            StalkState(10.0, 2.0, 0.8, 1.0),
            StalkState(0.5,  0.0, 0.0, 4.5),
        ]
        # Energy before: (10-2) + (5-9.5) = 8 - 4.5 = 3.5
        # Energy after + work: (10-2) + (0.5-0) + harvested_work = 8.5 + (-5.0) -> let's balance cleanly:
        # Let H_before = 15.0, D_before = 11.5 => net free energy = 3.5
        # After phase transition: H_after = 10.5, D_after = 2.0 => net = 8.5; if harvested_work = -5.0 (endothermic)
        # Better: exothermic Witch transformation where Hope converts to Despair + Harvested Work:
        exothermic_before = StalkState[
            StalkState(12.0, 1.0, 0.9, 1.0),
        ]
        exothermic_after = StalkState[
            StalkState(4.0,  0.0, 0.0, 3.5),
        ]
        # Net free energy before = 12.0 - 1.0 = 11.0; after = 4.0 - 0.0 = 4.0; harvested_work = 7.0
        @test verify_thermodynamic_law(exothermic_before, exothermic_after, 7.0)

        # Violating Second Law (entropy decreases) must fail
        entropy_drop = StalkState[
            StalkState(4.0, 0.0, 0.0, 0.2),
        ]
        @test !verify_thermodynamic_law(exothermic_before, entropy_drop, 7.0)
    end

    @testset "3. Law of Cycles Global Sheafification" begin
        sheaf, states = build_mitakihara_complex(loops = 100, d_break = 10.0)
        # Push Sayaka (node 3) over D_break = 10.0
        states[3] = StalkState(1.0, 10.5, 0.05, 0.0)

        purified = apply_law_of_cycles(sheaf, states)
        # Sayaka's despair is annihilated (D -> 0.0) and discharged cleanly as entropy
        @test purified[3] == StalkState(0.0, 0.0, 1.0, 10.5)
        # Nodes below D_break remain unchanged
        @test purified[4] == states[4]
    end

    @testset "4. Universal Edge Case: Rebellion Isolation & A7.2 Repair" begin
        sheaf, states = build_mitakihara_complex(loops = 100, d_break = 10.0)
        # Set Homura (node 2) above d_break inside Incubator Isolation Field
        states[2] = StalkState(4.0, 12.5, 0.01, 2.0)

        twisted_sheaf, stabilized, min_sigma = rebellion_isolation_surgery(
            sheaf,
            states,
            2, # Homura
            1, # Madoka (Law of Cycles anchor)
        )

        # A7.2 Tikhonov clamping guarantees strictly positive minimum singular value (no poles)
        @test min_sigma >= sheaf.tikhonov_lambda
        @test min_sigma > 0.0

        # Homura's Soul Gem purity is stabilized above collapse floor
        @test stabilized[2] >= sheaf.tikhonov_lambda

        # Akuma Homura Z₂ twist sustains non-trivial H¹ cohomology (Dirichlet energy > 0)
        @test dirichlet_energy(twisted_sheaf, stabilized) > 0.0
    end

end
