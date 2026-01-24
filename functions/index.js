import express from "express";
import cors from "cors";
import { YoutubeTranscript } from "youtube-transcript";

const app = express();
app.use(cors());

app.get("/transcript", async (req, res) => {
    const videoId = req.query.videoId;

    if (!videoId) {
        return res.status(400).json({ error: "videoId required" });
    }

    try {
        const captions = await YoutubeTranscript.fetchTranscript(videoId);
        const text = captions.map(c => c.text).join(" ");

        res.json({
            videoId,
            transcript: text,
            length: text.length
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Transcript not available" });
    }
});

app.listen(3000, () => {
    console.log("✅ Backend running at http://localhost:3000");
});
