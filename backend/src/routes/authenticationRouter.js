const router = require('express').Router()
const { loginUser } = require('../controllers/authController');  
 
router.post('/user/auth/login',
     /* 	#swagger.tags = ['Authorization']
     #swagger.description = 'Endpoint to post a authentication' */

     /*	#swagger.parameters['obj'] = {
        in: 'body',
        description: 'Auth information.',
        required: true,
        schema: { $ref: "#/definitions/Login" }
     } */
     loginUser); 

module.exports = router
