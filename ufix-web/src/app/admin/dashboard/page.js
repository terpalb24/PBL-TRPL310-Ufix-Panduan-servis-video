"use client";

import Cookies from "js-cookie";
import { useRouter } from "next/navigation";
import { useEffect } from "react";

export default function AdminDashboard() {
  const router = useRouter();

  useEffect(() => {
    const token = Cookies.get("token");
    const role = Cookies.get("role");
    const displayName = Cookies.get("adminName");

    if (!token || role !== "admin") {
      router.push("/admin"); // balik ke login
    }
  }, []);

  return (
    <div style={{ padding: "40px" }}>
      <h1>Dashboard Admin</h1>
      <p>Selamat datang di dashboard admin.</p>
    </div>
  );
}
