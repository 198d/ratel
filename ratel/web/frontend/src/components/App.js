import React from "react";

import Breadcrumbs from "../containers/Breadcrumbs";


export default ({ children }) => {
    return <div className="row">
        <div className="col-md-6 col-md-offset-3">
            <Breadcrumbs/>
            {children}
        </div>
    </div>;
}
