import React from "react";
import Immutable from "immutable";
import { bindActionCreators } from "redux";
import { connect } from "react-redux";
import { hashHistory } from "react-router";
import { push } from "react-router-redux";

import FileTreeEntry from "../components/FileTreeEntry";
import MountFileTreeControls from "../components/MountFileTreeControls";
import { mergePropsIgnoringOwnProps } from "../util";
import { fetchMountFiles } from "../actions";


const pathMatchesFilter = (path, filter) => {
    var i = 0, j = 0;
    while (true) {
        if (j == filter.length && i <= path.length)
            return true;
        if (i == path.length && j < filter.length)
            return false;
        if (path[i] == filter[j])
            j++;
        i++;
    }
};


const filterFiles = (files, filter) => {
    if (!filter) {
        return files;
    }

    return files.reduce( (accumulator, [name, path, children]) => {
        if(children) {
            let filteredChildren = filterFiles(children, filter);
            if (filteredChildren.length > 0) {
                accumulator.push([name, path, filteredChildren])
            }
        }
        else {
            if (pathMatchesFilter(path, filter)) {
                accumulator.push([name, path, children]);
            }
        }
        return accumulator;
    }, []);
};


class MountFileTree extends React.Component {
    constructor (props) {
        super(props);
        this.state = {
            filter: null
        };
    }

    render () {
        let {mount, children, dispatchers} = this.props,
            { fetchMountFiles, pushRoute } = dispatchers;

        if (mount === undefined) {
            return null;
        }

        if (mount && !mount.isMounted) {
            pushRoute("/");
            return null;
        }

        if (mount && !mount.files) {
            return null;
        }

        let filteredFiles = filterFiles(mount.files, this.state.filter);


        if (children) {
            return children;
        }
        else {
            return <div>
                <div className="row">
                    <div className="col-sm-12">
                        <MountFileTreeControls setFilter={(filter) => this.setState({filter})}
                                               currentFilter={this.state.filter}/>
                    </div>
                </div>
                <div className="row">
                    <div className="col-sm-12">
                        <FileTreeEntry path="" children={filteredFiles} mountName={mount.name}
                                       name={mount.name} depth={0}/>
                    </div>
                </div>
            </div>;
        }
    }
}


export default connect(
    (state, ownProps) => {
        let mountMap = state.getIn(["mounts", ownProps.params.name]),
            mount = mountMap && mountMap.toJS();

        return { mount, children: ownProps.children };
    },
    (dispatch) => {
        return {
            dispatchers: bindActionCreators(
                { fetchMountFiles, pushRoute: push },
                dispatch)
        };
    },
    mergePropsIgnoringOwnProps
)(MountFileTree);
