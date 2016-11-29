import React from "react";


export default ({mount, mountView, resetMountView, attemptMount}) => {
    let submitHandler = (ev) => {
        ev.preventDefault();
        attemptMount(mount, ev.target.elements.passphrase.value);
    }

    return <div className="panel panel-default bg-danger">
        <div className="panel-body">
            <div className="row">
                <div className="col-md-12">
                    <p>Enter eCryptfs passphrase for '{mount.name}'</p>
                </div>
            </div>
            <div className="row">
                <form onSubmit={submitHandler}>
                    <div className="col-md-12">
                        <div className="form-group">
                            <input type="password" name="passphrase" className="form-control"/>
                        </div>
                        <div className="text-right">
                            <span className="text-danger">{mountView.errorText}</span>{" "}
                            <button type="reset" onClick={() => resetMountView(mount)}
                                    className="btn btn-warning">Cancel</button>{" "}
                            <button type="submit" className="btn btn-primary">OK</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>;
}
