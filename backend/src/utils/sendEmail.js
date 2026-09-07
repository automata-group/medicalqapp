const nodemailer = require('nodemailer');

/**
 * Generate an executive, prestigious medical HTML email template for 6-digit OTP code
 */
const generateOtpEmailTemplate = (otp, expireMinutes = 15, isRegistration = false) => {
    const titleText = isRegistration
        ? 'رمز تفعيل الحساب الطبي - منصة SDLE'
        : 'رمز التحقق الطبي لتغيير كلمة المرور - منصة SDLE';

    const greetingMessage = isRegistration
        ? 'تحية طيبة وبعد،<br>يسرنا انضمامكم إلى منصة <strong>SDLE</strong> للتدريب والترخيص الطبي المعتمد. لإكمال تفعيل حسابكم الطبي والبدء في رحلتكم نحو نيل رخصة طب الأسنان، يرجى استخدام رمز التحقق التالي:'
        : 'تحية طيبة وبعد،<br>في إطار حرصنا في <strong>SDLE</strong> على أمان حسابكم الطبي ومتابعة تقدمكم نحو نيل رخصة الممارسة المهنية بكل تميز واقتدار، تلقينا طلباً لتغيير كلمة المرور الخاصة بحسابكم.';

    const codeLabel = isRegistration
        ? 'رمز التفعيل السري والآمن الخاص بكم هو:'
        : 'رمز التحقق السري والآمن الخاص بكم لتغيير كلمة المرور هو:';

    const securityAdvice = isRegistration
        ? '<strong style="color: #0f172a;">🛡️ إشعار أمان وخصوصية:</strong><br>هذا الرمز مخصص لتفعيل حسابكم الطبي الشخصي. فريق الدعم في منصة SDLE لن يطلب منكم مشاركة هذا الرمز أبداً تحت أي ظرف.'
        : '<strong style="color: #0f172a;">🛡️ إشعار أمان وخصوصية:</strong><br>هذا الرمز مخصص لاستخدامكم الشخصي فقط. فريق الدعم في منصة SDLE لن يطلب منكم مشاركة هذا الرمز أبداً تحت أي ظرف. إذا لم تقوموا بطلب تغيير كلمة المرور، فإن بياناتكم الطبية في أمان تام ويمكنكم تجاهل هذا البريد.';

    const englishText = isRegistration
        ? `Welcome to the SDLE Platform! To activate your medical account and begin your preparation journey for the Saudi Dental Licensure Examination, please use the 6-digit verification code above. This code will expire in ${expireMinutes} minutes.`
        : `As part of our commitment to safeguarding your dental licensure examination profile, please use the 6-digit verification code above to securely change your password. This code will expire in ${expireMinutes} minutes.`;

    return `
    <!DOCTYPE html>
    <html dir="rtl" lang="ar">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${titleText}</title>
        <style>
            @media only screen and (max-width: 600px) {
                .email-container { width: 100% !important; margin: 0 !important; border-radius: 0 !important; }
                .otp-number { font-size: 34px !important; letter-spacing: 6px !important; }
                .content-padding { padding: 24px 20px !important; }
            }
        </style>
    </head>
    <body style="margin: 0; padding: 0; background-color: #0b1329; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; color: #1e293b;">
        <table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: #0b1329; padding: 30px 12px;">
            <tr>
                <td align="center">
                    <!-- Main Container Card -->
                    <table border="0" cellpadding="0" cellspacing="0" width="100%" class="email-container" style="max-width: 580px; background-color: #ffffff; border-radius: 20px; overflow: hidden; box-shadow: 0 20px 40px rgba(0,0,0,0.35); border: 1px solid #1e293b;">
                        
                        <!-- Premium Header -->
                        <tr>
                            <td style="background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 50%, #1e40af 100%); padding: 40px 32px 32px; text-align: center; border-bottom: 3px solid #f59e0b;">
                                <!-- Gold Stethoscope / Caduceus Crest Icon -->
                                <table border="0" cellpadding="0" cellspacing="0" align="center" style="margin: 0 auto 16px auto;">
                                    <tr>
                                        <td align="center" style="width: 64px; height: 64px; background: rgba(245, 158, 11, 0.15); border: 1.5px solid #f59e0b; border-radius: 50%;">
                                            <span style="font-size: 30px; line-height: 1;">🩺</span>
                                        </td>
                                    </tr>
                                </table>
                                <h1 style="margin: 0 0 6px 0; color: #ffffff; font-size: 28px; font-weight: 800; letter-spacing: 2px;">SDLE</h1>
                                <p style="margin: 0; color: #f59e0b; font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 2px;">
                                    Saudi Dental Licensure Examination Platform
                                </p>
                                <p style="margin: 6px 0 0 0; color: #94a3b8; font-size: 12px; letter-spacing: 0.5px;">
                                    المنصة الطبية الشاملة لاجتياز اختبار رخصة طب الأسنان
                                </p>
                            </td>
                        </tr>

                        <!-- Main Content Body -->
                        <tr>
                            <td class="content-padding" style="padding: 38px 36px 28px; background-color: #ffffff; text-align: right; direction: rtl;">
                                
                                <!-- Honorable Greeting -->
                                <h2 style="margin: 0 0 16px 0; color: #0f172a; font-size: 20px; font-weight: 700;">
                                    سعادة الدكتور / الزميل العزيز،
                                </h2>
                                
                                <p style="margin: 0 0 24px 0; color: #475569; font-size: 15px; line-height: 1.8;">
                                    ${greetingMessage}
                                </p>

                                <p style="margin: 0 0 12px 0; color: #334155; font-size: 14px; font-weight: 600;">
                                    ${codeLabel}
                                </p>

                                <!-- Luxury Golden OTP Box -->
                                <table border="0" cellpadding="0" cellspacing="0" width="100%" style="margin: 0 auto 20px auto;">
                                    <tr>
                                        <td align="center">
                                            <div style="background: linear-gradient(180deg, #f8fafc 0%, #f1f5f9 100%); border: 2px dashed #2563eb; border-radius: 16px; padding: 20px 24px; text-align: center; max-width: 380px; box-shadow: 0 4px 12px rgba(37,99,235,0.08);">
                                                <span class="otp-number" style="font-family: 'Courier New', Courier, monospace; font-size: 40px; font-weight: 900; letter-spacing: 10px; color: #1e3a8a; display: block; direction: ltr;">${otp}</span>
                                            </div>
                                        </td>
                                    </tr>
                                </table>

                                <!-- Expiry Badge -->
                                <table border="0" cellpadding="0" cellspacing="0" align="center" style="margin: 0 auto 28px auto;">
                                    <tr>
                                        <td align="center" style="background-color: #fef2f2; border: 1px solid #fee2e2; border-radius: 20px; padding: 6px 16px;">
                                            <span style="color: #dc2626; font-size: 13px; font-weight: 600;">
                                                ⏱️ هذا الرمز صالح لمدة ${expireMinutes} دقيقة فقط
                                            </span>
                                        </td>
                                    </tr>
                                </table>

                                <!-- Medical Security Shield Advisory -->
                                <table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: #f8fafc; border-right: 4px solid #f59e0b; border-radius: 8px; padding: 14px 16px; margin-bottom: 28px;">
                                    <tr>
                                        <td style="font-size: 13px; color: #64748b; line-height: 1.6;">
                                            ${securityAdvice}
                                        </td>
                                    </tr>
                                </table>

                                <!-- English Section for Global Standard -->
                                <div style="border-top: 1px solid #e2e8f0; padding-top: 22px; margin-top: 24px; direction: ltr; text-align: left;">
                                    <h3 style="margin: 0 0 8px 0; color: #0f172a; font-size: 15px; font-weight: 700;">
                                        Dear Doctor,
                                    </h3>
                                    <p style="margin: 0; color: #64748b; font-size: 13px; line-height: 1.6;">
                                        ${englishText}
                                    </p>
                                </div>

                                <!-- Doctor Sign-off -->
                                <div style="margin-top: 28px; padding-top: 18px; border-top: 1px dashed #cbd5e1; text-align: right; direction: rtl;">
                                    <p style="margin: 0; font-size: 14px; color: #1e293b; font-weight: 600;">
                                        مع خالص تمنياتنا لكم بدوام التوفيق والاجتياز بامتياز،
                                    </p>
                                    <p style="margin: 4px 0 0 0; font-size: 13px; color: #2563eb; font-weight: 700;">
                                        فريق الإعداد الأكاديمي والتقني — منصة SDLE
                                    </p>
                                </div>

                            </td>
                        </tr>

                        <!-- Luxury Dark Footer -->
                        <tr>
                            <td style="background-color: #0f172a; padding: 24px 20px; text-align: center; border-top: 1px solid #1e293b;">
                                <p style="margin: 0 0 6px 0; color: #cbd5e1; font-size: 12px; font-weight: 600;">
                                    منصة SDLE للتدريب والترخيص الطبي المعتمد
                                </p>
                                <p style="margin: 0; color: #64748b; font-size: 11px;">
                                    &copy; ${new Date().getFullYear()} SDLE Platform. All Rights Reserved.
                                </p>
                            </td>
                        </tr>

                    </table>
                </td>
            </tr>
        </table>
    </body>
    </html>
    `;
};

