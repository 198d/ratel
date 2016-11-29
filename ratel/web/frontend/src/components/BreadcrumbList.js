import React from "react";

import { spaceComponents } from "../util";


export default ({breadcrumbs}) => {
    return <ol className="breadcrumb">
        {spaceComponents(
            breadcrumbs.map( ([url, value], index, crumbs) => {
                return <li key={index} className={ index == (crumbs.length - 1) ?
                                         "active" : "" }>
                    { index < crumbs.length -1 ?
                        <a href={url}>{value}</a>
                        : value }
                </li>
            }))}
    </ol>;
}
