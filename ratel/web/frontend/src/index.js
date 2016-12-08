import "../../../../bower_components/bootstrap/dist/css/bootstrap.min.css";
import "../../../../bower_components/font-awesome/css/font-awesome.min.css";

import React from "react";
import ReactDOM from "react-dom";
import Immutable from "immutable";
import thunkMiddleware from "redux-thunk";
import createLogger from "redux-logger";
import { createStore, applyMiddleware } from "redux";
import { Provider } from "react-redux";
import { Router, Route, IndexRoute, hashHistory } from "react-router";
import { syncHistoryWithStore, routerMiddleware, LOCATION_CHANGE } from "react-router-redux";

import App from "./components/App";
import MountList from "./containers/MountList";
import MountFileTree from "./containers/MountFileTree";
import MountFile from "./containers/MountFile";
import { sortDirectoryEntries, expandChildren } from "./util";
import { FETCH_MOUNTS_SUCCEEDED, FETCH_MOUNT_FILES_SUCCEEDED, CONFIRM_UNMOUNT,
         PROMPT_MOUNT_PASSPHRASE, ATTEMPT_MOUNT, ATTEMPT_UNMOUNT, RESET_MOUNT_VIEW,
         PUSH_BREADCRUMB, POP_BREADCRUMB, INCORRECT_MOUNT_PASSPHRASE, CLEAR_MOUNT_FILES,
         PUSH_LOADING_JOB, POP_LOADING_JOB, fetchMounts, pushBreadcrumb,
         popBreadcrumb } from "./actions";


const initialState = Immutable.fromJS({
    mounts: {},
    mountViews: {},
    loadingJobs: Immutable.Set(),
    breadcrumbs: [],
    routing: {}
});


const reducer = (state = initialState, action) => {
    switch (action.type) {
        case LOCATION_CHANGE:
            return state.set("routing", {locationBeforeTransitions: action.payload});

        case FETCH_MOUNTS_SUCCEEDED:
            return action.data.reduce((state, mount) => {
                return state.mergeDeepIn(["mounts", mount.name], Immutable.fromJS(mount))
                            .updateIn(["mountViews", mount.name],
                                      (val) => {
                                          return (
                                              val ||
                                              Immutable.fromJS({ view: "MOUNT_INFO",
                                                                 loading: false,
                                                                 errorText: null }));
                                      });
            }, state);

        case FETCH_MOUNT_FILES_SUCCEEDED:
            return state.mergeDeepIn(
                ["mounts", action.mount.name],
                Immutable.fromJS({
                    files: sortDirectoryEntries(action.files).map(([name, children]) => {
                        return expandChildren("", [name, children]);
                    })
                }));

        case CLEAR_MOUNT_FILES:
            return state.deleteIn(["mounts", action.mount.name, "files"]);

        case CONFIRM_UNMOUNT:
            return state.setIn(["mountViews", action.mount.name, "view"],
                               "CONFIRM_UNMOUNT_DIALOG");

        case PROMPT_MOUNT_PASSPHRASE:
            return state.setIn(["mountViews", action.mount.name, "view"],
                               "MOUNT_PASSPHRASE_PROMPT");

        case INCORRECT_MOUNT_PASSPHRASE:
            return state.setIn(
                ["mountViews", action.mount.name, "errorText"],
                "Incorrect passphrase; try again.");

        case RESET_MOUNT_VIEW:
            return state.setIn(
                ["mountViews", action.mount.name],
                Immutable.Map({
                    view: "MOUNT_INFO",
                    loading: false,
                    errorText: null
                }));

        case PUSH_BREADCRUMB:
            return state.update("breadcrumbs", (val) => val.push(action.crumb));

        case POP_BREADCRUMB:
            return state.update("breadcrumbs", (val) => val.pop());

        case PUSH_LOADING_JOB:
            return state.update("loadingJobs", (val) => val.add(action.name));

        case POP_LOADING_JOB:
            return state.update("loadingJobs", (val) => val.delete(action.name));

    }
    return state;
}


const store = createStore(
    reducer,
    applyMiddleware(
        routerMiddleware(hashHistory),
        thunkMiddleware,
        createLogger()
    )
);


const history = syncHistoryWithStore(hashHistory, store, {
    selectLocationState: (state) => state.get("routing")
});


store.dispatch(fetchMounts());


ReactDOM.render(<Provider store={store}>
    <Router history={history}>
        <Route path="/" component={App}
               onEnter={() => {
                   store.dispatch(
                       pushBreadcrumb([
                           "#/", <i className="fa fa-home"></i>
                       ]));
               }}>
            <IndexRoute component={MountList}/>
            <Route path=":name" component={MountFileTree}
                   onEnter={(context) => {
                       store.dispatch(
                           pushBreadcrumb([
                               `#/${context.params.name}`, context.params.name
                           ]));
                   }}
                   onLeave={() => store.dispatch(popBreadcrumb())}>
                <Route path="files/**" component={MountFile}
                       onEnter={(context) => {
                           store.dispatch(
                               pushBreadcrumb([
                                   `#/${context.params.name}/${context.params.splat}`,
                                   context.params.splat
                               ]));
                       }}
                       onLeave={() => store.dispatch(popBreadcrumb())}/>
            </Route>
        </Route>
    </Router>
</Provider>, document.getElementById("main"));
