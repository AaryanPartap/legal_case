export interface Note {
    id: string;
    content: string;
    timestamp: number;
}

export const saveNote = (note: Note): void => {
    const notes = getNotes();
    notes.push(note);
    localStorage.setItem('notes', JSON.stringify(notes));
};

export const getNotes = (): Note[] => {
    const notes = localStorage.getItem('notes');
    return notes ? JSON.parse(notes) : [];
};

export const deleteNote = (id: string): void => {
    const notes = getNotes().filter(note => note.id !== id);
    localStorage.setItem('notes', JSON.stringify(notes));
};