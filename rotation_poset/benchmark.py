import subprocess
import os
import sys

SOURCE_FILE = "benchmark.cpp"    
EXECUTABLE = "benchmark_exec"   
CSV_FILE = "measurements_mac.csv"  
LIBRARY_PATH = "target/release"
LIBRARY_NAME = "rotation_poset"
LIST_N = [100, 200, 400, 800]#, 1600, 3200, 6400]
LIST_SEED = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]


def initialization():
    
    if not os.path.exists(SOURCE_FILE):
        sys.exit(1)
    try:
        subprocess.run(["cargo", "build", "--release"], check=True)
        print("Library compiled successfully.")
        compile_key = "clang++" if sys.platform == "darwin" else "g++"
        subprocess.run([compile_key, "-O3", SOURCE_FILE, "-L"+LIBRARY_PATH, "-l"+LIBRARY_NAME, "-o", EXECUTABLE], check=True)
        print("Benchmark executable compiled successfully.")
    except subprocess.CalledProcessError:
        sys.exit(1)

    #if not os.path.exists(CSV_FILE) or os.path.getsize(CSV_FILE) == 0:
    with open(CSV_FILE, "w") as f:
        f.write("Version,N,Seed,Time_ms,PeakMemory_KB\n")

def run_tests():
    env_config = os.environ.copy()
    path_key = "DYLD_LIBRARY_PATH" if sys.platform == "darwin" else "LD_LIBRARY_PATH"
    env_config[path_key] = LIBRARY_PATH

    for n in LIST_N:
        for seed in LIST_SEED:
            command = ["./" + EXECUTABLE, str(n), str(seed), str(0), str(CSV_FILE)] # simple32 version
            try:
                subprocess.run(command, check=True, env=env_config, timeout=216000) 
            except subprocess.CalledProcessError as e:
                print(f"Error executing {command}: {e}")
            command = ["./" + EXECUTABLE, str(n), str(seed), str(1), str(CSV_FILE)] # complete version
            try:
                subprocess.run(command, check=True, env=env_config, timeout=216000) 
            except subprocess.CalledProcessError as e:
                print(f"Error executing {command}: {e}")

if __name__ == "__main__":
    initialization()
    print(f"Starting benchmark...")
    run_tests()
    print("\nBenchmark completed! Results in 'measurements.csv'.")
