import axios from "axios";

export async function generateGroundedAnswer(question, context) {

    const prompt = `
You are a factual video QA assistant.

Rules:
- Use ONLY the provided context.
- Do NOT use outside knowledge.
- Do NOT guess.
- If the answer is not present, say: "The video does not provide this information."
- Write the answer as a complete, well-formed sentence.
- Keep wording faithful to the context but make it grammatically clear.

Context:
${context}

Question:
${question}
`;

    const res = await axios.post(
        "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash-lite:generateContent",
        {
            contents: [{ parts: [{ text: prompt }] }]
        },
        {
            headers: {
                "Content-Type": "application/json",
                "x-goog-api-key": process.env.GEMINI_API_KEY
            }
        }
    );

    return res.data.candidates[0].content.parts[0].text;
}
