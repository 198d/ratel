import React from "react";

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


const buildDownloadUrl = (mountName, path) => {
    return `/files/${mountName}${path ? `/${path}`: ""}`;
};


const buildViewUrl = (mountName, path) => {
    return `#/${mountName}/files${path ? `/${path}`: ""}`;
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


const selectFake = (text) => {
    const isRTL = document.documentElement.getAttribute('dir') == 'rtl';
    let fakeElem = document.createElement('textarea');

    // Prevent zooming on iOS
    fakeElem.style.fontSize = '12pt';

    // Reset box model
    fakeElem.style.border = '0';
    fakeElem.style.padding = '0';
    fakeElem.style.margin = '0';

    // Move element out of screen horizontally
    fakeElem.style.position = 'absolute';
    fakeElem.style[ isRTL ? 'right' : 'left' ] = '-9999px';

    // Move element to the same position vertically
    let yPosition = window.pageYOffset || document.documentElement.scrollTop;
    fakeElem.addEventListener('focus', window.scrollTo(0, yPosition));
    fakeElem.style.top = yPosition + 'px';

    fakeElem.setAttribute('readonly', '');
    fakeElem.value = text;


    document.body.appendChild(fakeElem);
    fakeElem.select();

    return fakeElem;
};


const copyEntry = (mountName, path) => {
    let fakeTextarea = null,
        copyText = () => {
            if(fakeTextarea) {
                document.execCommand("copy");
                document.body.removeChild(fakeTextarea);
            }
            else if(fakeTextarea === null) {
                setTimeout(copyText, 250);
            }
        };

    setTimeout(copyText, 250);

    fetch(`/files/${mountName}/${path}`).then(
        response => {
            return response.text();
        }).then(text => {
            fakeTextarea = selectFake(text.trim());
        }).catch( exc => console.log(exc) );
};


const generateFileActions = (isDirectory, mountName, path) => {
    let entryActions = [
        <a key="download" className="file-action" href={buildDownloadUrl(mountName, path)}>
            <i className="fa fa-download"></i>
        </a>
    ];

    if (!isDirectory) {
        entryActions = [
            <a key="view" className="file-action" href={buildViewUrl(mountName, path)}>
                <i className="fa fa-eye"></i>
            </a>,
            <span onClick={() => copyEntry(mountName, path)} key="copy" className="file-action">
                <i className="fa fa-clipboard"></i>
            </span>
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
