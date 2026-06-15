import { useEffect, useState } from "react";
import SearchBar from "../SearchBar/SearchBar";
import { Table } from "antd";
import { PatientTableColumns } from "./PatientTableColumns";
import "./Patients.css";
import { getToken } from "../../../utility";
import axios from "axios";
import LoaderComponent from "../LoaderComponent/LoaderComponent";

function Patients() {
  const [loading, setLoading] = useState(true);
  const [allPatients, setAllPatients] = useState(null);
  const [filteredPatients, setFilteredPatients] = useState(null);

  const handleSearch = (searchValue) => {
    if (searchValue.length === 0) {
      setFilteredPatients(allPatients)
      return
    }
    setFilteredPatients(
      allPatients.filter((patient) =>
        patient.name.toLowerCase().trim().includes(searchValue.toLowerCase().trim())
      )
    );
  };

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = () => {
    axios
      .get("https://flexera.vercel.app/api/admin/users", {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${getToken()}`,
        },
      })
      .then((response) => {
        setAllPatients(response.data.users);
        setFilteredPatients(response.data.users);
        setLoading(false);
      })
      .catch((error) => {
        console.error(error);
        setLoading(false);
      });
  };

  if (loading) {
    return <LoaderComponent />;
  }
  return (
    <div className="Patients_sectiom">
      <SearchBar
        placeholderValue="Search for name"
        handleSearch={handleSearch}
      />
      <Table
        columns={PatientTableColumns}
        dataSource={filteredPatients}
        scroll={{ x: 500, y: 300 }}
        rowHoverable
      />
    </div>
  );
}

export default Patients;
