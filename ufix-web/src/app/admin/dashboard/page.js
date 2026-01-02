"use client";

import Cookies from "js-cookie";
import { useRouter } from "next/navigation";
import { useEffect } from "react";
import Sidebar from "../../../components/Sidebar";

export default function AdminDashboard() {
  const router = useRouter();

  useEffect(() => {
    const token = Cookies.get("token");
    const role = Cookies.get("role");

    if (!token || !["admin", "superadmin"].includes(role)) {
      router.push("/admin");
    }
  }, []);

  return (
    <div className="flex min-h-screen bg-gray-100">

      {/* SIDEBAR */}
      <Sidebar />

      {/* MAIN */}
      <main className="flex-1 p-8">
        <div className="max-w-7xl mx-auto">

          {/* HEADER */}
          <div className="flex justify-between items-center mb-8">
            <h1 className="text-3xl font-semibold text-gray-800">
              Manage Users
            </h1>

            <button className="bg-blue-600 text-white px-6 py-2 rounded-lg text-sm font-medium hover:bg-blue-700">
              + Add User
            </button>
          </div>

          {/* CARD */}
          <div className="bg-white rounded-2xl shadow-md p-8">

            {/* CARD HEADER */}
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-xl font-semibold text-gray-700">
                User List
              </h2>

              <input
                type="text"
                placeholder="Search user..."
                className="border rounded-lg px-4 py-2 text-sm w-64 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>

            {/* TABLE */}
            <div className="overflow-x-auto">
              <table className="w-full text-sm text-gray-700">
                <thead className="bg-gray-50 text-left text-gray-600">
                  <tr>
                    <th className="p-4">No</th>
                    <th className="p-4">Profile</th>
                    <th className="p-4">Email</th>
                    <th className="p-4">Role</th>
                    <th className="p-4 text-center">Action</th>
                  </tr>
                </thead>

                <tbody>
                  {[1, 2, 3, 4, 5].map((i) => (
                    <tr key={i} className="border-b hover:bg-gray-50">
                      <td className="p-4">{i}</td>

                      <td className="p-4">
                        <div className="flex items-center gap-3">
                          <img
                            src="https://i.pravatar.cc/40"
                            className="w-9 h-9 rounded-full"
                            alt="avatar"
                          />
                          <span className="font-medium">Nama User</span>
                        </div>
                      </td>

                      <td className="p-4">abcd@email.com</td>

                      <td className="p-4">
                        <span className="px-3 py-1 text-xs rounded-full bg-blue-100 text-blue-600">
                          Admin
                        </span>
                      </td>

                      <td className="p-4 text-center space-x-2">
                        <button className="px-4 py-1.5 border rounded-lg text-gray-600 hover:bg-gray-100">
                          Edit
                        </button>
                        <button className="px-4 py-1.5 border rounded-lg text-red-600 hover:bg-red-50">
                          Delete
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* PAGINATION */}
            <div className="flex justify-between items-center mt-6 text-sm text-gray-500">
              <span>Rows per page: 5</span>
              <span>1–5 of 10</span>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
