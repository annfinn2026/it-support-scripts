#!/usr/bin/env python3
"""
IT Support & Operations Log Analyzer and Endpoint Monitor
-----------------------------------------------------------
Author: Hans Annfinn Johannesen (2026)
Description:
    Et alsidigt Python-script til IT support-automatisering.
    1. Analyserer og ekstraherer fejl ('ERROR', 'WARNING', 'FAIL', 'CRITICAL') fra logfiler.
    2. Overvåger netværksenheder og HTTP-endpoints med svartidsmåling.
"""

import sys
import os
import re
import urllib.request
import urllib.error
from datetime import datetime
from typing import List, Dict

# Farvekoder til terminal output
GREEN = "\033[92m"
YELLOW = "\033[93m"
RED = "\033[91m"
CYAN = "\033[96m"
RESET = "\033[0m"


def monitor_http_endpoints(endpoints: List[str]) -> None:
    """Overvåger et sæt HTTP/HTTPS endpoints og måler svartid."""
    print(f"\n{CYAN}===================================================={RESET}")
    print(f"{CYAN}   [1/2] IT Support - Endpoint Health Monitor       {RESET}")
    print(f"{CYAN}===================================================={RESET}")
    print(f"Tidspunkt: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

    for url in endpoints:
        start_time = datetime.now()
        try:
            req = urllib.request.Request(
                url, headers={"User-Agent": "IT-Support-Health-Checker/1.0"}
            )
            with urllib.request.urlopen(req, timeout=5) as response:
                duration_ms = (datetime.now() - start_time).total_seconds() * 1000
                status_code = response.getcode()
                print(
                    f"   ✔ {url:<30} Status: {GREEN}{status_code} OK{RESET} | Svartid: {GREEN}{duration_ms:.1f} ms{RESET}"
                )
        except urllib.error.HTTPError as e:
            print(
                f"   ✖ {url:<30} Status: {RED}{e.code} HTTP Error{RESET}"
            )
        except urllib.error.URLError as e:
            print(
                f"   ✖ {url:<30} Status: {RED}UNREACHABLE ({e.reason}){RESET}"
            )
        except Exception as e:
            print(f"   ✖ {url:<30} Status: {RED}Fejl: {e}{RESET}")


def analyze_log_file(log_path: str) -> None:
    """Analyserer en logfil for kritiske fejl og udskriver en samlet rapport."""
    print(f"\n{CYAN}===================================================={RESET}")
    print(f"{CYAN}   [2/2] IT Support - Log Parser & Error Analysis   {RESET}")
    print(f"{CYAN}===================================================={RESET}")

    if not os.path.exists(log_path):
        print(f"   ℹ Ingen test-logfil fundet på '{log_path}'. Opretter en eksempel-rapport...")
        sample_logs = [
            "2026-07-27 09:15:02 INFO System booted successfully",
            "2026-07-27 09:15:10 WARNING Disk usage above 80% on /dev/sda1",
            "2026-07-27 09:16:45 ERROR Failed to connect to Active Directory Domain Controller",
            "2026-07-27 09:17:12 CRITICAL Database connection timeout on port 5432",
            "2026-07-27 09:18:00 INFO User 'johannesen' logged in via SSH",
            "2026-07-27 09:20:05 ERROR Print Spooler service failed to respond"
        ]
        with open(log_path, "w", encoding="utf-8") as f:
            f.write("\n".join(sample_logs) + "\n")
        print(f"   ✔ Eksempel-logfil oprettet på '{log_path}'.")

    counts = {"ERROR": 0, "WARNING": 0, "CRITICAL": 0, "FAIL": 0}
    found_issues: List[str] = []

    with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
        for line_num, line in enumerate(f, 1):
            for key in counts.keys():
                if re.search(r"\b" + key + r"\b", line, re.IGNORECASE):
                    counts[key] += 1
                    found_issues.append(f"   [Linje {line_num}] {line.strip()}")

    print(f"\nRapport for logfil: {log_path}")
    print(f"   - Kritiske Fejl (CRITICAL): {RED}{counts['CRITICAL']}{RESET}")
    print(f"   - Standard Fejl (ERROR)    : {RED}{counts['ERROR']}{RESET}")
    print(f"   - Advarsler (WARNING)      : {YELLOW}{counts['WARNING']}{RESET}")

    if found_issues:
        print(f"\nFundne kritiske hændelser:")
        for issue in found_issues:
            print(issue)
    else:
        print(f"\n   ✔ Ingen fejl fundet i logfilen!")


if __name__ == "__main__":
    # 1. Test HTTP Endpoints
    test_urls = [
        "https://www.google.com",
        "https://www.microsoft.com",
        "https://github.com"
    ]
    monitor_http_endpoints(test_urls)

    # 2. Analyser logfil
    sample_log = "system_support.log"
    analyze_log_file(sample_log)

    print(f"\n{CYAN}===================================================={RESET}")
    print(f"{CYAN}   Python IT Automationsscript fuldført!            {RESET}")
    print(f"{CYAN}===================================================={RESET}\n")
