#!/usr/bin/env python3
"""
Real-Debrid Tool - Interact with Real-Debrid API and manage download scripts
"""

import os
import requests


def get_links(page: int = 1, limit: int = 100) -> str:
    """
    Fetch downloads list from Real-Debrid API.
    
    Args:
        page: Page number (default: 1)
        limit: Results per page (default: 100)
        
    Returns:
        Raw JSON response text from Real-Debrid downloads endpoint
    """
    token = os.getenv("REAL_DEBRID_API_TOKEN")
    if not token:
        return "Error: REAL_DEBRID_API_TOKEN environment variable not set"
    
    response = requests.get(
        "https://api.real-debrid.com/rest/1.0/downloads",
        headers={"Authorization": f"Bearer {token}"},
        params={"page": page, "limit": limit}
    )
    return response.text

get_links.safe = True


def append_download_link(series: str, season: str, link: str) -> str:
    """
    Append a download link to a season's download.sh script.
    Creates the series/season folders and download.sh file if they don't exist.
    
    Args:
        series: Name of the TV show (used as folder name)
        season: Season name or number (e.g. 'Season 1', 'S01')
        link: The download URL to append
        
    Returns:
        Success message or error
    """
    try:
        folder = os.path.join(series, season)
        os.makedirs(folder, exist_ok=True)
        
        script_path = os.path.join(folder, "download.sh")
        
        is_new = not os.path.exists(script_path)
        
        with open(script_path, "a") as f:
            if is_new:
                f.write("#!/usr/bin/env bash\n\n")
            f.write(f"wget '{link}'\n")
        
        if is_new:
            os.chmod(script_path, 0o755)
            return f"Created {script_path} and added link"
        else:
            return f"Appended link to {script_path}"
    except Exception as e:
        return f"Error: {str(e)}"
