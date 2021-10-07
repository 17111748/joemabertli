import argparse
import random

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--rows', type=int)
    parser.add_argument('--cols', type=int)
    parser.add_argument('--num-traces', type=int)
    parser.add_argument('--bit-width', type=int, default=4)
    parser.add_argument('--trace-file', type=str, default='trace.trace')
    args = parser.parse_args()
    return args

def to_bin(x, args):
    return format(x & int("1" * args.bit_width, 2), '0' + str(args.bit_width) + 'b')

if __name__ == "__main__":
    args = parse_args()
    
    # Generate the input matrices
    traces = []

    for t in range(args.num_traces):
        A = []
        B = []
        for r in range(args.rows):
            A.append([])
            B.append([])
            for c in range(args.cols):
                min_val = -1 * (2 ** (args.bit_width - 1))
                max_val = 2 ** args.bit_width - 1
                A[r].append(to_bin(random.randint(min_val, max_val), args))
                B[r].append(to_bin(random.randint(min_val, max_val), args))

        traces.append({
            'A': A,
            'B': B
        })

    # Write matrices to file, in row-major order
    with open(args.trace_file, 'w') as f:
        for t in traces:
            A = t['A']
            B = t['B']

            for r in range(args.rows):
                for c in range(args.cols):
                    f.write(A[r][c] + '\n')

            for r in range(args.rows):
                for c in range(args.cols):
                    f.write(B[r][c] + '\n')

    print("Trace file successfully generated")






