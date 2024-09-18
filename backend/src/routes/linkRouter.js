const router = require('express').Router();
const { getAllLinks, getLinksById, createLinks, UpdateLinks, DeleteLinks } = require('../controllers/linkController.js');
const { middleware } = require('../middlewares/jsonwebtoken.js')

router.get("/links",
     /* 	#swagger.tags = ['Link']
     #swagger.description = 'Endpoint to get all link' */
     middleware, getAllLinks
);
router.get("/link/:link_ID",
     /* 	#swagger.tags = ['Link']
     #swagger.description = 'Endpoint to get a link based ID' */

     /*	#swagger.parameters['obj'] = {
        in: 'body',
        description: 'Link information.',
        required: true,
        schema: { $ref: "#/definitions/isAdmin" }
     } */
     middleware, getLinksById
);

router.post("/links",
     /* 	#swagger.tags = ['Link']
    #swagger.description = 'Endpoint to post a link' */

     /*	#swagger.parameters['obj'] = {
             in: 'body',
             description: 'Link information.',
             required: true,
             schema: { $ref: "#/definitions/AddLink" }
     } */
     middleware, createLinks
);
router.patch("/link/:link_ID",
     /* 	#swagger.tags = ['Link']
     #swagger.description = 'Endpoint to update a link based ID' */

     /* 	#swagger.parameters['obj'] = {
        in: 'body',
        description: 'Updated Link information.',
        required: true,
        schema: { $ref: "#/definitions/UpdateLink" }
} */
     middleware, UpdateLinks
);
router.delete("/link/:link_ID",
     /* 	#swagger.tags = ['Link']
     #swagger.description = 'Endpoint to delete a link based ID' */
     middleware, DeleteLinks
);

module.exports = router