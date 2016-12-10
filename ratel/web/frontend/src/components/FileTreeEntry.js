import React from "react";

import DownloadFile from "./DownloadFile";
import ViewFile from "./ViewFile";
import CopyFile from "./CopyFile";
import { spaceComponents } from "../util";


const makeTreeIndicator = (depth, last, parents) => {
    return (
        (depth > 1 ? `${ parents[0].last ? "\u00A0" : "\u2502"}\u00A0\u00A0` : "") +
        ("\u00A0\u00A0\u00A0".repeat(depth - 2 >= 0 ? depth - 2 : 0)) +
        (depth > 0 ?
            (last ? "\u2514" : "\u251C") +
            "\u2500\u00A0"
            : "")
    );
};


const generateChildEntries = (props) => {
    let {children, mountName, depth, parents} = props;

    if (!children || (children.length || 0) === 0) {
        return null;
    }

    return children.map(
        ([name, path, children], index, data) =>
            <FileTreeEntry key={path} name={name} path={path} children={children}
                           mountName={mountName} parents={parents ? parents.concat([props]) : []}
                           last={index == data.length - 1} depth={depth + 1}/>);
};


const generateFileActions = (isDirectory, mountName, path) => {
    let entryActions = [
        <DownloadFile key="download" mountName={mountName} path={path}/>
    ];

    if (!isDirectory) {
        entryActions = [
            <ViewFile key="view" mountName={mountName} path={path}/>,
            <CopyFile key="copy" mountName={mountName} path={path}/>
        ].concat(entryActions);
    }

    return entryActions;
};



const FileTreeEntry = (props) => {
    let {path, children, mountName, name, depth, last, parents} = props,
        displayName = children ? <span><span className="text-info">{name}</span>/</span>
                               : <span>{name}</span>;
    return <div>
        <div className="filename-actions">
            <span>{makeTreeIndicator(depth, last, parents)}</span>
            {displayName}{" "}
            {spaceComponents(generateFileActions(children, mountName, path))}
        </div>
        {generateChildEntries(props)}
    </div>;
};


export default FileTreeEntry;
