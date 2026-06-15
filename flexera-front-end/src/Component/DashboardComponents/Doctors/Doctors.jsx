import { useState, useEffect } from "react";
import SearchBar from "../SearchBar/SearchBar";
import { Table, Space, Button, Modal } from 'antd';
import { DoctorsTableColumns } from "./DoctorsTableColumns";
import { PlusOutlined } from "@ant-design/icons";
import { getToken } from "../../../utility";
import axios from "axios";
import AddDoctor from "./AddDoctor/AddDoctor";
import EditDoctor from "./EditDoctor/EditDoctor";
import { DeleteOutlined, EditOutlined } from "@ant-design/icons";
import LoaderComponent from "../LoaderComponent/LoaderComponent";
import "./Doctors.css";

// missing points
// 1) handle custom validation or error msgs BE [add doctor]

function Doctors() {
  const [loading, setLoading] = useState(true);
  const [addDoctorLoading, setAddDoctorLoading] = useState(false);
  const [editDoctorLoading, setEditDoctorLoading] = useState(false);
  const [allDoctors, setAllDoctors] = useState(null);
  const [filteredDoctors, setFilteredDoctors] = useState(null);
  const [showAddDoctorModal, setShowAddDoctorModal] = useState(false);
  const [showEditDoctorModal, setShowEditDoctorModal] = useState(false);
  const [editedDoctor, setEditedDoctor] = useState(null);
  const [isDeleteModalOpen, setIsDeleteModalOpen] = useState(false);
  const [selectDeletedDoctor, setSelectedDeletedDoctor] = useState(null)

  console.log('selectDeletedDoctor>>', selectDeletedDoctor);

  const handleSearch = (searchValue) => {
    if (searchValue.length === 0) {
      setFilteredDoctors(allDoctors)
      return
    }
    setFilteredDoctors(
      allDoctors.filter(
        (doctor) =>
          doctor.name.toLowerCase().trim().includes(searchValue.toLowerCase().trim()) ||
          doctor._id.toLowerCase().trim().includes(searchValue.toLowerCase().trim())
      )
    );
  };

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = () => {
    axios
      .get("https://flexera.vercel.app/api/doctors", {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${getToken()}`,
        },
      })
      .then((response) => {
        setAllDoctors(response.data.doctors);
        setFilteredDoctors(response.data.doctors);
        setLoading(false);
      })
      .catch((error) => {
        console.error(error);
        setLoading(false);
      });
  };

  const handleDeleteDoctor = () => {
    axios
      .delete(`https://flexera.vercel.app/api/admin/doctors/${selectDeletedDoctor?._id}`, {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${getToken()}`,
        },
      })
      .then((response) => {
        console.log("response>>", response);
        fetchData();
        setSelectedDeletedDoctor(null)
        setIsDeleteModalOpen(false)
      })
      .catch((error) => {
        console.log("error>", error);
        setSelectedDeletedDoctor(null);
        setIsDeleteModalOpen(false)
      });
  };

  const handleCancelDelteDoctor = () => {
    setIsDeleteModalOpen(false)
    setSelectedDeletedDoctor(null)
  }

  const columnsWithEdit = DoctorsTableColumns.map((col) => {
    if (col.key === "action") {
      return {
        ...col,
        render: (_, record) => (
          <Space size="middle">
            <EditOutlined
              className="editIcon"
              onClick={() => {
                setEditedDoctor(record);
                setShowEditDoctorModal(true);
              }}
            />
            <DeleteOutlined
              className="deleteIcon"
              size={24}
              onClick={() => {
                setSelectedDeletedDoctor(record)
                setIsDeleteModalOpen(true)
              }}
            />
          </Space>
        ),
      };
    }
    return col;
  });

  const handleCloseModal = () => {
    setShowAddDoctorModal(false);
    setShowEditDoctorModal(false);
  };

  const addDoctor = (values) => {
    console.log("values>>", values);
    setAddDoctorLoading(true);
    const data = new FormData();
    data.append("_id", values._id);
    data.append("name", values.name);
    data.append("email", values.email);
    data.append("phone", values.phone);
    data.append("price", values.price);
    if (values.image && values?.image?.length > 0) {
      data.append("image", values.image[0].originFileObj);
    } else {
      data.append("image", "");
    }

    axios
      .post("https://flexera.vercel.app/api/doctors", data, {
        headers: {
          "Content-Type": "multipart/form-data",
          Authorization: `Bearer ${getToken()}`,
        },
      })
      .then((res) => {
        console.log("resss>", res);
        fetchData();
        setShowAddDoctorModal(false);
        setAddDoctorLoading(false);
      })
      .catch((error) => {
        console.log("err", error);
        setAddDoctorLoading(false);
      });
  };

  const updateDoctor = (values) => {
    setEditDoctorLoading(true);
    const data = new FormData();
    data.append("name", values.name);
    data.append("email", values.email);
    data.append("phone", values.phone);
    data.append("price", values.price);
    if (values.image && values.image.length > 0) {
      data.append("image", values.image[0].originFileObj);
    } else {
      data.append("image", "");
    }

    axios
      .put(
        `https://flexera.vercel.app/api/admin/doctors/${editedDoctor?._id}`,
        data,
        {
          headers: {
            "Content-Type": "multipart/form-data",
            Authorization: `Bearer ${getToken()}`,
          },
        }
      )
      .then((res) => {
        console.log("resss>", res);
        fetchData();

        setShowEditDoctorModal(false);
        setEditDoctorLoading(false);
      })
      .catch((error) => {
        console.log("err", error);
        setEditDoctorLoading(false);
      });
  };

  if (loading) {
    return <LoaderComponent />;
  }

  return (
    <div className="doctors_sectiom">
      <div className="action_container">
        <SearchBar
          placeholderValue="Search for name or id "
          handleSearch={handleSearch}
        />
        <button
          className="addMember"
          onClick={() => {
            setShowAddDoctorModal(true);
          }}
        >
          Add Member <PlusOutlined />
        </button>
      </div>
      <Table
        columns={columnsWithEdit}
        dataSource={filteredDoctors}
        scroll={{ x: 500, y: 300 }}
        rowHoverable
      />
      <AddDoctor
        isOpen={showAddDoctorModal}
        addDoctorLoading={addDoctorLoading}
        handleCloseModal={handleCloseModal}
        submitAction={addDoctor}
      />
      <EditDoctor
        isOpen={showEditDoctorModal}
        editDoctorLoading={editDoctorLoading}
        editedDoctor={editedDoctor}
        submitAction={updateDoctor}
        handleCloseModal={handleCloseModal}
      />
      <Modal
        title="Delete doctor"
        className="delete_doctor_modal"
        closable={false}
        open={isDeleteModalOpen}
        onOk={handleDeleteDoctor}
        onCancel={handleCancelDelteDoctor}
      >
        <p>{`Are you sure you want to delete doctor ${selectDeletedDoctor?.name} ?`}</p>
      </Modal>
    </div>
  );
}

export default Doctors;
