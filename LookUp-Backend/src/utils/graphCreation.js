const Metadata = require("../models/metadataModel");
const User = require("../models/userModel");

var visitedPhoneNumbers = new Set()
var links = new Set()

function isSubsetOfNestedSet(subset, nestedSet) {
    for (let set of nestedSet) {
        if (isEqual(subset, set)) {
            return true;
        }
    }
    return false;
}

function isEqual(set1, set2) {
    if (set1.size !== set2.size) {
        return false;
    }
    for (let element of set1) {
        if (!set2.has(element)) {
            return false;
        }
    }
    return true;
}

async function generateGraph(phoneNumber, targetDepth) {
    //let ownContactMetadata = { phoneNumber: phoneNumber };
    const userMetadata = await Metadata.findOne({phoneNumber: phoneNumber});
    if(!userMetadata) return "User Not Found";
    let rootNode = await getNode(
        userMetadata,
        targetDepth,
        1,
    );
    let graph = {
        depth: targetDepth,
        rootNode: rootNode,
        links: Array.from(links).map(link => Array.from(link))
    };
    return graph;
}

async function getNode(contactMetadata, targetDepth, currentDepth) {
    let node = {
        contactMetadata: contactMetadata,
        children: []
    };
    visitedPhoneNumbers.add(contactMetadata.phoneNumber);

    if (currentDepth >= targetDepth) {
        return node;
    }

    const user = await User.findOne({phoneNumber: contactMetadata.phoneNumber});
    //User -> [User]
    console.log("User" + user);
    if(!user) return node;
    
    //console.log("Connection: " + connections);
    let numbers = [];
    user.contacts.map(contact => {
        if(contact) numbers.push(contact);
    });
    let metadatas = await Metadata.find({phoneNumber: numbers});
    numbers = [];

    for (let metadata of metadatas) {
        // insert a link
        let link = new Set([contactMetadata.phoneNumber, metadata.phoneNumber]);
        if(!isSubsetOfNestedSet(link, links) && contactMetadata.phoneNumber != metadata.phoneNumber) links.add(link);

        // prevent overlaps when graph loops back to itself
        if (visitedPhoneNumbers.has(metadata.phoneNumber)) {
            continue;
        }

        let child = await getNode(
            metadata,
            targetDepth,
            currentDepth + 1,
        );
        node.children.push(child);
    }
    return node;
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
// console.log('start')
// let ret = await generateGraph("432395512",3);
// console.log(ret);
// links.clear(); //TODO: clear this and visitedNodes
// visitedPhoneNumbers.clear();
// //generateGraph("432395512",2).then((value) => { console.log(value)})
// console.log('end')
// })()

module.exports = { generateGraph, links, visitedPhoneNumbers };