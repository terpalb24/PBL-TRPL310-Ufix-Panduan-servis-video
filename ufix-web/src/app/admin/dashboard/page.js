"use client";

import Cookies from "js-cookie";
import { useRouter } from "next/navigation";
import { useEffect } from "react";

export default function AdminDashboard() {
  const router = useRouter();

  useEffect(() => {
    const token = Cookies.get("token");
    const role = Cookies.get("role");

    if (!token || role !== "admin") {
      router.push("/admin");
    }
  }, []);

  return (
    <div className="flex min-h-screen bg-gray-100">

      {/* MAIN CONTENT */}
      <div className="flex-1 p-6">
        
        {/* HEADER */}
        <div className="flex justify-between items-center mb-6">
          <h1 className="text-2xl font-semibold">Manage Users</h1>
          <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
            Add User
          </button>
        </div>

        {/* CARD */}
        <div className="bg-white rounded-xl shadow p-6">
          
          {/* CARD HEADER */}
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-lg font-semibold">User List</h2>
            <input
              type="text"
              placeholder="Search User"
              className="border rounded-full px-4 py-2 text-sm focus:outline-none"
            />
          </div>

          {/* TABLE */}
          <table className="w-full text-sm">
            <thead className="bg-gray-50 text-left">
              <tr>
                <th className="p-3">No</th>
                <th className="p-3">Profile</th>
                <th className="p-3">Email</th>
                <th className="p-3">Role</th>
                <th className="p-3 text-center">Action</th>
              </tr>
            </thead>

            <tbody>
              {[1,2,3,4,5].map((i) => (
                <tr key={i} className="border-b">
                  <td className="p-3">{i}</td>

                  <td className="p-3 flex items-center gap-3">
                    <img
                      src="https://i.pravatar.cc/40"
                      className="w-8 h-8 rounded-full"
                      alt="avatar"
                    />
                    <span>Nama User</span>
                  </td>

                  <td className="p-3">abcd@email.com</td>
                  <td className="p-3">Admin</td>

                  <td className="p-3 text-center space-x-2">
                    <button className="px-3 py-1 border rounded text-gray-600 hover:bg-gray-100">
                      Edit
                    </button>
                    <button className="px-3 py-1 border rounded text-red-500 hover:bg-red-50">
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          {/* PAGINATION */}
          <div className="flex justify-between items-center mt-4 text-sm text-gray-500">
            <span>Rows per page: 5</span>
            <span>1–3 of 10</span>
          </div>
        </div>
      </div>
    </div>
  );
}
