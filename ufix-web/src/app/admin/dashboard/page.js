"use client";

import { useEffect, useState } from "react";
import Sidebar from "@/components/Sidebar";

export default function AdminDashboard() {
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalTeknisi: 0,
    totalAppUser: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchDashboard();
  }, []);

  const fetchDashboard = async () => {
    try {
      const res = await fetch("http://localhost:3001/api/admin/dashboard");
      if (!res.ok) throw new Error("Gagal mengambil data dashboard");

      const data = await res.json();
      if (!data.success) throw new Error(data.message);

      setStats(data.data);
    } catch (err) {
      console.error("Dashboard error:", err.message);
      alert("Dashboard error: " + err.message);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <p className="p-8">Loading dashboard...</p>;

  return (
    <div className="flex min-h-screen bg-gray-100">
      <Sidebar />
      <main className="flex-1 p-8">
        <h1 className="text-3xl font-bold mb-2">Dashboard</h1>
        <p className="text-gray-500 mb-8">Welcome to UFix Admin Panel</p>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <DashboardCard title="Total Users" value={stats.totalUsers} />
          <DashboardCard title="Technicians" value={stats.totalTeknisi} />
          <DashboardCard title="App Users" value={stats.totalAppUser} />
        </div>
      </main>
    </div>
  );
}

function DashboardCard({ title, value }) {
  return (
    <div className="bg-white p-6 rounded-xl shadow hover:shadow-md transition">
      <p className="text-sm text-gray-500">{title}</p>
      <h2 className="text-3xl font-bold mt-2 text-gray-800">{value}</h2>
    </div>
  );
}
