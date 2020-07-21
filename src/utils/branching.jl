"""
    branching(N::node, avg_x::Array{Float64}, variable_index::Int)
returns the child nodes generated from the parent node N where
avg_x is the vector of averaged values of the decision variables
generated by solving the dual problem and variable_index is the index
of the coordinate based on which child nodes are generated
"""
function branching(N::node, avg_x::Array{Float64}, variable_index::Int)

    l_node_value = floor(Int64, avg_x[variable_index])
    r_node_value = l_node_value + 1
    l_node = child_node_generation(N, variable_index, "<=", l_node_value)
    r_node = child_node_generation(N, variable_index, ">=", r_node_value)

    return l_node, r_node

end
