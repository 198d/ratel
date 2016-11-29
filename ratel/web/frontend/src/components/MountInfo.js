import React from "react";


export default ({mount, confirmUnmount, promptMountPassphrase}) => {
    let mountAction = mount.isMounted ? "Unmount" : "Mount",
        mountIcon = mount.isMounted ? "fa-lock" : "fa-unlock-alt",
        mountHandler = (ev) => {
            mount.isMounted ?
                confirmUnmount(mount)
                : promptMountPassphrase(mount);
        };


    return <div className="panel panel-default">
        <div className="panel-body">
            <div className="row">
                <div className="col-md-6">{mount.name}</div>
                <div className="col-md-6 text-right">
                    <button onClick={mountHandler}
                            className="btn btn-default" title={mountAction}>
                        <i className={["fa", mountIcon].join(' ')}></i>
                    </button>
                    {" "}
                    <a href={`#/${mount.name}`} className="btn btn-default"
                       title="Browse" disabled={!mount.isMounted}>
                        <i className="fa fa-folder-open"></i>
                    </a>
                </div>
            </div>
        </div>
    </div>;
}
