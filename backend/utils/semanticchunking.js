import { cosineSimilarity } from "./similarity.js";


export function semanticMerge(chunks, embeddings, threshold = 0.78) {
    const merged = [];
    let current = { ...chunks[0] };


    for (let i = 1; i < chunks.length; i++) {
        const sim = cosineSimilarity(
            embeddings[i - 1],
            embeddings[i]
        );


        if (sim < threshold) {
            // topic drift → close current
            merged.push(current);
            current = { ...chunks[i] };
        } else {
            // same topic → merge
            current.text += " " + chunks[i].text;
            current.endTime = chunks[i].endTime;
        }
    }


    merged.push(current);
    return merged;
}
