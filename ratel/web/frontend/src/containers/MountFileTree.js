import React from "react";
import Immutable from "immutable";
import { bindActionCreators } from "redux";
import { connect } from "react-redux";
import { hashHistory } from "react-router";
import { push } from "react-router-redux";

import FileTreeEntry from "../components/FileTreeEntry";
import { mergePropsIgnoringOwnProps } from "../util";
import { fetchMountFiles } from "../actions";


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

        if (children) {
            return children;
        }
        else {
            return <div>
                <div className="row">
                    <div className="col-sm-12">
                        <FileTreeEntry path="" children={mount.files} mountName={mount.name}
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
