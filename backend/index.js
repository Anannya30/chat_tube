import dotenv from "dotenv";
dotenv.config({ path: "../.env" });


import express from "express";
import cors from "cors";
import axios from "axios";
import fs from "fs";
import { execSync } from "child_process";
import { chunkTranscriptWithTimestamps } from "./utils/chunking.js";
import { semanticMerge } from "./utils/semanticchunking.js";
import { embedText } from "./utils/embeddings.js";
import { cosineSimilarity } from "./utils/similarity.js";
import { evaluateConfidence } from "./utils/confidence.js";
import { generateGroundedAnswer } from "./utils/llm.js";
import youtubeRoutes from "./routes/youtube.js";
let mergedChunks = [];



const app = express();
app.use(cors());
app.use(express.json());
app.use("/youtube", youtubeRoutes);

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`server is running on PORT ${PORT}`);
});

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

function isSummaryQuestion(q) {
    const text = q.toLowerCase();
    return (
        text.includes("summary") ||
        text.includes("summarize") ||
        text.includes("overview") ||
        text.includes("about this video")
    );
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
        console.log(" Video:", videoId);

        const audioFile = downloadAudio(videoId);
        console.log("Audio downloaded:", audioFile);

        const audioUrl = await uploadAudio(audioFile);
        console.log("Audio uploaded");

        const transcriptId = await createTranscript(audioUrl);
        console.log("Transcribing...");

        const transcript = await pollTranscript(transcriptId);
        console.log("Transcript done");

        const chunks = chunkTranscriptWithTimestamps(transcript.words);
        console.log("Before semantic merge:", chunks.length);

        // Embed each chunk BEFORE semantic merge
        const embeddings = [];
        for (const chunk of chunks) {
            const embedding = await embedText(chunk.text);
            embeddings.push(embedding);
        }

        console.log("Chunk embeddings created:", embeddings.length);

        mergedChunks = semanticMerge(chunks, embeddings);

        for (let i = 0; i < mergedChunks.length; i++) {
            mergedChunks[i].embedding = await embedText(mergedChunks[i].text);
        }

        console.log("After semantic merge:", mergedChunks.length);


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

//embedding the question asked and picking top-k chunks
app.post("/ask", express.json(), async (req, res) => {
    const { question } = req.body;

    if (!question) {
        return res.status(400).json({ error: "Question required" });
    }

    if (!mergedChunks.length) {
        return res.status(400).json({
            error: "Transcript not processed yet. Call /transcript first."
        });
    }

    try {
        const questionEmbedding = await embedText(question);

        const topChunks = mergedChunks
            .map(chunk => ({
                text: chunk.text,
                startTime: chunk.startTime,
                endTime: chunk.endTime,
                score: cosineSimilarity(questionEmbedding, chunk.embedding),
            }))
            .sort((a, b) => b.score - a.score)
            .slice(0, 3);

        const bestScore = topChunks[0]?.score ?? 0;
        const confidence = evaluateConfidence(bestScore);

        if (!confidence.allowAnswer) {
            return res.json({
                question,
                answer: null,
                confidence: {
                    score: Number(bestScore.toFixed(3)),
                    level: confidence.level
                },
                message: "This question is not answered in the video."
            });
        }

        const contextText = isSummaryQuestion(question)
            ? mergedChunks.map(c => c.text).join("\n\n")
            : topChunks.map(c => c.text).join("\n\n");

        console.log(
            isSummaryQuestion(question)
                ? "Calling Gemini with FULL transcript context..."
                : "Calling Gemini with TOP chunks..."
        );

        const answer = await generateGroundedAnswer(
            question,
            contextText
        );

        res.json({
            question,
            answer,
            confidence: {
                score: Number(bestScore.toFixed(3)),
                level: confidence.level
            },
            source: {
                startTime: bestChunk.startTime,
                endTime: bestChunk.endTime
            }
        });

    } catch (err) {
        console.error("ASK ERROR:", err);
        res.status(500).json({ error: err.message });
    }
});



app.listen(3000, () =>
    console.log("Backend running on http://localhost:3000")
);