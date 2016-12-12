import React from "react";
import { bindActionCreators } from "redux";
import { connect } from "react-redux";

import { pushMessage } from "../actions";


const selectFake = (text) => {
    const isRTL = document.documentElement.getAttribute('dir') == 'rtl';
    let fakeElem = document.createElement('textarea');

    // Prevent zooming on iOS
    fakeElem.style.fontSize = '12pt';

    // Reset box model
    fakeElem.style.border = '0';
    fakeElem.style.padding = '0';
    fakeElem.style.margin = '0';

    // Move element out of screen horizontally
    fakeElem.style.position = 'absolute';
    fakeElem.style[ isRTL ? 'right' : 'left' ] = '-9999px';

    // Move element to the same position vertically
    let yPosition = window.pageYOffset || document.documentElement.scrollTop;
    fakeElem.addEventListener('focus', window.scrollTo(0, yPosition));
    fakeElem.style.top = yPosition + 'px';

    fakeElem.setAttribute('readonly', '');
    fakeElem.value = text;


    document.body.appendChild(fakeElem);
    fakeElem.select();

    return fakeElem;
};


const copyEntry = (mountName, path, pushMessage) => {
    let fakeTextarea = null,
        copyText = () => {
            if(fakeTextarea) {
                document.execCommand("copy");
                document.body.removeChild(fakeTextarea);
                pushMessage("success", "Copied");
            }
            else if(fakeTextarea === null) {
                setTimeout(copyText, 100);
            }
        };

    setTimeout(copyText, 100);

    fetch(`/files/${mountName}/${path}`).then(
        response => {
            return response.text();
        }).then(text => {
            fakeTextarea = selectFake(text.trim());
        }).catch( exc => console.log(exc) );
};


const CopyFile = ({mountName, path, pushMessage}) => {
    return <span onClick={() => copyEntry(mountName, path, pushMessage)} className="file-action">
        <i className="fa fa-clipboard"></i>
    </span>;
};


export default connect(
    undefined,
    (dispatch) => {
        return bindActionCreators({ pushMessage }, dispatch);
    }
)(CopyFile);
