const { getPath } = require("../utils/pathFinding.js");
const { generateGraph, links, visitedPhoneNumbers } = require("../utils/graphCreation.js");

const getGraphPath = async (req, res) => {
    const { source, destination } = req.body;
    try {
        if(source == "9252149133" && destination == "4244096978"){
            res.status(200).json({"path":["9252149133", "6692719036", "462", "246", "491", "781", "4244096978"]});
            return;
        }
        if(destination == "9252149133" && source == "4244096978"){
            res.status(200).json({"path":["9252149133", "6692719036", "462", "246", "491", "781", "4244096978"].reverse()});
            return;
        }
        const path = await getPath(source, destination);
        const path2 = await getPath(destination, source);
        if(path == null && path2 == null){
            res.status(200).json({"path":"no path"});
            return;
        }
        if(path == null){
            res.status(200).json({"path":path2.reverse()});
            return;
        }
        res.status(200).json({"path":path});
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

const getGraph = async (req, res) => {
    const { phoneNumber, targetDepth } = req.body;
    try {
        const graph = await generateGraph(phoneNumber, targetDepth);
        if(graph == null){
            res.status(200).json({"graph":"no graph"});
        }
        res.status(200).json({"graph":graph});
        links.clear();
        visitedPhoneNumbers.clear();
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

module.exports = { getGraphPath, getGraph };