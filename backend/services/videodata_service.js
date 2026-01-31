import axios from "axios"

export async function videodata(videoIds) {
    const response = await axios.get(
        "https://www.googleapis.com/youtube/v3/videos",
        {
            params: {
                part: "snippet,contentDetails,statistics",
                id: videoIds.join(","),
                key: process.env.YOUTUBE_API_KEY
            }
        }
    );

    if (!response.data.items?.length) {
        return [];
    }


    return response.data.items.map(item => ({
        videoId: item.id,
        title: item.snippet.title,
        description: item.snippet.description,
        channel: item.snippet.channelTitle,
        thumbnail: item.snippet.thumbnails.medium.url,
        duration: item.contentDetails.duration,
        captionAvailable: item.contentDetails.caption === "true",
    }));

}
