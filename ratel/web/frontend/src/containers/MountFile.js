import React from "react";
import { bindActionCreators } from "redux";
import { connect } from "react-redux";
import { push } from "react-router-redux";

import MountFileContents from "../components/MountFileContents.js";
import { mergePropsIgnoringOwnProps } from "../util";


class MountFile extends React.Component {
    constructor (props) {
        super(props);

        this.state = {
            contents: null
        };

        let { mount, pushRoute, params } = props;

        fetch(`/files/${params.name}/${params.splat}`).then(
            response => {
                if (response.status == 404) {
                    pushRoute(`/${params.name}`);
                }
                else if (response.status == 200) {
                    response.text().then(text => {
                        this.setState({ contents: text });
                    });
                }
                else {
                    throw Exception();
                }
            }).catch(exc => console.log(exc));
    }

    render () {
        return <MountFileContents contents={this.state.contents}/>;
    }
}


export default connect(
    (state, ownProps) => {
        return { params: ownProps.params };
    },
    (dispatch) => {
        return bindActionCreators({
            pushRoute: push
        }, dispatch);
    },
    mergePropsIgnoringOwnProps
)(MountFile);
