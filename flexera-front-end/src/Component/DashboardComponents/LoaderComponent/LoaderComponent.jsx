import { Spin } from "antd";
import "./LoaderComponent.css";

function LoaderComponent({ height }) {
  return (
    <div className="loaderDiv" style={{
      height: height ?? '60vh'
    }}>
      <Spin size="large" />
    </div>
  );
}

export default LoaderComponent;
