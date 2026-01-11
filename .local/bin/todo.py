import re
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional

try:
    from timefhuman import timefhuman
except ImportError:
    raise ImportError("timefhuman is required. Install with: pip install timefhuman")


class Todo:
    def __init__(self, md_files: List[str]):
        """
        Initialize Todo with a list of markdown file paths.
        
        Args:
            md_files: List of markdown file paths (e.g., ['/path/2026-01-11.md'])
        """
        self.todos: Dict[int, dict] = {}
        self._id_counter = 0
        self._load_todos(md_files)
    
    def _get_file_date(self, file_path: str) -> datetime:
        """Extract date from filename (format: YYYY-MM-DD.md). Returns datetime at midnight."""
        match = re.search(r'(\d{4})-(\d{2})-(\d{2})', file_path)
        if match:
            try:
                return datetime(int(match.group(1)), int(match.group(2)), int(match.group(3)))
            except ValueError:
                return datetime.now()
        return datetime.now()
    
    def _parse_due_date(self, due_str: str, reference_date: datetime) -> Optional[datetime]:
        """Parse due date string using timefhuman with reference_date as context."""
        try:
            # timefhuman returns a list, extract first element
            results = timefhuman(due_str, reference_date=reference_date)
            if results:
                # Handle various return types from timefhuman
                result = results[0]
                
                # If it's a tuple (range), return the start time
                if isinstance(result, tuple):
                    return result[0]
                # If it's a list (alternatives), return the first
                elif isinstance(result, list):
                    first = result[0]
                    return first[0] if isinstance(first, tuple) else first
                # Otherwise it's a datetime
                else:
                    return result
        except Exception:
            # Fallback if timefhuman fails to parse
            return None
    
    def _extract_tags(self, text: str) -> List[str]:
        """Extract all #tag mentions from text"""
        return re.findall(r'#(\w+)', text)
    
    def _extract_locations(self, text: str) -> List[str]:
        """Extract all @location mentions from text"""
        return re.findall(r'@([\w\s]+)', text)
    
    def _extract_due_date(self, text: str) -> Optional[str]:
        """Extract due:... from text"""
        match = re.search(r'due:(.+?)(?:\s+[#@]|\s*$)', text)
        if match:
            return match.group(1).strip()
        return None
    
    def _load_todos(self, md_files: List[str]) -> None:
        """Load todos from markdown files and extract all attributes"""
        for file_path in md_files:
            path = Path(file_path)
            if not path.exists():
                continue
            
            file_date = self._get_file_date(str(path))
            
            with open(path, 'r', encoding='utf-8') as f:
                for line_num, line in enumerate(f, 1):
                    # Match lines starting with - [ ] or * [ ] (unchecked todos)
                    if re.match(r'^\s*[-*]\s+\[\s*\]\s+', line):
                        todo_text = line.rstrip()
                        
                        # Extract attributes
                        tags = self._extract_tags(todo_text)
                        locations = self._extract_locations(todo_text)
                        due_str = self._extract_due_date(todo_text)
                        due_date = None
                        
                        if due_str:
                            due_date = self._parse_due_date(due_str, file_date)
                        
                        # Create todo item dict
                        self.todos[self._id_counter] = {
                            'text': todo_text,
                            'file': str(path),
                            'line_number': line_num,
                            'tags': tags,
                            'locations': locations,
                            'due_date': due_date
                        }
                        self._id_counter += 1
    
    def get_all(self) -> Dict[int, dict]:
        """Return all todos"""
        return self.todos.copy()
