export function chunkTranscriptWithTimestamps(
    words,
    maxTokens = 180,
    overlapTokens = 40
) {
    if (!words || words.length === 0) {
        throw new Error("No words provided for chunking");
    }

    const chunks = [];
    let currentChunk = [];
    let currentTokens = 0;
    let chunkIndex = 0;

    for (const word of words) {
        currentChunk.push(word);
        currentTokens++;

        const isSentenceEnd = /[.!?]$/.test(word.text);

        if (isSentenceEnd && currentTokens >= maxTokens) {
            chunks.push(buildChunk(currentChunk, chunkIndex));
            chunkIndex++;

            const overlap = currentChunk.slice(-overlapTokens);
            currentChunk = overlap;
            currentTokens = overlap.length;
        }
    }

    if (currentChunk.length > 0) {
        chunks.push(buildChunk(currentChunk, chunkIndex));
    }

    return chunks;
}

function buildChunk(words, chunkIndex) {
    return {
        chunkIndex,
        text: words.map(w => w.text).join(" "),
        startTime: words[0].start,
        endTime: words[words.length - 1].end
    };
}
