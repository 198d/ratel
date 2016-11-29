import { connect } from "react-redux";

import BreadcrumbList from "../components/BreadcrumbList";


const mapStateToProps = (state) => {
    return { breadcrumbs: state.get("breadcrumbs").toJS() };
};


export default connect(mapStateToProps)(BreadcrumbList);
