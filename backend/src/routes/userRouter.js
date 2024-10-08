const router = require('express').Router();
const { getAllUsers, getUsersById, createUsers, UpdateUsers, DeleteUsers, getUsersByEmail } = require('../controllers/userController.js');
const { middleware } = require('../middlewares/jsonwebtoken.js')

router.get("/users",
     /* 	#swagger.tags = ['User']
     #swagger.description = 'Endpoint to get all user' */
     getAllUsers
);
router.get("/user/:user_ID",
     /* 	#swagger.tags = ['User']
     #swagger.description = 'Endpoint to get a user based ID' */
     getUsersById
);

router.post("/user",
     /* 	#swagger.tags = ['User']
    #swagger.description = 'Endpoint to post a user' */

     /*	#swagger.parameters['obj'] = {
             in: 'body',
             description: 'User information.',
             required: true,
             schema: { $ref: "#/definitions/AddUser" }
     } */
     createUsers
);
router.patch("/user/:user_ID",
     /* 	#swagger.tags = ['User']
     #swagger.description = 'Endpoint to update a user based ID' */

     /* 	#swagger.parameters['obj'] = {
        in: 'body',
        description: 'Updated User information.',
        required: true,
        schema: { $ref: "#/definitions/UpdateUser" }
} */
     UpdateUsers
);
router.delete("/user/:user_ID",
     /* 	#swagger.tags = ['User']
     #swagger.description = 'Endpoint to delete a user based ID' */
     DeleteUsers
); 

module.exports = router