import React from "react";


const buildDownloadUrl = (mountName, path) => {
    return `/files/${mountName}${path ? `/${path}`: ""}`;
};


export default ({mountName, path}) => {
    return <a className="file-action" href={buildDownloadUrl(mountName, path)}>
        <i className="fa fa-download"></i>
    </a>;
}
