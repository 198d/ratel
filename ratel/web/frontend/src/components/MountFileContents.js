import React from "react";


export default ({contents}) => {
    if(contents) {
        return <pre>{contents}</pre>;
    }
    else {
        return null;
    }
};
