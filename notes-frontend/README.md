# Notes Application

This is a simple notes application built with React and TypeScript. It allows users to create, save, and manage their notes efficiently.

## Project Structure

```
notes-frontend
├── public
│   └── index.html          # Main HTML file
├── src
│   ├── main.tsx           # Entry point for the React application
│   ├── App.tsx            # Main App component
│   ├── pages
│   │   └── Home.tsx       # Home page component
│   ├── components
│   │   ├── NoteEditor.tsx  # Component for editing notes
│   │   ├── NoteList.tsx    # Component for displaying the list of notes
│   │   └── NoteItem.tsx    # Component for individual note items
│   ├── services
│   │   └── storage.ts      # Service for saving and retrieving notes
│   ├── hooks
│   │   └── useNotes.ts     # Custom hook for managing notes state
│   ├── types
│   │   └── note.ts         # TypeScript interface for note structure
│   └── styles
│       └── index.css       # CSS styles for the application
├── package.json            # npm configuration file
├── tsconfig.json           # TypeScript configuration file
├── vite.config.ts          # Vite configuration file
├── .gitignore              # Git ignore file
└── README.md               # Project documentation
```

## Features

- Create new notes using a text editor.
- Save notes to local storage for persistence.
- Display a list of saved notes.
- Edit and delete notes.

## Getting Started

1. Clone the repository:
   ```
   git clone https://github.com/Harshit6057/legal_case.git
   cd legal_case/notes-frontend
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Start the development server:
   ```
   npm run dev
   ```

4. Open your browser and navigate to `http://localhost:3000` to view the application.

## Contributing

Feel free to submit issues or pull requests for any improvements or bug fixes. 

## License

This project is licensed under the MIT License.