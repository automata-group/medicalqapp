const nodemailer = require('nodemailer');

const sendEmail = async (options) => {
    // Check if SMTP variables are set, otherwise fallback to console
    if (!process.env.SMTP_HOST) {
        console.log('========================================');
        console.log('⚠️ SMTP Config Missing - Email logged to console');
        console.log(`📧 EMAIL SENT TO: ${options.email}`);
        console.log(`Subject: ${options.subject}`);
        console.log(`Message: ${options.message}`);
        console.log('========================================');
        return;
    }

    const transporter = nodemailer.createTransport({
        host: process.env.SMTP_HOST,
        port: process.env.SMTP_PORT,
        auth: {
            user: process.env.SMTP_EMAIL,
            pass: process.env.SMTP_PASSWORD
        }
    });

    const message = {
        from: `${process.env.FROM_NAME} <${process.env.FROM_EMAIL}>`,
        to: options.email,
        subject: options.subject,
        text: options.message,
        html: options.html // Support HTML
    };

    const info = await transporter.sendMail(message);

    console.log('Message sent: %s', info.messageId);
};

module.exports = sendEmail;
