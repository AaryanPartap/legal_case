import React, { useState } from 'react';
import { saveNote } from '../services/storage';

const NoteEditor: React.FC = () => {
    const [noteContent, setNoteContent] = useState('');

    const handleChange = (event: React.ChangeEvent<HTMLTextAreaElement>) => {
        setNoteContent(event.target.value);
    };

    const handleSave = () => {
        if (noteContent.trim()) {
            saveNote(noteContent);
            setNoteContent('');
        }
    };

    return (
        <div className="note-editor">
            <textarea
                value={noteContent}
                onChange={handleChange}
                placeholder="Write your note here..."
            />
            <button onClick={handleSave}>Save Note</button>
        </div>
    );
};

export default NoteEditor;