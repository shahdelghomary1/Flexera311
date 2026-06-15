import { SearchOutlined } from "@ant-design/icons";
import "./SearchBar.css";

const SearchBar = ({ handleSearch }) => {
  return (
    <div className="search_bar_container">
      <input
        type="text"
        placeholder="Search for your favorite doctor..."
        className="search_input"
        onChange={(e) => {
          handleSearch(e.target.value);
        }}
      />
      <div className="search_icon">
        <SearchOutlined />
      </div>
    </div>
  );
};
export default SearchBar;
