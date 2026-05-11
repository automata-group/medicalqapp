const { OpenAI } = require('openai');
const dotenv = require('dotenv');
dotenv.config();

const openai = new OpenAI({
    apiKey: process.env.OPENAI_API_KEY
});

/**
 * Local smart analysis when no API key is configured.
 * Parses the prompt to extract topics and generates a structured Arabic report.
 */
function generateLocalAnalysis(content) {
    // Extract topic lines from the prompt
    const lines = content.split('\n');
    const topicCounts = {};

    lines.forEach(line => {
        const match = line.match(/الموضوع:\s*(.+)/);
        if (match) {
            const topic = match[1].trim();
            topicCounts[topic] = (topicCounts[topic] || 0) + 1;
        }
    });

    const sortedTopics = Object.entries(topicCounts)
        .sort((a, b) => b[1] - a[1]);

    const totalMistakes = Object.values(topicCounts).reduce((a, b) => a + b, 0);

    let report = `## 📊 Your Recent Mistake Analysis\n\n`;
    report += `I have reviewed **${totalMistakes} mistakes** from your recent answers.\n\n`;
    report += `---\n\n`;
    report += `### 🎯 Topics Needing Review\n\n`;
    report += `| Topic | Mistake Count | Priority |\n`;
    report += `|---------|-------------|----------|\n`;

    sortedTopics.forEach(([topic, count]) => {
        const priority = count >= 3 ? '🔴 High' : count >= 2 ? '🟡 Medium' : '🟢 Low';
        report += `| ${topic} | ${count} | ${priority} |\n`;
    });

    report += `\n---\n\n`;
    report += `### 💡 Tips for Improvement\n\n`;

    if (sortedTopics.length > 0) {
        const topTopic = sortedTopics[0][0];
        report += `- 🎯 **Start by reviewing**: "${topTopic}" — this topic has your highest error rate.\n`;
    }
    report += `- 📖 **Review incorrect questions** again using "Mistake Review" mode.\n`;
    report += `- ⏰ **Dedicate 15 minutes daily** to spaced repetition review.\n`;
    report += `- 💪 **Don't give up** — mistakes are the first step to real learning!\n\n`;
    report += `---\n_📌 Note: To enable full smart AI analysis, please configure OPENAI\\_API\\_KEY in server settings._`;

    return report;
}

exports.generateAnalysis = async (content) => {
    try {
        if (!process.env.OPENAI_API_KEY || process.env.OPENAI_API_KEY === 'your_openai_api_key_here') {
            return generateLocalAnalysis(content);
        }

        const response = await openai.chat.completions.create({
            model: "gpt-4o-mini",
            messages: [
                {
                    role: "system",
                    content: "You are a medical study assistant. Analyze the user's mistakes and provide a clear, encouraging summary in English. Use markdown tables and emojis to organize the information. Show which topics need most attention."
                },
                {
                    role: "user",
                    content: content
                }
            ],
            temperature: 0.7
        });

        return response.choices[0].message.content;
    } catch (error) {
        console.error('AI Service Error:', error);
        // Fallback to local analysis on API error
        return generateLocalAnalysis(content);
    }
};
