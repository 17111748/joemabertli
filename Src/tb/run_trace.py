"""

run_trace.py
_____________

Use this script to compile and run a simulation. 

    > python3 run_trace.py <options>

Use the -h flag for a list of options

Ex.

    > python3 run_trace.py --num-traces=2 --trace-file=traces/2x2_4bits_2tests.trace --N=2 --in-bitwidth=4 --out-bitwidth=8

"""
import os
import sys
import argparse
import numpy as np

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--num-traces', type=int)
    parser.add_argument('--in-bitwidth', type=int)
    parser.add_argument('--out-bitwidth', type=int)
    parser.add_argument('--trace-file', type=str, default='trace.trace')
    parser.add_argument('--compile', action="store_true")
    parser.add_argument('--N', help="The x and y dimension of the matrices", type=int)
    parser.add_argument('--gui', action="store_true")
    parser.add_argument('--signed', action="store_true")
    args = parser.parse_args()
    return args

def tc(bin_str, bitwidth, signed):
    x = int(bin_str, 2)
    sign = (x & (2 ** (bitwidth - 1))) == (2 ** (bitwidth - 1))
    x_pos = x & (2 ** (bitwidth - 1) - 1)

    if signed:
        return x_pos + (-1 * sign * 2 ** (bitwidth - 1))
    else:
        return x_pos + sign * 2 ** (bitwidth - 1)

def mmm(A, B, bitwidth, signed):
    A = np.array(A)
    B = np.array(B)
    M = np.matmul(A, B)
    M = np.mod(M, 2 ** bitwidth)
    return M

def matrix_eq(A, B):
    A_n = len(A)
    A_m = len(A[0])

    for r in range(A_n):
        for c in range(A_m):
            if A[r][c] != B[r][c]:
                return False

    return True

def print_matrix(A, bitwidth):
    s = '{:' + f'{int(bitwidth / 2)}' + '}'
    print('\n'.join([''.join([s.format(item) for item in row]) 
      for row in A]))

if __name__ == "__main__":
    args = parse_args()

    if(args.compile):
        exit = os.system("vcs -sverilog -debug_all -j4 +warn=all mxu_trace_tb.sv ../tau_mac/*.sv")

        if(exit != 0):
            sys.exit(exit)

    simv_cmd = f"./simv +TRACE={args.trace_file} +NUM_TRACES={args.num_traces}"

    if(args.gui): 
        simv_cmd += " -gui &"
        print("Opening the GUI...")

    os.system(simv_cmd)

    ### Check output ###
    with open('mxu_tb_out.log', "r") as f:
        out_lines = f.readlines()

    with open(args.trace_file, "r") as f:
        in_lines = f.readlines()

    # Gather the inputs and output
    traces = []
    in_count = 0
    out_count = 0
    for t in range(args.num_traces):
        Y = []
        A = []
        B = []
        for r in range(args.N):
            Y.append([])
            A.append([])
            for c in range(args.N):
                Y[r].append(tc(out_lines[out_count], args.out_bitwidth, args.signed))
                A[r].append(tc(in_lines[in_count], args.in_bitwidth, args.signed))
                in_count += 1
                out_count += 1

        for r in range(args.N):
            B.append([])
            for c in range(args.N):
                B[r].append(tc(in_lines[in_count], args.in_bitwidth, args.signed))
                in_count += 1

        print("==================================")
        print(f"Trace:\t{t}")
        print("----------------------------------")
        print("A:")
        print_matrix(A, args.out_bitwidth)
        print("----------------------------------")
        print("B:")
        print_matrix(B, args.out_bitwidth)
        print("----------------------------------")
        print("Output:")
        print_matrix(Y, args.out_bitwidth)

        M = mmm(A, B, args.out_bitwidth, args.signed)

        if(not matrix_eq(M, Y)):
            print("Test failed. Correct output matrix:")
            print_matrix(M, args.out_bitwidth)
            sys.exit(1)

        traces.append({
            'Y': Y,
            'A': A,
            'B': B
        })


    print("All tests passed.")
