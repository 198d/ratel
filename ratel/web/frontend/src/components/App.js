import React from "react";

import Navbar from "../containers/Navbar";
import Breadcrumbs from "../containers/Breadcrumbs";
import SearchResults from "../containers/SearchResults";
import Messages from "../containers/Messages";


export default ({ children }) => {
    return <div>
        <Navbar/>
        <div className="container">
            <div className="row">
                <div className="col-md-8 col-md-offset-2">
                    <SearchResults/>
                    <Breadcrumbs/>
                    <hr/>
                    {children}
                </div>
            </div>
        </div>
        <Messages/>
    </div>;
}
