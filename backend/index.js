import dotenv from "dotenv";
dotenv.config({ path: "../.env" });


import express from "express";
import cors from "cors";
import axios from "axios";
import fs from "fs";
import { execSync } from "child_process";
import { chunkTranscriptWithTimestamps } from "./utils/chunking.js";
import { embedText } from "./utils/embeddings.js";


const app = express();
app.use(cors());

const API_KEY = process.env.ASSEMBLYAI_API_KEY;
if (!API_KEY) throw new Error("AssemblyAI key missing");


//Download audio
function downloadAudio(videoId) {
    const output = `audio_${videoId}.mp3`;

    const YT_DLP = `"C:\\yt-dlp\\yt-dlp.exe"`;

    const command = `${YT_DLP} -x --audio-format mp3 -o audio_${videoId}.mp3 https://www.youtube.com/watch?v=${videoId}`;
    console.log("COMMAND =", command);
    execSync(command, { stdio: "inherit" });

    return output;
}


//Upload audio
async function uploadAudio(filePath) {
    const stream = fs.createReadStream(filePath);

    const res = await axios.post(
        "https://api.assemblyai.com/v2/upload",
        stream,
        {
            headers: {
                Authorization: API_KEY,
                "Transfer-Encoding": "chunked"
            }
        }
    );

    return res.data.upload_url;
}

// Create transcript
async function createTranscript(audioUrl) {
    const res = await axios.post(
        "https://api.assemblyai.com/v2/transcript",
        { audio_url: audioUrl },
        {
            headers: {
                Authorization: API_KEY,
                "Content-Type": "application/json"
            }
        }
    );
    return res.data.id;
}

//Poll transcript
async function pollTranscript(id) {
    while (true) {
        const res = await axios.get(
            `https://api.assemblyai.com/v2/transcript/${id}`,
            { headers: { Authorization: API_KEY } }
        );

        if (res.data.status === "completed") {
            console.log(res.data.words.slice(0, 5));

            return {
                text: res.data.text,
                words: res.data.words
            };
        }

        if (res.data.status === "error") throw new Error(res.data.error);

        await new Promise(r => setTimeout(r, 3000));
    }
}

// API
app.get("/transcript", async (req, res) => {
    const { videoId } = req.query;
    if (!videoId) return res.status(400).json({ error: "videoId required" });

    try {
        console.log("🎥 Video:", videoId);

        const audioFile = downloadAudio(videoId);
        console.log("🎧 Audio downloaded:", audioFile);

        const audioUrl = await uploadAudio(audioFile);
        console.log("☁️ Audio uploaded");

        const transcriptId = await createTranscript(audioUrl);
        console.log("🧠 Transcribing...");

        const transcript = await pollTranscript(transcriptId);
        console.log("✅ Transcript done");

        const chunks = chunkTranscriptWithTimestamps(transcript.words);
        console.log("Before semantic merge:", chunks.length);

        // Embed each chunk BEFORE semantic merge
        const chunkEmbeddings = [];
        for (const chunk of chunks) {
            const embedding = await embedText(chunk.text);

            chunkEmbeddings.push({
                ...chunk,
                embedding,
            });
        }

        console.log("Chunk embeddings created:", chunkEmbeddings.length);

        const testEmbedding = await embedText(
            "Backpropagation is used to train neural networks."
        );
        console.log("Embedding length:", testEmbedding.length);



        fs.unlinkSync(audioFile);

        res.json({
            videoId,
            transcript: transcript.text,
            words: transcript.words
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
});

app.listen(3000, () =>
    console.log("Backend running on http://localhost:3000")
);