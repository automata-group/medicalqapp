const { ContributionCluster, QuestionContribution } = require('../models');
const { Op } = require('sequelize');

// Stopwords in English and Arabic commonly found in clinical vignettes
const STOPWORDS = new Set([
    // English
    'a', 'an', 'the', 'in', 'on', 'at', 'by', 'for', 'with', 'about', 'against', 'between',
    'into', 'through', 'during', 'before', 'after', 'above', 'below', 'to', 'from', 'up',
    'down', 'is', 'are', 'was', 'were', 'be', 'been', 'being', 'have', 'has', 'had',
    'do', 'does', 'did', 'and', 'but', 'if', 'or', 'because', 'as', 'until', 'while',
    'of', 'it', 'its', 'this', 'that', 'these', 'those', 'what', 'which', 'who', 'whom',
    'how', 'when', 'where', 'why', 'patient', 'presents', 'presented', 'complaining',
    'complains', 'year', 'old', 'male', 'female', 'man', 'woman', 'years', 'following',
    'most', 'likely', 'appropriate', 'management', 'diagnosis', 'treatment', 'next', 'step',
    
    // Arabic
    'في', 'من', 'إلى', 'على', 'عن', 'مع', 'هذا', 'هذه', 'هؤلاء', 'ذلك', 'تلك', 'التي',
    'الذي', 'الذين', 'هو', 'هي', 'هم', 'هن', 'كان', 'كانت', 'يكون', 'تكون', 'أن', 'إن',
    'ما', 'ماذا', 'كيف', 'متى', 'أين', 'لماذا', 'هل', 'مريض', 'مريضة', 'حالة', 'عمر',
    'سنة', 'يعاني', 'تعاني', 'يشكو', 'تشكو', 'أفضل', 'العلاج', 'التشخيص', 'الخطوة', 'التالية'
]);

/**
 * Clean and tokenize text for comparison
 */
function tokenize(text) {
    if (!text || typeof text !== 'string') return new Set();
    
    // Lowercase and remove punctuation
    const clean = text
        .toLowerCase()
        .replace(/[.,\/#!$%\^&\*;:{}=\-_`~()?"'’]/g, ' ')
        .replace(/\s+/g, ' ')
        .trim();

    const words = clean.split(' ').filter(w => w.length > 2 && !STOPWORDS.has(w));
    return new Set(words);
}

/**
 * Calculate Sorensen-Dice coefficient between two sets of tokens
 */
function diceCoefficient(setA, setB) {
    if (!setA.size || !setB.size) return 0;
    
    let intersection = 0;
    for (const item of setA) {
        if (setB.has(item)) {
            intersection++;
        }
    }
    
    return (2 * intersection) / (setA.size + setB.size);
}

/**
 * Extract an informative title from the question text
 */
function generateClusterTitle(text) {
    if (!text) return 'Exam Recall Question';
    const firstSentence = text.split(/[.?!;\n]/)[0].trim();
    if (firstSentence.length > 80) {
        return firstSentence.substring(0, 77) + '...';
    }
    return firstSentence || 'Exam Recall Question';
}

/**
 * Check if a new contribution matches existing contributions or clusters
 */
async function detectDuplicateAndCluster(contribution, transaction = null) {
    try {
        const { specialtyId, questionText } = contribution;
        if (!questionText || questionText.trim().length < 10) return null;

        const newTokens = tokenize(questionText);
        if (newTokens.size < 2) return null;

        // Fetch recent active contributions in the same specialty
        const candidates = await QuestionContribution.findAll({
            where: {
                specialtyId,
                id: { [Op.ne]: contribution.id || 0 },
                status: { [Op.notIn]: ['rejected'] }
            },
            attributes: ['id', 'questionText', 'clusterId', 'status'],
            transaction
        });

        let bestMatch = null;
        let highestScore = 0;

        for (const candidate of candidates) {
            const candidateTokens = tokenize(candidate.questionText);
            const score = diceCoefficient(newTokens, candidateTokens);

            if (score > highestScore) {
                highestScore = score;
                bestMatch = candidate;
            }
        }

        // Similarity threshold (0.55 allows slight phrasing differences common in exam recall)
        const SIMILARITY_THRESHOLD = 0.55;

        if (highestScore >= SIMILARITY_THRESHOLD && bestMatch) {
            let targetClusterId = bestMatch.clusterId;

            if (targetClusterId) {
                // Add to existing cluster
                const cluster = await ContributionCluster.findByPk(targetClusterId, { transaction });
                if (cluster) {
                    await cluster.increment('totalReports', { by: 1, transaction });
                    return {
                        clusterId: targetClusterId,
                        score: Math.round(highestScore * 100),
                        isNewCluster: false
                    };
                }
            }

            // Otherwise, create a new cluster and link both
            const clusterTitle = generateClusterTitle(bestMatch.questionText);
            const newCluster = await ContributionCluster.create({
                specialtyId,
                topicId: contribution.topicId || null,
                title: clusterTitle,
                totalReports: 2,
                status: 'open'
            }, { transaction });

            // Link the matched candidate to this cluster
            await bestMatch.update({ clusterId: newCluster.id }, { transaction });

            return {
                clusterId: newCluster.id,
                score: Math.round(highestScore * 100),
                isNewCluster: true
            };
        }

        return null;
    } catch (error) {
        console.error('Duplicate detection error:', error);
        return null; // Non-fatal, contribution can still be saved
    }
}

module.exports = {
    tokenize,
    diceCoefficient,
    detectDuplicateAndCluster
};
