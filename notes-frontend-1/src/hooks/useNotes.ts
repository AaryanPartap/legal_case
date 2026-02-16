import { useEffect, useState } from 'react';
import { getNotes, saveNote, deleteNote } from '../services/storage';
import { Note } from '../types/note';

const useNotes = () => {
    const [notes, setNotes] = useState<Note[]>([]);

    useEffect(() => {
        const fetchNotes = async () => {
            const storedNotes = await getNotes();
            setNotes(storedNotes);
        };
        fetchNotes();
    }, []);

    const addNote = async (content: string) => {
        const newNote: Note = {
            id: Date.now().toString(),
            content,
            timestamp: new Date().toISOString(),
        };
        await saveNote(newNote);
        setNotes((prevNotes) => [...prevNotes, newNote]);
    };

    const removeNote = async (id: string) => {
        await deleteNote(id);
        setNotes((prevNotes) => prevNotes.filter(note => note.id !== id));
    };

    return {
        notes,
        addNote,
        removeNote,
    };
};

export default useNotes;