# ChatTube — AI-Powered Video Question Answering System

## Project Overview

ChatTube is an AI-powered video learning system that allows users to ask questions about a YouTube video and receive answers strictly grounded in the video’s transcript.

Unlike generic chatbots, ChatTube uses a Retrieval-Augmented Generation (RAG) pipeline to ensure responses are based on what is actually said in the video, along with a confidence-aware answering mechanism to reduce hallucinations.

The project is currently not deployed and runs locally for development and experimentation.

## Motto

> “Ask questions. Get answers only when the video supports them.”

## Key Features

- **RAG-based Video Q&A**: Answers are generated only from retrieved transcript segments  
- **Semantic Search with Embeddings**: Questions are matched against transcript chunks using vector similarity  
- **Confidence Score for Answers**: Each response includes a confidence level indicating how strongly the video supports the answer  
- **Hallucination Control**: If confidence is low, the system explicitly refuses to answer  
- **Transcript Chunking & Semantic Merging**: Long transcripts are intelligently split and merged for better retrieval  
- **Persistent Chat History**: All questions and answers are stored and can be revisited  
- **Timestamp-Aware Context**: Retrieved chunks retain video time ranges for traceability  

## Flow of the App

- User opens the app and lands on the **Home screen**
- User enters a topic (e.g., *machine learning*) in the search bar
- The app searches YouTube and displays relevant videos with available transcripts
- User selects a video and starts watching it inside the app

### First-time Video Processing
- Backend fetches the transcript
- Transcript is chunked, semantically merged, embedded, and stored in Supabase

### Question Answering Flow
- User asks questions while watching the video
- The question is converted into an embedding
- Relevant transcript chunks are retrieved using semantic similarity
- Retrieved context is passed to the LLM with strict grounding rules
- A confidence score is evaluated:
  - If confidence is sufficient → answer is shown
  - If confidence is low → the system refuses to answer
- Question, answer (or refusal), and confidence score are stored in chat history

## 📸 Application Screenshots

### 1. Home Screen
![Home Screen](screenshots/home_screen.png)

### 2. Topic Search
![Topic Search](screenshots/search_bar.png)

### 3. Video Suggestions
![Video Suggestions](screenshots/video_suggestions.png)

### 4. Loading & Processing
![Loading Screen](screenshots/loading_screen.png)

### 5. Chat with Video (RAG-powered)
![Chat Screen](screenshots/chat_screen_final.png)

## How It Works

- Transcripts are extracted and split into semantic chunks
- Each chunk is converted into a vector embedding and stored in Supabase
- User questions are embedded using the same embedding model
- Relevant chunks are retrieved using cosine similarity
- Top chunks are passed to the LLM with grounding constraints
- The system answers only if confidence is sufficient
- All interactions are persisted for continuity

## Tech Stack

### Frontend
- Flutter (Dart) — Android-focused UI
- YouTube Player integration

### Backend
- Node.js + Express
- REST APIs for transcript processing and Q&A

### AI / RAG Pipeline
- Google Gemini API — Answer generation
- Xenova MiniLM — Text embeddings
- Cosine Similarity — Semantic retrieval
- Retrieval-Augmented Generation (RAG) — Core architecture

### Database

**Firebase**
- Stores raw / processed transcript chunks
- Handles real-time sync and app-level state
- Optimized for frontend-driven updates

**Supabase**
- Stores cleaned transcript chunks and embeddings
- Used for semantic search (RAG retrieval)
- Optimized for SQL queries, filtering, and vector similarity

> Firebase is used for real-time app data and user-facing state, while Supabase is used for structured transcript storage and vector embeddings for semantic retrieval.

## Current Limitations

- English transcripts only
- Answers depend on transcript quality
- No direct timestamp jumping from answers

## Future Enhancements

- User authentication and personalized history
- Timestamp-based video seeking from answers
- Multi-video and playlist-level RAG
- Improved abstractive reasoning across transcript sections
- Multi-language transcript support
- Reranking for long-form videos
- UI-level evidence highlighting
