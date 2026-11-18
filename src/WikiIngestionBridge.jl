module WikiIngestionBridge

using LinearAlgebra
using StaticArrays
using ..ThermodynamicSheaf

export RationalTuple, AuditIngestNode, AuditIngestEdge
export parse_exact_rational, load_mcp_audit_payload, parse_madoka_test_tile

"""
    RationalTuple
Exact rational p/q representation preserving BigInt fractions emitted by
mediawiki-audit-mcp (src/graph-engine.mjs) before projection into Float64 stalks.
"""
struct RationalTuple
    num::BigInt
    den::BigInt
end

struct AuditIngestNode
    id::String
    hope_pq::RationalTuple
    despair_pq::RationalTuple
    purity_pq::RationalTuple
    entropy_pq::RationalTuple
    provenance_sha256::String
end

struct AuditIngestEdge
    src_id::String
    dst_id::String
    loop_count::Int
    relation_type::String   # e.g. "karmic_loop", "grief_transfer", "isolation_cut"
end

"""
    parse_exact_rational(s::AbstractString) -> RationalTuple

Parses an exact rational string "p/q" or integer "p" from mediawiki-audit-mcp
without intermediate IEEE-754 floating-point loss.
"""
function parse_exact_rational(s::AbstractString)::RationalTuple
    cleaned = strip(s)
    if occursin('/', cleaned)
        parts = split(cleaned, '/')
        length(parts) == 2 || throw(ArgumentError("Invalid rational format: $s"))
        p = parse(BigInt, strip(parts[1]))
        q = parse(BigInt, strip(parts[2]))
        q != 0 || throw(DivideError())
        g = gcd(p, q)
        p_red = div(p, g)
        q_red = div(q, g)
        if q_red < 0
            p_red = -p_red
            q_red = -q_red
        end
        return RationalTuple(p_red, q_red)
    else
        return RationalTuple(parse(BigInt, cleaned), BigInt(1))
    end
end

@inline function _to_float64(r::RationalTuple)::Float64
    return Float64(r.num) / Float64(r.den)
end

"""
    load_mcp_audit_payload(
        nodes::Vector{AuditIngestNode},
        edges::Vector{AuditIngestEdge};
        d_break::Float64 = 10.0,
        tikhonov_lambda::Float64 = 0.0015
    ) -> Tuple{MadokaSheaf, Vector{StalkState}, Dict{String, Int}}

Converts validated mediawiki-audit-mcp graph records into a zero-allocation
MadokaSheaf complex. Enforces non-empty SHA-256 provenance digests on every node.
"""
function load_mcp_audit_payload(
    nodes::Vector{AuditIngestNode},
    edges::Vector{AuditIngestEdge};
    d_break::Float64 = 10.0,
    tikhonov_lambda::Float64 = 0.0015
)
    index_map = Dict{String, Int}()
    states = Vector{StalkState}(undef, length(nodes))

    for (idx, node) in enumerate(nodes)
        length(strip(node.provenance_sha256)) == 64 ||
            throw(ArgumentError("Node '$(node.id)' missing 64-char SHA-256 provenance receipt"))

        index_map[node.id] = idx
        states[idx] = StalkState(
            _to_float64(node.hope_pq),
            _to_float64(node.despair_pq),
            _to_float64(node.purity_pq),
            _to_float64(node.entropy_pq),
        )
    end

    id4 = SMatrix{4, 4, Float64, 16}(1.0I)
    sheaf_edges = SheafEdge[]

    for e in edges
        haskey(index_map, e.src_id) || throw(KeyError(e.src_id))
        haskey(index_map, e.dst_id) || throw(KeyError(e.dst_id))

        src_idx = index_map[e.src_id]
        dst_idx = index_map[e.dst_id]
        weight = 1.0 + log(Float64(max(1, e.loop_count)))

        if e.relation_type == "isolation_cut"
            # Incubator Isolation Field severs restriction map to rank-deficient floor
            F_cut = SMatrix{4, 4, Float64, 16}(tikhonov_lambda * I)
            push!(sheaf_edges, SheafEdge(src_idx, dst_idx, F_cut, id4, weight))
        else
            push!(sheaf_edges, SheafEdge(src_idx, dst_idx, id4, id4, weight))
        end
    end

    sheaf = MadokaSheaf(length(nodes), sheaf_edges, d_break, tikhonov_lambda)
    return sheaf, states, index_map
end

"""
    parse_madoka_test_tile(filepath::AbstractString) -> Dict{String, String}

Lightweight zero-dependency parser for NDH-Core/engine/madoka-tests/*.md tiles.
Extracts key-value metadata lines (e.g., `- **Name:** ...`, `- **Altitude:** ...`)
so diagnostic tiles can be cross-checked against sheaf invariants.
"""
function parse_madoka_test_tile(filepath::AbstractString)::Dict{String, String}
    isfile(filepath) || throw(SystemError("Tile file not found: $filepath"))
    meta = Dict{String, String}()

    for line in eachline(filepath)
        m = match(r"^\s*-\s*\*\*([^*:]+):\*\*\s*(.+)$", line)
        if m !== nothing
            key = lowercase(replace(strip(m.captures[1]), r"\s+" => "_"))
            val = strip(m.captures[2])
            meta[key] = val
        end
    end
    return meta
end

end # module
