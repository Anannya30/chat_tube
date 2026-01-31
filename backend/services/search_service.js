import axios from "axios";

console.log("YouTube API Key present:", !!process.env.YOUTUBE_API_KEY);


export async function searchvideos(query, maxResults = 10) {
    const response = await axios.get(
        "https://youtube.googleapis.com/youtube/v3/search",
        {
            params: {
                part: "snippet",
                q: query,
                type: "video",
                videoCaptions: "closedCaptions",
                maxResults,
                key: process.env.YOUTUBE_API_KEY
            }
        }
    );

    const videoIds = response.data.items.map(
        item => item.id.videoId
    );

    return videoIds;
}