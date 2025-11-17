#!/usr/bin/env python3
"""
Claude Multi-Instance Orchestrator - Tkinter GUI
Production-ready graphical interface for managing MCP servers and orchestrator
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import subprocess
import threading
import time
import os
import sys

class MCPServerGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Claude Multi-Instance Orchestrator")
        self.root.geometry("800x700")
        self.root.resizable(False, False)

        # Get installation directory
        self.install_dir = os.path.dirname(os.path.abspath(__file__))

        # Server definitions
        self.servers = [
            {"name": "Serena", "port": 3001, "desc": "Memory & Coordination"},
            {"name": "Firecrawl", "port": 3002, "desc": "Web Scraping"},
            {"name": "Git MCP", "port": 3003, "desc": "Git Operations"},
            {"name": "Filesystem MCP", "port": 3004, "desc": "File Operations"},
            {"name": "Terminal MCP", "port": 3005, "desc": "Terminal Execution"},
            {"name": "Playwright MCP", "port": 3006, "desc": "Browser Automation"},
            {"name": "Puppeteer MCP", "port": 3007, "desc": "Headless Browser"},
            {"name": "Context7 MCP", "port": 3008, "desc": "Documentation Search"},
            {"name": "Hugging Face MCP", "port": 3009, "desc": "AI Model Discovery"},
        ]

        # Status tracking
        self.status_labels = {}
        self.status_indicators = {}
        self.auto_refresh = True

        self.setup_ui()
        self.start_status_monitor()

    def setup_ui(self):
        """Create the GUI layout"""

        # Header
        header_frame = tk.Frame(self.root, bg="#2c3e50", height=100)
        header_frame.pack(fill=tk.X)
        header_frame.pack_propagate(False)

        title_label = tk.Label(
            header_frame,
            text="Claude Multi-Instance Orchestrator",
            font=("Arial", 20, "bold"),
            bg="#2c3e50",
            fg="white"
        )
        title_label.pack(pady=10)

        subtitle_label = tk.Label(
            header_frame,
            text="MCP Server Management & Control",
            font=("Arial", 12),
            bg="#2c3e50",
            fg="#ecf0f1"
        )
        subtitle_label.pack()

        # Main content area
        content_frame = tk.Frame(self.root, bg="#ecf0f1")
        content_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)

        # Status indicator (Green/Red light)
        self.status_frame = tk.Frame(content_frame, bg="#ecf0f1")
        self.status_frame.pack(fill=tk.X, pady=(0, 20))

        self.light_canvas = tk.Canvas(
            self.status_frame,
            width=60,
            height=60,
            bg="#ecf0f1",
            highlightthickness=0
        )
        self.light_canvas.pack(side=tk.LEFT, padx=10)

        self.light_indicator = self.light_canvas.create_oval(
            10, 10, 50, 50,
            fill="#e74c3c",
            outline="#c0392b",
            width=3
        )

        self.status_text = tk.Label(
            self.status_frame,
            text="⚠️  SERVERS NOT READY",
            font=("Arial", 16, "bold"),
            bg="#ecf0f1",
            fg="#e74c3c"
        )
        self.status_text.pack(side=tk.LEFT, padx=10)

        # Server status table
        table_frame = tk.LabelFrame(
            content_frame,
            text="MCP Server Status",
            font=("Arial", 12, "bold"),
            bg="#ecf0f1",
            padx=10,
            pady=10
        )
        table_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 20))

        # Table headers
        headers_frame = tk.Frame(table_frame, bg="#34495e")
        headers_frame.pack(fill=tk.X, pady=(0, 5))

        tk.Label(
            headers_frame,
            text="Service",
            font=("Arial", 10, "bold"),
            bg="#34495e",
            fg="white",
            width=20,
            anchor="w"
        ).pack(side=tk.LEFT, padx=5)

        tk.Label(
            headers_frame,
            text="Port",
            font=("Arial", 10, "bold"),
            bg="#34495e",
            fg="white",
            width=8,
            anchor="w"
        ).pack(side=tk.LEFT, padx=5)

        tk.Label(
            headers_frame,
            text="Description",
            font=("Arial", 10, "bold"),
            bg="#34495e",
            fg="white",
            width=25,
            anchor="w"
        ).pack(side=tk.LEFT, padx=5)

        tk.Label(
            headers_frame,
            text="Status",
            font=("Arial", 10, "bold"),
            bg="#34495e",
            fg="white",
            width=12,
            anchor="w"
        ).pack(side=tk.LEFT, padx=5)

        # Server rows
        for server in self.servers:
            row_frame = tk.Frame(table_frame, bg="white", relief=tk.RIDGE, borderwidth=1)
            row_frame.pack(fill=tk.X, pady=2)

            tk.Label(
                row_frame,
                text=server["name"],
                font=("Arial", 10),
                bg="white",
                width=20,
                anchor="w"
            ).pack(side=tk.LEFT, padx=5)

            tk.Label(
                row_frame,
                text=str(server["port"]),
                font=("Arial", 10),
                bg="white",
                width=8,
                anchor="w"
            ).pack(side=tk.LEFT, padx=5)

            tk.Label(
                row_frame,
                text=server["desc"],
                font=("Arial", 10),
                bg="white",
                width=25,
                anchor="w"
            ).pack(side=tk.LEFT, padx=5)

            status_label = tk.Label(
                row_frame,
                text="● OFFLINE",
                font=("Arial", 10, "bold"),
                bg="white",
                fg="#e74c3c",
                width=12,
                anchor="w"
            )
            status_label.pack(side=tk.LEFT, padx=5)

            self.status_labels[server["port"]] = status_label

        # Control buttons
        button_frame = tk.Frame(content_frame, bg="#ecf0f1")
        button_frame.pack(fill=tk.X, pady=(0, 10))

        self.start_button = tk.Button(
            button_frame,
            text="🚀 Start All MCP Servers",
            font=("Arial", 12, "bold"),
            bg="#27ae60",
            fg="white",
            command=self.start_all_servers,
            height=2,
            cursor="hand2"
        )
        self.start_button.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 5))

        self.stop_button = tk.Button(
            button_frame,
            text="⏹️  Stop All Servers",
            font=("Arial", 12, "bold"),
            bg="#e67e22",
            fg="white",
            command=self.stop_all_servers,
            height=2,
            cursor="hand2"
        )
        self.stop_button.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=5)

        self.launch_button = tk.Button(
            button_frame,
            text="🎯 Launch Orchestrator",
            font=("Arial", 12, "bold"),
            bg="#3498db",
            fg="white",
            command=self.launch_orchestrator,
            height=2,
            cursor="hand2",
            state=tk.DISABLED
        )
        self.launch_button.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=5)

        self.cleanup_button = tk.Button(
            button_frame,
            text="🗑️  Close All Sessions",
            font=("Arial", 12, "bold"),
            bg="#e74c3c",
            fg="white",
            command=self.cleanup_all_sessions,
            height=2,
            cursor="hand2"
        )
        self.cleanup_button.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(5, 0))

        # Refresh button
        refresh_frame = tk.Frame(content_frame, bg="#ecf0f1")
        refresh_frame.pack(fill=tk.X)

        tk.Button(
            refresh_frame,
            text="🔄 Refresh Status",
            font=("Arial", 10),
            bg="#95a5a6",
            fg="white",
            command=self.update_status,
            cursor="hand2"
        ).pack(side=tk.LEFT, padx=(0, 10))

        tk.Label(
            refresh_frame,
            text="Auto-refresh every 2 seconds",
            font=("Arial", 9),
            bg="#ecf0f1",
            fg="#7f8c8d"
        ).pack(side=tk.LEFT)

    def check_server_status(self, port):
        """Check if a server is running on the given port"""
        try:
            result = subprocess.run(
                ["nc", "-z", "localhost", str(port)],
                capture_output=True,
                timeout=1
            )
            return result.returncode == 0
        except:
            return False

    def update_status(self):
        """Update the status of all servers"""
        all_online = True

        for server in self.servers:
            port = server["port"]
            is_online = self.check_server_status(port)

            if is_online:
                self.status_labels[port].config(
                    text="● ONLINE",
                    fg="#27ae60"
                )
            else:
                self.status_labels[port].config(
                    text="● OFFLINE",
                    fg="#e74c3c"
                )
                all_online = False

        # Update main status indicator
        if all_online:
            self.light_canvas.itemconfig(
                self.light_indicator,
                fill="#27ae60",
                outline="#229954"
            )
            self.status_text.config(
                text="✅ ALL SYSTEMS GO",
                fg="#27ae60"
            )
            self.launch_button.config(state=tk.NORMAL)
        else:
            self.light_canvas.itemconfig(
                self.light_indicator,
                fill="#e74c3c",
                outline="#c0392b"
            )
            self.status_text.config(
                text="⚠️  SERVERS NOT READY",
                fg="#e74c3c"
            )
            self.launch_button.config(state=tk.DISABLED)

    def start_status_monitor(self):
        """Start automatic status monitoring"""
        def monitor():
            while self.auto_refresh:
                self.root.after(0, self.update_status)
                time.sleep(2)

        thread = threading.Thread(target=monitor, daemon=True)
        thread.start()

    def start_all_servers(self):
        """Start all MCP servers"""
        self.start_button.config(state=tk.DISABLED, text="Starting...")

        def run_start():
            import traceback
            try:
                script_path = os.path.join(
                    self.install_dir,
                    "scripts/mcp/start-all-mcp.sh"
                )

                # Write debug info
                with open("/tmp/gui-start-debug.log", "w") as f:
                    f.write(f"=== GUI START DEBUG ===\n")
                    f.write(f"Time: {time.time()}\n")
                    f.write(f"Script: {script_path}\n")
                    f.write(f"CWD: {self.install_dir}\n")
                    f.write(f"Exists: {os.path.exists(script_path)}\n")
                    f.write(f"Executable: {os.access(script_path, os.X_OK)}\n")
                    f.write(f"Python: {sys.executable}\n")
                    f.write(f"Thread: {threading.current_thread().name}\n")
                    f.write(f"\n=== CALLING subprocess.run (120s timeout) ===\n")
                    f.flush()

                start_time = time.time()
                # Run the startup script with a generous timeout
                result = subprocess.run(
                    [script_path],
                    cwd=self.install_dir,
                    capture_output=True,
                    text=True,
                    timeout=120,
                    env=os.environ.copy()
                )
                elapsed = time.time() - start_time

                # Write result
                with open("/tmp/gui-start-debug.log", "a") as f:
                    f.write(f"\n=== COMPLETED ===\n")
                    f.write(f"Elapsed: {elapsed:.2f}s\n")
                    f.write(f"Exit code: {result.returncode}\n")
                    f.write(f"STDOUT ({len(result.stdout)} chars):\n{result.stdout}\n")
                    f.write(f"STDERR ({len(result.stderr)} chars):\n{result.stderr}\n")
                    f.flush()

                self.root.after(0, lambda: self.on_start_complete(result))
            except subprocess.TimeoutExpired as e:
                with open("/tmp/gui-start-debug.log", "a") as f:
                    f.write(f"\n=== TIMEOUT AFTER {e.timeout}s ===\n")
                    f.write(f"STDOUT: {e.stdout}\n")
                    f.write(f"STDERR: {e.stderr}\n")
                    f.flush()
                self.root.after(0, lambda: self.on_start_error(f"Timeout after {e.timeout}s"))
            except Exception as e:
                with open("/tmp/gui-start-debug.log", "a") as f:
                    f.write(f"\n=== EXCEPTION ===\n")
                    f.write(f"{type(e).__name__}: {str(e)}\n")
                    f.write(f"Traceback:\n{traceback.format_exc()}\n")
                    f.flush()
                self.root.after(0, lambda: self.on_start_error(str(e)))

        thread = threading.Thread(target=run_start, daemon=True)
        thread.start()

    def on_start_complete(self, result):
        """Handle server start completion"""
        self.start_button.config(state=tk.NORMAL, text="🚀 Start All MCP Servers")

        if result.returncode == 0:
            messagebox.showinfo(
                "Success",
                "All MCP servers have been started successfully!\n\nWait a few seconds for all servers to come online."
            )
            self.update_status()
        else:
            messagebox.showerror(
                "Error",
                f"Failed to start some servers.\n\nCheck logs in /tmp/*-mcp.log"
            )

    def on_start_error(self, error):
        """Handle server start error"""
        self.start_button.config(state=tk.NORMAL, text="🚀 Start All MCP Servers")
        messagebox.showerror("Error", f"Failed to start servers:\n{error}")

    def stop_all_servers(self):
        """Stop all MCP servers"""
        response = messagebox.askyesno(
            "Confirm Stop",
            "Are you sure you want to stop all MCP servers?"
        )

        if not response:
            return

        try:
            script_path = os.path.join(
                self.install_dir,
                "scripts/mcp/stop-all-mcp.sh"
            )

            subprocess.run([script_path], cwd=self.install_dir)

            messagebox.showinfo(
                "Stopped",
                "All MCP servers have been stopped."
            )

            self.update_status()
        except Exception as e:
            messagebox.showerror("Error", f"Failed to stop servers:\n{e}")

    def cleanup_all_sessions(self):
        """Clean up all claude-feature tmux sessions"""
        try:
            # Get all claude-feature sessions
            result = subprocess.run(
                ["tmux", "list-sessions"],
                capture_output=True,
                text=True
            )

            if result.returncode == 0:
                sessions = [line.split(":")[0] for line in result.stdout.splitlines()
                           if line.startswith("claude-feature-")]

                if not sessions:
                    messagebox.showinfo("Cleanup", "No claude-feature sessions found")
                    return

                # Kill all sessions
                cleanup_script = "\n".join([f"tmux kill-session -t '{s}' 2>/dev/null || true"
                                           for s in sessions])
                subprocess.run(["bash", "-c", cleanup_script])

                # Clean up worktrees and branches
                for session in sessions:
                    feature_name = session.replace("claude-feature-", "")
                    subprocess.run(["git", "worktree", "remove", "--force", f"../wt-feature-{feature_name}"],
                                 capture_output=True, cwd=self.install_dir, check=False)
                    subprocess.run(["git", "branch", "-D", f"feature/{feature_name}"],
                                 capture_output=True, cwd=self.install_dir, check=False)
                    subprocess.run(["rm", "-rf", f".git/quality-gates/{feature_name}"],
                                 capture_output=True, cwd=self.install_dir, check=False)

                messagebox.showinfo("Cleanup Complete",
                                  f"Cleaned up {len(sessions)} session(s):\n" + "\n".join(sessions))
            else:
                messagebox.showinfo("Cleanup", "No tmux sessions found")

        except Exception as e:
            messagebox.showerror("Cleanup Error", f"Failed to cleanup sessions:\n{e}")

    def launch_orchestrator(self):
        """Launch the orchestrator"""
        # Prompt for feature name
        dialog = tk.Toplevel(self.root)
        dialog.title("Launch Orchestrator")
        dialog.geometry("400x150")
        dialog.transient(self.root)
        dialog.grab_set()

        tk.Label(
            dialog,
            text="Enter Feature Name:",
            font=("Arial", 12)
        ).pack(pady=20)

        entry = tk.Entry(dialog, font=("Arial", 12), width=30)
        entry.pack(pady=10)
        entry.focus()

        def do_launch():
            feature_name = entry.get().strip()

            if not feature_name:
                messagebox.showerror("Error", "Feature name is required!")
                return

            dialog.destroy()

            try:
                # ALWAYS clean up ALL claude-feature sessions before launching
                # This prevents any stale sessions from causing issues
                result = subprocess.run(
                    ["tmux", "list-sessions"],
                    capture_output=True,
                    text=True
                )

                if result.returncode == 0:
                    sessions = [line.split(":")[0] for line in result.stdout.splitlines()
                               if line.startswith("claude-feature-")]

                    if sessions:
                        # Kill all existing sessions
                        cleanup_script = "\n".join([f"tmux kill-session -t '{s}' 2>/dev/null || true"
                                                   for s in sessions])
                        subprocess.run(["bash", "-c", cleanup_script])

                        # Clean up worktrees and branches
                        for session in sessions:
                            fname = session.replace("claude-feature-", "")
                            subprocess.run(["git", "worktree", "remove", "--force", f"../wt-feature-{fname}"],
                                         capture_output=True, cwd=self.install_dir, check=False)
                            subprocess.run(["git", "branch", "-D", f"feature/{fname}"],
                                         capture_output=True, cwd=self.install_dir, check=False)
                            subprocess.run(["rm", "-rf", f".git/quality-gates/{fname}"],
                                         capture_output=True, cwd=self.install_dir, check=False)
                        time.sleep(1)  # Wait for cleanup to complete

                session_name = f"claude-feature-{feature_name}"

                # Now run bootstrap script (creates tmux session)
                # Source .env and run bootstrap with proper shell environment
                bootstrap_cmd = f"cd {self.install_dir} && source .env 2>/dev/null; ./bootstrap.sh {feature_name}"
                bootstrap_result = subprocess.run(
                    ["bash", "-c", bootstrap_cmd],
                    cwd=self.install_dir,
                    capture_output=True,
                    text=True,
                    env={**os.environ, "PATH": os.environ.get("PATH", "") + ":/usr/local/bin:/usr/bin"}
                )

                if bootstrap_result.returncode != 0:
                    error_msg = f"Bootstrap script failed:\n\n"
                    error_msg += f"STDOUT:\n{bootstrap_result.stdout}\n\n"
                    error_msg += f"STDERR:\n{bootstrap_result.stderr}"
                    messagebox.showerror("Bootstrap Failed", error_msg)
                    return

                # Now launch 4 terminals attached to different windows
                # Get screen geometry for positioning
                session_name = f"claude-feature-{feature_name}"

                # Monitor Layout: Monitor 3 (left) - Monitor 2 (middle) - Monitor 1 (right)
                # Pixel positions: 0-1919 (M3), 1920-3839 (M2), 3840-5759 (M1)
                # Using wmctrl to position windows after launch

                # Terminal 1: Monitor 3 (left) - Planning - FULLSCREEN
                subprocess.Popen(
                    ["xterm", "-xrm", "XTerm.vt100.allowTitleOps: false",
                     "-geometry", "220x60+0+0",  # Position on Monitor 3
                     "-T", f"{feature_name} - Planning",
                     "-e", "bash", "-c",
                     f"PROMPT_COMMAND='printf \"\\033]0;{feature_name} - Planning\\007\"'; "
                     f"unset TMUX; unset TMUX_PANE; tmux attach-session -t '{session_name}:w1-planning'; exec bash"],
                    cwd=self.install_dir
                )
                time.sleep(2.0)
                # Maximize after tmux has rendered
                subprocess.run(["wmctrl", "-r", f"{feature_name} - Planning", "-b", "add,maximized_vert,maximized_horz"], check=False)

                # Terminal 2: Monitor 2 (middle left half) - Architecture
                subprocess.Popen(
                    ["xterm", "-xrm", "XTerm.vt100.allowTitleOps: false",
                     "-geometry", "110x60+1920+0",  # Position on Monitor 2 left
                     "-T", f"{feature_name} - Architecture",
                     "-e", "bash", "-c",
                     f"PROMPT_COMMAND='printf \"\\033]0;{feature_name} - Architecture\\007\"'; "
                     f"unset TMUX; unset TMUX_PANE; tmux attach-session -t '{session_name}:w2-arch-dev1'; exec bash"],
                    cwd=self.install_dir
                )
                time.sleep(2.0)
                # Resize to half-width and maximize vertically after tmux renders
                subprocess.run(["wmctrl", "-r", f"{feature_name} - Architecture", "-b", "add,maximized_vert"], check=False)
                subprocess.run(["wmctrl", "-r", f"{feature_name} - Architecture", "-e", "0,1920,0,960,-1"], check=False)

                # Terminal 3: Monitor 2 (middle right half) - Dev+QA+Docs
                subprocess.Popen(
                    ["xterm", "-xrm", "XTerm.vt100.allowTitleOps: false",
                     "-geometry", "110x60+2880+0",  # Position on Monitor 2 right
                     "-T", f"{feature_name} - Dev+QA+Docs",
                     "-e", "bash", "-c",
                     f"PROMPT_COMMAND='printf \"\\033]0;{feature_name} - Dev+QA+Docs\\007\"'; "
                     f"unset TMUX; unset TMUX_PANE; tmux attach-session -t '{session_name}:w3-dev2-qa-docs'; exec bash"],
                    cwd=self.install_dir
                )
                time.sleep(2.0)
                # Resize to half-width and maximize vertically after tmux renders
                subprocess.run(["wmctrl", "-r", f"{feature_name} - Dev+QA+Docs", "-b", "add,maximized_vert"], check=False)
                subprocess.run(["wmctrl", "-r", f"{feature_name} - Dev+QA+Docs", "-e", "0,2880,0,960,-1"], check=False)

                # Terminal 4: Monitor 1 (right) - Orchestrator - FULLSCREEN
                subprocess.Popen(
                    ["xterm", "-xrm", "XTerm.vt100.allowTitleOps: false",
                     "-geometry", "220x60+3840+0",  # Position on Monitor 1
                     "-T", f"{feature_name} - Orchestrator",
                     "-e", "bash", "-c",
                     f"PROMPT_COMMAND='printf \"\\033]0;{feature_name} - Orchestrator\\007\"'; "
                     f"unset TMUX; unset TMUX_PANE; tmux attach-session -t '{session_name}:w0-orchestrator'; exec bash"],
                    cwd=self.install_dir
                )
                time.sleep(2.0)
                # Maximize after tmux has rendered
                subprocess.run(["wmctrl", "-r", f"{feature_name} - Orchestrator", "-b", "add,maximized_vert,maximized_horz"], check=False)

                messagebox.showinfo(
                    "Launched",
                    f"All 12 instances launched for: {feature_name}\n\n"
                    "Monitor 3 (left): Planning (Librarian, Planner-A, Planner-B)\n"
                    "Monitor 2 (middle): Architecture (left), Dev+QA+Docs (right)\n"
                    "Monitor 1 (right): Orchestrator"
                )

            except Exception as e:
                messagebox.showerror("Error", f"Failed to launch orchestrator:\n{e}")

        tk.Button(
            dialog,
            text="Launch",
            command=do_launch,
            bg="#3498db",
            fg="white",
            font=("Arial", 11, "bold"),
            cursor="hand2"
        ).pack(pady=10)

        entry.bind("<Return>", lambda e: do_launch())

def main():
    root = tk.Tk()
    app = MCPServerGUI(root)
    root.mainloop()

if __name__ == "__main__":
    main()
