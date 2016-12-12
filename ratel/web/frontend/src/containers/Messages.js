import React from "react";
import { connect } from "react-redux";


const Messages = ({messages}) => {
    if (messages.length === 0) {
        return null;
    }

    return <div className="messages">
        {messages.map(({level, message}, index) => {
            let icon = (() => {
                    switch (level) {
                        case "info":
                            return "fa-info";
                        case "danger":
                            return "fa-times";
                        case "warning":
                            return "fa-exclamation";
                        case "success":
                            return "fa-check";
                    }
                    return "";
                })();
            return <div key={index} className={`message bg-${level} text-${level}`}>
                <div className="container">
                    <div className="row">
                        <div className="col-md-8 col-md-offset-2">
                            <i className={`fa ${icon}`}></i> {message}
                        </div>
                    </div>
                </div>
            </div>;
        })}
    </div>;
};


export default connect(
    (state) => {
        return { messages: state.get("messages").toJS() };
    }
)(Messages);
