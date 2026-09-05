const swaggerJsDoc = require('swagger-jsdoc');

const options = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'SDLE API',
            version: '1.0.0',
            description: 'API Documentation for SDLE user and admin endpoints',
            contact: {
                name: 'Developer',
                email: 'dev@example.com'
            }
        },
        servers: [
            {
                url: 'http://localhost:5000',
                description: 'Development Server'
            }
        ],
        components: {
            securitySchemes: {
                bearerAuth: {
                    type: 'http',
                    scheme: 'bearer',
                    bearerFormat: 'JWT'
                }
            }
        },
        security: [{
            bearerAuth: []
        }]
    },
    apis: ['./src/routes/**/*.js', './src/models/*.js'], // Path to API docs
};

const specs = swaggerJsDoc(options);

module.exports = specs;
