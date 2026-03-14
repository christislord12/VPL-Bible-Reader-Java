import javax.swing.*;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.util.*;

public class BibleReader extends JFrame {
    private JComboBox<String> fileSelector;
    private JComboBox<String> bookSelector;
    private JTextArea verseDisplay;
    private File bibleDir;
    private Map<String, java.util.List<String>> currentBookMap;

    public BibleReader(String folderPath) {
        this.bibleDir = new File(folderPath);
        this.currentBookMap = new TreeMap<String, java.util.List<String>>();

        setTitle("Java VPL Bible Reader");
        setSize(800, 600);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setLayout(new BorderLayout());

        // Top Panel: File and Book selection
        JPanel topPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        
        fileSelector = new JComboBox<String>();
        bookSelector = new JComboBox<String>();
        
        loadVplFiles();

        topPanel.add(new JLabel("Version:"));
        topPanel.add(fileSelector);
        topPanel.add(new JLabel("Book:"));
        topPanel.add(bookSelector);
        
        add(topPanel, BorderLayout.NORTH);

        // Center: Scrolling Text Area
        verseDisplay = new JTextArea();
        verseDisplay.setEditable(false);
        verseDisplay.setLineWrap(true);
        verseDisplay.setWrapStyleWord(true);
        verseDisplay.setFont(new Font("Serif", Font.PLAIN, 16));
        verseDisplay.setMargin(new Insets(10, 10, 10, 10));

        JScrollPane scrollPane = new JScrollPane(verseDisplay);
        add(scrollPane, BorderLayout.CENTER);

        // Listeners
        fileSelector.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                parseVplFile((String) fileSelector.getSelectedItem());
            }
        });

        bookSelector.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                displayBook((String) bookSelector.getSelectedItem());
            }
        });

        // Initialize first load
        if (fileSelector.getItemCount() > 0) {
            parseVplFile((String) fileSelector.getSelectedItem());
        }
    }

    private void loadVplFiles() {
        if (bibleDir.exists() && bibleDir.isDirectory()) {
            File[] files = bibleDir.listFiles(new FilenameFilter() {
                public boolean accept(File dir, String name) {
                    return name.toLowerCase().endsWith(".txt");
                }
            });
            if (files != null) {
                for (File f : files) fileSelector.addItem(f.getName());
            }
        }
    }

    private void parseVplFile(String fileName) {
        currentBookMap.clear();
        bookSelector.removeAllItems();
        File vplFile = new File(bibleDir, fileName);

        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new FileReader(vplFile));
            String line;
            while ((line = reader.readLine()) != null) {
                if (line.length() < 4) continue;
                
                // Extracting first 3 characters as the Book ID
                String bookId = line.substring(0, 3).trim();
                
                if (!currentBookMap.containsKey(bookId)) {
                    currentBookMap.put(bookId, new ArrayList<String>());
                    bookSelector.addItem(bookId);
                }
                currentBookMap.get(bookId).add(line);
            }
        } catch (IOException ex) {
            JOptionPane.showMessageDialog(this, "Error reading file: " + ex.getMessage());
        } finally {
            try { if (reader != null) reader.close(); } catch (IOException e) {}
        }
    }

    private void displayBook(String bookId) {
        if (bookId == null || !currentBookMap.containsKey(bookId)) return;
        
        StringBuilder sb = new StringBuilder();
        for (String verse : currentBookMap.get(bookId)) {
            sb.append(verse).append("\n");
        }
        verseDisplay.setText(sb.toString());
        verseDisplay.setCaretPosition(0); // Scroll to top
    }

    public static void main(final String[] args) {
        // Ensure UI is created on the Event Dispatch Thread
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                String path = (args.length > 0) ? args[0] : "./bibles";
                new BibleReader(path).setVisible(true);
            }
        });
    }
}
