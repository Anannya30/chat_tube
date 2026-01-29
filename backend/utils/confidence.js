export function evaluateConfidence(score) {
    if (score < 0.2) {
        return {
            level: "low",
            allowAnswer: false
        };
    }

    if (score < 0.4) {
        return {
            level: "medium",
            allowAnswer: true
        };
    }

    if (score < 0.6) {
        return {
            level: "high",
            allowAnswer: true
        };
    }

    return {
        level: "very_confident",
        allowAnswer: true
    };
}
