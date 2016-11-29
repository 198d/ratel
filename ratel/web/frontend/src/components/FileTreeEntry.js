import React from "react";

import { spaceComponents } from "../util";


const makeTreeIndicator = (depth, last) => {
    return (
        (depth > 1 ? "\u2502\u00A0\u00A0" : "") +
        ("\u00A0\u00A0\u00A0".repeat(depth - 2 >= 0 ? depth - 2 : 0)) +
        (depth > 0 ?
            (last ? "\u2514" : "\u251C") +
            "\u2500\u00A0"
            : "")
    );
};


const buildDownloadUrl = (mountName, path) => {
    return `/files/${mountName}${path ? `/${path}`: ""}`;
};


const generateChildEntries = (children, mountName, depth) => {
    if (!children || (children.length || 0) === 0) {
        return null;
    }

    return children.map(
        ([name, path, children], index, data) =>
            <FileTreeEntry key={path} name={name} path={path} children={children}
                           mountName={mountName}
                           last={index == data.length - 1} depth={depth + 1}/>);
};


const generateFileActions = (isDirectory, mountName, path) => {
    let entryActions = [
        <a key="download" className="file-action" href={buildDownloadUrl(mountName, path)}>
            <i className="fa fa-download"></i>
        </a>
    ];

    return entryActions;
};



const FileTreeEntry = ({path, children, mountName, name, depth, last}) => {
    let displayName = children ? <span><strong className="text-info">{name}</strong>/</span> : <span>{name}</span>;
    return <div>
        <div className="filename-actions">
            <span>{makeTreeIndicator(depth, last)}</span>
            {displayName}{" "}
            {spaceComponents(generateFileActions(children, mountName, path))}
        </div>
        {generateChildEntries(children, mountName, depth)}
    </div>;
};


export default FileTreeEntry;
