const spaceComponents = (components) => {
    return Array.prototype.concat.apply(
        [], components.map( component => [component, " "] ));
};


const mergePropsIgnoringOwnProps = (stateProps, dispatchProps, ownProps) => {
    return Object.assign({}, stateProps, dispatchProps);
};


const expandChildren = (currentPath, [currentName, currentChildren]) => {
    var newPath = currentPath ? [currentPath, currentName].join("/")
                              : currentName,
        expandedChildren = null;

    if (currentChildren) {
        expandedChildren = sortDirectoryEntries(currentChildren).map(child => {
            return expandChildren(newPath, child);
        });
    }

    return [currentName, newPath, expandedChildren];
};


const sortDirectoryEntries = (entries) => {
    return entries.sort(function([leftName, leftChildren], [rightName, rightChildren]) {
        if(leftChildren && !rightChildren) {
            return -1;
        }
        else if (rightChildren && !leftChildren) {
            return 1;
        }
        else {
            return leftName.localeCompare(rightName);
        }
    });
};


export {
    spaceComponents,
    mergePropsIgnoringOwnProps,
    expandChildren,
    sortDirectoryEntries
};
