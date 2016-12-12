import React from "react";
import { connect } from "react-redux";

import DownloadFile from "../components/DownloadFile";
import ViewFile from "../components/ViewFile";
import CopyFile from "../containers/CopyFile";


const scoreFile = (path, searchString) => {
    let possibleMatches = [],
        score = 0.0,
        pathIndex = 0;
    for(pathIndex; pathIndex < path.length; pathIndex++) {
        if (path[pathIndex] == searchString[0]) {
            possibleMatches.push([pathIndex, null, 0]);
        }

        possibleMatches = possibleMatches.reduce(
            (accum, [startPos, endPos, ssIndex]) => {
                if(ssIndex < searchString.length) {
                    if (path[pathIndex] == searchString[ssIndex]) {
                        ssIndex++;
                    }
                    if(ssIndex == searchString.length) {
                        endPos = pathIndex;
                    }
                }
                if (endPos && (1 / (endPos - startPos)) > score) {
                    score = 1 / (endPos - startPos);
                }
                else {
                    accum.push([startPos, endPos, ssIndex]);
                }
                return accum;
            }, []);
    }
    return score;
};


const searchFiles = (mount, files, searchString, results=[]) => {
    files.map( ([name, path, children]) => {
        if(children) {
            searchFiles(mount, children, searchString, results);
        }
        else {
            let score = scoreFile(path, searchString);
            if (score > 0) {
                results.push([score, path, mount]);
            }
        }
    }, []);
    return results;
};


const SearchResults = ({searchString, mounts}) => {
    if (!searchString) {
        return null;
    }

    let availableMounts = mounts.filter( mount => mount.isMounted && mount.files),
        results = availableMounts.reduce((results, mount) => {
            searchFiles(mount, mount.files, searchString, results);
            return results;
        }, []);

    results.sort(([scoreA, pathA, mountA], [scoreB, pathB, mountB]) => {
        return scoreB - scoreA;
    });

    if (results.length === 0) {
        if (availableMounts.length > 0) {
            return <div className="search-results">
                No results found in {availableMounts.reduce((elems, mount, index, mounts) => {
                                         if (index > 0 && index == mounts.length - 1) {
                                             elems.push(" or ");
                                         }
                                         else if (index > 0) {
                                             elems.push(", ");
                                         }
                                         elems.push(<strong key={mount.name}>{mount.name}</strong>);
                                         return elems;
                                     }, [])}.
            </div>;
        }
        else {
            return <div className="search-results">
                No mounts available to search.
            </div>;
        }
    }
    else {
        return <ul className="list-unstyled search-results">
            {results.map(([score, path, mount]) => {
                return <li key={[mount.name, path].join("/")}>
                    {path}{" "}
                    <small className="text-muted">
                        in <strong>{mount.name}</strong>
                    </small>
                    <span className="search-result-actions pull-right">
                        <ViewFile path={path} mountName={mount.name}/>{" "}
                        <CopyFile path={path} mountName={mount.name}/>{" "}
                        <DownloadFile path={path} mountName={mount.name}/>
                    </span>
                </li>;
            })}
        </ul>;
    }
}


export default connect(
    (state) => {
        return {
            searchString: state.get("searchString"),
            mounts: state.get("mounts").valueSeq().toJS()
        };
    }
)(SearchResults);
