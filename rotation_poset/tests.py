import subprocess
import os
import sys

SOURCE_FILE = "main.cpp"    
EXECUTABLE = "./test_exec"   
CSV_FILE = "measurements.csv"  
LIBRARY_PATH = "./target/release"
LIBRARY_NAME = "rotation_poset"
LIST_N = [100, 200]
LIST_SEED = [42, 123]
LIST_FUNCTIONS = [0, 1]



def initialization():
    
    if not os.path.exists(EXECUTABLE):
        if not os.path.exists(SOURCE_FILE):
            sys.exit(1)
        try:
            subprocess.run(["cargo", "build", "--release"])
            compile_key = "clang++" if sys.platform == "darwin" else "g++"
            subprocess.run([compile_key, "-O3", SOURCE_FILE, "-L"+LIBRARY_PATH, "-l"+LIBRARY_NAME, "-o", EXECUTABLE], check=True)
        except subprocess.CalledProcessError:
            sys.exit(1)

    if not os.path.exists(CSV_FILE):
        with open(CSV_FILE, "w") as f:
            f.write("Version,N,Seed,Time_ms,PeakMemory_KB\n")

def run_tests():
    if not os.path.exists(EXECUTABLE):
        print(f"Error: {EXECUTABLE} not found.")
        return
    
    env_config = os.environ.copy()
    path_key = "DYLD_LIBRARY_PATH" if sys.platform == "darwin" else "LD_LIBRARY_PATH"
    env_config[path_key] = LIBRARY_PATH

    for n in LIST_N:
        for seed in LIST_SEED:
            for func_id in LIST_FUNCTIONS:
                command = [EXECUTABLE, str(n), str(seed), str(func_id)]
                
                try:
                    subprocess.run(command, check=True, env=env_config, timeout=60) 
                except subprocess.CalledProcessError as e:
                    print(f"Error executing {command}: {e}")

if __name__ == "__main__":
    print(f"Starting benchmark...")
    initialization()
    run_tests()
    print("\nBenchmark completed! Results in 'measurements.csv'.")
