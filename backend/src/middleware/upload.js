const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Ensure uploads directory exists
const uploadDir = 'uploads/';
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, uploadDir);
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});

const fileFilter = (req, file, cb) => {
    console.log(`Multer fileFilter - Name: ${file.originalname}, Mimetype: ${file.mimetype}`);

    const isImage = file.mimetype.startsWith('image/') ||
        file.originalname.match(/\.(jpg|jpeg|png|gif|webp|jfif|heic|heif)$/i);

    if (isImage) {
        cb(null, true);
    } else {
        console.error(`Rejected file: ${file.originalname} (${file.mimetype})`);
        return cb(new Error('Only image files are allowed!'), false);
    }
};

const upload = multer({
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
    fileFilter: fileFilter
});

module.exports = upload;
