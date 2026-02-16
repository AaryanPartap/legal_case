import React from 'react';
import { Note } from '../types/note';

interface NoteItemProps {
    note: Note;
    onDelete: (id: string) => void;
    onEdit: (id: string) => void;
}

const NoteItem: React.FC<NoteItemProps> = ({ note, onDelete, onEdit }) => {
    return (
        <div className="note-item">
            <p>{note.content}</p>
            <div className="note-item-actions">
                <button onClick={() => onEdit(note.id)}>Edit</button>
                <button onClick={() => onDelete(note.id)}>Delete</button>
            </div>
        </div>
    );
};

export default NoteItem;