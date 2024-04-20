const Metadata = require("../models/metadataModel");
const User = require("../models/userModel");
const mongoose = require("mongoose");
const Graph = require('node-dijkstra')

async function getPath(src, dest) {
    const route = new Graph()
    const allMetadata = await Metadata.find({});
    for(metadata of allMetadata){
        const { phoneNumber } = metadata;
        //console.log(phoneNumber);
        const user = await User.findOne({phoneNumber: phoneNumber});
        const nodes = {}
        if(user != null) {
            if(user.contacts != null){
                for(contact of user.contacts){
                    nodes[contact] = 1;
                }
                route.addNode(phoneNumber, nodes);
                //console.log(phoneNumber, nodes);
            }
            for (var member in nodes) delete nodes[member];
        }
    }
    return route.path(src, dest);
}

// mongoose
//   .connect("mongodb+srv://lookup:iwanttolookup@cluster0.3sjbfru.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")
//   .then(() => {
//     console.log(
//         "connected to db"
//       );
//   })
//   .catch((error) => {
//     console.log(error);
//   });


// (async() => {
//     console.log('start')
//     await getPath("432395512", "5557664823"); 
//     console.log('end')
//   })()

module.exports = { getPath };