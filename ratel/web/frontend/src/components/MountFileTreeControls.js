import React from "react";


export default ({setFilter, refreshFiles, currentFilter}) => {
    return <form onReset={() => setFilter(null)}>
        <div className="form-group input-group">
            <input className="form-control"
                   onKeyUp={(ev) => setFilter(
                       ev.target.value == "" ? null : ev.target.value)}
                    defaultValue={currentFilter || ""}
                    autoComplete="off" autoCorrect="off" autoCapitalize="off"
                    spellCheck="false" type="text"
                    placeholder="Enter text to filter files"/>
            <span className="input-group-btn">
                <button type="reset" className="btn btn-default"
                        disabled={!currentFilter}>
                    <i className="fa fa-close"></i>
                </button>
                <button type="button" className="btn btn-default"
                        onClick={() => refreshFiles()}>
                    <i className="fa fa-refresh"></i>
                </button>
            </span>
        </div>
    </form>;
};
