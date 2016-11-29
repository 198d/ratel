import React from "react";
import Immutable from "immutable";
import { bindActionCreators } from "redux";
import { connect } from "react-redux";
import { hashHistory } from "react-router";
import { push } from "react-router-redux";

import FileTreeEntry from "../components/FileTreeEntry";
import { mergePropsIgnoringOwnProps } from "../util";
import { fetchMountFiles } from "../actions";


let MountFileTree = ({mount, dispatchers}) => {
    let { fetchMountFiles, pushRoute } = dispatchers;

    if (mount === undefined) {
        return null;
    }

    if (mount && !mount.isMounted) {
        pushRoute("/");
        return null;
    }

    if (mount && !mount.files) {
        fetchMountFiles(mount);
        return null;
    }

    return <FileTreeEntry path="" children={mount.files}
                          mountName={mount.name} name={mount.name}
                          depth={0}/>
}


export default connect(
    (state, ownProps) => {
        let mountMap = state.getIn(["mounts", ownProps.params.name]),
            mount = mountMap && mountMap.toJS();

        return { mount };
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
