const { SubscriptionPlan } = require('../models');
const { Op } = require('sequelize');

const OFFICIAL_PLANS = [
    {
        name: 'شهر واحد',
        slug: '1-month',
        description: 'اشتراك لمدة شهر واحد مع وصول كامل لكافة بنوك الأسئلة ومزايا الذكاء الاصطناعي',
        price: 149.00,
        currency: 'SAR',
        durationInDays: 30,
        isActive: true,
        isPopular: false,
        discountPercentage: 0,
        features: [
            'وصول كامل لجميع بنوك أسئلة SDLE',
            'تحليلات الأداء والذكاء الاصطناعي',
            'اختبارات تجريبية غير محدودة',
            'إمكانية الممارسة والمراجعة الشاملة'
        ]
    },
    {
        name: '3 أشهر',
        slug: '3-months',
        description: 'اشتراك لمدة 3 أشهر مع توفير مميز وتدريب مكثف على اختبار SDLE',
        price: 399.00,
        currency: 'SAR',
        durationInDays: 90,
        isActive: true,
        isPopular: false,
        discountPercentage: 11,
        features: [
            'وصول كامل لجميع بنوك أسئلة SDLE',
            'تحليلات الأداء والذكاء الاصطناعي',
            'اختبارات تجريبية غير محدودة',
            'توفير 11% مقارنة بالاشتراك الشهري',
            'متابعة مستوى التقدم الأكاديمي'
        ]
    },
    {
        name: '6 أشهر',
        slug: '6-months',
        description: 'الخطة الأكثر طلباً وشعبية للاستعداد الشامل والمثالي لاختبار SDLE',
        price: 749.00,
        currency: 'SAR',
        durationInDays: 180,
        isActive: true,
        isPopular: true,
        discountPercentage: 16,
        features: [
            'وصول كامل لجميع بنوك أسئلة SDLE',
            'تحليلات الأداء والذكاء الاصطناعي',
            'اختبارات تجريبية غير محدودة',
            'توفير 16% مقارنة بالاشتراك الشهري',
            'دعم أولوية وتحديثات مستمرة'
        ]
    },
    {
        name: 'سنة (12 شهر)',
        slug: '12-months',
        description: 'أفضل قيمة وأطول مدة تغطية لجميع فترات الاختبار مع ميزات غير محدودة',
        price: 1299.00,
        currency: 'SAR',
        durationInDays: 365,
        isActive: true,
        isPopular: false,
        discountPercentage: 27,
        features: [
            'وصول كامل لجميع بنوك أسئلة SDLE',
            'تحليلات الأداء والذكاء الاصطناعي',
            'اختبارات تجريبية غير محدودة',
            'أفضل قيمة توفير (27%)',
            'دعم أولوية وتحديثات مستمرة للبنوك'
        ]
    }
];

async function seedOfficialPlans() {
    try {
        console.log('🔄 Checking official subscription plans...');
        for (const planData of OFFICIAL_PLANS) {
            const existing = await SubscriptionPlan.findOne({
                where: {
                    [Op.or]: [
                        { slug: planData.slug },
                        { name: planData.name }
                    ]
                }
            });

            if (!existing) {
                await SubscriptionPlan.create(planData);
                console.log(`✅ Created official plan: ${planData.name} (${planData.price} SAR)`);
            } else {
                await existing.update({
                    name: planData.name,
                    slug: planData.slug,
                    price: planData.price,
                    currency: planData.currency,
                    durationInDays: planData.durationInDays,
                    isActive: true,
                    isPopular: planData.isPopular,
                    discountPercentage: planData.discountPercentage,
                    features: planData.features,
                    description: planData.description
                });
                console.log(`ℹ️ Updated official plan: ${planData.name} (${planData.price} SAR)`);
            }
        }
        console.log('✅ All 4 official subscription plans verified in database.');
    } catch (err) {
        console.error('⚠️ Error seeding official plans:', err.message);
    }
}

module.exports = { seedOfficialPlans, OFFICIAL_PLANS };
