import express from "express";
import cors from "cors";


import { searchvideos } from "../services/search_service.js";
import { videodata } from "../services/videodata_service.js";

const router = express.Router();

router.get("/search", async (req, res) => {
    const { text } = req.query;
    if (!text) {
        return res.status(400).json({
            error: "enter topics related to what you want to search about"
        });
    }

    try {

        const videoIds = await searchvideos(text, 10);
        console.log("number of video Ids fetched:", videoIds.length);

        const Video = await videodata(videoIds);
        console.log("number of videos for which data is fetched", Video.length);

        res.json({
            count: videoIds.length,
            videos: Video
        })

    } catch (err) {
        console.error("Youtube search error", err);
        res.status(500).json({
            error: err.message
        });
    }
})

export default router;