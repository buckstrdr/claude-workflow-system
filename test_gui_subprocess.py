#!/usr/bin/env python3
"""
Test script to mimic GUI's exact subprocess.run() call
"""
import subprocess
import os
import sys
import time
import threading

install_dir = "/home/buckstrdr/claude-workflow-system"
script_path = os.path.join(install_dir, "scripts/mcp/start-all-mcp.sh")

print(f"=== TEST SUBPROCESS CALL ===")
print(f"Script: {script_path}")
print(f"CWD: {install_dir}")
print(f"Exists: {os.path.exists(script_path)}")
print(f"Executable: {os.access(script_path, os.X_OK)}")
print(f"Python: {sys.executable}")
print()

def run_in_thread():
    """Run exactly like GUI does - in a background thread"""
    print(f"Thread: {threading.current_thread().name}")
    print(f"Starting subprocess.run() with 120s timeout...")
    print()

    start_time = time.time()

    try:
        result = subprocess.run(
            [script_path],
            cwd=install_dir,
            capture_output=True,
            text=True,
            timeout=120,
            env=os.environ.copy()
        )

        elapsed = time.time() - start_time

        print(f"=== COMPLETED ===")
        print(f"Elapsed: {elapsed:.2f}s")
        print(f"Exit code: {result.returncode}")
        print()
        print(f"=== STDOUT ({len(result.stdout)} chars) ===")
        print(result.stdout)
        print()
        print(f"=== STDERR ({len(result.stderr)} chars) ===")
        print(result.stderr)
        print()

        # Check server status
        print("=== CHECKING SERVER STATUS ===")
        for port in [3001, 3002, 3003, 3004, 3005, 3006, 3007, 3008]:
            nc_result = subprocess.run(
                ["nc", "-z", "localhost", str(port)],
                capture_output=True,
                timeout=1
            )
            status = "ONLINE" if nc_result.returncode == 0 else "OFFLINE"
            print(f"Port {port}: {status}")

    except subprocess.TimeoutExpired as e:
        elapsed = time.time() - start_time
        print(f"=== TIMEOUT AFTER {e.timeout}s ===")
        print(f"Elapsed: {elapsed:.2f}s")
        print(f"STDOUT: {e.stdout}")
        print(f"STDERR: {e.stderr}")
    except Exception as e:
        print(f"=== EXCEPTION ===")
        print(f"{type(e).__name__}: {str(e)}")
        import traceback
        traceback.print_exc()

# Run in a thread just like GUI does
thread = threading.Thread(target=run_in_thread, daemon=True)
thread.start()

# Wait for thread to complete
thread.join()

print()
print("=== TEST COMPLETE ===")
