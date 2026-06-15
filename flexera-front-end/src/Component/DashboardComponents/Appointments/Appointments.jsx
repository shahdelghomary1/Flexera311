import { useState, useEffect } from "react";
import SearchBar from "../SearchBar/SearchBar";
import { Table, Space } from "antd";
import { AppointmentsTableColumns } from "./AppointmentsTableColumns";
import LoaderComponent from "../LoaderComponent/LoaderComponent";
import axios from "axios";
import { getToken } from "../../../utility";
import { formatTimeRange } from '../../../utility'

function Appointments() {
  const [loading, setLoading] = useState(true);
  const [allAppointments, setAllAppointments] = useState(null);
  const [filteredAppointments, setFilteredAppointments] = useState(null);

  const handleSearch = (searchValue) => {
    if (searchValue.length === 0) {
      setFilteredAppointments(allAppointments)
      return
    }
    setFilteredAppointments(
      allAppointments.filter((appointment) =>
        appointment?.patient?.name.toLowerCase().trim().includes(searchValue.toLowerCase().trim())
      )
    );
  };

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = () => {
    axios
      .get("https://flexera.vercel.app/api/admin/appointments", {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${getToken()}`,
        },
      })
      .then((response) => {
        setAllAppointments(response.data.appointments);
        setFilteredAppointments(response.data.appointments);
        setLoading(false);
      })
      .catch((error) => {
        console.error(error);
        setLoading(false);
      });
  };

  const columnsWithEdit = AppointmentsTableColumns.map((col) => {
    if (col.key === "time") {
      return {
        ...col,
        render: (_, record) => (
          <Space size="middle">
            {formatTimeRange(record?.time)}
          </Space>
        ),
      };
    }
    return col;
  });

  if (loading) {
    return <LoaderComponent />;
  }
  return (
    <div className="doctors_sectiom">
      <div className="action_container">
        <SearchBar
          placeholderValue="Search for name"
          handleSearch={handleSearch}
        />
      </div>
      <Table
        columns={columnsWithEdit}
        dataSource={filteredAppointments}
        scroll={{ x: 500, y: 300 }}
        rowHoverable
      />
    </div>
  );
}

export default Appointments;
