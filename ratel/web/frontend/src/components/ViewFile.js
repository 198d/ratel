import React from "react";


const buildViewUrl = (mountName, path) => {
    return `#/${mountName}/files${path ? `/${path}`: ""}`;
};


export default ({mountName, path}) => {
    return <a className="file-action" href={buildViewUrl(mountName, path)}>
        <i className="fa fa-eye"></i>
    </a>;
}
