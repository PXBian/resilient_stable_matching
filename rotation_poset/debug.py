import subprocess
import os
import sys

SOURCE_FILE = "debug.cpp"    
EXECUTABLE = "./debug_exec"  
LIBRARY_PATH = "./target/debug"
LIBRARY_NAME = "rotation_poset"

if __name__ == "__main__":
    print(f"Starting.")

    subprocess.run(["cargo", "build"])
    print(f"Compiled Rust library.")

    compile_key = "clang++" if sys.platform == "darwin" else "g++"
    subprocess.run([compile_key, SOURCE_FILE, "-L"+LIBRARY_PATH, "-l"+LIBRARY_NAME, "-o", EXECUTABLE], check=True)
    print(f"Compiled C++ executable.")

    env_config = os.environ.copy()
    path_key = "DYLD_LIBRARY_PATH" if sys.platform == "darwin" else "LD_LIBRARY_PATH"
    env_config[path_key] = LIBRARY_PATH
    command = [EXECUTABLE]
    subprocess.run(command, check=True, env=env_config, timeout=216000) 
    print("Executed.")
