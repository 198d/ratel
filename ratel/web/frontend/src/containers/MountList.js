import React from "react";
import { bindActionCreators } from "redux";
import { connect } from "react-redux";

import MountInfo from "../components/MountInfo";
import MountPassphrasePrompt from "../components/MountPassphrasePrompt";
import ConfirmUnmountDialog from "../components/ConfirmUnmountDialog";
import { mergePropsIgnoringOwnProps } from "../util";
import { resetMountView, confirmUnmount, promptMountPassphrase, attemptMount,
         attemptUnmount } from "../actions";


const MountList = ({mounts, mountViews, dispatchers}) => {
    let {resetMountView, confirmUnmount, promptMountPassphrase,
         attemptUnmount, attemptMount} = dispatchers;

    return <div className="mounts">{
        mounts.map(
            (mount) => {
                let mountView = mountViews[mount.name];

                switch (mountView.view) {
                    case "MOUNT_INFO":
                        return <MountInfo key={mount.name} mount={mount}
                                          mountView={mountView}
                                          confirmUnmount={confirmUnmount}
                                          promptMountPassphrase={promptMountPassphrase}/>;

                    case "CONFIRM_UNMOUNT_DIALOG":
                        return <ConfirmUnmountDialog
                                    key={mount.name} mount={mount}
                                    mountView={mountView}
                                    resetMountView={resetMountView}
                                    attemptUnmount={attemptUnmount}/>;

                    case "MOUNT_PASSPHRASE_PROMPT":
                        return <MountPassphrasePrompt
                                    key={mount.name} mount={mount}
                                    mountView={mountView}
                                    resetMountView={resetMountView}
                                    attemptMount={attemptMount}/>;
                }
                return null;
            }
        )
    }</div>;
}


export default connect(
    (state, ownProps) => {
        return {
            mounts: state.get("mounts").valueSeq().toJS(),
            mountViews: state.get("mountViews").toJS()
        };
    },
    (dispatch) => {
        return {
            dispatchers: bindActionCreators(
                { resetMountView, confirmUnmount, promptMountPassphrase,
                  attemptMount, attemptUnmount },
                dispatch)
        };
    },
    mergePropsIgnoringOwnProps
)(MountList);
