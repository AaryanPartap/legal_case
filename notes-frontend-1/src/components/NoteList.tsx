import React from 'react';
import NoteItem from './NoteItem';
import { Note } from '../types/note';

interface NoteListProps {
  notes: Note[];
  onDelete: (id: string) => void;
}

const NoteList: React.FC<NoteListProps> = ({ notes, onDelete }) => {
  return (
    <div>
      <h2>Saved Notes</h2>
      <ul>
        {notes.map(note => (
          <NoteItem key={note.id} note={note} onDelete={onDelete} />
        ))}
      </ul>
    </div>
  );
};

export default NoteList;