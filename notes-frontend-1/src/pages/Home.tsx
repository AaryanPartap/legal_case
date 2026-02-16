import React from 'react';
import NoteEditor from '../components/NoteEditor';
import NoteList from '../components/NoteList';

const Home: React.FC = () => {
    return (
        <div>
            <h1>Notes Application</h1>
            <NoteEditor />
            <NoteList />
        </div>
    );
};

export default Home;