const swaggerAutogen = require('swagger-autogen')({
     autoHeaders: false,
     autoQuery: true,
     autoBody: true,
     writeOutputFile: true
});

const doc = {
     info: {
          title: 'My API Web Launcher for CRM',
          description: 'This is documentation for My API Web Launcher for CRM',
     },
     host: 'localhost:3000/api',
     schemes: ['http', 'https'],
     // host: 'api-crm.rikiadhin.my.id/api', for deploying
     // schemes: ['https'], for deploying
     consumes: ['application/json'],
     produces: ['application/json'],
     tags: [ 
          {
               "name": "Authorization",
               "description": "Endpoints for authentication"
          },
          {
               "name": "Link",
               "description": "Endpoints for Link"
          },
          {
               "name": "User",
               "description": "Endpoints for User"
          }
     ],
     securityDefinitions: {
          Bearer: {
               "type": "apiKey",  // Using apiKey for Bearer token
               "name": "Authorization",
               "in": "header",
               "description": "Enter the token with 'Bearer ' prefix (e.g., 'Bearer your-token')"
          }
     },
     security: [
          {
               Bearer: []  // Reference the security scheme in the endpoints
          }
     ],
     definitions: {
          Crm: {
               type: 'object',
               properties: {
                    title: {
                         type: 'string',
                         example: 'My CRM Title'
                    },
                    url: {
                         type: 'string',
                         example: 'https://example.com'
                    }
               }
          },
          Login: {
               email: "admin@gmail.com",
               password: "admin"
          },
          AddUser: { 
               name: "",
               email: "",
               password: "",
               isAdmin: false
          },
          UpdateUser: { 
               name: "",
               email: "",
               password: "",
               isAdmin: false
          },
          AddLink: {
               user_ID: "",
               title: "",
               url: ""
          },
          UpdateLink: {
               user_ID: "",
               title: "",
               url: ""
          }
     },
};

const outputFile = './swagger-output.json';
const routes = ['./src/routes/index.js'];

/* NOTE: If you are using the express Router, you must pass in the 'routes' only the 
root file where the route starts, such as index.js, app.js, routes.js, etc ... */

swaggerAutogen(outputFile, routes, doc, { toCSharp: true, toCSharpAsync: true }).then(() => {
     require('./index.js');
});