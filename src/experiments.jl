#src_link  =  "/scratch/work/belyakn1/BnB_p_lagrangian/src/"
#src_link  =  "/Users/nikitabelyak/Dropbox (Aalto)/branch-and-bound-caroe-and-schultz/src/"
<<<<<<< HEAD

src_link  = "/Users/nikitabelyak/Dropbox (Aalto)/branch-and-bound-caroe-and-schultz/src/"
=======
src_link =  "/Users/Fabricio/Documents/GitHub/BnB_Caroe-and-Schultz/src/"
>>>>>>> c677a3c8d776719e0446ff0fae35d051737fd194

cd(src_link)
using Pkg
Pkg.activate(".")
Pkg.instantiate()

include(src_link*"initialization.jl")

# set unique envinronment for Gurobi
const GRB_ENV = Gurobi.Env()

# check whether th efolder for the "today" experiments exists
# and if not create one
if !isdir(chop(src_link, tail = 4) * "experiments_" * string(Dates.today()))
    mkdir(chop(src_link, tail = 4) * "experiments_" * string(Dates.today()))
end

output_link = chop(src_link, tail = 4) * "experiments_" * string(Dates.today()) * "/"



## Constructing the experiments
# the structure that will collect the experiments results
output_df = DataFrame( num_of_scen = Int[], num_fs_var = Int[], num_ss_var = Int[], num_const = Int[], p_RNMDT = Int[], primal_f = Float64[], primal_x = String[], primal_gap = Float64[], RNMDT_UB = Float64[], RNMDT_x = String[], RNMDT_time = Float64[], RNMDT_wy_gap = Float64[], BnB_UB = Float64[], BnB_LB = Float64[], BnB_x = String[], BnB_time = Float64[], BnB_wy_gap = Float64[], BnB_nodes_explored = Int[] )

<<<<<<< HEAD
scenarios = [5,10,15]
scenarios = [5]
fs_var = [5, 7, 10]
fs_var = [5]
=======
scenarios = [10]
#scenarios = [5]
fs_var = [5]
#fs_var = [5]
>>>>>>> c677a3c8d776719e0446ff0fae35d051737fd194

for s in scenarios
    for i_fs_var in fs_var


        p = -1
        # defining general intial parameters for the optimisation problem
        initial_parameters = initialisation(s,i_fs_var,i_fs_var,i_fs_var, p)

        # generating the structure containing the constraints and objective related parameters
        generated_parameters = parameters_generation(initial_parameters)

        primal_problem = MIP_generation(initial_parameters, generated_parameters)
        optimize!(primal_problem)
        primal_problem_f = objective_value(primal_problem)
        primal_problem_x = string(value.(primal_problem[:x][:,1]))
        primal_problem_optimality_gap = MOI.get(primal_problem, MOI.RelativeGap())

        bnb_g_time = 0
        rnmdt_g_time = 0

            while (bnb_g_time < 3600) && (p >= -5)

                RNMDT_relaxation = RNMDT_based_problem_generation(initial_parameters, generated_parameters)

                if rnmdt_g_time < 15
                    rndmt_init_time = time()
                    optimize!(RNMDT_relaxation)
                    rndmt_final_time = time() - rndmt_init_time
                    rnmdt_g_time += rndmt_final_time
                    rndmt_happened = true
                else
                    rndmt_happened = false
                end

                bnb_p_init_time = time()
                bnb_output = bnb_solve(initial_parameters, non_ant_tol, tol_bb, integrality_tolerance)
                bnb_p_final_time = time() - bnb_p_init_time

                bnb_g_time += bnb_p_final_time

                if rndmt_happened
                    push!(output_df, (s, i_fs_var, i_fs_var, i_fs_var, p, primal_problem_f, primal_problem_x, primal_problem_optimality_gap, objective_value(RNMDT_relaxation), string(value.(RNMDT_relaxation[:x][:,1])), rndmt_final_time, RNMDT_gap_computation( value.(RNMDT_relaxation[:y]), value.(RNMDT_relaxation[:w_RNMDT])), bnb_output.UBDg, bnb_output.LBDg, string(bnb_output.soln_val), bnb_p_final_time, bnb_output.RNMDT_gap_wy, bnb_output.nodes_used))
                else
                    push!(output_df, (s, i_fs_var, i_fs_var, i_fs_var, p, primal_problem_f, primal_problem_x, primal_problem_optimality_gap, 0.0, "NaN", 0.0, 0.0, bnb_output.UBDg, bnb_output.LBDg, string(bnb_output.soln_val), bnb_p_final_time,  bnb_output.RNMDT_gap_wy, bnb_output.nodes_used ))
                end
                p -= 1

                # defining general intial parameters for the optimisation problem
                initial_parameters = initialisation(s,i_fs_var,i_fs_var,i_fs_var,p)

                # generating the structure containing the constraints and objective related parameters
                generated_parameters = parameters_generation(initial_parameters)

                XLSX.writetable(output_link*"experiments"*string(Dates.now())*".xlsx", output_df)
            end

    end

end

XLSX.writetable(output_link*"experiments"*string(Dates.now())*".xlsx", output_df)
