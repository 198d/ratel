import React from "react";
import { bindActionCreators } from "redux";
import { connect  } from "react-redux";

import { fetchMounts } from "../actions";


class Navbar extends React.Component {
    constructor (props) {
        super(props);
        this.state = {
            searching: false
        };
    }

    render () {
        let { loadingJobs, fetchMounts } = this.props,
            searchButtonClasses = ["btn", "btn-default", "navbar-btn"],
            refreshIconClasses = ["fa", "fa-refresh"],
            searchRowStyle = {
                display: this.state.searching ? "block" : "none"
            };

        if (this.state.searching) {
            searchButtonClasses.push("active");
        }

        if(loadingJobs.length > 0) {
            refreshIconClasses.push("fa-spin");
        }

        let toggleSearching = () => {
            this.setState({
                searching: !this.state.searching
            });
        };

        return <nav className="navbar navbar-default">
            <div className="container">
                <div className="row">
                    <div className="col-md-8 col-md-offset-2">
                        <a href="#/" className="navbar-brand">Ratel</a>{" "}
                        <div className="navbar-right navbar-actions">
                            {/*<button type="button" className={searchButtonClasses.join(" ")}
                                    onClick={toggleSearching}>
                                <i className="fa fa-search"></i>
                            </button>{" "}*/}
                            <button type="button" onClick={() => fetchMounts()}
                                    className="btn btn-default navbar-btn">
                                <i className={refreshIconClasses.join(" ")}></i>
                            </button>
                        </div>
                    </div>
                </div>
                {/*<div className="row" style={searchRowStyle}>
                    <div className="col-md-8 col-md-offset-2">
                        <p><input type="text" className="form-control"
                                  placeholder="Enter text to find files and mounts"/></p>
                    </div>
                </div>*/}
            </div>
        </nav>;
    }
}


export default connect(
    (state) => {
        return {
            loadingJobs: state.get("loadingJobs").toJS()
        }
    },
    (dispatch) => {
        return bindActionCreators({ fetchMounts }, dispatch);
    }
)(Navbar);
