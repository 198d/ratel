import React from "react";


export default ({mount, resetMountView, attemptUnmount}) => {
    return <div className="panel panel-default">
        <div className="panel-body">
            <div className="row">
                <div className="col-md-12">
                    <p>Are you sure you want to unmount '{mount.name}'?</p>
                </div>
            </div>
            <div className="row">
                <div className="col-md-12 text-right">
                    <button onClick={() => resetMountView(mount)}
                            className="btn btn-warning">Cancel</button>{" "}
                    <button onClick={() => attemptUnmount(mount)}
                            className="btn btn-primary">OK</button>
                </div>
            </div>
        </div>
    </div>;
}
