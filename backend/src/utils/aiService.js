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

    let report = `## 📊 تحليل أخطائك الأخيرة\n\n`;
    report += `لقد راجعت **${totalMistakes} خطأ** من إجاباتك الأخيرة.\n\n`;
    report += `---\n\n`;
    report += `### 🎯 المواضيع التي تحتاج إلى مراجعة\n\n`;
    report += `| الموضوع | عدد الأخطاء | الأولوية |\n`;
    report += `|---------|-------------|----------|\n`;

    sortedTopics.forEach(([topic, count]) => {
        const priority = count >= 3 ? '🔴 عالية' : count >= 2 ? '🟡 متوسطة' : '🟢 منخفضة';
        report += `| ${topic} | ${count} | ${priority} |\n`;
    });

    report += `\n---\n\n`;
    report += `### 💡 نصائح للتحسين\n\n`;

    if (sortedTopics.length > 0) {
        const topTopic = sortedTopics[0][0];
        report += `- 🎯 **ابدأ بمراجعة**: "${topTopic}" — فهذا الموضوع سجّل أعلى نسبة أخطاء لديك.\n`;
    }
    report += `- 📖 **راجع الأسئلة الخاطئة** مرة ثانية باستخدام وضع "مراجعة الأخطاء".\n`;
    report += `- ⏰ **خصص 15 دقيقة يومياً** للمراجعة المتكررة (Spaced Repetition).\n`;
    report += `- 💪 **لا تستسلم** — الخطأ هو أول خطوة في التعلم الحقيقي!\n\n`;
    report += `---\n_📌 ملاحظة: لتفعيل التحليل الذكي بالذكاء الاصطناعي الكامل، يرجى تكوين OPENAI\\_API\\_KEY في إعدادات السيرفر._`;

    return report;
}

exports.generateAnalysis = async (content) => {
    try {
        if (!process.env.OPENAI_API_KEY || process.env.OPENAI_API_KEY === 'your_openai_api_key_here') {
            return generateLocalAnalysis(content);
        }

        const response = await openai.chat.completions.create({
            model: "gpt-3.5-turbo",
            messages: [
                {
                    role: "system",
                    content: "You are a medical study assistant. Analyze the user's mistakes and provide a clear, encouraging summary in Arabic. Use markdown tables and emojis to organize the information. Show which topics need most attention."
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