const sendEmail = async (options) => {
    // Check if SMTP variables are set, otherwise fallback to console
    const host = process.env.SMTP_HOST;
    const emailUser = process.env.SMTP_EMAIL;
    const emailPass = process.env.SMTP_PASSWORD;

    if (!host && !process.env.SMTP_SERVICE) {
        console.log('========================================');
        console.log('⚠️ SMTP Config Missing - Email logged to console');
        console.log(`📧 EMAIL SENT TO: ${options.email}`);
        console.log(`Subject: ${options.subject}`);
        if (options.otp) {
            console.log(`🔑 OTP CODE: ${options.otp}`);
        }
        console.log(`Message: ${options.message}`);
        console.log('========================================');
        return;
    }

    const port = Number(process.env.SMTP_PORT) || 465;
    const transportConfig = process.env.SMTP_SERVICE
        ? {
            service: process.env.SMTP_SERVICE,
            auth: { user: emailUser, pass: emailPass }
        }
        : {
            host: host,
            port: port,
            secure: port === 465, // True for 465 (SSL), false for other ports (587 TLS)
            auth: {
                user: emailUser,
                pass: emailPass
            },
            tls: {
                rejectUnauthorized: false // Allow self-signed or hosted certs if needed
            }
        };

    const transporter = nodemailer.createTransport(transportConfig);

    const fromName = process.env.FROM_NAME || 'SDLE';
    const fromEmail = process.env.FROM_EMAIL || emailUser || 'noreply@healthlicenseprep.com';

    const message = {
        from: `"${fromName}" <${fromEmail}>`,
        to: options.email,
        subject: options.subject,
        text: options.message,
        html: options.html || (options.otp ? generateOtpEmailTemplate(options.otp, options.expireMinutes || 15, options.isRegistration || false) : undefined)
    };

    try {
        const info = await transporter.sendMail(message);
        console.log('✅ Email sent successfully: %s', info.messageId);
        return info;
    } catch (err) {
        console.error('❌ Failed to send email via SMTP:', err.message);
        console.log('========================================');
        console.log('⚠️ Fallback - Email content:');
        console.log(`📧 To: ${options.email}`);
        if (options.otp) console.log(`🔑 OTP CODE: ${options.otp}`);
        console.log('========================================');
        throw err;
    }
};

sendEmail.sendEmail = sendEmail;
sendEmail.generateOtpEmailTemplate = generateOtpEmailTemplate;

module.exports = sendEmail;
