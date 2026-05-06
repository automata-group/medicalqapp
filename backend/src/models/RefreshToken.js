const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const crypto = require('crypto');

const RefreshToken = sequelize.define('RefreshToken', {
    token: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true
    },
    userId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: 'Users',
            key: 'id'
        }
    },
    expiryDate: {
        type: DataTypes.DATE,
        allowNull: false
    },
    revoked: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    },
    revokedAt: {
        type: DataTypes.DATE,
        allowNull: true
    },
    replacedByToken: {
        type: DataTypes.STRING,
        allowNull: true
    },
    createdByIp: {
        type: DataTypes.STRING,
        allowNull: true
    },
    userAgent: {
        type: DataTypes.STRING,
        allowNull: true
    }
}, {
    timestamps: true,
    indexes: [
        {
            fields: ['token']
        },
        {
            fields: ['userId']
        }
    ]
});

RefreshToken.createToken = async function (user, ipAddress = null, userAgent = null) {
    const _token = crypto.randomBytes(40).toString('hex');

    const expiresDays = parseInt(process.env.JWT_REFRESH_EXPIRE_DAYS || '7', 10);
    const expiredAt = new Date();
    expiredAt.setDate(expiredAt.getDate() + expiresDays);

    const refreshToken = await this.create({
        token: _token,
        userId: user.id,
        expiryDate: expiredAt,
        createdByIp: ipAddress,
        userAgent: userAgent
    });

    return refreshToken.token;
};

RefreshToken.verifyExpiration = (token) => {
    return token.expiryDate.getTime() < new Date().getTime();
};

/**
 * Revokes a token and optionally links it to its replacement (Rotation)
 */
RefreshToken.revoke = async function (tokenInstance, newRefreshToken = null) {
    tokenInstance.revoked = true;
    tokenInstance.revokedAt = new Date();
    if (newRefreshToken) {
        tokenInstance.replacedByToken = newRefreshToken;
    }
    await tokenInstance.save();
};

module.exports = RefreshToken;
