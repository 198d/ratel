const FETCH_MOUNTS_SUCCEEDED = "@@ratel/FETCH_MOUNTS_SUCCEEDED";
const FETCH_MOUNT_FILES_SUCCEEDED = "@@ratel/FETCH_MOUNT_FILES_SUCCEEDED";
const CLEAR_MOUNT_FILES = "@@ratel/CLEAR_MOUNT_FILES";

const RESET_MOUNT_VIEW = "@@ratel/RESET_MOUNT_VIEW";
const CONFIRM_UNMOUNT = "@@ratel/CONFIRM_UNMOUNT";
const PROMPT_MOUNT_PASSPHRASE = "@@ratel/PROMPT_MOUNT_PASSPHRASE";
const INCORRECT_MOUNT_PASSPHRASE = "@@ratel/INCORRECT_MOUNT_PASSPHRASE";

const ATTEMPT_MOUNT = "@@ratel/ATTEMPT_MOUNT";
const ATTEMPT_UNMOUNT = "@@ratel/ATTEMPT_UNMOUNT";

const PUSH_BREADCRUMB = "@@ratel/PUSH_BREADCRUMB";
const POP_BREADCRUMB = "@@ratel/POP_BREADCRUMB";

const PUSH_LOADING_JOB = "@@ratel/PUSH_LOADING_JOB";
const POP_LOADING_JOB = "@@ratel/POP_LOADING_JOB";

const SET_SEARCH = "@@ratel/SET_SEARCH";
const CLEAR_SEARCH = "@@ratel/CLEAR_SEARCH";


const fetchMounts = () => {
    let loadingJobName = "mounts";
    return (dispatch) => {
        dispatch(pushLoadingJob(loadingJobName));
        fetch("/api/mounts").then(response => {
            dispatch(popLoadingJob(loadingJobName));
            return response.json()
        }).then(jsonData => {
            dispatch({
                type: FETCH_MOUNTS_SUCCEEDED,
                data: jsonData
            });
            jsonData.forEach((mount) => {
                if (mount.isMounted) {
                    dispatch(fetchMountFiles(mount));
                }
            });
        }).catch( (exc) => {
            console.log(exc);
        });
    };
};


const fetchMountFiles = (mount) => {
    let loadingJobName = `${mount.name}-files`
    return (dispatch) => {
        dispatch(pushLoadingJob(loadingJobName));
        fetch(`/api/mounts/${mount.name}/files`).then(response => {
            dispatch(popLoadingJob(loadingJobName));
            return response.json();
        }).then(files => {
            dispatch({
                type: FETCH_MOUNT_FILES_SUCCEEDED,
                mount, files
            });
        });
    };
};


const mountActionFactory = (action) => {
    return (mount) => {
        return {type: action, mount };
    };
};
const incorrectMountPassphrase = mountActionFactory(INCORRECT_MOUNT_PASSPHRASE);
const resetMountView = mountActionFactory(RESET_MOUNT_VIEW);
const confirmUnmount = mountActionFactory(CONFIRM_UNMOUNT);
const promptMountPassphrase = mountActionFactory(PROMPT_MOUNT_PASSPHRASE);


const attemptMount = (mount, passphrase) => {
    return (dispatch) => {
        fetch(`/api/mounts/${mount.name}/mount`, {
            method: "POST",
            body: passphrase
        }).then(response => {
            if(response.status == 401) {
                dispatch(incorrectMountPassphrase(mount));
            } else {
              dispatch(resetMountView(mount));
              dispatch(fetchMounts());
            }
        }).catch(exc => console.log(exc));
    }
};


const attemptUnmount = (mount) => {
    return (dispatch) => {
        fetch(`/api/mounts/${mount.name}/umount`, {method: "POST"}).then(response => {
            dispatch(resetMountView(mount));
            dispatch(fetchMounts());
            dispatch(clearMountFiles(mount));
        }).catch(exc => console.log(exc));
    }
};


const clearMountFiles = (mount) => {
    return {
        type: CLEAR_MOUNT_FILES,
        mount
    };
};


const pushBreadcrumb = (crumb) => {
    return {
        type: PUSH_BREADCRUMB,
        crumb
    };
};


const popBreadcrumb = () => {
    return {
        type: POP_BREADCRUMB,
    };
};


const pushLoadingJob = (name) => {
    return {
        type: PUSH_LOADING_JOB,
        name
    };
};


const popLoadingJob = (name) => {
    return {
        type: POP_LOADING_JOB,
        name
    };
};


const setSearch = (searchString) => {
    return {
        type: SET_SEARCH,
        searchString
    };
};


const clearSearch = () => {
    return {
        type: CLEAR_SEARCH
    };
};


export {
    FETCH_MOUNTS_SUCCEEDED,
    FETCH_MOUNT_FILES_SUCCEEDED,
    CLEAR_MOUNT_FILES,

    RESET_MOUNT_VIEW,
    INCORRECT_MOUNT_PASSPHRASE,
    CONFIRM_UNMOUNT,
    PROMPT_MOUNT_PASSPHRASE,

    ATTEMPT_UNMOUNT,
    ATTEMPT_MOUNT,

    PUSH_BREADCRUMB,
    POP_BREADCRUMB,

    PUSH_LOADING_JOB,
    POP_LOADING_JOB,

    SET_SEARCH,
    CLEAR_SEARCH,

    fetchMounts,
    fetchMountFiles,
    clearMountFiles,

    resetMountView,
    incorrectMountPassphrase,
    confirmUnmount,
    promptMountPassphrase,

    attemptMount,
    attemptUnmount,

    pushBreadcrumb,
    popBreadcrumb,

    setSearch,
    clearSearch
}
