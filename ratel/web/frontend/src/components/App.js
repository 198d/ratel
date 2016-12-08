import React from "react";

import Navbar from "../containers/Navbar";
import Breadcrumbs from "../containers/Breadcrumbs";

export default ({ children }) => {
    return <div>
        <Navbar/>
        <div className="container">
            <div className="row">
                <div className="col-md-8 col-md-offset-2">
                    <Breadcrumbs/>
                    <hr/>
                    {children}
                </div>
            </div>
        </div>
    </div>;
}
