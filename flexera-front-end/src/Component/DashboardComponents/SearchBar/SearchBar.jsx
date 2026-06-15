import { SearchOutlined } from "@ant-design/icons";
import "./SearchBar.css";

const SearchBar = ({ placeholderValue, handleSearch }) => {
  return (
    <div className="dashboard_search_bar_container">
      <input
        type="text"
        placeholder={placeholderValue}
        className="dashboard_search_input"
        onChange={(e) => {
          handleSearch(e.target.value)
        }}
      />
      <div className="dashboard_search_icon">
        <SearchOutlined />
      </div>
    </div>
  );
};
export default SearchBar;
