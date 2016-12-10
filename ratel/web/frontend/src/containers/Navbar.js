import React from "react";
import { bindActionCreators } from "redux";
import { connect  } from "react-redux";

import { fetchMounts, clearSearch, setSearch } from "../actions";


const SearchBar = ({onKeyUp}) => {
    return <div className="row">
        <div className="col-md-8 col-md-offset-2">
            <p><input type="text" className="form-control"
                      onKeyUp={onKeyUp}
                      autoComplete={false} autoCorrect={false} autoCapitalize={false}
                      spellCheck={false}
                      placeholder="Search for files in available mounts"/></p>
        </div>
    </div>;
};


class Navbar extends React.Component {
    constructor (props) {
        super(props);
        this.state = {
            searching: false
        };
    }

    render () {
        let { loadingJobs, fetchMounts, clearSearch, setSearch } = this.props,
            searchButtonClasses = ["btn", "btn-default", "navbar-btn"],
            refreshIconClasses = ["fa", "fa-refresh"];

        if (this.state.searching) {
            searchButtonClasses.push("active");
        }

        if(loadingJobs.length > 0) {
            refreshIconClasses.push("fa-spin");
        }

        let toggleSearching = () => {
            if (!!this.state.searching) {
                clearSearch();
            }
            this.setState({
                searching: !this.state.searching
            });
        };

        let setSearchTimeout,
            onKeyUp = (ev) => {
                let value = ev.target.value;
                if (setSearchTimeout) {
                    clearTimeout(setSearchTimeout);
                }
                setSearchTimeout = setTimeout(() => {
                    if (value !== "") {
                        setSearch(value);
                    }
                    else {
                        clearSearch();
                    }
                }, 100);
            };

        return <nav className="navbar navbar-default">
            <div className="container">
                <div className="row">
                    <div className="col-md-8 col-md-offset-2">
                        <a href="#/" className="navbar-brand">Ratel</a>{" "}
                        <div className="navbar-right navbar-actions">
                            <button type="button" className={searchButtonClasses.join(" ")}
                                    onClick={toggleSearching}>
                                <i className="fa fa-search"></i>
                            </button>{" "}
                            <button type="button" onClick={() => fetchMounts()}
                                    className="btn btn-default navbar-btn">
                                <i className={refreshIconClasses.join(" ")}></i>
                            </button>
                        </div>
                    </div>
                </div>
                { this.state.searching ? <SearchBar onKeyUp={onKeyUp}/> : null }
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
        return bindActionCreators({ fetchMounts, clearSearch, setSearch }, dispatch);
    }
)(Navbar);
