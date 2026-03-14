from __future__ import print_function  # Makes print() work like a function in Python 2
import os
import sys

# Compatibility layer for input
if sys.version_info[0] < 3:
    input_func = raw_input
else:
    input_func = input

def parse_vpl_file(file_path):
    """Parses the VPL file into a dictionary of lists."""
    book_map = {}
    # Use 'rb' and manual decode for universal compatibility
    try:
        with open(file_path, 'rb') as f:
            for line in f:
                # Decode bytes to string
                line = line.decode('utf-8', errors='ignore').strip()
                if len(line) < 4:
                    continue
                
                book_id = line[:3].strip()
                
                if book_id not in book_map:
                    book_map[book_id] = []
                book_map[book_id].append(line)
    except Exception as e:
        print("Error reading file: " + str(e))
    return book_map

def display_menu(items, title):
    """Prints a numbered menu and returns the user's choice."""
    print("\n--- " + title + " ---")
    for i, item in enumerate(items, 1):
        print(str(i) + ". " + item)
    print("0. Exit/Back")
    
    choice = input_func("Selection: ")
    if choice.isdigit():
        return int(choice)
    return -1

def main():
    bible_dir = "./bibles"
    
    if not os.path.exists(bible_dir):
        print("Error: Directory '" + bible_dir + "' not found.")
        return

    # Scan directory
    vpl_files = [f for f in os.listdir(bible_dir) if f.lower().endswith('.txt')]
    
    if not vpl_files:
        print("No .txt files found in " + bible_dir)
        return

    while True:
        file_choice = display_menu(vpl_files, "Select a Bible Version")
        
        if file_choice == 0:
            break
        if 1 <= file_choice <= len(vpl_files):
            selected_file = vpl_files[file_choice - 1]
            file_path = os.path.join(bible_dir, selected_file)
            
            current_bible = parse_vpl_file(file_path)
            
            # In Python 2, dict.keys() is a list. In Python 3, it's a view.
            # We convert to a list for indexed access.
            book_list = sorted(current_bible.keys()) if sys.version_info[0] < 3 else list(current_bible.keys())
            
            # Note: Python 2 dicts don't preserve order. 
            # If order is vital in Python 2, you'd need collections.OrderedDict
            
            while True:
                book_choice = display_menu(book_list, "Select a Book (" + selected_file + ")")
                
                if book_choice == 0:
                    break
                if 1 <= book_choice <= len(book_list):
                    selected_book = book_list[book_choice - 1]
                    
                    print("\n=== " + selected_book + " ===")
                    for verse in current_bible[selected_book]:
                        print(verse)
                    
                    input_func("\n(End of book) Press Enter to continue...")

if __name__ == "__main__":
    main()
